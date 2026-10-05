#!/usr/bin/env python3
"""One finite full-field Dense construction per schema/backend; not timing research."""
import argparse,hashlib,importlib.util,json,os
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sp=importlib.util.spec_from_file_location('frozen_measure',ROOT/'experiments/s-perf/measure-run.py');M=importlib.util.module_from_spec(sp);sp.loader.exec_module(M)
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--overlay',required=True,type=Path);p.add_argument('--build-dir',required=True,type=Path);p.add_argument('--cpu',type=int,default=8);a=p.parse_args();os.sched_setaffinity(0,{a.cpu});a.build_dir.mkdir(parents=True,exist_ok=False)
 manifest=json.loads((a.overlay/'overlay.json').read_text());result={'status':'INCOMPLETE','acceptedBenchmarkCandidate':False,'scope':'Finite construction only; no comparative timing/qualification/keep','count':64,'authoredTicksPerWorld':64,'batch':1,'repetitions':0,'toolchainVersion':M.D.B.command(['bend','version']).strip(),'cpuAffinity':[a.cpu],'overlayManifestSHA256':h(a.overlay/'overlay.json'),'integrationPrepareSHA256':h(a.overlay/'integration-prepare.json'),'limitsSeconds':{'checker':5,'runtime':5,'codegen':30,'clang':120},'cases':[]}
 try:
  assert all(h(a.overlay/n)==v for n,v in manifest['sources'].items())
  programs=M.D.B.build(a.overlay/'experiments/s-integrate/measurement-samples-bend.bend',a.build_dir)
  result['artifacts']={prog.name:h(prog) for prog in programs};result['validatorSHA256']=h(Path(M.D.B.__file__))
  for sn,schema in enumerate(('Motion','Health')):
   refcommand=['node',ROOT/'experiments/s-integrate/measurement-reference.mjs',schema,'dense','64'];raw=M.D.B.command(refcommand);ref=json.loads(raw);refpath=a.build_dir/(schema+'-reference.json');refpath.write_text(raw)
   case={'schema':schema,'workload':'dense','referenceCommand':list(map(str,refcommand)),'referenceSHA256':h(refpath),'backends':[]};result['cases'].append(case)
   for backend,program in zip(('Native','JS'),programs):
    command=[program,'--threads','1','--gpu','off',str(sn),'0','64','1'] if backend=='Native' else ['node',program,str(sn),'0','64','1']
    text=M.D.B.command(command);out=a.build_dir/(schema+'-'+backend+'.txt');out.write_text(text)
    # Full-field oracle remains byte-identical; no duration or ratio is selected.
    checked=M.D.checked(backend,text,schema,False,64,1,ref)
    case['backends'].append({'backend':backend,'status':'FULL_FIELD_PASS','command':list(map(str,command)),'outputSHA256':h(out),'finalSha256':checked['finalSha256'],'worksumPerWorld':checked['worksumPerWorld'],'freshMeasuredWorlds':checked['freshMeasuredWorlds']})
  assert all(h(a.overlay/n)==v for n,v in manifest['sources'].items())
  result['status']='FINITE_DENSE_CONSTRUCTION_FULL_FIELDS_PASS'
 except Exception as e:result.update(status='FAIL',error=str(e))
 (a.build_dir/'evidence.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2));return int(result['status']=='FAIL')
if __name__=='__main__':raise SystemExit(main())
