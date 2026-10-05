#!/usr/bin/env python3
"""Derive isolated held-owner adapter; never edit protected source checkout."""
import argparse,difflib,hashlib,json,re,shutil
from pathlib import Path
HERE=Path(__file__).resolve().parent
h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def definitions(text):
 return {m.group(1):m.group(0) for m in re.finditer(r'^def ([\w.]+)\([^\n]*\n(?:(?!^(?:def |type |import |#)).*\n)*',text,re.M)}
def main():
 p=argparse.ArgumentParser();p.add_argument('--base-overlay',required=True,type=Path);p.add_argument('--output',required=True,type=Path);a=p.parse_args()
 manifest=json.loads((a.base_overlay/'overlay.json').read_text());assert all(h(a.base_overlay/n)==v for n,v in manifest['sources'].items())
 shutil.copytree(a.base_overlay,a.output);core=a.output/'experiments/s-integrate'
 original=(core/'measurement-bend.bend').read_text();modified=original.replace('import ./capture.bend as C\n','import ./capture.bend as C\nimport ./held.bend as HG\nimport ./held-adapter.bend as HA\n')
 for n,sc,m,aux,f,l,mode in [('motion','MotionSchema','Position','Velocity','Selected','MotionLedger','MotionMode'),('health','HealthSchema','Vitals','Armor','Tracked','HealthLedger','HealthMode')]:
  world=f'S.World<T.{sc},T.{m},T.{aux},T.{f},T.{l},T.{mode}>';handle=f'S.Handle<T.{sc}>';command=f'S.Command<T.{m},T.{aux},T.{f}>';tx=f'X.Tx<{world},{handle},{command}>';held=f'HG.Held<{world},T.{m},T.{l},{handle},{command}>'
  helpers=f'''def {n}_held_body(owner:{held}) -> {held} & U32:
  {n}_body({held},HA.{n}_read_main,HA.{n}_set_main0,HA.{n}_read_ledger,HA.{n}_set_ledger0,owner)
def {n}_original_body(owner:{tx}) -> {tx} & U32:
  {n}_body({tx},A.{n}_read_main,A.{n}_set_main0,A.{n}_read_ledger,A.{n}_set_ledger0,owner)
def {n}_held_apply(owner:{tx}) -> {tx} & U32:
  HA.{n}_run(~{n}_held_body,~{n}_original_body,owner)
'''
  anchor=f'type {n.title()}Rows is Type:';assert modified.count(anchor)==1;modified=modified.replace(anchor,helpers+anchor)
  old=f'{n}_body({tx},A.{n}_read_main,A.{n}_set_main0,A.{n}_read_ledger,A.{n}_set_ledger0,{n}_select(owner,handle))';new=f'{n}_held_apply({n}_select(owner,handle))';assert modified.count(old)==1;modified=modified.replace(old,new)
 before=definitions(original);after=definitions(modified);callbacks={}
 for n in ('motion','health'):
  for suffix in ('body','body_read','body_ledger'):
   name=n+'_'+suffix;assert before[name]==after[name],name;callbacks[name]=hashlib.sha256(before[name].encode()).hexdigest()
 for name,body in before.items():
  if name not in ('motion_rows','health_rows'):assert body==after[name],name
 (core/'measurement-bend.bend').write_text(modified)
 for old,new in [('held.bend','held.bend'),('adapter.bend','held-adapter.bend')]:shutil.copyfile(HERE/old,core/new)
 diff=''.join(difflib.unified_diff(original.splitlines(keepends=True),modified.splitlines(keepends=True),fromfile='protected/measurement-bend.bend',tofile='derived/measurement-bend.bend'));(a.output/'measurement-adapter.diff').write_text(diff)
 changed=[n for n,v in manifest['sources'].items() if h(a.output/n)!=v];assert changed==['experiments/s-integrate/measurement-bend.bend']
 sources={n:h(a.output/n) for n in manifest['sources']};sources.update({str((core/n).relative_to(a.output)):h(core/n) for n in ['held.bend','held-adapter.bend']})
 derived=dict(manifest,sources=sources);(a.output/'overlay.json').write_text(json.dumps(derived,indent=2)+'\n')
 receipt={'status':'ISOLATED_ADAPTER_DERIVED','acceptedBenchmarkCandidate':False,'baseOverlayManifestSHA256':h(a.base_overlay/'overlay.json'),'derivedOverlayManifestSHA256':h(a.output/'overlay.json'),'changedProtectedModuleOnlyInTemporaryCopy':changed,'callbackFunctionSHA256':callbacks,'originalMeasurementSHA256':h(a.base_overlay/'experiments/s-integrate/measurement-bend.bend'),'derivedMeasurementSHA256':h(core/'measurement-bend.bend'),'heldPrototypeCommit':'febc9d6','heldPrototypeSHA256':h(HERE/'held.bend'),'adapterSHA256':h(HERE/'adapter.bend'),'adapterDiffSHA256':h(a.output/'measurement-adapter.diff')}
 (a.output/'integration-prepare.json').write_text(json.dumps(receipt,indent=2)+'\n');print(json.dumps(receipt,indent=2))
if __name__=='__main__':main()
