import http from 'k6/http';
import { check, sleep } from 'k6';

// Defina a URL base como localhost:5000
const BASE_URL = __ENV.URL_DO_APP || 'https://giropops-senhas.local.com';

export const options = {
    // Configuração dos estágios para atingir 1000 requisições por minuto
    stages: [
        { duration: '1m', target: 1000 }, // Ramp up para 1000 requisições por minuto em 1 minuto
        { duration: '5m', target: 1000 }, // Manter 1000 requisições por minuto por 5 minutos
        { duration: '1m', target: 0 },    // Ramp down para 0 requisições por minuto em 1 minuto
    ],
};

export default function () {
    // Realiza uma requisição GET para a página principal
    let res = http.get(`${BASE_URL}/`);
    check(res, {
        'Página principal deve responder com status 200': (r) => r.status === 200,
    });

    res = http.post(`${BASE_URL}/`, { tamanho: 12, incluir_numeros: 'on', incluir_caracteres_especiais: 'on' });
    check(res, {
        'Criação de senha deve responder com status 200': (r) => r.status === 200,
    });

    res = http.post(`${BASE_URL}/api/gerar-senha`, JSON.stringify({
        tamanho: 12,
        incluir_numeros: true,
        incluir_caracteres_especiais: true,
    }), { headers: { 'Content-Type': 'application/json' } });
    check(res, {
        'API de geração de senha deve responder com status 200': (r) => r.status === 200,
        'Resposta deve conter uma senha': (r) => JSON.parse(r.body).senha !== undefined,
    });

    // Realiza uma requisição GET para listar senhas via API
    res = http.get(`${BASE_URL}/api/senhas`);
    check(res, {
        'API de listagem de senhas deve responder com status 200': (r) => r.status === 200,
    });

    sleep(1);
}
