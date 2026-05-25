from fastapi import FastAPI, UploadFile, Response
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import cv2
import numpy as np

class CalcParams(BaseModel):
    operator: str
    operand1: float
    operand2: float

app = FastAPI()
app.add_middleware(CORSMiddleware,
                   allow_origins=["*"],
                   allow_methods=["*"],
                   allow_headers=["*"],
                   )

@app.get("/")
def read_root():
    return {"hello": "world"}

@app.get("/calc")
def get_calc(a: float = 0, b: float = 0):
    return {"add": a + b, "sub": a - b}

@app.post("/calc")
def post_calc(params: CalcParams):
    op = params.operator
    a1 = params.operand1
    a2 = params.operand2
    if op == 'add':
        ans = a1 + a2
    elif op == 'sub':
        ans = a1 - a2
    elif op == 'mul':
        ans = a1 * a2
    elif op == 'div':
        ans = a1 / a2
    else:
        ans = 0
    
    return {"ans": ans}

@app.post("/improc")
async def improc(image_file: UploadFile,
                 procedure: str):
    data = await image_file.read()
    arr = np.frombuffer(data, np.uint8)
    img = cv2.imdecode(arr, cv2.IMREAD_COLOR)
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    if procedure == 'gray':
        img2 = gray
    elif procedure == 'edge':
        img2 = cv2.Canny(gray, 100, 200)
    elif procedure == 'illust':
        img2 = cv2.stylization(img, sigma_s=60, sigma_r=0.07)
    else:
        img2 = img
    _, enc_img = cv2.imencode(".jpg", img2)
    return Response(content=enc_img.tobytes(),
                    media_type='image/jpeg')
