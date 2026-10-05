#!/usr/bin/env python3
import pathlib,subprocess,os,signal,json,hashlib,ast
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[2];ART=pathlib.Path(os.environ.get('BENDVY_CACHE_CHECK_ARTIFACT','/tmp/bendvy-fivehour-cache-source-check'));ART.mkdir(exist_ok=False);CPU=os.environ.get('BENDVY_CPU','5');e={'status':'INCOMPLETE','cases':[],'limitSeconds':5}
guards=ROOT/'experiments/s-prep/owned-write-query/run.py';tree=ast.parse(guards.read_text());exec(compile(ast.Module(body=[n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name=='run'],type_ignores=[]),str(guards),'exec'),globals())
try:
 e['sourceCommit']=run(['git','-C',ROOT,'rev-parse','HEAD']).strip();e['sources']={}
 for p in [*HERE.glob('*.py'),*HERE.glob('*.bend'),guards]:
  assert p.read_bytes()==subprocess.check_output(['git','-C',str(ROOT),'show','HEAD:'+p.relative_to(ROOT).as_posix()],timeout=5);e['sources'][p.relative_to(ROOT).as_posix()]=hashlib.sha256(p.read_bytes()).hexdigest()
 e['runnerSHA256']=hashlib.sha256(pathlib.Path(__file__).read_bytes()).hexdigest();e['version']=run(['bend','version']);run(['bend','guide']);overlay=ART/'overlay';run(['python3',HERE/'materialize.py',overlay]);pkg=overlay/'experiments/s-integrate'
 for name in ['measurement-bend.bend','raw-boundaries.bend']:
  output=run(['taskset','-c',CPU,'bend',pkg/name,'--check-only']);assert 'ALL PROOFS CHECK' in output;e['cases'].append({'entry':name,'status':'PASS','output':output})
 e['specialization']=json.loads((overlay/'cache-specialization.json').read_text());e['status']='PASS_SOURCE_ONLY'
except Exception as error:e['error']=repr(error);raise
finally:(ART/'check-evidence.json').write_text(json.dumps(e,indent=2)+'\n')
