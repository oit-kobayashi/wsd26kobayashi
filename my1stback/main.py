from fastapi import FastAPI
from pydantic import BaseModel

class CalcParams(BaseModel):
    operator: str
    operand1: float
    operand2: float

app = FastAPI()


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

