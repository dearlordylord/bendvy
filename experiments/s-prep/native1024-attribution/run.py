#!/usr/bin/env python3
import argparse,json,subprocess,sys
from pathlib import Path
P=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();subprocess.run([sys.executable,P/'verify-inputs.py'],check=True);a.output.mkdir(exist_ok=False)
for item in json.loads((P/'input-pins.json').read_text()):
 for transport in ([False,True] if item['count']==1024 else [True]):
  source=Path(item['build'])/'batch.c';out=a.output/(item['schema'].lower()+'-'+str(item['count'])+('-transport' if transport else '-base'))
  subprocess.run([sys.executable,P/('transport-count.py' if transport else 'count.py'),'--count',str(item['count']),'--source',source,'--reference',item['reference'],'--output',out,'--source-root',item['sourceRoot'],'--schema',item['schema'],'--expected-source-sha256',item['files'][str(source)]],check=True)
  subprocess.run([sys.executable,P/'analyze.py','--source',source,'--sites',out/'sites.json','--output',out/'analysis.json'],check=True)
