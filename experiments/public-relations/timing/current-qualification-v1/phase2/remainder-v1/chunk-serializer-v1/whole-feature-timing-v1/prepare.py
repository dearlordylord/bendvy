"""No-child preparation: exact source transformations and independent complete oracle."""
from pathlib import Path
import gzip,hashlib,importlib.util,json,os,re,sys
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
BASE=HERE.parents[3]
ROOT=HERE.parents[7]
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def verify_source():
 source=(HERE.parent/'driver.bend').read_text()
 for line in source.splitlines():
  if line.startswith('import ') and ' as ' in line:
   name=line.split()[1];source=source.replace(line,line.replace(name,os.path.relpath((HERE.parent/name).resolve(),HERE)))
 source=source.replace('import ../../../../trace-boundary.bend as Boundary','import boundary.bend as Boundary')
 source=source.replace('case I.Input{family,+population,span,seed}:IO.bind(Unit,Unit,Boundary.begin(),_ => materialized(population,trace(first,second,firstStats,secondStats,I.Input{family,population,span,seed})))','case I.Input{family,+population,span,seed}:materialized(population,trace(first,second,firstStats,secondStats,I.Input{family,population,span,seed}))')
 source=source.replace('case I.Valid{+input}:prepared(Setup.run(~O.Workshop,input),Setup.run(~O.Other,input),input)','case I.Valid{+input}:IO.bind(Unit,Unit,Boundary.begin(),_ => prepared(Setup.run(~O.Workshop,input),Setup.run(~O.Other,input),input))')
 assert source==(HERE/'driver.bend').read_text()
 ts=(BASE/'phase2/reference.mjs').read_text()
 ts=ts.replace("const worlds=['Workshop','Other'].map(root=>prepareWorld(root,input));\nconsole.error(JSON.stringify({boundary:'begin'}));","console.error(JSON.stringify({boundary:'begin'}));\nconst started=process.hrtime.bigint();\nconst worlds=['Workshop','Other'].map(root=>prepareWorld(root,input));")
 ts=ts.replace("console.error(JSON.stringify({boundary:'complete-trace-forced',...summary}));","const elapsedNs=(process.hrtime.bigint()-started).toString();\nconsole.error(JSON.stringify({boundary:'complete-trace-forced',...summary,region:'whole-feature-setup-operations-full-trace',elapsedNs}));")
 ts=ts.replace('metadata:freeze({root,worldCreates:1,registeredSystems:2,spawnCommands:population,payloadOwners:population-1,seedRelations:5,barriers:2})','metadata:{root,worldCreates:1,registeredSystems:2,spawnCommands:population,payloadOwners:population-1,seedRelations:5,barriers:2}')
 ts=ts.replace('return freeze({root,records});','return {root,records};')
 ts=ts.replace('const trace=freeze({input,setup:worlds.map(world=>world.metadata),roots:worlds.map(world=>world.run())});','const trace={input,setup:worlds.map(world=>world.metadata),roots:worlds.map(world=>world.run())};')
 assert ts==(HERE/'reference.mjs').read_text()
 assert (HERE/'boundary.c').read_text().index('volatile uint32_t nodes=')<(HERE/'boundary.c').read_text().index('clock_gettime(CLOCK_MONOTONIC,&end)')
 assert (HERE/'boundary.js').read_text().index('every(x =>')<(HERE/'boundary.js').read_text().index('const elapsedNs')
def closure(p,seen):
 p=p.resolve()
 if p in seen:return
 assert p.is_file() and not p.is_symlink();seen.add(p)
 if p.suffix=='.bend':
  for name in re.findall(r'^\s*import\s+(\S+)',p.read_text(),re.M):
   if name=='Base':continue
   closure(p.parent/name.strip('"'),seen)
