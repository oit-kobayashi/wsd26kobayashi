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
    print(op, a1, a2)
    return {"ans": 123.45} # この部分を op, a1, a2 の内容に応じて変える。例: (op, a1, a2)==("add", 12, 34) なら {"ans": 46.0} 

