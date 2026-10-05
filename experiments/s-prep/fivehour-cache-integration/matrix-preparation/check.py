#!/usr/bin/env python3
import pathlib,subprocess,os,signal,json,hashlib,ast
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[3];ART=pathlib.Path(os.environ.get('BENDVY_MATRIX_CHECK_ARTIFACT','/tmp/bendvy-fivehour-matrix-check'));ART.mkdir(exist_ok=False);CPU=os.environ.get('BENDVY_CPU','5');e={'status':'INCOMPLETE','cases':[],'limitSeconds':5,'claim':'source/checker only, no runtime/reference/performance observation'}
guards=ROOT/'experiments/s-prep/owned-write-query/run.py';tree=ast.parse(guards.read_text());exec(compile(ast.Module(body=[n for n in tree.body if isinstance(n,ast.FunctionDef) and n.name=='run'],type_ignores=[]),str(guards),'exec'),globals())
try:
 e['sourceCommit']=run(['git','-C',ROOT,'rev-parse','HEAD']).strip();e['sourceHashes']={}
 for p in [*HERE.glob('*.py'),*HERE.glob('*.bend'),*HERE.parent.glob('*.py'),*HERE.parent.glob('*.bend'),*HERE.parent.glob('candidate-inputs/*.bend'),HERE.parent/'source-inputs.json',guards]:
  assert p.read_bytes()==subprocess.check_output(['git','-C',str(ROOT),'show','HEAD:'+p.relative_to(ROOT).as_posix()],timeout=5);e['sourceHashes'][p.relative_to(ROOT).as_posix()]=hashlib.sha256(p.read_bytes()).hexdigest()
 e['version']=run(['bend','version']);run(['bend','guide'])
 for variant in ['js','native']:
  overlay=ART/variant;run(['python3',HERE/'materialize.py',overlay]+(['--native-payload'] if variant=='native' else []));entry=overlay/'experiments/s-integrate/dense-sparse-semantic.bend';output=run(['taskset','-c',CPU,'bend',entry,'--check-only']);assert 'ALL PROOFS CHECK' in output;e['cases'].append({'variant':variant,'status':'PASS_SOURCE_ONLY','output':output,'materialization':json.loads((overlay/'matrix-semantic-proposal.json').read_text())})
 e['status']='PASS_SOURCE_ONLY'
except Exception as error:e['error']=repr(error);raise
finally:(ART/'matrix-check-evidence.json').write_text(json.dumps(e,indent=2)+'\n')
