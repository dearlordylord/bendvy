#!/usr/bin/env python3
import argparse,json,subprocess,sys
from pathlib import Path
V=Path(__file__).resolve().parent;P=V.parent
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args()
subprocess.run([sys.executable,V/'verify-inputs.py'],check=True);a.output.mkdir(exist_ok=False)
for item in json.loads((V/'input-pins.json').read_text()):
 source=Path(item['build'])/'batch.c';out=a.output/item['schema'].lower()
 subprocess.run([sys.executable,P/'count.py','--source',source,'--reference',item['reference'],'--output',out,'--source-root',item['sourceRoot'],'--schema',item['schema'],'--expected-source-sha256',item['files'][str(source)]],check=True)
 subprocess.run([sys.executable,P/'analyze.py','--source',source,'--sites',out/'sites.json','--output',out/'analysis.json'],check=True)
