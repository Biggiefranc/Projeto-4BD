from fastapi import FastAPI

# Cria a instância da aplicação (igual ao const app = express())
app = FastAPI()

# Define uma rota GET (igual ao app.get('/', ...))
@app.get("/")
def inicio():
    return {"mensagem": "API rodando!"}

# Rota com parâmetro na URL (igual ao /usuarios/:id no Express)
@app.get("/usuarios/{user_id}")
def buscar_usuario(user_id: int):
    return {"id": user_id, "nome": "Robert"}
