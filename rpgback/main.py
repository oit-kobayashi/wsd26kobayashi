import os
from sqlmodel import Field, SQLModel, create_engine, Session, select, String
from enum import Enum

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
    r = s.exec(select(Race).where(Race.name == race)).first()
    ch = Character(name=name, race_id=r.id)
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

with Session(engine) as s:
    ch = spawn(s, name="Kobayashi", race="Hobbit")
    print(ch)
    
