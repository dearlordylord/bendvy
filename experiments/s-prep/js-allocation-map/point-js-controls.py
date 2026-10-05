#!/usr/bin/env python3
"""Explicit JS-only subset; cannot substitute for the original 16-case two-backend gate."""
import hashlib,importlib.util,json,os,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];HERE=ROOT/'experiments/s-prep/fivehour-connected-gates';sys.path.insert(0,str(HERE))
source=HERE/'static-world-run.py';text=source.read_text();pins=hashlib.sha256(source.read_bytes()).hexdigest()
changes={"for program in B.build(source,folder):":"for program in diagnostic_js_build(source,folder):", "assert len(r['cases'])==16":"assert len(r['cases'])==8", "FINITE_ACTUAL_STATIC_FOREIGN_WORLD_FIELDS_PASS":"JS_ONLY_FINITE_FACTORY_FIELD_COMPARISON_PASS", "'Native':{'clang':'-O3','threads':1,'gpu':'off'},":"", "'scope':'Finite actual factory lineage, two live local-id-1 worlds, static SC/HA foreign and same-world callback full fields; no universal refinement or performance acceptance'":"'scope':'JS-only 8-program subset of 16-program gate; no Native/full22/authority proof/performance acceptance'"}
for old,new in changes.items():assert text.count(old)==1,old;text=text.replace(old,new)
namespace={'__name__':'js_diagnostic','__file__':str(source)};exec(compile(text,str(source)+'[JS-only diagnostic]', 'exec'),namespace)
def build(entry,folder):
 B=namespace['B'];assert 'ALL PROOFS CHECK' in B.command(['bend',entry,'--check-only'],timeout=15);js=folder/(entry.stem+'.js');B.command(['bend',entry,'-o',js],timeout=30);return [js]
namespace['diagnostic_js_build']=build;os.environ['BENDVY_CHECKER_SECONDS']='15';namespace['main']()
output=Path(sys.argv[sys.argv.index('--output')+1]);p=output/'evidence.json';d=json.loads(p.read_text());d['derivedRunner']={'originalRunnerSHA256':pins,'adapterSHA256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'explicitChanges':changes};p.write_text(json.dumps(d,indent=2)+'\n')
