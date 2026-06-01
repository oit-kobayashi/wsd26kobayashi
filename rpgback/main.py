import os
import random
from sqlmodel import Field, SQLModel, create_engine, Session, select, String
from enum import Enum
from fastapi import FastAPI
from pydantic import BaseModel
from map import MAP

app = FastAPI()

DB_URL = os.getenv("DATABASE_URL", "postgresql://postgres:password@localhost:5432/mydb")
engine = create_engine(DB_URL)

class RaceName(str, Enum):
    Human = "Human"
    Elf = "Elf"
    Dwarf = "Dwarf"
    Hobbit = "Hobbit"
    HalfOrc = "HalfOrc"
    Gnome = "Gnome"

class Race(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    name: RaceName = Field(unique=True, sa_type=String)
    base_hp: int | None = 10

class Item(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    name: str = Field(unique=True)
    price: int = 0

class Character(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    name: str
    pos_x: int | None
    pos_y: int | None
    gold: int = 0
    race_id: int | None = Field(default=0, foreign_key="race.id")

class Inventory(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    character_id: int | None = Field(default=None,
                                     foreign_key="character.id")
    item_id: int | None = Field(default=None,
                                foreign_key="item.id")


SQLModel.metadata.create_all(engine)

with Session(engine) as s:
    for r in RaceName:
        if not s.exec(select(Race).where(Race.name == r)).first():
            s.add(Race(name=r))
    s.commit()

def spawn(s: Session, name="Alice", race="Human") -> Character:
    while True:
        y = random.randint(0, len(MAP) - 1)
        x = random.randint(0, len(MAP[0]) - 1)
        if MAP[y][x] == " ":
            break
    r = s.exec(select(Race).where(Race.name == race)).first()
    ch = Character(name=name, race_id=r.id, pos_x=x, pos_y=y)
    s.add(ch)
    s.flush()
    sword = s.exec(select(Item).where(Item.name == "short sword")).first()
    potion = s.exec(select(Item).where(Item.name == "healing potion")).first()
    inv1 = Inventory(character_id=ch.id, item_id=sword.id)
    inv2 = Inventory(character_id=ch.id, item_id=potion.id)
    inv3 = Inventory(character_id=ch.id, item_id=potion.id)
    s.add(inv1)
    s.add(inv2)
    s.add(inv3)
    s.commit()
    s.refresh(ch)
    return ch


def get_inventory(s: Session, ch: Character):
    return s.exec(select(Item)
                  .join(Inventory)
                  .where(Item.id == Inventory.item_id)
                  .where(Inventory.character_id == ch.id)).all()


# with Session(engine) as s:
#     ch = spawn(s, name="Kobayashi", race="Hobbit")
#     print(ch)
#     for i in get_inventory(s, ch):
#         print(f'{i.name} (price: {i.price})')

class SpawnParams(BaseModel):
    name: str
    race: str


@app.post("/api")
def api_spawn(params: SpawnParams):
    with Session(engine) as s:
        ch = spawn(s, params.name, params.race)
        return {'id': ch.id}

@app.get("/api/character/{id}")
def app_character(id: int):
    with Session(engine) as s:
        ch = s.get(Character, id)
        inv = [i.name for i in get_inventory(s, ch)]
        race = s.get(Race, ch.race_id)
        return {'id': ch.id,
                'name': ch.name,
                'race': race.name,
                'gold': ch.gold,
                'pos_x': ch.pos_x,
                'pos_y': ch.pos_y,
                'inventory': inv
                }
    

@app.get("/api/localmap/{id}")
def api_localmap(id: int):
    with Session(engine) as s:
        ch = s.get(Character, id)
        local_map = [MAP[y][ch.pos_x - 3:ch.pos_x + 4] for y in range(ch.pos_y - 3, ch.pos_y + 4) ]
        return {"local_map": local_map}


class MoveParam(BaseModel):
    dx: int
    dy: int


@app.post("/api/{id}/move")
def api_move(id: int, params: MoveParam):
    with Session(engine) as s:
        ch = s.get(Character, id)
        x = ch.pos_x + params.dx
        y = ch.pos_y + params.dy
        if MAP[y][x] != "#":
            ch.pos_x = x
            ch.pos_y = y
            s.add(ch)
            s.commit()
        s.refresh(ch)
        return ch
