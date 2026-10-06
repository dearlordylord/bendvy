#!/usr/bin/env python3
"""Original nine intended access boundaries rebound to actual private Slot Host providers."""
from pathlib import Path
import argparse,json,re,shutil,hashlib,subprocess,signal,os
H=Path(__file__).resolve().parent;ROOT=Path('/workspace/formal-proofs/bendvy');sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();p=argparse.ArgumentParser();p.add_argument('--source',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--prepare-only',action='store_true');a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{9});m=json.loads((a.source/'overlay.json').read_text());pins=m['sources'];assert len(pins)==29 and all(sha(a.source/n)==h for n,h in pins.items());cache=json.loads((a.source/'cache-specialization.json').read_text());digest=hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest();assert cache==m['cacheSpecialization'] and all(cache[k]==pins and cache[k+'SHA256']==digest for k in ['runtimeClosure','specializedClosure']);old=(ROOT/'experiments/s-integrate/integrated-access-positive.bend').read_text();assert old.encode()==subprocess.check_output(['git','-C',str(ROOT),'show','8250177:experiments/s-integrate/integrated-access-positive.bend']);text=old.replace('import Base\n','import Base\nimport ./cache.bend as CC\nimport ./cached-payload.bend as CP\n',1)
for kind,typ in [('Position','CP.PrototypeMotionMainSlot'),('Vitals','CP.PrototypeHealthMainSlot'),('MotionLedger','CC.Cache<T.MotionLedger,T.LedgerView>'),('HealthLedger','CC.Cache<T.HealthLedger,T.LedgerView>')]:text=re.sub(r'T\.'+kind+r'\b',typ,text)
for lane,stem in [('motion','position'),('health','vitals')]:
 for op in ['get','swap']:text=text.replace('P.'+stem+'_'+op,'CP.prototype_slot_'+stem+'_'+op)
 for suffix in ['a','b']:text=text.replace('V.'+lane+'_'+suffix+'(','V.prototype_slot_host_'+lane+'_'+suffix+'(')
 # Frozen source already requires named saturated templates; do not change abstract Owner kind or ownership.
 text=text.replace('def '+lane+'_read(-Owner:Type,-Aux:Type,get:','def '+lane+'_read(~Owner:Type,~Aux:Type,~get:').replace('aux_get:Aux -> Aux & Maybe<&2,T.'+('VelocityView' if lane=='motion' else 'ArmorView')+'>','~aux_get:Aux -> Aux & Maybe<&2,T.'+('VelocityView' if lane=='motion' else 'ArmorView')+'>')
 text=text.replace('Owner,Aux,get,aux_get,handle,flag,owner,aux)','~Owner,~Aux,~get,~aux_get,handle,flag,owner,aux)')
 # All fixed type/getter/client query arguments are already the public frozen template telescope.
 text=text.replace(','+lane+'_read,Q.Required{}',',~'+lane+'_read,Q.Required{}')
labels=['positive','undeclared_token','cross_schema','write_through_read','reconstruct_owner','invalid_owner_return','audit_copy_text_historical','audit_copy','irrecoverable_destructure'];r={'status':'INCOMPLETE','scope':'Fresh nine original scoped static access subjects, actual private Slot A/B and generic named read client; no universal authority','sourcePins':pins,'sourceClosureSHA256':digest,'originalFixtureSHA256':hashlib.sha256(old.encode()).hexdigest(),'positiveAdaptedSHA256':hashlib.sha256(text.encode()).hexdigest(),'localTemplateAdaptation':'Owner/Aux/get/aux_get freeze markers and saturated query client required by frozen source; kind Type and owner/result telescope unchanged','cases':[]}
def block(s,name):return re.search(r'^def '+re.escape(name)+r'\(.*?(?=\ndef |\ntype |\Z)',s,re.M|re.S)[0]
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
for label in labels:
 folder=a.output/label;folder.mkdir();core=folder/'core';shutil.copytree(a.source/'experiments/s-integrate',core);fixture=core/'integrated-access-positive.bend';s=text;file=fixture;location='motion_read';patterns=[]
 if label in ['undeclared_token','cross_schema']:
  file=core/'systems.bend';s=file.read_text();name='prototype_slot_host_motion_a';b=block(s,name);assert b.count('T.PositionToken{},11')==1;token='T.VelocityToken{}' if label=='undeclared_token' else 'T.VitalsToken{}';s=s.replace(b,b.replace('T.PositionToken{},11',token+',11'),1);location=name;patterns=['expected : T.PositionToken',token]
 elif label in ['audit_copy','audit_copy_text_historical']:
  file=core/'audited-invoker.bend';s=file.read_text();b=block(s,'log');assert b.count('D.audit_log(audit,text)')==1;new=b.replace('D.audit_log(audit,text)','IO.bind(D.Audit,D.Audit,D.audit_log(audit,text), _ => D.audit_log(audit,text))')
  if label=='audit_copy':assert 'text:String' in new;new=new.replace('text:String','+text:String',1)
  s=s.replace(b,new,1);location='log';who='audit' if label=='audit_copy' else 'text';patterns=['expected : '+who,'observed : '+who+' (consumed more than once)']
 elif label!='positive':
  b=block(s,'motion_read');body=b.splitlines()[-1];newbody=body
  if label=='write_through_read':newbody=body.replace(',owner,aux)',',CP.prototype_slot_position_swap(owner,30),aux)');patterns=['expected : CP.PrototypeMotionMainSlot','observed : Owner']
  elif label=='reconstruct_owner':newbody=body.replace(',owner,aux)',',CP.prototype_slot_position_new(T.Position{[30:U32^2n],7}),aux)');patterns=['expected : Owner','observed : CP.PrototypeMotionMainSlot']
  elif label=='invalid_owner_return':newbody=body.replace(',owner,aux)',',aux,owner)');patterns=['expected : Owner','observed : Aux']
  elif label=='irrecoverable_destructure':newbody='  match owner:\n    case T.Position{values,frame}: (T.Position{[30:U32^2n],frame},(aux,O.QueryRow{handle,T.PositionView{T.Four{30,30,30,30},frame},None{},flag}))';patterns=['expected : a datatype','observed : Owner','T.Position{']
  assert newbody!=body;s=s.replace(b,b.replace(body,newbody),1)
 fixture.write_text(text)
 if label!='positive':file.write_text(s)
 case={'label':label,'status':'PREPARED','entrySHA256':sha(fixture),'target':file.name,'targetSHA256':sha(file),'intendedLocation':location,'intendedPatterns':patterns,'classification':'historical String quantity witness' if label=='audit_copy_text_historical' else 'intended affine Audit ownership witness' if label=='audit_copy' else 'original scoped provider boundary'};r['cases'].append(case);save()
 if a.prepare_only:continue
 cmd=['bend',str(fixture),'--check-only'];pr=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True)
 try:o,_=pr.communicate(timeout=15)
 except subprocess.TimeoutExpired:os.killpg(pr.pid,signal.SIGKILL);o,_=pr.communicate();case.update(status='TIMEOUT');(folder/'checker.txt').write_text(o);save();raise
 (folder/'checker.txt').write_text(o);case.update(checkerExit=pr.returncode,outputSHA256=hashlib.sha256(o.encode()).hexdigest(),command=cmd,limitSeconds=15)
 if label=='positive':assert pr.returncode==0 and 'ALL PROOFS CHECK' in o,o
 else:
  assert pr.returncode==1 and 'SOME PROOFS FAIL' in o and 'Location: '+location in o,o
  for pat in patterns:assert pat in o,(label,pat,o)
 case['status']='INTENDED_CHECKER_BOUNDARY_PASS';save()
r['status']='PREPARED_NOT_EXECUTED' if a.prepare_only else 'FRESH_NINE_SLOT_HOST_SCOPED_ACCESS_BOUNDARIES_PASS';save()
