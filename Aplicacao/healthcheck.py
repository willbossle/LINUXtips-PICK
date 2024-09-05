import requests
from requests.exceptions import RequestException

try:
    response = requests.get('http://localhost:5000/')
    if response.status_code == 200:
        exit(0)
    else:
        exit(1)
except RequestException:
    exit(1)