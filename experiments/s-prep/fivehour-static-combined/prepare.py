#!/usr/bin/env python3
"""Isolated static Held plus static Cache recipe; no timing acceptance."""
import argparse,hashlib,importlib.util,json,pathlib,subprocess
HERE=pathlib.Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def prepare(root,destination,native=False):
 helper=root/'experiments/s-prep/fivehour-held-specialization/prepare.py'
 assert sha(helper)=='36593377973e581b404b72e47a5786fd02b7d76edf63bccaab60352afc2b3413'
 assert subprocess.check_output(['git','-C',str(root),'show','HEAD:'+str(helper.relative_to(root))])==helper.read_bytes()
 assert sha(root/'experiments/s-prep/fivehour-cache-integration/materialize.py')=='18655a4f0a348deabf3b4668dd6083670fd040ad81339c1800ef13446cf96dc1'
 spec=importlib.util.spec_from_file_location('held_prepare',helper);module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
 core=module.prepare(destination,native=native,provider_only=False,freeze_callback=False)
 before=json.loads((destination/'overlay.json').read_text());baseline=before['cacheSpecialization']['runtimeClosureSHA256']
 replacements={'cache.bend':'1e39566e68de59350a93ad11fae6175a8c368463d0d2f9ee2ff28e3a6963e40b','cached-payload.bend':'03b01d1fc4e313c149302778753749e363527584d3e5b500f018c43a595dd05f'}
 for name,digest in replacements.items():
  source=HERE/'pinned'/name;assert sha(source)==digest
  old=(core/name).read_text();new=source.read_text()
  # Static variant preserves every exported definition header and all original type declarations.
  headers=lambda text:[line for line in text.splitlines() if line.startswith(('def ','type ')) and not line.startswith('def static_')]
  assert all(line in new.splitlines() for line in headers(old)),name
  (core/name).write_bytes(source.read_bytes())
 pins={str(p.relative_to(destination)):sha(p) for p in destination.rglob('*.bend')};cache=before['cacheSpecialization'];cache['runtimeClosure']={name:pins[name] for name in cache['runtimeClosure']};cache['runtimeClosureSHA256']=hashlib.sha256(json.dumps(cache['runtimeClosure'],sort_keys=True,separators=(',',':')).encode()).hexdigest()
 for name in replacements:cache['specializedClosure']['experiments/s-integrate/'+name]=pins['experiments/s-integrate/'+name]
 cache['derivedPrivateVariant']='combined-static-held-cache-v1';before['sources']=pins
 (destination/'overlay.json').write_text(json.dumps(before,indent=2)+'\n');(destination/'cache-specialization.json').write_text(json.dumps(cache,indent=2)+'\n')
 receipt={'status':'UNMEASURED_COMBINED_SOURCE','recipeSHA256':sha(root/'experiments/s-prep/fivehour-cache-integration/materialize.py'),'helperSHA256':sha(helper),'helperCommit':subprocess.check_output(['git','-C',str(root),'rev-parse','HEAD'],text=True).strip(),'staticCacheSources':replacements,'staticHeldClosureSHA256':baseline,'runtimeClosureSHA256':cache['runtimeClosureSHA256'],'runtimeModules':len(cache['runtimeClosure']),'nativePayload':native,'frozenCallback':False}
 (destination/'combined-static-recipe.json').write_text(json.dumps(receipt,indent=2)+'\n');return core
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--root',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);p.add_argument('--native-payload',action='store_true');a=p.parse_args();print(prepare(a.root,a.output,a.native_payload))
