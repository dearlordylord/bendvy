"""Join actual terminal seed counts to existing reached pre-finish callback facts."""
from pathlib import Path
import gzip,hashlib,json,re,stat,sys
actual,oracle,metric=map(Path,sys.argv[1:]);before=actual.lstat();assert stat.S_ISREG(before.st_mode) and not actual.is_symlink();h=hashlib.sha256();n=0;parts=[]
with actual.open('rb') as a,gzip.open(oracle,'rb') as o:
 while chunk:=a.read(1048576):
  assert chunk==o.read(len(chunk));h.update(chunk);n+=len(chunk);parts.append(chunk)
 assert o.read(1)==b''
after=actual.lstat();assert (before.st_dev,before.st_ino,before.st_mode,before.st_size,before.st_mtime_ns)==(after.st_dev,after.st_ino,after.st_mode,after.st_size,after.st_mtime_ns)
wire=b''.join(parts);facts=[]
for u,c,k,e in re.findall(rb'undo=(\d+);commands=(\d+);kinds=(.*?);events=(.*?);trace=',wire):
 assert re.fullmatch(rb'\[(?:Original\{\d+\}(?:, Original\{\d+\})*)?\]',e),e
 facts.append({'undo':int(u),'commands':int(c),'events':len(re.findall(rb'Original\{\d+\}',e))})
assert facts
m=metric.read_bytes();seeds=json.loads(m)['samples'];assert [s['kind'] for s in seeds]==['warmup-seed','measured-seed']
maxima=lambda rows:{k:max(row[k] for row in rows) for k in ['undo','commands','events']}
print(json.dumps({'status':'TX_MAXIMA_PASS','canonicalPath':str(actual),'canonicalBytes':n,'canonicalSHA256':h.hexdigest(),'oraclePath':str(oracle),'oracleGzipSHA256':hashlib.sha256(oracle.read_bytes()).hexdigest(),'metricPath':str(metric),'metricSHA256':hashlib.sha256(m).hexdigest(),'renderedCallbackFacts':len(facts),'callbackMaxima':maxima(facts),'actualSeedSamples':seeds,'combinedMaxima':maxima(facts+seeds),'scope':'Componentwise maxima of actual terminal lists; repeated fact renderings not summed. Canonical Tx has no marks field; lifecycle column stamps, allocation and RSS unmeasured.'},separators=(',',':')))
print('TX_MAXIMA_PASS',file=sys.stderr)
