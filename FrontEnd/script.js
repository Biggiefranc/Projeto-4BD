const API_URL = "http://127.0.0.1:8000";

const categorias = [
  "Todas",
  "Moda",
  "Casa e Decoração",
  "Eletrônicos",
  "Beleza",
  "Alimentos e Bebidas",
  "Esporte e Lazer",
  "Turismo",
  "Serviços",
  "Outros",
];

let categoriaAtiva = "Todas";

// ELEMENTOS DA TELA

const form = document.getElementById("formBusca");
const campoBusca = document.getElementById("q");
const campoCep = document.getElementById("cep");
const resultado = document.getElementById("resultado");
const filtros = document.getElementById("categorias");
const totalResultados = document.getElementById("totalResultados");
const tituloResultados = document.getElementById("tituloResultados");
const subtituloResultados = document.getElementById("subtituloResultados");
const btnBuscar = document.getElementById("btnBuscar");

// FUNÇÃO PARA PROTEGER O HTML

function esc(valor) {
  return String(valor || "").replace(
    /[&<>"']/g,
    (caractere) =>
      ({
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        '"': "&quot;",
        "'": "&#39;",
      })[caractere],
  );
}

// FORMATAR CEP

campoCep.addEventListener("input", () => {
  let cep = campoCep.value.replace(/\D/g, "").slice(0, 8);

  if (cep.length > 5) {
    cep = cep.slice(0, 5) + "-" + cep.slice(5);
  }

  campoCep.value = cep;
});

// CRIAR FILTROS

function renderizarCategorias() {
  filtros.innerHTML = "";

  categorias.forEach((nome) => {
    const botao = document.createElement("button");

    botao.type = "button";
    botao.className = "chip" + (nome === categoriaAtiva ? " ativa" : "");

    botao.textContent = nome;

    botao.addEventListener("click", () => {
      categoriaAtiva = nome;
      renderizarCategorias();

      const cep = campoCep.value.replace(/\D/g, "");

      if (cep.length === 8) {
        buscarLojas();
      }
    });

    filtros.appendChild(botao);
  });
}

// MONTAR ENDEREÇO

function montarEndereco(loja) {
  return [
    loja.rua,
    loja.numero,
    loja.bairro,
    [loja.cidade, loja.uf].filter(Boolean).join(" - "),
  ]
    .filter(Boolean)
    .join(", ");
}

// CRIAR CARD DA LOJA

function criarCard(loja) {
  const endereco = montarEndereco(loja);

  const telefone = (loja.telefones || [])
    .map((numero) => {
      const numeroLink = numero.replace(/[^\d+]/g, "");

      return `
                <a href="tel:${esc(numeroLink)}">
                    ${esc(numero)}
                </a>
            `;
    })
    .join("");

  const siteValido = loja.site && /^https?:\/\//i.test(loja.site);

  const site = siteValido
    ? `
            <a href="${esc(loja.site)}"
               target="_blank"
               rel="noopener noreferrer">
               Acessar site
            </a>
          `
    : "";

  const mapa = `
        <a href="https://www.openstreetmap.org/?mlat=${encodeURIComponent(loja.lat)}&mlon=${encodeURIComponent(loja.lon)}#map=18/${encodeURIComponent(loja.lat)}/${encodeURIComponent(loja.lon)}"
           target="_blank"
           rel="noopener noreferrer">
           Ver no mapa
        </a>
    `;

  const distancia = Number(loja.distancia_km);

  return `
        <article class="loja">

            <div class="loja-topo">
                <h3>${esc(loja.nome)}</h3>

                <span class="distancia">
                    ${
                      Number.isFinite(distancia)
                        ? distancia.toFixed(2) + " km"
                        : ""
                    }
                </span>
            </div>

            ${
              endereco
                ? `<p class="info">${esc(endereco)}</p>`
                : `<p class="info">Endereço não informado no mapa.</p>`
            }

            ${
              loja.horario
                ? `<p class="info">Horário: ${esc(loja.horario)}</p>`
                : ""
            }

            ${
              loja.descricao ? `<p class="info">${esc(loja.descricao)}</p>` : ""
            }

            <div class="tags">
                <span class="tag">${esc(loja.categoria)}</span>
            </div>

            <div class="acoes">
                ${telefone}
                ${site}
                ${mapa}
            </div>

            <p class="origem">
                Fonte: OpenStreetMap
            </p>

        </article>
    `;
}

// MOSTRAR MENSAGEM

function mostrarMensagem(titulo, mensagem, erro = false) {
  resultado.innerHTML = `
        <div class="${erro ? "estado-erro" : "estado-vazio"}">
            <h3>${esc(titulo)}</h3>
            <p>${esc(mensagem)}</p>
        </div>
    `;
}

// BUSCAR ESTABELECIMENTOS REAIS

async function buscarLojas() {
  const cep = campoCep.value.replace(/\D/g, "");
  const q = campoBusca.value.trim();

  if (cep.length !== 8) {
    mostrarMensagem("CEP inválido", "Informe os 8 números do seu CEP.", true);

    return;
  }

  const parametros = new URLSearchParams();

  parametros.set("cep", cep);
  parametros.set("raio", "5000");

  if (q) {
    parametros.set("q", q);
  }

  if (categoriaAtiva !== "Todas") {
    parametros.set("categoria", categoriaAtiva);
  }

  btnBuscar.disabled = true;
  btnBuscar.textContent = "Buscando...";

  totalResultados.textContent = "";

  resultado.innerHTML = `
        <div class="carregando">
            <p>Procurando estabelecimentos próximos...</p>
        </div>
    `;

  try {
    const resposta = await fetch(`${API_URL}/buscar?${parametros.toString()}`);

    const dados = await resposta.json();

    if (!resposta.ok) {
      throw new Error(dados.detail || "Não foi possível realizar a busca.");
    }

    const lojas = dados.lojas || [];

    totalResultados.textContent = `${dados.total} encontrados`;

    tituloResultados.textContent = "Estabelecimentos próximos";

    subtituloResultados.textContent = `Resultados para ${dados.localizacao.cidade} - ${dados.localizacao.uf}`;

    if (lojas.length === 0) {
      mostrarMensagem(
        "Nenhum estabelecimento encontrado",
        "Tente outra categoria ou aumente o raio de busca.",
      );

      return;
    }

    resultado.innerHTML = lojas.map(criarCard).join("");
  } catch (erro) {
    mostrarMensagem("Não foi possível buscar", erro.message, true);
  } finally {
    btnBuscar.disabled = false;
    btnBuscar.textContent = "Buscar";
  }
}

// ENVIAR FORMULÁRIO

form.addEventListener("submit", (evento) => {
  evento.preventDefault();
  buscarLojas();
});

// INICIAR

renderizarCategorias();
