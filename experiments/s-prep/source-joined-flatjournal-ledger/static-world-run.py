#!/usr/bin/env python3
"""Finite actual static callback foreign-world controls; no proof/performance claim."""
import argparse,hashlib,importlib.util,json,os,shutil
from pathlib import Path
import provider_controls as PC
ROOT=Path('/workspace/formal-proofs/bendvy');HERE=ROOT/'experiments/s-prep/fivehour-connected-gates'
def load(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
B=load('bounded',ROOT/'experiments/t05/run.py');S=load('slicer',HERE/'materialize-controls.py')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def expected(schema,namespace,foreign):
 field='coordinates' if schema=='motion' else 'levels';main={field:dict(zip('abcd',[10 if foreign else 11,11,12,13]))}
 main.update({'frame':7} if schema=='motion' else {'reserve':9,'class':2})
 aux={'rates':dict(zip('abcd',[110,111,112,113])),'moving':True} if schema=='motion' else {'layers':dict(zip('abcd',[110,111,112,113])),'grade':3}
 flag={'group':8}
 return {'phase':'pre','value':4294967295 if foreign else 46,'selected':{'namespace':3-namespace if foreign else namespace,'id':1},'undo':'L:77;' if foreign else f'L:100;M{namespace}/1:10;L:77;','commands':[{'kind':'RemoveFlagView','id':1},{'kind':'DespawnView','id':2}],'pings':[12,11],'marks':[{'namespace':namespace,'id':1}] if foreign else [{'namespace':namespace,'id':1}]*2,'world':{'namespace':namespace,'next':2,'rows':[{'id':1,'main':main,'aux':aux,'flag':flag,'added':3,'changed':3}],'pending':[{'kind':'RemoveFlagView','id':1}],'ledger':{'totals':dict(zip('abcd',[100 if foreign else 101,101,102,103])),'epoch':4},'mode':'MotionOn' if schema=='motion' else 'HealthOn'}}
def main():
 p=argparse.ArgumentParser();p.add_argument('--overlay',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--cpu',type=int,default=9);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False);os.sched_setaffinity(0,{a.cpu});r={'status':'INCOMPLETE','scope':'Finite actual factory lineage, two live local-id-1 worlds, static SC/HA foreign and same-world callback full fields; no universal refinement or performance acceptance','limitsSeconds':{'checker':int(os.environ.get('BENDVY_CHECKER_SECONDS','5')),'runtime':5,'codegen':30,'clang':120},'backendPolicy':{'Native':{'clang':'-O3','threads':1,'gpu':'off'},'JS':{'runtime':'Node'}},'observationModes':['cached','raw-uncached-affine-owner'],'fixtureSHA256':sha(HERE/'static-world-controls.bend'),'cases':[]}
 try:
  pins=json.loads((a.overlay/'overlay.json').read_text())['sources'];assert all(sha(a.overlay/n)==v for n,v in pins.items());r['sourcePins']=pins;r['overlaySHA256']=sha(a.overlay/'overlay.json');assert PC.static_registration(a.overlay/'experiments/s-integrate')
  expected_rows=[]
  original=PC.definitions((a.overlay/'experiments/s-integrate/measurement-bend.bend').read_text())
  point=PC.definitions((HERE/'tx-controls.bend').read_text())
  r['originalCallbackDefinitionPins']={n:hashlib.sha256(original[n].encode()).hexdigest() for n in PC.CALLBACK_NAMES}
  for observer in ('cached','raw'):
   for client in ('static','original-point'):
    for schema in ('motion','health'):
     folder=a.output/(observer+'-'+client+'-'+schema);folder.mkdir();core=folder/'core';shutil.copytree(a.overlay/'experiments/s-integrate',core);source=core/'static-world-controls.bend';text=(HERE/'static-world-controls.bend').read_text()
     if client=='original-point':
      (core/'gate-original-callbacks.bend').write_text('import Base\nimport ./types.bend as T\n'+''.join(original[n] for n in PC.CALLBACK_NAMES))
      text=text.replace('import ./prototype-static-client.bend as M','import ./gate-original-callbacks.bend as M')
      for lane in ('motion','health'):
       text=text.replace('HA.'+lane+'_row(~M.'+lane+'_body,',lane+'_body(')
      at=text.index('def quad(');text=text[:at]+point['motion_body']+point['health_body']+text[at:]
     if client=='static':
      for lane in ('motion','health'):
       anchor='HA.'+lane+'_row(~M.'+lane+'_body,';assert text.count(anchor)==1;text=text.replace(anchor,'HA.prototype_flatjournal_'+lane+'_row(~M.'+lane+'_body,')
     if observer=='raw':
      for name in ('position','vitals','motion_ledger','health_ledger'):text=text.replace('P.'+name+'_get','P.'+name+'_uncached')
     other='health' if schema=='motion' else 'motion';text=text.replace('    '+other+'_start(True{})\n','').replace('    '+other+'_start(False{})\n','');text,retained,removed=S.reachable_fixture(text,'main');source.write_text(text)
     r.setdefault('fixtureSlices',[]).append({'schema':schema,'observer':observer,'client':client,'SHA256':sha(source),'retained':retained,'removed':removed})
     wanted=[record for foreign in (True,False) for ns in (1,2) for record in ({'command':'MissingEntity'},expected(schema,ns,foreign))]
     if observer=='cached' and client=='static':expected_rows.extend(wanted)
     for program in B.build(source,folder):
      raw=B.execute(program);out=folder/(program.name+'.jsonl');out.write_text(raw+'\n');rows=[json.loads(x) for x in raw.splitlines()]
      assert rows==wanted,{'schema':schema,'observer':observer,'client':client,'actual':rows,'expected':wanted}
      r['cases'].append({'schema':schema,'observer':observer,'client':client,'backend':'JS' if program.suffix=='.js' else 'Native','status':'FULL_FIELDS_PASS','programPath':str(program.resolve()),'outputPath':str(out.resolve()),'programSHA256':sha(program),'outputSHA256':sha(out),'records':len(rows)})
  r['independentExpectations']=expected_rows;assert len(r['cases'])==16;assert all(sha(a.overlay/n)==v for n,v in pins.items());r['status']='FINITE_ACTUAL_STATIC_FOREIGN_WORLD_FIELDS_PASS'
 except Exception as e:r.update(status='FAIL',error=repr(e));raise
 finally:(a.output/'evidence.json').write_text(json.dumps(r,indent=2)+'\n')
if __name__=='__main__':main()