def main():
 verify_source();seen=set();closure(HERE/'driver.bend',seen)
 spec=importlib.util.spec_from_file_location('oracle',BASE/'phase2/oracle.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
 out=HERE/'prepared';out.mkdir(exist_ok=True)
 cases=[]
 for family,population,span in [('population',n,0) for n in (64,256,1024)]+[(f,256,s) for f in ('fanout','depth') for s in (1,16,128)]:
  value=m.trace(family,population,span,0);raw=(json.dumps(value,separators=(',',':'))+'\n').encode();name=f'{family}-{population}-{span}-0.json.gz'
  (out/name).write_bytes(gzip.compress(raw,mtime=0))
  cases.append(dict(input=[family,str(population),str(span),'0'],oracle=name,bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest(),gzipSha256=sha(out/name),counts=m.operation_counts(value)))
 pins={str(p.relative_to(ROOT)):sha(p) for p in sorted(seen)}
 for p in [HERE/'reference.mjs',BASE/'phase2/reference.mjs',BASE/'phase2/oracle.py',HERE.parent/'driver.bend']:
  pins[str(p.relative_to(ROOT))]=sha(p)
 manifest=dict(status='PREPARATION_ONLY_NOT_LAUNCH_ADMITTED',region='whole-feature-setup-operations-full-trace',operationsOnly=False,sourcePins=pins,cases=cases)
 (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
 print(json.dumps(dict(sourceControl='PASS',sourcePins=len(pins),cases=len(cases),manifestSha256=sha(out/'manifest.json'))))
def admission(directory):
 # Existing runner/Inputs/immutable logs, no execution wrapper or child launch.
 directory=Path(directory).resolve()
 assert not directory.exists() and not directory.is_symlink()
 verify_source()
 def load(name,path):
  spec=importlib.util.spec_from_file_location(name,path);module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module);return module
 config=load('config',ROOT/'experiments/public-simulation/delivery-v1/installed-config.py')
 runner=load('runner',ROOT/'scripts/task_runner.py')
 force=load('trace_force',BASE/'trace-cheap.py').force
 manifest=json.loads((HERE/'prepared/manifest.json').read_text())
 paths=[ROOT/n for n in manifest['sourcePins']]
 paths.extend([p for p in HERE.rglob('*') if p.is_file()])
 helpers=[ROOT/'scripts/task_runner.py',ROOT/'scripts/evidence_boundary.py',ROOT/'scripts/receipt-logs.py',ROOT/'scripts/bend-check',ROOT/'experiments/public-simulation/delivery-v1/installed-config.py',BASE/'trace-cheap.py']
 paths.extend(helpers)
 selected=json.loads((HERE/'selected-ts.json').read_text());reference=Path(selected['repository'])
 paths.extend(reference/n for n in selected['pins'])
 tools={key:config.TOOL_PATHS[key] for key in ('bend','node','taskset','clang','clangWrapper')}
 paths.extend(map(Path,tools.values()))
 pins={str(p.resolve(strict=True)):sha(p.resolve(strict=True)) for p in paths}
 resource_roots=runner.Inputs(directories=config.RESOURCE_ROOTS).expected
 prefix=[tools['taskset'],'-c','5'];entry=str(HERE/'driver.bend')
 check=dict(label='source5',argv=prefix+[tools['bend'],entry,'--check-only'],seconds=5)
 checkplan=dict(scope='Single source-current full timing consumer development check, not proofs/backend/performance',pins=pins,resourceRoots=resource_roots,environment=config.environment(),cwd=str(ROOT),output=str(directory/'source5'),command=check,lock='/tmp/bendvy-parity-heavy.lock',rawPathsAbsent=True,recipe='Existing task_runner.Inputs + task_runner.Runner + receipt-logs.CommandLogs; acquire shared flock before command; expected=None; preserve exact exit/failure/raw and unconditional receipt. Accept only actual full check diagnostics reviewed, never infer runtime/IO implementation from foreign declarations.')
 directory.mkdir()
 (directory/'source5-plan.json').write_text(json.dumps(checkplan,indent=2)+'\n')
 cases=[]
 for case in manifest['cases']:
  raw=gzip.decompress((HERE/'prepared'/case['oracle']).read_bytes());expected=json.loads(raw)
  assert len(raw)==case['bytes'] and hashlib.sha256(raw).hexdigest()==case['sha256']
  cases.append(dict(**case,walk=force(expected)))
 common=dict(scope='Semantics/forcing preparation only, not comparative timing admission',pins=pins,resourceRoots=resource_roots,environment=config.environment(),cwd=str(ROOT),lock='/tmp/bendvy-parity-heavy.lock',cases=cases,prerequisites=['Reviewed source5 result','Independent complete source/oracle review','Each previous entire cohort completes before next','Generated exact continuation/effect inspection before interpreting clock intervals'],rawPathsAbsent=True,generatedPathsAbsent=True,postConsumer='Whole raw stdout retained; JSON parsed complete equality with independent oracle, thirty records; exactly Begin + Complete stderr, Complete walk exact and decimal nonnegative elapsedNs; bytes/encoding differences published. Timer diagnostic values never accepted as performance under contention.')
 for backend in ('ts','js','native'):
  out=directory/backend
  generated=out/('trace.js' if backend=='js' else 'trace.c');binary=out/'trace.native'
  commands=[]
  if backend!='ts':commands.append(dict(label='emit',argv=prefix+[tools['bend'],entry,'-o',str(generated)],seconds=30))
  if backend=='native':commands.append(dict(label='build',argv=prefix+[tools['clangWrapper'],'-O3',str(generated),'-o',str(binary),'-pthread','-lm'],seconds=120))
  for case in cases:
   args=case['input'];label='-'.join(args)
   command=prefix+([tools['node'],str(HERE/'reference.mjs')] if backend=='ts' else [tools['node'],str(generated)] if backend=='js' else [str(binary),'--threads','1','--gpu','off'])+args
   commands.append(dict(label=label,argv=command,seconds=5,oracle=str(HERE/'prepared'/case['oracle'])))
  plan=dict(common,backend=backend,commands=commands,output=str(out),status='NOT_LAUNCH_ADMITTED',population1024='Prior full consumer timeout immutable. This plan preserves the case but does NOT authorize unchanged runtime retry; evidence-backed source/topology change or root explicit changed-subject admission required before reaching this command.')
  (directory/(backend+'-semantics-proposal.json')).write_text(json.dumps(plan,indent=2)+'\n')
 print(json.dumps({p.name:sha(p) for p in directory.iterdir()},indent=2))
if __name__=='__main__':
 if len(sys.argv)==3 and sys.argv[1]=='--admission':admission(sys.argv[2])
 elif len(sys.argv)==1:main()
 else:raise SystemExit('usage: prepare.py [--admission ABSENT_DIRECTORY]')
