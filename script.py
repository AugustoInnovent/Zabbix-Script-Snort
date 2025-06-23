import requests
from collections import Counter
import subprocess
import json
import urllib3

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

UNIFI_CONTROLLER = "https://192.168.41.13:8443"
USERNAME = "admin"
PASSWORD = "Mudar@2018"
SITE = "default"

ZABBIX_SERVER = "127.0.0.1"
ZABBIX_HOST = "UNIFI-CONTROLLER"
ZABBIX_SENDER = "/usr/bin/zabbix_sender"

session = requests.Session()
session.verify = False

resp = session.post(f"{UNIFI_CONTROLLER}/api/login", json={
    "username": USERNAME,
    "password": PASSWORD
})

clients = session.get(f"{UNIFI_CONTROLLER}/api/s/{SITE}/stat/sta").json()["data"]

aps = Counter(client['ap_mac'] for client in clients)

lld_data = {
    "data": [{"{#AP_MAC}": mac} for mac in aps.keys()]
}

subprocess.run([
    ZABBIX_SENDER,
    "-z", ZABBIX_SERVER,
    "-s", ZABBIX_HOST,
    "-k", "unifi.ap.discovery",
    "-o", json.dumps(lld_data)
])

for ap_mac, count in aps.items():
    key = f"unifi.ap.users[{ap_mac}]"
    value = str(count)
    subprocess.run([
        ZABBIX_SENDER,
        "-z", ZABBIX_SERVER,
        "-s", ZABBIX_HOST,
        "-k", key,
        "-o", value
    ])
