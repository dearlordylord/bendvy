#!/usr/bin/env python3
from pathlib import Path
import argparse,json,hashlib,subprocess,signal
H=Path(__file__).resolve().parent;p=argparse.ArgumentParser();p.add_argument('--candidate',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','sourceManifestSHA256':sha(a.candidate/'overlay.json'),'closure':json.loads((a.candidate/'overlay.json').read_text())['privateHandoff']['closure'],'diagnosticCheckerSeconds':15,'defaultProofCheckerSeconds':5,'scope':'Executable definition checks only; no ECS proof or --verdict','commands':[]}
for module in ['query','held-adapter','measurement-bend']:
 f=a.candidate/'experiments/s-integrate'/(module+'.bend');argv=['taskset','-c','10','bend',str(f),'--check-only'];c=subprocess.Popen(argv,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True)
 try:o,e=c.communicate(timeout=15)
 except subprocess.TimeoutExpired:os.killpg(c.pid,signal.SIGKILL);o,e=c.communicate();r['commands'].append({'argv':argv,'capSeconds':15,'timeout':True});(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');raise
 for name,text in [('stdout',o),('stderr',e)]:(a.output/(module+'.'+name)).write_text(text)
 r['commands'].append({'argv':argv,'capSeconds':15,'exit':c.returncode,'sourceSHA256':sha(f),'stdoutSHA256':sha(a.output/(module+'.stdout')),'stderrSHA256':sha(a.output/(module+'.stderr'))});assert c.returncode==0 and 'ALL PROOFS CHECK' in o+e
r['status']='FRESH_THREE_EXECUTABLE_MODULE_CHECKS_PASS';(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n');print(r['status'])
