#!/usr/bin/env python3
"""Derive fresh-world batch reference preserving original update/oracle bodies."""
import argparse,hashlib,json
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--source',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--batch',type=int,default=64);p.add_argument('--schema',choices=['Motion','Health'],default='Health');a=p.parse_args()
s=a.source.read_text().replace("new URL('../../.references/sources.json',import.meta.url)","'/workspace/formal-proofs/bendvy/.references/sources.json'");anchor='  const start=performance.now();for(let i=0;i<iterations;i++)tick(Update);const executionMilliseconds=performance.now()-start;'
assert s.count(anchor)==1
s=s.replace(anchor,'''  return {run(){for(let i=0;i<iterations;i++)tick(Update);},observe(executionMilliseconds){''')
end="    commandOccupancyAfterSeed:0,readerOccupancy:'not used by dense/sparse',retainedLiveCount:count};\n}"
assert s.count(end)==1;s=s.replace(end,end[:-2]+'\n  }};\n}')
start=s.index('const [schema,workload,countText,');s=s[:start]+f'''const schema='{a.schema}',workload='dense',count=1024,batch={a.batch};
const warmOwner=execute(schema,workload,count);const ws=performance.now();warmOwner.run();const we=performance.now();const warmup=warmOwner.observe(we-ws);
const prepared=Array.from({{length:batch}},()=>execute(schema,workload,count));
const start=performance.now();for(const owner of prepared)owner.run();const end=performance.now();
const samples=prepared.map(owner=>owner.observe(0));
console.log(JSON.stringify({{schema,workload,count,iterations,batch,warmup,samples,batchMilliseconds:end-start,scope:'single bracket; setup/final full observation outside; no numerical acceptance'}}));
'''
# Expose complete raw final world alongside hashes; retain original exact oracle assertion.
s=s.replace("finalSha256:sha(JSON.stringify(final)),", "final,finalSha256:sha(JSON.stringify(final)),")
a.output.write_text(s)
print(json.dumps({'sourceSHA256':hashlib.sha256(a.source.read_bytes()).hexdigest(),'derivedSHA256':hashlib.sha256(s.encode()).hexdigest(),'batch':a.batch}))
