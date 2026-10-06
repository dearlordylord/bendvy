#!/usr/bin/env python3
"""Pinned archived controls retargeted to the actual private row provider, both schemas."""
import argparse,pathlib,re,json,hashlib,subprocess,signal,time,os,sys,importlib.util
p=argparse.ArgumentParser();p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();a.output.mkdir(exist_ok=False);os.sched_setaffinity(0,{8});ROOT=pathlib.Path('/workspace/formal-proofs/bendvy');BASE=ROOT/'experiments/s-prep/fivehour-connected-gates';sys.path.insert(0,str(BASE));import static_provider_boundary as SPB
core=a.overlay/'experiments/s-integrate';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();r={'status':'INCOMPLETE','scope':'Retargeted exact archived cases on reached row owner; not stock access9 or universal authority','sourcePins':json.loads((a.overlay/'overlay.json').read_text())['sources'],'CPU':8,'checkerDiagnosticSeconds':15,'proofDefaultSeconds':5,'cases':[]}
old='H.Held<S.World<T.MotionSchema,CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,CC.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,CC.Cache<T.Position,T.PositionView>,CC.Cache<T.MotionLedger,T.LedgerView>,S.Handle<T.MotionSchema>,S.Command<CC.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected>>'
new='HA.PrototypeFlatRowOwner<T.Position,T.PositionView,T.MotionLedger,T.LedgerView,T.MotionSchema>'
def save():(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
try:
 for schema in ('motion','health'):
  for name,contract in sorted(SPB.CASES.items()):
   original=ROOT/'docs/research/static-provider-dispatch/controls'/(name+'.bend.txt');assert sha(original)==contract['sourceSHA256'];text=original.read_text();text=text.replace(old,new)
   for lane in ('motion','health'):
    for op in ('get','set','ledger','setledger'):text=re.sub(r'HA\.'+lane+'_'+op+r'\b','HA.prototype_flatrows_'+lane+'_'+op,text)
   text=text.replace('H.Held{world,main,ledger,handle,undo,commands,pings,marks}','HA.PrototypeFlatRowOwner{main_raw,main_cached,ledger_raw,ledger_cached,handle,undo,marks}')
   for callback_lane in ('motion','health'):
    text=text.replace('HA.motion_row(~SC.'+callback_lane+'_body,owner)','HA.prototype_flatjournal_motion_row(~SC.'+callback_lane+'_body,owner)')
   if schema=='health':
    for first,second in [('motion','health'),('Motion','Health'),('Position','Vitals'),('Velocity','Armor'),('Selected','Tracked')]:text=text.replace(first,'__TEMP__').replace(second,first).replace('__TEMP__',second)
   for relative in re.findall(r'^import (\S+)',text,re.M):
    if relative!='Base':assert relative.startswith('../JS/experiments/s-integrate/');text=text.replace('import '+relative+' as ','import '+str(core/pathlib.Path(relative).name)+' as ')
   source=a.output/(schema+'-'+name+'.bend');source.write_text(text);st=time.monotonic();c=subprocess.Popen(['bend',str(source),'--check-only'],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,start_new_session=True);timed=False
   try:out=c.communicate(timeout=15)[0]
   except subprocess.TimeoutExpired:timed=True;os.killpg(c.pid,signal.SIGKILL);out=c.communicate()[0]
   rec={'schema':schema,'name':name,'originalSHA256':sha(original),'adaptedSHA256':sha(source),'exit':c.returncode,'timeout':timed,'limitSeconds':15,'seconds':time.monotonic()-st,'output':out};r['cases'].append(rec);save();assert c.returncode==contract['exit'] and not timed,rec
   if c.returncode==0:assert 'ALL PROOFS CHECK' in out
   else:
    assert 'SOME PROOFS FAIL' in out and '- expected :' in out and '- observed :' in out
    assert 'Location: '+('inspect' if name=='owner-inspection' else 'forbidden' if name=='public-setter-on-abstract-owner' else 'invoke') in out
    main='Position' if schema=='motion' else 'Vitals';ledger='Motion' if schema=='motion' else 'Health'
    if name=='owner-inspection':assert '- expected : a datatype' in out and 'observed : inspect~Owner' in out
    elif name=='public-setter-on-abstract-owner':assert 'expected : HA.PrototypeFlatRowOwner<' in out and 'observed : forbidden~Owner' in out
    elif name=='undeclared-ledger-authority':assert 'T.'+ledger+'LedgerToken' in out and 'T.'+main+'Token' in out and 'T.Access<T.'+main+'View>' in out
    elif name=='write-through-read':assert 'T.Access<T.'+main+'View>' in out and '@_:U32 -> HA.PrototypeFlatRowOwner<' in out
    else:assert 'T.PositionToken' in out and 'T.VitalsToken' in out
    rec['intendedBoundaryChecked']=True;save()
 assert len(r['cases'])==16 and sum(x['exit']==0 for x in r['cases'])==4;r['status']='ACTUAL_FOLD_REGISTRATION_ROW_PROVIDER_FOUR_POSITIVE_TWELVE_NEGATIVES_PASS'
except Exception as e:r.update(status='FAIL',error=repr(e));raise
finally:save()
