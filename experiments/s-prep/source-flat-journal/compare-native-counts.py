#!/usr/bin/env python3
"""Compare exact archived Motion operation counts; never elapsed acceptance."""
import argparse,pathlib,json,gzip,hashlib,collections,re
p=argparse.ArgumentParser();p.add_argument('--counts',type=pathlib.Path,required=True);p.add_argument('--drop',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();root=pathlib.Path('/workspace/formal-proofs/bendvy/experiments/s-prep');h=pathlib.Path(__file__).resolve().parent
# Parent root may not yet integrate earlier branch archives; explicit same-branch fallback.
if not (root/'native-hotness-seed-followup/evidence/fold-noaux-join-evidence.json.gz').exists():root=h.parent
base=root/'native-hotness-seed-followup/evidence';dropbase=root/'native-joined-hotpath/evidence'
read=lambda p:json.loads(gzip.decompress(p.read_bytes())) if p.suffix=='.gz' else json.loads(p.read_text())
old=read(base/'fold-noaux-join-evidence.json.gz');new=read(a.counts/'evidence.json');assert old['status']==new['status']=='CALLSITE_COUNTS_FULL65_FIELDS_PASS';assert old['sourceSHA256']=='f5261110337876cd31e0a0fd8c4d50f5f182b085306904f82ab69b6c7beb6295';assert new['sourceSHA256']=='47d44d1c7597b8c134b3824f6d268f8ba4d2b46eed5e6ef703baddefd1e1665c'
for key in ['fullWorlds','updates','compilerWrapperSHA256','compilerELFSHA256']:assert old[key]==new[key]
metrics={k:{'join':old[k],'flat':new[k],'delta':new[k]-old[k]} for k in ['heapEntries','requestedWords','rfcCreated']}
def operations(sites):
 c=collections.Counter()
 for s in sites:c[s['operation']]+=s.get('entries',0)
 return c
opsold=operations(read(base/'fold-noaux-join-sites.json.gz'));opsnew=operations(read(a.counts/'sites.json'))
ops={k:{'join':opsold[k],'flat':opsnew[k],'delta':opsnew[k]-opsold[k]} for k in ['heap_alloc_miss','bank_pop','malloc','mmap','mprotect','corpus_grow','rfc_seal','term_keep','term_drop']}
def drop(text):return {m[1]:int(m[2]) for m in re.finditer(r'^([a-z_]+):(\d+)$',text,re.M)}
x=drop(gzip.decompress((dropbase/'motion-drop-counts.txt.gz').read_bytes()).decode());y=drop((a.drop/'counts.txt').read_text());dd=read(a.drop/'evidence.json');assert dd['status']=='DROP_BRANCHES_FULL65_FIELDS_PASS' and dd['sourceSHA256']==new['sourceSHA256']
result={'status':'SOURCE_PINNED_MOTION_NATIVE_OPERATION_COMPARISON_PASS','scope':'Counts in clocks3–4, oneworker/GPUoff; no timing, physicalallocation, universal or product acceptance','baselineC':old['sourceSHA256'],'candidateC':new['sourceSHA256'],'fullWorldsEach':65,'updates':old['updates'],'metrics':metrics,'operations':ops,'dropBranches':{k:{'join':x[k],'flat':y[k],'delta':y[k]-x[k]} for k in x},'baselineEvidenceSHA256':hashlib.sha256((base/'fold-noaux-join-evidence.json.gz').read_bytes()).hexdigest(),'candidateEvidenceSHA256':hashlib.sha256((a.counts/'evidence.json').read_bytes()).hexdigest(),'dropEvidenceSHA256':hashlib.sha256((a.drop/'evidence.json').read_bytes()).hexdigest()}
a.output.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result['metrics']))
