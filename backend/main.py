from fastapi import FastAPI
import mysql.connector

app = FastAPI()

@app.get("/")
def inicio():
    return {
        "message": "API rodando"
    }

def conexão():
    return mysql.connector.connect(
        host=os.getenv("DB_HOST"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        database=os.getenv("DB_NAME")
    )