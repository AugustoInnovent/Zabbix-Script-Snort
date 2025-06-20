import requests
 
UNIFI_CONTROLLER = "https://192.168.41.13:8443"
USERNAME = "admin"
PASSWORD = "Mudar@2018"
SITE = "default"
 
session = requests.Session()
session.verify = False

resp = session.post(f"{UNIFI_CONTROLLER}/api/login", json={
    "username": USERNAME,
    "password": PASSWORD
})

clients = session.get(f"{UNIFI_CONTROLLER}/api/s/{SITE}/stat/sta").json()["data"]

from collections import Counter
aps = Counter(client['ap_mac'] for client in clients)

for ap_mac, count in aps.items():
    print(f"{ap_mac}: {count} usuários")
