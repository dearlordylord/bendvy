"""Seal B1 role streams solely from independent operation/common/TS models."""
from pathlib import Path
import gzip,hashlib,json,copy,subprocess
import common_model as C
from ts_model import full
here=Path(__file__).parent;fixtures=json.loads(gzip.decompress((here/'observer-fixtures.json.gz').read_bytes()));M=C.M
# Reproduce original canonical exactly again from byte-identical source; isolated spools.
import io
M.Model=C.Observer;tmp=here/'seal-tmp';tmp.mkdir(exist_ok=True);realPath=Path;M.Path=lambda v:tmp/realPath(v).name if str(v).startswith('/tmp/failedtxn-oracle-ns-')else realPath(v)
sha=lambda x:hashlib.sha256(x).hexdigest();canonical=[]
for name,ns in [('warmup',1),('measured',2)]:
 stream=io.StringIO();stream.write(name+'={');m,spool=M.setup_output(M.World(ns),64,64,stream)
 for i in range(64):M.do_iteration(m,i)
 M.write_state('',m,stream,boundaries=spool);stream.write('}\n');spool.unlink();raw=stream.getvalue().encode();canonical.append(raw)
 assert m.completed()==fixtures[ns-1]['records']and m.raw_map()==fixtures[ns-1]['rawActorMap']
 (here/f'canonical-ns{ns}.stdout.gz').write_bytes(gzip.compress(raw,mtime=0))
assert b''.join(canonical)==gzip.decompress((here/'canonical-baseline/expected.stdout.gz').read_bytes())
assert fixtures[0]['tuple']==fixtures[1]['tuple']
result={'scope':'FailedTxnMotion64 B1 complete-method correctness only; no ratios/RSS/precision/batchqualification','records':len(fixtures[0]['records']),'tupleValues':len(fixtures[0]['tuple']),'fold':fixtures[0]['fold'],'oracles':{},'rss':'Actual TS process.resourceUsage().maxRSS preserved AFTERendclock in fresh rawsidecar; wholeprocess highwater including warmup, not independent RSSsample or qualifiedcomparison','sourcePins':{str(p.resolve()):sha(p.read_bytes())for p in [here/'operation_model.py',here/'common_model.py',here/'ts_model.py',Path(__file__)]}}
root=Path('/workspace/formal-proofs/bendvy');reference=root/'.references/bevy-ts'
assert subprocess.check_output(['git','-C',str(reference),'rev-parse','HEAD'],text=True).strip()=='3040a3b2a3f28fa8554d856f9ccb6bf5433fa334'
for p in [root/'experiments/s-integrate/measurement-reference.mjs',root/'.references/sources.json',*(reference/'packages/core/src').rglob('*.ts')]:result['sourcePins'][str(p)]=sha(p.read_bytes())
result['tsClockBasis']={'runSystem':'Runtime.ts:1402 advances tick before callback; traceSystem captures thisRun; commitSystemTransaction:1030 adds event publication tick; applyDeferred:1443 adds tick; advanceFrame:1642 increments frame only','rollback':'internal/world.ts rollbackTransaction restores journal values, not world tick','queryOrder':'actual query order preserved; no sorting to manufacture correspondence','voidResult':'New raw-result transport explicitly tags Undefined; actual result still executed/validated unchanged'}
for role in ['bend','ts']:
 target=here/f'{role}-expected.stdout';h=hashlib.sha256();n=0
 with target.open('wb')as out:
  def write(raw):
   global n;out.write(raw);h.update(raw);n+=len(raw)
  for i,label in enumerate(['WARMUP','SAMPLE']):
   f=fixtures[i];write(f"{label}\nFORCE:{f['fold']}\nTUPLE:".encode());write((json.dumps(f['tuple'])if role=='bend'else C.compact(f['tuple'])).encode());write(b'\n')
   if role=='bend':
    write(('ACTORS:'+C.compact(f['rawActorMap'])+'\nCANONICAL-BEGIN\n').encode());write(canonical[i]);write(b'CANONICAL-END\n')
   else:write(('FULL:'+C.compact(full(f))+'\n').encode())
 raw=target.read_bytes();assert len(raw)==n and sha(raw)==h.hexdigest();g=target.with_suffix(target.suffix+'.gz');g.write_bytes(gzip.compress(raw,mtime=0));result['oracles'][role]={'path':str(g.resolve()),'bytes':n,'sha256':h.hexdigest(),'gzipSHA256':sha(g.read_bytes())}
(here/'expected-common.json.gz').write_bytes(gzip.compress(C.compact({'tuple':fixtures[0]['tuple'],'fold':fixtures[0]['fold']}).encode(),mtime=0))
(here/'PILOT-ORACLE-BASIS.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
