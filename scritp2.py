import requests
import json
import subprocess
from collections import Counter

UNIFI_CONTROLLER = "https://192.168.41.13:8443"
USERNAME = "admin"
PASSWORD = "Mudar@2018"
SITE = "default"
ZABBIX_HOST = "Ap do conjunto 84"
ZABBIX_SERVER = "127.0.0.1"

session = requests.Session()
session.verify = False

# Autenticação
resp = session.post(f"{UNIFI_CONTROLLER}/api/login", json={
    "username": USERNAME,
    "password": PASSWORD
})
resp.raise_for_status()

# Obtem clientes conectados
clients = session.get(f"{UNIFI_CONTROLLER}/api/s/{SITE}/stat/sta").json()["data"]

# Conta por AP
aps = Counter(client['ap_mac'] for client in clients)

# Envia dados
for ap_mac, count in aps.items():
    subprocess.run([
        "/usr/bin/zabbix_sender",
        "-z", ZABBIX_SERVER,
        "-s", ZABBIX_HOST,
        "-k", f"unifi.ap.users[{ap_mac}]",
        "-o", str(count)
    ])
