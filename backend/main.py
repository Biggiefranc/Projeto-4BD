
import os
import re
import math
import requests
import mysql.connector

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

load_dotenv()

app = FastAPI(title="Buscador de Lojas")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"]
)

CABECALHOS = {
    "User-Agent": "BuscadorDeLojasIFCE/1.0",
    "Accept": "application/json"
}


# =========================
# CONEXÃO COM MYSQL
# =========================

def conectar():
    return mysql.connector.connect(
        host=os.getenv("DB_HOST"),
        port=int(os.getenv("DB_PORT", 3306)),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        database=os.getenv("DB_NAME")
    )


# =========================
# CATEGORIAS
# =========================

@app.get("/categorias")
def categorias():
    db = conectar()
    cursor = db.cursor(dictionary=True)

    try:
        cursor.execute("""
            SELECT c.id, c.nome,
                   s.id AS sub_id,
                   s.nome AS sub_nome
            FROM categorias_loja c
            LEFT JOIN subcategorias s
                ON c.id = s.id_categoria_loja
            ORDER BY c.id, s.id
        """)

        dados = {}

        for r in cursor.fetchall():
            c = dados.setdefault(r["id"], {
                "id": r["id"],
                "nome": r["nome"],
                "subcategorias": []
            })

            if r["sub_id"] is not None:
                c["subcategorias"].append({
                    "id": r["sub_id"],
                    "nome": r["sub_nome"]
                })

        return list(dados.values())

    finally:
        cursor.close()
        db.close()


# =========================
# LOJAS DO MYSQL
# =========================

@app.get("/lojas")
def lojas(
    q: str = "",
    categoria_id: int = None,
    subcategoria_id: int = None
):
    db = conectar()
    cursor = db.cursor(dictionary=True)

    try:
        sql = """
            SELECT DISTINCT l.*
            FROM lojas l
            LEFT JOIN lojas_subcategorias ls
                ON l.id = ls.id_loja
            LEFT JOIN subcategorias s
                ON s.id = ls.id_subcategoria
            WHERE l.nome LIKE %s
        """

        params = [f"%{q}%"]

        if categoria_id:
            sql += " AND s.id_categoria_loja = %s"
            params.append(categoria_id)

        if subcategoria_id:
            sql += " AND s.id = %s"
            params.append(subcategoria_id)

        cursor.execute(sql, params)
        resultado = cursor.fetchall()

        for loja in resultado:
            cursor.execute(
                "SELECT numero FROM telefones WHERE id_loja = %s",
                (loja["id"],)
            )

            loja["telefones"] = [
                t["numero"] for t in cursor.fetchall()
            ]

            cursor.execute("""
                SELECT s.id, s.nome,
                       s.id_categoria_loja AS categoria_id
                FROM lojas_subcategorias ls
                JOIN subcategorias s
                    ON s.id = ls.id_subcategoria
                WHERE ls.id_loja = %s
            """, (loja["id"],))

            loja["subcategorias"] = cursor.fetchall()
            loja["distancia_km"] = None

        return resultado

    finally:
        cursor.close()
        db.close()


# =========================
# CÁLCULO DE DISTÂNCIA
# =========================

def calcular_distancia(lat1, lon1, lat2, lon2):
    raio_terra = 6371

    lat1 = math.radians(lat1)
    lat2 = math.radians(lat2)

    diferenca_lat = math.radians(lat2 - lat1)
    diferenca_lon = math.radians(lon2 - lon1)

    a = (
        math.sin(diferenca_lat / 2) ** 2
        + math.cos(lat1) * math.cos(lat2)
        * math.sin(diferenca_lon / 2) ** 2
    )

    c = 2 * math.atan2(
        math.sqrt(a),
        math.sqrt(1 - a)
    )

    return round(raio_terra * c, 2)


# =========================
# CLASSIFICAÇÃO
# =========================

