#!/usr/bin/env python3
"""Compose separately reviewed private Native columns and static Cache/Held; no timing."""
import argparse,copy,hashlib,json,pathlib,re,shutil
H=pathlib.Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
BASE_CLOSURE='bd9660f1c27e0531eeefef3af1fac3e0b3fd1f3e8f19e902e2952254ed6a7ea4'
PINS={'storage.bend':'cc33de4db37a732af8322442be2fb615f35ed8465a0d9470616e1bbfe2d25e3a','query.bend':'2d9dd65d57919371506a26b30a96b7919da4b018d6380d7f59a901685b1bc0cf','held-adapter.bend':'f1dc68b726bad16930dfcf919bbdfeccb82779cc746799e65be9414c58efabd4','cache.bend':'1e39566e68de59350a93ad11fae6175a8c368463d0d2f9ee2ff28e3a6963e40b','cached-payload.bend':'03b01d1fc4e313c149302778753749e363527584d3e5b500f018c43a595dd05f'}
def arguments(text):
 result=[];start=0;depth=0
 for i,char in enumerate(text):
  if char in '<({[':depth+=1
  elif char in '>)}]':depth-=1
  elif char==',' and depth==0:result.append(text[start:i]);start=i+1
 result.append(text[start:]);return result

def main():
 p=argparse.ArgumentParser();p.add_argument('--base',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();assert a.base.is_absolute() and a.base.resolve()==a.base and a.output.is_absolute() and a.output.resolve()==a.output and not a.output.exists()
 original=json.loads((a.base/'overlay.json').read_text());assert original['cacheSpecialization']['runtimeClosureSHA256']==BASE_CLOSURE;assert len(original['cacheSpecialization']['runtimeClosure'])==28;assert all(sha(a.base/n)==digest for n,digest in original['sources'].items());assert all(sha(H/'pinned'/n)==v for n,v in PINS.items());a.output.mkdir();shutil.copytree(a.base/'experiments',a.output/'experiments');core=a.output/'experiments/s-integrate'
 for n in PINS:shutil.copy2(H/'pinned'/n,core/n)
 held=(core/'held.bend').read_text();additions=[]
 for name in ['main_read','main_write','ledger_read','ledger_write']:
  m=re.search(r'^def '+name+r'\(',held,re.M);end=held.find('\ndef ',m.start()+1);part=held[m.start():end if end>=0 else len(held)].replace('def '+name+'(', 'def '+name+'_static(',1);part=re.sub(r'-(W|M|L|H|C|V):',r'~\1:',part);part=part.replace(',get:', ',~get:').replace(',swap:', ',~swap:');additions.append(part.rstrip())
 (core/'held.bend').write_text(held.rstrip()+'\n\n'+'\n\n'.join(additions)+'\n')
 text=(core/'held-adapter.bend').read_text();offset=0;count=0
 while (m:=re.search(r'H\.(main_read|main_write|ledger_read|ledger_write)\(',text[offset:])):
  begin=offset+m.start();start=offset+m.end();i=start;depth=1
  while depth:depth+=(text[i]=='(')-(text[i]==')');i+=1
  args=arguments(text[start:i-1]);assert len(args)==8;static=7 if m[1].endswith('read') else 6;replacement='H.'+m[1]+'_static('+','.join('~'+arg if n<static else arg for n,arg in enumerate(args))+')';text=text[:begin]+replacement+text[i:];offset=begin+len(replacement);count+=1
 assert count==8;(core/'held-adapter.bend').write_text(text)
 manifest=copy.deepcopy(original);cache=manifest['cacheSpecialization'];cache['baselineRuntimeClosureSHA256']=BASE_CLOSURE;cache['baselineDescriptiveSourcePins']={k:cache[k] for k in ['cacheSourceSHA256','cachedPayloadSHA256','rawPayloadSHA256','rawProviderSHA256']};cache['baselineSpecializedClosure']=cache['specializedClosure'];cache['baselinePinnedSourceInputs']=cache['pinnedSourceInputs'];cache['pinnedSourceInputsRole']='baseline recipe provenance; final current module hashes are runtimeClosure and derivedSourceInputs';cache['derivedPrivateVariant']='native-columns-static-cache-held-v1';cache['scope']='unmeasured private Native columns plus static Cache/Held; original nominal types/headers/callbacks; requires reviewed later-segment scope'
 pins={str(p.relative_to(a.output)):sha(p) for p in a.output.rglob('*.bend')};cache['runtimeClosure']={n:pins[n] for n in cache['runtimeClosure']};assert len(cache['runtimeClosure'])==28;cache['runtimeClosureSHA256']=hashlib.sha256(json.dumps(cache['runtimeClosure'],sort_keys=True,separators=(',',':')).encode()).hexdigest();cache['specializedClosure']={n:pins[n] for n in cache['specializedClosure']};cache['derivedSourceInputs']={n:pins['experiments/s-integrate/'+n] for n in [*PINS,'held.bend']};cache['specializedClosure'].update({'experiments/s-integrate/'+n:digest for n,digest in cache['derivedSourceInputs'].items()});cache['currentRuntimeModules']=28
 for field,n in [('cacheSourceSHA256','cache.bend'),('cachedPayloadSHA256','cached-payload.bend'),('rawPayloadSHA256','payload.bend'),('rawProviderSHA256','uncached-payload.bend')]:cache[field]=pins['experiments/s-integrate/'+n]
 assert cache['rawProviderVariant']=='native-four-cell-structural' and cache['rawProviderSHA256']=='2938897514720ed50abc100d99bbc7effd730a8b5c155ad8d9ac98d1bf5143b4';manifest['sources']=pins;manifest['overrides']=copy.deepcopy(manifest['overrides']);manifest['nativeStaticComposition']={'recipeSHA256':sha(pathlib.Path(__file__)),'sourceInputs':PINS,'providerCallSites':count,'baseRuntimeClosureSHA256':BASE_CLOSURE,'runtimeClosureSHA256':cache['runtimeClosureSHA256'],'nativeRawPreserved':True,'measurementAcceptance':False};(a.output/'overlay.json').write_text(json.dumps(manifest,indent=2)+'\n');(a.output/'cache-specialization.json').write_text(json.dumps(cache,indent=2)+'\n');(a.output/'combined-native-static-recipe.json').write_text(json.dumps(manifest['nativeStaticComposition'],indent=2)+'\n');print(cache['runtimeClosureSHA256'])
if __name__=='__main__':main()
