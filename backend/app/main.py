from fastapi import FastAPI
app = FastAPI()

#Servidor rodando.
@app.get("/")
def inicio():
    return {"mensagem": "API rodando"}

@app.get("/usuarios/{user_id}")
def buscar_usuario(user_id: int):
    return {"id": user_id, "nome": "Robert"}

def get_db():
    #Função para obter a conexão com o banco de dados.
    connection = mysql.connector.connect(
        host= "localhost",
        user="root",
        password="",
        database=""
    )
    try:
        yield connection #Garante que a conexão esteja pronta para a rota usar.
    finally:
        connection.close() #Garante que ela feche assim que terminar.