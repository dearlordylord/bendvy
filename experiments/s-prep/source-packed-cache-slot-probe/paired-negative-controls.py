#!/usr/bin/env python3
from pathlib import Path
import re,subprocess,json,argparse,hashlib
H=Path(__file__).resolve().parent;p=argparse.ArgumentParser();p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);r={'scope':'Fresh finite packed-paired actual rank2 callback authority/type negatives; no universal proof','subjects':{}}
for lane,typ,other in [('motion','Position','Vitals'),('health','Vitals','Position')]:
 src=(H/('paired-'+lane+'-pairs.bend')).read_text();block=re.search(r'^def client\(.*?(?=\ndef |\Z)',src,re.M|re.S)[0];header=block.split('\n')[0].replace('def client(','def bad(')
 clone='''def clone_sum(~O:Type,result:O & T.Access<T.'''+typ+'''View>) -> U32:
  match result:
    case (_,T.Found{view}): view_sum(view)
    case _: 0
'''
 for name,body in [('clone-owner','(owner,clone_sum(~O,get(owner,T.'+typ+'Token{})))'),('undeclared-access','CP.prototype_slot_'+('position' if lane=='motion' else 'vitals')+'_get(owner)'),('cross-schema','client_observed(~O,get(owner,T.'+other+'Token{}))')]:
  fixture=a.output/(lane+'-'+name+'.bend');fixture.write_text(src.replace(block,clone+header+'\n  '+body+'\n').replace('invoke(~client,owner)','invoke(~bad,owner)'));output=a.output/(lane+'-'+name);cmd=['python3',str(H/'paired-fixture-run.py'),'--output',str(output),'--fixture',str(fixture),'--negative'];x=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True);assert x.returncode==0,x.stdout;r['subjects'][lane+'-'+name]={'status':'INTENDED_TYPE_REJECTION_PASS','fixtureSHA256':hashlib.sha256(fixture.read_bytes()).hexdigest(),'receiptSHA256':hashlib.sha256((output/'evidence.json').read_bytes()).hexdigest()};(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
r['status']='SIX_ACTUAL_RANK2_TYPE_NEGATIVES_PASS';(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