def classificar_loja(tags):
    tipo = tags.get("shop", "")

    if tipo in [
        "clothes", "shoes", "bag",
        "jewelry", "fashion"
    ]:
        return "Moda"

    if tipo in [
        "furniture", "houseware",
        "interior_decoration"
    ]:
        return "Casa e Decoração"

    if tipo in [
        "electronics", "computer",
        "mobile_phone"
    ]:
        return "Eletrônicos"

    if tipo in [
        "beauty", "cosmetics",
        "hairdresser"
    ]:
        return "Beleza"

    if tipo in [
        "supermarket", "convenience",
        "bakery", "butcher"
    ]:
        return "Alimentos e Bebidas"

    if tipo in [
        "sports", "bicycle", "outdoor"
    ]:
        return "Esporte e Lazer"

    if tags.get("amenity") in [
        "restaurant", "cafe", "fast_food"
    ]:
        return "Alimentos e Bebidas"

    if tags.get("tourism"):
        return "Turismo"

    if tags.get("office") or tags.get("craft"):
        return "Serviços"

    return "Outros"


# =========================
# LOCALIZAÇÃO DO CEP
# =========================

def localizar_cep(cep, dados_cep):

    locais = []

    # PRIMEIRA TENTATIVA: CEP

    try:
        resposta = requests.get(
            "https://nominatim.openstreetmap.org/search",
            params={
                "postalcode": cep,
                "country": "Brasil",
                "format": "jsonv2",
                "limit": 1
            },
            headers=CABECALHOS,
            timeout=15
        )

        resposta.raise_for_status()
        locais = resposta.json()

    except (requests.RequestException, ValueError) as erro:
        print("Falha na busca pelo CEP:", erro)

    # SEGUNDA TENTATIVA: ENDEREÇO

    if not locais:

        endereco = ", ".join(filter(None, [
            dados_cep.get("logradouro"),
            dados_cep.get("bairro"),
            dados_cep.get("localidade"),
            dados_cep.get("uf"),
            "Brasil"
        ]))

        try:
            resposta = requests.get(
                "https://nominatim.openstreetmap.org/search",
                params={
                    "q": endereco,
                    "format": "jsonv2",
                    "limit": 1
                },
                headers=CABECALHOS,
                timeout=15
            )

            resposta.raise_for_status()
            locais = resposta.json()

        except (requests.RequestException, ValueError) as erro:
            print("Falha na busca pelo endereço:", erro)

    if not locais:
        raise HTTPException(
            status_code=404,
            detail="Não encontramos esse endereço no mapa."
        )

    return (
        float(locais[0]["lat"]),
        float(locais[0]["lon"])
    )


# =========================
# CONSULTA AO OPENSTREETMAP
# =========================

def consultar_openstreetmap(consulta):

    servidores = [
        "https://overpass-api.de/api/interpreter",
        "https://overpass.kumi.systems/api/interpreter",
        "https://overpass.private.coffee/api/interpreter"
    ]

    ultimo_erro = None

    for servidor in servidores:

        try:
            print("Consultando servidor:", servidor)

            resposta = requests.post(
                servidor,
                data={"data": consulta},
                headers=CABECALHOS,
                timeout=45
            )

            resposta.raise_for_status()

            dados = resposta.json()

            elementos = dados.get("elements", [])

            print(
                "Estabelecimentos encontrados:",
                len(elementos)
            )

            return elementos

        except (requests.RequestException, ValueError) as erro:

            ultimo_erro = str(erro)

            print(
                "Servidor indisponível:",
                servidor,
                ultimo_erro
            )

    raise HTTPException(
        status_code=503,
        detail=(
            "Os servidores de mapas estão indisponíveis. "
            "Tente novamente mais tarde."
        )
    )


# =========================
# BUSCA POR CEP
# =========================

