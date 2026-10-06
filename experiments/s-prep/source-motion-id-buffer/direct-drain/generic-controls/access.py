#!/usr/bin/env python3
"""Fresh actual private entry registration/provider controls, not universal authority."""
from pathlib import Path
import argparse,json,hashlib,shutil,subprocess,signal,os,re
H=Path(__file__).resolve().parent;p=argparse.ArgumentParser();p.add_argument('--overlay',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--schema',choices=['Motion','Health'],default='Motion');a=p.parse_args();assert not a.output.exists();a.output.mkdir();sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();m=json.loads((a.overlay/'overlay.json').read_text());pins={str(f.relative_to(a.overlay)):sha(f) for f in (a.overlay/'experiments/s-integrate').glob('*.bend')};assert len(pins)==29 and pins==m['sources'];assert m['cacheSpecialization']==json.loads((a.overlay/'cache-specialization.json').read_text())
root=a.output/'core';root.mkdir();[shutil.copyfile(f,root/f.name) for f in (a.overlay/'experiments/s-integrate').glob('*.bend')]
header='import Base\nimport ./held-adapter.bend as HA\nimport ./storage.bend as S\nimport ./transaction.bend as X\nimport ./query.bend as Q\nimport ./cached-payload.bend as CP\nimport ./types.bend as T\nimport ./cache.bend as CC\n'
W='S.World<T.MotionSchema,CP.PrototypeMotionMainSlot,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>';C='S.Command<CP.PrototypeMotionMainSlot,T.Velocity,T.Selected>';Tx=f'X.PrototypeFlatTx<T.MotionSchema,{W},{C}>'
client='~Owner:Type,~get:Owner -> T.PositionToken -> Owner & T.Access<T.PositionView>,~set:Owner -> T.PositionToken -> U32 -> Owner,~ledger:Owner -> T.MotionLedgerToken -> Owner & Maybe<&2,T.LedgerView>,~setledger:Owner -> T.MotionLedgerToken -> U32 -> Owner,owner:Owner'
register=f'def registered(owner:{Tx}) -> {Tx} & U32:\n  HA.prototype_handoff_flatfold_motion(~body,Q.Required{{}},owner,0)\n'
read='def read_done(~Owner:Type,pair:Owner & T.Access<T.PositionView>) -> Owner & U32:\n  match pair:\n    case (owner,view): (owner,0)\n'
cases={
 'cross-schema-callback':('', '(owner,0)',['SOME PROOFS FAIL','Location: registered','VitalsToken','PositionToken']),
 'declared-write':('', '(set(owner,T.PositionToken{},55),0)',None),
 'declared-read':(read,'read_done(~Owner,get(owner,T.PositionToken{}))',None),
 'undeclared-access':('def other_read_done(~Owner:Type,pair:Owner & T.Access<T.VitalsView>) -> Owner & U32:\n  match pair:\n    case (owner,view): (owner,0)\n','other_read_done(~Owner,HA.prototype_packed_prototype_journalledger_health_get(owner,T.VitalsToken{}))',['expected : HA.PrototypePackedHealthRowOwner','observed : body~Owner','Location: body']),
 'cross-schema':('', '(set(owner,T.VitalsToken{},55),0)',['expected : T.PositionToken','observed : T.VitalsToken','Location: body']),
 'write-through-read':('def read_scope(~Owner:Type,~get:Owner -> T.PositionToken -> Owner & T.Access<T.PositionView>,owner:Owner) -> Owner:\n  HA.prototype_packed_row_set(owner,T.PositionToken{},55)\n','(read_scope(~Owner,~get,owner),0)',['expected : HA.PrototypePackedMotionRowOwner','observed : read_scope~Owner','Location: read_scope']),
 'clone-owner':('def clone_done(~Owner:Type,pair:Owner & Owner) -> Owner & U32:\n  match pair:\n    case (owner,other): (owner,0)\n','clone_done(~Owner,(owner,owner))',['owner (consumed more than once)','Location: body'])}
def role(text):
 if a.schema=='Motion':return text
 text=text.replace('HA.prototype_packed_row_set','HA.__WRITE_PROVIDER__').replace('HA.prototype_packed_prototype_journalledger_health_get','HA.__OTHER_PROVIDER__')
 for left,right in [('Motion','Health'),('Position','Vitals'),('Velocity','Armor'),('Selected','Tracked')]:text=text.replace(left,'__ROLE_TMP__').replace(right,left).replace('__ROLE_TMP__',right)
 return text.replace('prototype_handoff_flatfold_motion','prototype_handoff_flatfold_health').replace('HA.__WRITE_PROVIDER__','HA.prototype_packed_prototype_journalledger_health_set').replace('HA.__OTHER_PROVIDER__','HA.prototype_packed_row_get')
r={'runnerSHA256':sha(Path(__file__)),'status':'INCOMPLETE','schema':a.schema,'scope':'Closed private rank2 callback controls; Batch exposure is not production confinement','source29':pins,'closure':hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest(),'commands':[],'cases':[],'diagnosticCheckerSeconds':15,'defaultProofCheckerSeconds':5}
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
for label,(prefix,expression,anchors) in cases.items():
 result='Owner & U32';case_client=client.replace('Position','Vitals') if label=='cross-schema-callback' else client;body=prefix+f'def body({case_client}) -> {result}:\n  {expression}\n'+register;f=root/(label+'.bend');f.write_text(role(header+body));anchors=None if anchors is None else list(map(role,anchors));cmd=['taskset','-c','6','bend',str(f),'--check-only'];c=subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True)
 try:o,e=c.communicate(timeout=15)
 except subprocess.TimeoutExpired:os.killpg(c.pid,signal.SIGKILL);o,e=c.communicate();r['commands'].append({'argv':cmd,'capSeconds':15,'timeout':True});save();raise
 text=o+e;(a.output/(label+'.txt')).write_text(text);ok=(c.returncode==0 and 'ALL PROOFS CHECK' in text) if anchors is None else (c.returncode!=0 and 'SOME PROOFS FAIL' in text and all(x in text for x in anchors));r['commands'].append({'argv':cmd,'capSeconds':15,'exit':c.returncode,'outputSHA256':sha(a.output/(label+'.txt'))});r['cases'].append({'label':label,'status':'PASS' if ok else 'FAIL','expected':'positive' if anchors is None else 'intended diagnostic','anchors':anchors,'subjectSHA256':sha(f)});save()
r['status']='FRESH_PRIVATE_REGISTERED_PROVIDER_TWO_POSITIVES_FIVE_NEGATIVES_PASS' if all(x['status']=='PASS' for x in r['cases']) else 'FAILED';save();print(r['status']);raise SystemExit(0 if r['status'].endswith('_PASS') else 1)
