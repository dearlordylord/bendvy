#!/usr/bin/env python3
"""Isolated pinned-source experiment; every check has a five-second deadline."""
import pathlib,tempfile,subprocess,hashlib,json,difflib,shutil,os,signal,sys
HERE=pathlib.Path(__file__).resolve().parent
ROOT=pathlib.Path('/workspace/formal-proofs/bendvy')
SOURCE=ROOT/'.references/bend2/bend2'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(args,env=None):
 child_env=dict(os.environ,BENDTT='/home/node/.bend/bendtt/61e0d2d9f4ddd7dd/bendtt',NODE_NO_WARNINGS='1')
 if env: child_env.update(env)
 proc=subprocess.Popen(args,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,env=child_env,start_new_session=True)
 try:
  out,err=proc.communicate(timeout=5)
  return {'exit':proc.returncode,'stdout':out,'stderr':err}
 except subprocess.TimeoutExpired:
  os.killpg(proc.pid,signal.SIGKILL)
  out,err=proc.communicate()
  return {'exit':124,'stdout':out,'stderr':err,'timeout_seconds':5,'cleanup':'owned process group SIGKILL'}
manifest=json.loads((HERE/'pins.json').read_text())
for path,digest in manifest['files'].items():
 p=HERE/path if not path.startswith('/') else pathlib.Path(path)
 assert sha(p)==digest, 'frozen hash mismatch: '+path
assert subprocess.check_output(['git','-C',str(SOURCE.parent),'rev-parse','HEAD'],text=True).strip()==manifest['source_revision']
result={'source_revision':subprocess.check_output(['git','-C',str(SOURCE.parent),'rev-parse','HEAD'],text=True).strip(),'version':run(['bend','version']),'hashes':{str(p):sha(p) for p in [SOURCE/'bend.ts',pathlib.Path('/home/node/.bend/bendtt/61e0d2d9f4ddd7dd/bendtt'),pathlib.Path('/home/node/.bend/bin/bend'),pathlib.Path('/home/node/.bend/bend2/base.bend'),pathlib.Path('/home/node/.bend/bend2/bendtt.lean')]},'cases':{}}
result['fixture_hashes']={p.name:sha(p) for p in sorted(HERE.glob('*.bend'))}
result['runner_hash']=sha(pathlib.Path(__file__).resolve())
original=(SOURCE/'bend.ts').read_text()
needle='  if (lhs === rhs) {\n    return true;\n  }'
start=original.index('function compare_go(')
pos=original.index(needle,start)
patched=original[:pos]+original[pos:].replace(needle,needle+'\n  if (book !== RIGID && compare_go(mode, RIGID, lhs, rhs, dep)) {\n    return true;\n  }',1)
assert (HERE/'recursive-rigid.patch').read_text()==''.join(difflib.unified_diff(original.splitlines(True),patched.splitlines(True),fromfile='a/bend2/bend.ts',tofile='b/bend2/bend.ts'))
with tempfile.TemporaryDirectory(prefix='owned-checker-') as d:
 tmp=pathlib.Path(d)
 for name in ['bend.ts','safe.ts','base.bend','bendtt.lean']:shutil.copyfile(SOURCE/name,tmp/name)
 harness=tmp/'check.mjs'
 harness.write_text("import * as B from './bend.ts';import * as S from './safe.ts';try{const b=B.book_nil(); await B.book_load(b,process.argv[2],'',new Map());B.book_valid(b);if(b.hols)throw Error('holes');if(Object.values(b.tlds).some(t=>t.b!==true && (t.u===true || t.i!==undefined)))throw Error('unsafe rejected');console.log('CHECK PASS');if(!S.safe_check(b))throw Error('kernel rejection');console.log('KERNEL PASS');}catch(e){console.error(e?.bok ? B.err_show(e) : String(e)+'\\n'+(e.stack??''));process.exitCode=1;}")
 if len(sys.argv)>1:
  (tmp/'bend.ts').write_text(patched)
  override={'BENDTT':'/usr/bin/false'} if '--reject-kernel' in sys.argv[2:] else None
  outcome=run(['node','--experimental-transform-types',str(harness),str(pathlib.Path(sys.argv[1]).resolve())],override)
  if override: outcome['controlled_kernel_override']='/usr/bin/false'
  print(json.dumps(outcome,indent=2));sys.exit(outcome['exit'])
 for case in ['found-neutral','found-word','false','affine','schema','hole','unsafe']:
  file=HERE/(case+'.bend');result['cases'][case]={'installed':run(['bend',str(file),'--verdict' if case=='unsafe' else '--check-only'])}
 shutil.copyfile(HERE/'comparator.mjs',tmp/'comparator.mjs')
 result['comparison_modes']={}
 for mode,code in [('original',original),('patched',patched)]:
  (tmp/'bend.ts').write_text(code)
  result['comparison_modes'][mode]=run(['node','--experimental-transform-types',str(tmp/'comparator.mjs')])
  for case in result['cases']:
   result['cases'][case][mode]=run(['node','--experimental-transform-types',str(harness),str(HERE/(case+'.bend')),'kernel'])
  if mode=='patched':
   result['forced_false_kernel']={'override':'/usr/bin/false','result':run(['node','--experimental-transform-types',str(harness),str(HERE/'found-neutral.bend')],{'BENDTT':'/usr/bin/false'})}
(HERE/'evidence.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:{m:v['exit'] for m,v in r.items()} for k,r in result['cases'].items()},indent=2))

for case in ['found-neutral','found-word']:
 assert result['cases'][case]['installed']['exit']==1
 assert result['cases'][case]['original']['exit']==1
 assert result['cases'][case]['patched']['exit']==0
 assert 'KERNEL PASS' in result['cases'][case]['patched']['stdout']
for case in ['false','affine','schema','hole','unsafe']:
 assert all(v['exit']==1 for v in result['cases'][case].values())


for case in ['found-neutral','found-word']:
 for mode in ['installed','original']:
  err=result['cases'][case][mode]['stderr']
  assert 'stack' in err and ('overflow' in err or 'Maximum call stack' in err), (case,mode,err)
for case,needle in [('false','expected'),('affine','consumed more than once'),('schema','Right'),('hole','TODO'),('unsafe','unsafe')]:
 for mode,r in result['cases'][case].items():
  assert needle in r['stderr'] or (case=='hole' and 'holes' in r['stderr']), (case,mode,r)
r=result['forced_false_kernel']['result']
assert r['exit']==1 and 'CHECK PASS' in r['stdout'] and 'kernel rejection' in r['stderr']

assert all(r['exit']==0 for r in result['comparison_modes'].values())


for mode,r in result['cases']['false'].items():
 assert 'True{}' in r['stderr'] and 'False{}' in r['stderr'] and 'false_equality' in r['stderr']
for mode,r in result['cases']['schema'].items():
 assert 'Left' in r['stderr'] and 'Right' in r['stderr'] and 'cross' in r['stderr']

print('DIAGNOSTIC GATES PASS; compiler adoption remains unapproved')
