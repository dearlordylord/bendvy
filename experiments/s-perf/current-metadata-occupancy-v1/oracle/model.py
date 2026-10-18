"""Independent complete-state per-column occupancy over unchanged indexed Readers."""
from pathlib import Path
import copy,json,gzip,hashlib
import operation_model as O
P=Path(__file__).parent;sha=lambda v:hashlib.sha256(v).hexdigest()
def shape(n):
 assert n>0 and n&(n-1)==0
 return [n,n-1]
def entries(rows):
 return [len(rows),sum(a>0 for _,a,b in rows),sum(b>0 for _,a,b in rows),sum(a>0 or b>0 for _,a,b in rows)]
def snapshot(column):
 # Inspect structural counts and actual scalar metadata only. Payload C is opaque.
 a=column.added;c=column.changed;assert len(a)==len(c)
 return {'kind':'indexed','values':shape(len(column.values)),'metadata':{'added':shape(len(a))+[sum(v>0 for v in a)],'changed':shape(len(c))+[sum(v>0 for v in c)],'capacity':len(a),'depth':len(a).bit_length()-1,'exceptional':entries(column.exceptional),'populated':sum(x>0 or y>0 for x,y in zip(a,c))}}
OriginalColumn=O.IndexedColumn
class Column(OriginalColumn):
 def __init__(self):
  super().__init__();self.occupancy=[{'site':'empty','snapshot':snapshot(self)}];self.hook_origins=[{'site':'empty','index':None,'tick':None}];self.rejected_clears=0
 def replace(self,index,incoming,tick):
  result=super().replace(index,incoming,tick)
  self.occupancy.append({'site':'mark','snapshot':snapshot(self)});self.hook_origins.append({'site':'mark','index':index,'tick':tick})
  return result
 def clear(self,index):
  fits=0<index<=len(self.values);result=super().clear(index)
  if fits:
   self.occupancy.append({'site':'clear_stamp','snapshot':snapshot(self)});self.hook_origins.append({'site':'clear_stamp','index':index,'tick':None})
  else:self.rejected_clears+=1
  return result
def leaves(value,path=()):
 if isinstance(value,dict):
  for k,v in value.items():yield from leaves(v,path+(k,))
 elif isinstance(value,list):
  for i,v in enumerate(value):yield from leaves(v,path+(i,))
 elif isinstance(value,int):yield path,value
 # kind strings describe the reached representation, not numeric N/A zeros.
def peaks(samples):
 maxima={};witnesses={}
 for i,s in enumerate(samples):
  for path,value in leaves(s['snapshot']):
   key='.'.join(map(str,path))
   if key not in maxima or value>maxima[key]:maxima[key]=value;witnesses[key]=i
 return {'fieldMaxima':maxima,'firstWitnessSample':witnesses}
def generate():
 basis=json.loads((P/'SOURCE-BASIS.json').read_text())
 for pin in basis['sourcePins']:assert sha((P/pin['copy']).read_bytes())==pin['sha256']
 assert sha((P/'operation_model.py').read_bytes())=='6ecaf75517608a5366f69e182139f9b47b2a09826aa6c1f9f092b14cd5e26050'
 q=basis['qualifiedCanonical'];packed=(P/q['copy']).read_bytes();assert sha(packed)==q['gzipSHA256'];qualified=gzip.decompress(packed)
 control,_=O.report(64,64);assert control==qualified and(len(control),sha(control))==(q['bytes'],q['sha256'])
 (P/'canonical-control.stdout.gz').write_bytes(gzip.compress(control,mtime=0))
 O.IndexedColumn=Column
 try:observed,program=O.report(64,64)
 finally:O.IndexedColumn=OriginalColumn
 assert observed==control # exact same original payloads, clocks, owners/readers/canonical
 result={name:column.occupancy for name,column in zip(['main','aux','flag'],program.world.columns)}
 assert [len(v)for v in result.values()]==[321,23,22]
 main=result['main'];assert [s['site']for s in main]==['empty']+['mark']*64+['mark','mark','mark','clear_stamp']*64
 assert all(s['site']=='mark'for name in ['aux','flag']for s in result[name][1:])
 assert [c.rejected_clears for c in program.world.columns]==[0,64,64]
 assert len(program.locals)==192 and len(program.reads)==84 and len(program.logs)==194
 assert program.world.clock==577 and not program.world.pending and not program.world.events
 raw=json.dumps(result,separators=(',',':')).encode();(P/'expected.stats.json').write_bytes(raw);packed=gzip.compress(raw,mtime=0);(P/'expected.stats.json.gz').write_bytes(packed)
 analysis={name:peaks(values)for name,values in result.items()}
 origins={name:c.hook_origins for name,c in zip(['main','aux','flag'],program.world.columns)}
 (P/'HOOK-ORIGINS.json').write_text(json.dumps(origins,indent=2)+'\n')
 receipt={'status':'PASS','origin':'Independent unchanged indexedReaders model plus source-derived complete-state hooks; no candidate output input','modelSHA256':sha(Path(__file__).read_bytes()),'sourceBasisSHA256':sha((P/'SOURCE-BASIS.json').read_bytes()),'canonicalControl':{'bytes':len(control),'sha256':sha(control),'observedCanonicalIdentical':observed==control},'sampleCounts':{n:len(v)for n,v in result.items()},'siteCounts':{n:{site:sum(s['site']==site for s in v)for site in ['empty','mark','clear_stamp','restore_stamp']}for n,v in result.items()},'rejectedClearCalls':{'main':0,'aux':64,'flag':64},'bytes':len(raw),'sha256':sha(raw),'gzipBytes':len(packed),'gzipSHA256':sha(packed),'perColumnCompleteStatePeaks':analysis,'peakScope':'Each numeric field maximum over this column complete snapshots, with actual sample witness. Balanced monotone factory growth bounds maximal complete retained structure. No Worldaggregate/sumofcolumnmaxima, bytes, uniquephysicalnodes, lowering/DynamicData aliasing, or internalpartialconstruction-temporary claim.'}
 (P/'GENERATION-RECEIPT.json').write_text(json.dumps(receipt,indent=2)+'\n');print(json.dumps(receipt,sort_keys=True))
if __name__=='__main__':generate()
