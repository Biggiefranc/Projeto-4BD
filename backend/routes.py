from fastapi import APIRouter
from .schemas import Item, ItemCreate
from .itens import service

router = APIRouter(prefix="/itens", tags=["Itens"])

@router.get("/", response_model=list[Item])
def get_itens():
    return service.listar_todos()

@router.post("/", response_model=Item)
def post_item(item: ItemCreate):
    return service.adicionar_item(item)
