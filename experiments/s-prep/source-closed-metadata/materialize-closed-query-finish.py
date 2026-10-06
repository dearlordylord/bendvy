#!/usr/bin/env python3
"""Close exactly the observed indexed query reversal boundary."""
import argparse,hashlib,json,pathlib,re,shutil
HERE=pathlib.Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--input',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();assert not a.output.exists();assert not a.output.absolute().is_relative_to(a.input.resolve());assert not any(x.is_symlink() for x in a.input.rglob('*'))
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();pins={str(p.relative_to(a.input)):sha(p) for p in a.input.rglob('*.bend')};assert len(pins)==29 and pins==json.loads((HERE/'closed-world-observation-output-pins.json').read_text());overlay=json.loads((a.input/'overlay.json').read_text());cache=json.loads((a.input/'cache-specialization.json').read_text());assert cache==overlay['cacheSpecialization'];assert cache['runtimeClosure']==cache['specializedClosure']==overlay['sources']==pins;assert cache['runtimeClosureSHA256']==hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest()
name='experiments/s-integrate/query.bend';source=(a.input/name).read_text()
def body(name):
 m=re.search(r'^def '+name+r'\(',source,re.M);assert m
 tail=source[m.start():];n=re.search(r'\n(?:def |type )',tail)
 return tail[:n.start()+1] if n else tail
idx=body('struct_idx_finish');cols=body('struct_cols_finish')
newidx=re.sub(r'-(\w+):\s*(Data|Type)',r'~\1: \2',idx.replace('def struct_idx_finish(','def prototype_closed_query_idx_finish(',1))
newcols=re.sub(r'-(\w+):\s*(Data|Type)',r'~\1: \2',cols.replace('def struct_cols_finish(','def prototype_closed_query_cols_finish(',1))
assert newcols.count('struct_idx_finish(M,A,F,O,')==1
newcols=newcols.replace('struct_idx_finish(M,A,F,O,','prototype_closed_query_idx_finish(~M,~A,~F,~O,')
assert source.count('case 0n: struct_cols_finish(M,A,F,O,')==1
source=source.replace('def struct_idx_go(',newidx+'\n'+newcols+'\ndef struct_idx_go(',1).replace('case 0n: struct_cols_finish(M,A,F,O,','case 0n: prototype_closed_query_cols_finish(~M,~A,~F,~O,')
assert idx in source and cols in source and 'List.reverse(&2,O,values)' in newidx
shutil.copytree(a.input,a.output);(a.output/name).write_text(source);newpins={str(p.relative_to(a.output)):sha(p) for p in a.output.rglob('*.bend')};assert [k for k in pins if pins[k]!=newpins[k]]==[name]
cache['runtimeClosure']=newpins;cache['specializedClosure']=newpins.copy();cache['runtimeClosureSHA256']=hashlib.sha256(json.dumps(newpins,sort_keys=True,separators=(',',':')).encode()).hexdigest();overlay['sources']=newpins;overlay['cacheSpecialization']=cache
for name,value in [('overlay.json',overlay),('cache-specialization.json',cache),('closed-observation.json',{'status':'UNVERIFIED_SOURCE_HYPOTHESIS','inputPins':pins,'outputPins':newpins,'recipeSHA256':sha(pathlib.Path(__file__))})]:(a.output/name).write_text(json.dumps(value,indent=2)+'\n')
print(a.output/'experiments/s-integrate')
