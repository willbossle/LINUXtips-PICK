from flask import Flask, render_template, request, jsonify
import redis
import string
import random
import os
from prometheus_client import Counter, generate_latest, start_http_server, Gauge  # Adicionando a importação necessária

app = Flask(__name__)

redis_host = os.environ.get('REDIS_HOST')
redis_port = 6379
redis_password = ""

r = redis.StrictRedis(host=redis_host, port=redis_port, password="", decode_responses=True)

senha_gerada_counter = Counter('senha_gerada', 'Contador de senhas geradas')
senha_curta_nao_segura_counter = Counter('senha_curta_nao_segura_counter', 'Contador de senhas com menos de 12 caracteres ou sem maiúsculas ou sem números ou sem caracteres especiais')
health_status = Gauge('flask_app_health_status', 'Status de saúde da aplicação Flask', labelnames=['status'])


def criar_senha(tamanho, incluir_numeros, incluir_caracteres_especiais):
    caracteres = string.ascii_letters

    if incluir_numeros:
        caracteres += string.digits

    if incluir_caracteres_especiais:
        caracteres += string.punctuation

    senha = ''.join(random.choices(caracteres, k=tamanho))

    return senha

def atualizar_contadores(senha):
    tamanho = len(senha)
    tem_maiusculas = any(c.isupper() for c in senha)
    tem_numeros = any(c.isdigit() for c in senha)
    tem_simbolos = any(c in string.punctuation for c in senha)

    if tamanho < 12:
        if not tem_maiusculas:
            senha_curta_nao_segura_counter.inc()
        if not tem_numeros:
            senha_curta_nao_segura_counter.inc()
        if not tem_simbolos:
            senha_curta_nao_segura_counter.inc()

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        tamanho = int(request.form.get('tamanho', 8))
        incluir_numeros = request.form.get('incluir_numeros') == 'on'
        incluir_caracteres_especiais = request.form.get('incluir_caracteres_especiais') == 'on'
        senha = criar_senha(tamanho, incluir_numeros, incluir_caracteres_especiais)

        r.lpush("senhas", senha)
        senha_gerada_counter.inc()
    senhas = r.lrange("senhas", 0, 9)
    if senhas:
        senhas_geradas = [{"id": index + 1, "senha": senha} for index, senha in enumerate(senhas)]
        return render_template('index.html', senhas_geradas=senhas_geradas, senha=senhas_geradas[0]['senha'] or '' )
    return render_template('index.html')


@app.route('/api/gerar-senha', methods=['POST'])
def gerar_senha_api():
    dados = request.get_json()

    tamanho = int(dados.get('tamanho', 8))
    incluir_numeros = dados.get('incluir_numeros', False)
    incluir_caracteres_especiais = dados.get('incluir_caracteres_especiais', False)

    senha = criar_senha(tamanho, incluir_numeros, incluir_caracteres_especiais)
    r.lpush("senhas", senha)
    senha_gerada_counter.inc()

    return jsonify({"senha": senha})

@app.route('/api/senhas', methods=['GET'])
def listar_senhas():
    senhas = r.lrange("senhas", 0, 9)

    resposta = [{"id": index + 1, "senha": senha} for index, senha in enumerate(senhas)]
    return jsonify(resposta)

@app.route('/metrics')
def metrics():
    # Atualiza o status de saúde
    try:
        r.ping()
        health_status.labels(status='up').set(1)
    except redis.ConnectionError:
        health_status.labels(status='down').set(0)
    return generate_latest()

@app.route('/health', methods=['GET'])
def health_check():
    # Verifica se o Redis está acessível
    try:
        r.ping()
        status = "ok"
    except redis.ConnectionError:
        status = "failed"
    
    # Retorna o status da aplicação em formato JSON
    return jsonify({"status": status}), 200 if status == "ok" else 500


if __name__ == '__main__':
    start_http_server(8000)  # Inicializa o servidor de métricas Prometheus
    app.run(debug=False, host='0.0.0.0', port=5000)