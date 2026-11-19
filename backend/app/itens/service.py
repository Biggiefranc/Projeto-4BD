from .schemas import Item, ItemCreate

banco_itens: list[Item] = []

def listar_todos() -> list[Item]:
    return banco_itens

def adicionar_item(dados: ItemCreate) -> Item:
    novo_id = len(banco_itens) + 1
    novo_item = Item(id=novo_id, **dados.model_dump())
    banco_itens.append(novo_item)
    return novo_item
