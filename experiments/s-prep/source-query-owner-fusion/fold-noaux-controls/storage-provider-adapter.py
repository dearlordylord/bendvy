#!/usr/bin/env python3
"""Use the storage-owned exact fold registration recognizer; no shared edits."""
import pathlib,json,hashlib,importlib.util,importlib.machinery,sys,runpy,argparse,os
H=pathlib.Path(__file__).resolve().parent;SOURCE=H.parent;ROOT=SOURCE.parents[2];PC=ROOT/'experiments/s-prep/fivehour-connected-gates/provider_controls.py';LOCAL=H/'storage-fold-provider-controls.py'
p=argparse.ArgumentParser();p.add_argument('--kind',choices=['provider','factory'],required=True);p.add_argument('--overlay',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();assert not a.output.exists()
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();pins={str(p.relative_to(a.overlay)):sha(p) for p in a.overlay.rglob('*.bend')};assert len(pins)==29 and hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest()=='49614f72311af5b03123d536ff301115d28b8886bf516b0d7057a8c52e68ad38'
spec=importlib.util.spec_from_file_location('storage_fold_pc',LOCAL);local=importlib.util.module_from_spec(spec);spec.loader.exec_module(local);assert local.static_registration(a.overlay/'experiments/s-integrate')
original=importlib.machinery.SourceFileLoader.exec_module
def hook(loader,module):
 original(loader,module)
 if pathlib.Path(loader.path).resolve()==PC.resolve():module.static_registration=local.static_registration
importlib.machinery.SourceFileLoader.exec_module=hook
recipe=SOURCE/('provider-run.py' if a.kind=='provider' else 'protected-run.py');r={'status':'INCOMPLETE','kind':a.kind,'sourcePins':pins,'sharedRecipeSHA256':sha(recipe),'sharedProviderControlsSHA256':sha(PC),'storageOwnedRecognizerSHA256':sha(LOCAL),'adaptation':'Only exact storage-owned static_registration: exact fold call and mixed old-route rejection; callback/header/body checks unchanged','directTxAcceptance':False}
try:
 sys.argv=[str(recipe),*( ['--kind','factory'] if a.kind=='factory' else []),'--overlay',str(a.overlay),'--output',str(a.output)];runpy.run_path(str(recipe),run_name='__main__');r['status']='FRESH_STORAGE_RECOGNIZED_SCOPED_GATE_PASS'
except Exception as e:r.update(status='FAILED_PRESERVED_SUBJECT',error=repr(e));raise
finally:importlib.machinery.SourceFileLoader.exec_module=original;(a.output.parent/(a.output.name+'.storage-adapter.json')).write_text(json.dumps(r,indent=2)+'\n')
print(r['status'])
