import re
import subprocess
from collections import defaultdict
from datetime import datetime

ZABBIX_HOST = "PFSENSE-FOR"
ZABBIX_SERVER = "74.163.81.252"
ZABBIX_KEY = "net.topprotos.pf"
LOG_FILE = "/var/log/filter.log"

log_pattern = re.compile(r"<134>1 (\d{4}-\d{2}-\d{2})T.*?filterlog.*?(tcp|udp|icmp)", re.IGNORECASE)

protocolos = defaultdict(int)

hoje = datetime.now().strftime("%Y-%m-%d")

with open(LOG_FILE, "r") as f:
    for linha in f:
        match = log_pattern.search(linha)
        if match:
            data, protocolo = match.groups()
            if data == hoje:
                protocolos[protocolo.lower()] += 1

for protocolo, count in protocolos.items():
    item_key = f"{ZABBIX_KEY}[{protocolo}]"
    cmd = [
        "zabbix_sender",
        "-z", ZABBIX_SERVER,
        "-s", ZABBIX_HOST,
        "-k", item_key,
        "-o", str(count)
    ]
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    print(f"[{item_key}] = {count}")
    print(result.stdout)
    if result.stderr:
        print("Erro:", result.stderr)
