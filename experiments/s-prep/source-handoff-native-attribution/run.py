#!/usr/bin/env python3
"""Replay four serial copied-C diagnostics; source/build/algorithm remain frozen."""
import argparse,json,subprocess,sys
from pathlib import Path
P=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args()
subprocess.run([sys.executable,P/'verify-inputs.py'],check=True)
a.output.mkdir(exist_ok=False)
for item in json.loads((P/'input-pins.json').read_text()):
 build=Path(item['build']);out=a.output/(item['schema'].lower()+'-'+item['role']);source=build/'batch.c'
 subprocess.run([sys.executable,P/'count.py','--source',source,'--reference',item['reference'],'--output',out,'--source-root',item['sourceRoot'],'--schema',item['schema'],'--expected-source-sha256',item['files'][str(source)]],check=True)
 subprocess.run([sys.executable,P/'analyze.py','--source',source,'--sites',out/'sites.json','--output',out/'analysis.json'],check=True)