@app.get("/buscar")
def buscar(
    cep: str,
    raio: int = 5000,
    q: str = "",
    categoria: str = ""
):

    cep = re.sub(r"\D", "", cep)

    if len(cep) != 8:
        raise HTTPException(
            status_code=400,
            detail="CEP inválido. Informe os 8 números."
        )

    if raio < 500 or raio > 20000:
        raise HTTPException(
            status_code=400,
            detail="O raio deve estar entre 500 e 20000 metros."
        )

    # CONSULTA VIA CEP

    try:
        resposta_cep = requests.get(
            f"https://viacep.com.br/ws/{cep}/json/",
            headers=CABECALHOS,
            timeout=10
        )

        resposta_cep.raise_for_status()
        dados_cep = resposta_cep.json()

    except requests.RequestException:
        raise HTTPException(
            status_code=503,
            detail="Não foi possível consultar o serviço de CEP."
        )

    if dados_cep.get("erro"):
        raise HTTPException(
            status_code=404,
            detail="CEP não encontrado."
        )

    # LOCALIZAÇÃO

    latitude, longitude = localizar_cep(
        cep,
        dados_cep
    )

    # CONSULTA OVERPASS

    consulta = f"""
    [out:json][timeout:30];
    (
      nwr(around:{raio},{latitude},{longitude})["shop"];
      nwr(around:{raio},{latitude},{longitude})["amenity"~"restaurant|cafe|fast_food"];
      nwr(around:{raio},{latitude},{longitude})["office"];
      nwr(around:{raio},{latitude},{longitude})["craft"];
      nwr(around:{raio},{latitude},{longitude})["tourism"];
    );
    out center tags;
    """

    elementos = consultar_openstreetmap(consulta)

    resultado = []

    # PROCESSAMENTO DOS ESTABELECIMENTOS

    for elemento in elementos:

        tags = elemento.get("tags", {})
        nome = tags.get("name")

        if not nome:
            continue

        # COORDENADAS

        if "lat" in elemento and "lon" in elemento:
            lat_loja = elemento["lat"]
            lon_loja = elemento["lon"]

        elif "center" in elemento:
            lat_loja = elemento["center"]["lat"]
            lon_loja = elemento["center"]["lon"]

        else:
            continue

        # DISTÂNCIA

        distancia = calcular_distancia(
            latitude,
            longitude,
            lat_loja,
            lon_loja
        )

        # CATEGORIA

        categoria_loja = classificar_loja(tags)

        # FILTRO POR NOME

        if q and q.lower() not in nome.lower():
            continue

        # FILTRO POR CATEGORIA

        if (
            categoria
            and categoria.lower() != categoria_loja.lower()
        ):
            continue

        # TELEFONE

        telefone = (
            tags.get("phone")
            or tags.get("contact:phone")
        )

        telefones = [telefone] if telefone else []

        # RESULTADO

        resultado.append({
            "id": f"osm-{elemento['type']}-{elemento['id']}",
            "osm_id": elemento["id"],
            "origem": "osm",
            "nome": nome,
            "categoria": categoria_loja,
            "rua": tags.get("addr:street", ""),
            "numero": tags.get("addr:housenumber", ""),
            "bairro": tags.get("addr:suburb", ""),
            "cep": tags.get("addr:postcode", ""),
            "cidade": tags.get(
                "addr:city",
                dados_cep.get("localidade", "")
            ),
            "uf": tags.get(
                "addr:state",
                dados_cep.get("uf", "")
            ),
            "lat": lat_loja,
            "lon": lon_loja,
            "site": (
                tags.get("website")
                or tags.get("contact:website", "")
            ),
            "horario": tags.get("opening_hours", ""),
            "telefones": telefones,
            "distancia_km": distancia,
            "subcategorias": []
        })

    # ORDENA PELA DISTÂNCIA

    resultado.sort(
        key=lambda loja: loja["distancia_km"]
    )

    return {
        "cep": cep,
        "localizacao": {
            "latitude": latitude,
            "longitude": longitude,
            "cidade": dados_cep.get("localidade", ""),
            "uf": dados_cep.get("uf", "")
        },
        "total": len(resultado),
        "lojas": resultado[:100]
    }


# =========================
# PRODUTOS DO MYSQL
# =========================

@app.get("/lojas/{loja_id}/produtos")
def produtos(loja_id: int):

    db = conectar()
    cursor = db.cursor(dictionary=True)

    try:
        cursor.execute("""
            SELECT nome, preco
            FROM produtos
            WHERE id_loja = %s
        """, (loja_id,))

        return cursor.fetchall()

    finally:
        cursor.close()
        db.close()
