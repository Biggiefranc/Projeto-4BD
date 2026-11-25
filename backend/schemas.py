from pydantic import BaseModel

class ItemCreate(BaseModel):
    nome: str
    quantidade: int

class Item(ItemCreate):
    id: int
