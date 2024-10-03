import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
    // 1000 requisições por minuto corresponde a aproximadamente 17 requisições por segundo
    vus: 17, // Número de usuários virtuais
    duration: '1m', // Duração do teste
    rps: 1000, // Limita a 1000 requisições por minuto
};

export default function () {
    const url = 'https://giropops-senhas.local.com/api/gerar-senha';

    const payload = JSON.stringify({
        tamanho: 12,
        incluir_numeros: true,
        incluir_caracteres_especiais: true,
    });

    const params = {
        headers: {
            'Content-Type': 'application/json',
        },
    };

    let res = http.post(url, payload, params);

    check(res, {
        'is status 200': (r) => r.status === 200,
        'response time < 200ms': (r) => r.timings.duration < 200,
    });

    sleep(0.5); // Pausa de 0.5 segundos entre as requisições
}
