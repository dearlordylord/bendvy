#!/usr/bin/env python3
"""Isolated pinned-source experiment; every check has a five-second deadline."""
import pathlib,tempfile,subprocess,hashlib,json,difflib,shutil,os
HERE=pathlib.Path(__file__).resolve().parent
ROOT=pathlib.Path('/workspace/formal-proofs/bendvy')
SOURCE=ROOT/'.references/bend2/bend2'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(args,env=None):
 env=dict(os.environ,BENDTT='/home/node/.bend/bendtt/61e0d2d9f4ddd7dd/bendtt',NODE_NO_WARNINGS='1')
 try:
  r=subprocess.run(args,capture_output=True,text=True,timeout=5,env=env)
  return {'exit':r.returncode,'stdout':r.stdout,'stderr':r.stderr}
 except subprocess.TimeoutExpired as e:return {'exit':124,'stdout':str(e.stdout),'stderr':str(e.stderr),'timeout_seconds':5}
result={'source_revision':subprocess.check_output(['git','-C',str(SOURCE.parent),'rev-parse','HEAD'],text=True).strip(),'version':run(['bend','version']),'hashes':{str(p):sha(p) for p in [SOURCE/'bend.ts',pathlib.Path('/home/node/.bend/bendtt/61e0d2d9f4ddd7dd/bendtt'),pathlib.Path('/home/node/.bend/bin/bend'),pathlib.Path('/home/node/.bend/bend2/base.bend'),pathlib.Path('/home/node/.bend/bend2/bendtt.lean')]},'cases':{}}
original=(SOURCE/'bend.ts').read_text()
needle='  if (lhs === rhs) {\n    return true;\n  }'
start=original.index('function compare_go(')
pos=original.index(needle,start)
patched=original[:pos]+original[pos:].replace(needle,needle+'\n  if (book !== RIGID && compare_go(mode, RIGID, lhs, rhs, dep)) {\n    return true;\n  }',1)
(HERE/'recursive-rigid.patch').write_text(''.join(difflib.unified_diff(original.splitlines(True),patched.splitlines(True),fromfile='a/bend2/bend.ts',tofile='b/bend2/bend.ts')))
with tempfile.TemporaryDirectory(prefix='owned-checker-') as d:
 tmp=pathlib.Path(d)
 for name in ['bend.ts','safe.ts','base.bend','bendtt.lean']:shutil.copyfile(SOURCE/name,tmp/name)
 harness=tmp/'check.mjs'
 harness.write_text("import * as B from './bend.ts';import * as S from './safe.ts'; const b=B.book_nil(); await B.book_load(b,process.argv[2],'',new Map());B.book_valid(b);if(b.hols)throw Error('holes');console.log('CHECK PASS');if(process.argv[3]==='kernel'){if(!S.safe_check(b))throw Error('kernel rejection');console.log('KERNEL PASS');}")
 for case in ['found-neutral','found-word','false','affine','schema']:
  file=HERE/(case+'.bend');result['cases'][case]={'installed':run(['bend',str(file),'--check-only'])}
 for mode,code in [('original',original),('patched',patched)]:
  (tmp/'bend.ts').write_text(code)
  for case in result['cases']:
   result['cases'][case][mode]=run(['node','--experimental-transform-types',str(harness),str(HERE/(case+'.bend')),'kernel'])
(HERE/'evidence.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:{m:v['exit'] for m,v in r.items()} for k,r in result['cases'].items()},indent=2))

for case in ['found-neutral','found-word']:
 assert result['cases'][case]['installed']['exit']==1
 assert result['cases'][case]['original']['exit']==1
 assert result['cases'][case]['patched']['exit']==0
 assert 'KERNEL PASS' in result['cases'][case]['patched']['stdout']
for case in ['false','affine','schema']:
 assert all(v['exit']==1 for v in result['cases'][case].values())
print('DIAGNOSTIC GATES PASS; compiler adoption remains unapproved')
