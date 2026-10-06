#!/usr/bin/env python3
"""Exact-source specialization refusals, not language or universal legality tests."""
import importlib.util,pathlib,tempfile,shutil,json,hashlib
H=pathlib.Path(__file__).resolve().parent
s=importlib.util.spec_from_file_location('recipe',H/'materialize-noaux.py');M=importlib.util.module_from_spec(s);s.loader.exec_module(M)
receipt={'scope':'Pinned-source materialization refusal only; not checker semantic rejection','cases':[]}
with tempfile.TemporaryDirectory() as tmp:
 for label,old,new in [('changed-client-body','done(c0,c1,c2,c3,c4,c5,c6,c7,owner,aux,handle)','done(c0,c1,c2,c3,c4,c5,c6,c7,owner,aux,handle) # changed client body'),('different-client-route','Q.prototype_cont_each(','Q.each(')]:
  source=pathlib.Path(tmp)/label;shutil.copytree(H/'overlay-cont-v2',source)
  p=source/'experiments/s-integrate/measurement-bend.bend';text=p.read_text();assert old in text;p.write_text(text.replace(old,new,1))
  # Even coherent metadata cannot authorize an unreviewed source/client.
  pins={str(p.relative_to(source)):M.sha(p) for p in source.rglob('*.bend')};cache=json.loads((source/'cache-specialization.json').read_text());cache.update(runtimeClosure=pins,specializedClosure=pins,runtimeClosureSHA256=M.closure(pins));manifest=json.loads((source/'overlay.json').read_text());manifest.update(sources=pins,cacheSpecialization=cache)
  (source/'cache-specialization.json').write_text(json.dumps(cache));(source/'overlay.json').write_text(json.dumps(manifest))
  output=H/('guard-refusal-'+label)
  try:M.materialize(source,output)
  except AssertionError: receipt['cases'].append({'subject':label,'result':'EXACT_SOURCE_PIN_REFUSED','closure':M.closure(pins)});assert not output.exists()
  else:raise AssertionError('Unexpected source admitted')
receipt['status']='TWO_CHANGED_SOURCE_PIN_REFUSALS_PASS';(H/'evidence/noaux-source-guard-controls.json').write_text(json.dumps(receipt,indent=2)+'\n');print(receipt['status'])
