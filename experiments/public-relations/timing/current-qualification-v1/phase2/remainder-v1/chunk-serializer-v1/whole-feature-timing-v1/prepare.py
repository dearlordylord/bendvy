"""No-child preparation: exact source transformations and independent complete oracle."""
from pathlib import Path
import gzip,hashlib,importlib.util,json,os,re,sys
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
BASE=HERE.parents[3]
ROOT=HERE.parents[8]
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
if __name__=='__main__':main()
