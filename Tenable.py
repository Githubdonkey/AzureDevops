import argparse
import sys
import time
from datetime import datetime, time
#from datetime import datetime

parser = argparse.ArgumentParser(description='Arguments for Tenable ScanID')
parser.add_argument("--access", required=True, help="This is the tenable access key")
parser.add_argument("--secret", required=True, help="This is the tenable access key")
parser.add_argument("--choice", required=True, help="This is the tenable access key")
parser.add_argument("--group", help="This is the tenable access key")

args = parser.parse_args()
TenableAccessKey = args.access
TenableSecretKey = args.secret
Choice = args.choice

now = datetime.now()
current_time = now.strftime("%H:%M:%S")
start = '23:00:00'
end = '23:59:20'
if current_time > start and current_time < end:
    print('in')
    print(current_time)
else:
    print('out')
    print(current_time)

if current_time > '23:00:00' and current_time < '23:00:20':
    print('in')
    print(current_time)
else:
    print('out')
    print(current_time)

#from tenable.io import TenableIO
#tio = TenableIO(TenableAccessKey, TenableSecretKey)

if Choice == "details":
    print("Confirming " , Choice)
    sys.exit(0)
if Choice == "quit":
    print("quit ", Choice)
    sys.exit(0)
if Choice == "error":
    print("error ", Choice)
    sys.exit(1)

NESSUS_GROUPS = "SecurityAssets"

#SystemName = args.choice
#for agent in tio.agents.list(('name', 'match', (SystemName))):
#    print(agent['status'])
#    print(agent['ip'])