#!/usr/bin/env python3
"""Prepare additive production modules/relocated controls; never edit live src."""
import pathlib,hashlib,json,shutil,re,difflib
HERE=pathlib.Path(__file__).resolve().parent;OLD=HERE.parent;ROOT=HERE.parents[2];V5=OLD/'production-candidate-v5'
sha=lambda p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
MAP={'types.bend':'relation-types.bend','graph-core.bend':'relation-graph.bend','world-adapter.bend':'relation-commands.bend','providers.bend':'relation-providers.bend','cleanup-core.bend':'relation-cleanup.bend','reorder-core.bend':'relation-reorder-core.bend','reorder-adapter.bend':'relation-reorder.bend'}
modules=HERE/'modules';modules.mkdir(exist_ok=True);bindings={};patch=[]
for target in MAP.values():
 source=V5/target;original=source.read_text();text=original.replace('../../../src/ecs/','')
 assert [x for x in original.splitlines() if not x.startswith('import ')]==[x for x in text.splitlines() if not x.startswith('import ')]
 dst=modules/target;assert not dst.exists();dst.write_text(text)
 bindings[str(dst.relative_to(ROOT))]={'source':str(source),'sourceSHA256':sha(source),'outputSHA256':sha(dst),'bodyUnchanged':True}
 patch.extend(difflib.unified_diff([],text.splitlines(keepends=True),fromfile='/dev/null',tofile='b/src/ecs/'+target))
(HERE/'additive-modules.patch').write_text(''.join(patch))
def relocate(text):
 text=text.replace('../../src/ecs/','../../../src/ecs/')
 # V5 source already has ../../../, avoid its double relocation.
 for old,new in MAP.items():text=re.sub(r'(?m)^import '+re.escape(old)+r'(?= as |$)','import ../../../src/ecs/'+new,text)
 for name in MAP.values():text=re.sub(r'(?m)^import '+re.escape(name)+r'(?= as |$)','import ../../../src/ecs/'+name,text)
 return text
for src in OLD.glob('*.bend'):
 if src.name in MAP:continue
 chosen=V5/src.name if (V5/src.name).exists() else src
 text=chosen.read_text()
 if chosen.parent==V5:
  for name in MAP.values():text=re.sub(r'(?m)^import '+re.escape(name)+r'(?= as |$)','import ../../../src/ecs/'+name,text)
 else:text=relocate(text)
 dst=HERE/src.name;assert not dst.exists();dst.write_text(text);bindings[str(dst.relative_to(ROOT))]={'source':str(chosen),'sourceSHA256':sha(chosen),'outputSHA256':sha(dst),'importOnly':True}
for name in ['large-owned.bend','negative-clear-graph.bend','negative-clear-world.bend']:
 source=V5/name;text=source.read_text()
 for m in MAP.values():text=re.sub(r'(?m)^import '+re.escape(m)+r'(?= as |$)','import ../../../src/ecs/'+m,text)
 dst=HERE/name;assert not dst.exists();dst.write_text(text);bindings[str(dst.relative_to(ROOT))]={'source':str(source),'sourceSHA256':sha(source),'outputSHA256':sha(dst),'importOnly':True}
for src in OLD.glob('*.mjs'):
 chosen=V5/src.name if (V5/src.name).exists() else src;shutil.copyfile(chosen,HERE/src.name)
for name in ['tool-pins.py','validate.py','cleanup-model.py','reorder-model.py']:
 source=OLD/name
 if source.exists():shutil.copyfile(source,HERE/name)
shutil.copyfile(V5/'large-reference.mjs',HERE/'large-reference.mjs')
# Reuse literal/oracle bodies, supervision and prospective guard structure.
for suite in ['graph','world','provider','cleanup','reorder','foreign','large']:
 source=V5/('controls.py' if suite=='cleanup' else 'large-controls.py') if suite in ['cleanup','large'] else OLD/(suite+'-controls.py')
 s=source.read_text().replace('ROOT=HERE.parents[1]','ROOT=HERE.parents[2]')
 s=s.replace('production-candidate-v5','promotion-stage') if suite in ['cleanup','large'] else s.replace('experiments/public-relations/','experiments/public-relations/promotion-stage/')
 s=s.replace("'experiments/public-relations'/", "'experiments/public-relations/promotion-stage'/")
 s=s.replace("files=set(HERE.glob('*.bend'))", "files=set((HERE/'modules').glob('*.bend'))|{HERE/'derivation.json',HERE/'additive-modules.patch'}|set(HERE.glob('*.bend'))")
 s=s.replace("'BENDVY_CLANG19_ROOT':'/tmp/bendvy-clang19-diagnostic/root'", "'BENDVY_CLANG19_ROOT':'/tmp/bendvy-clang19-diagnostic/root','BEND_NO_TELEMETRY':'1'")
 old="  normal={str(p.relative_to(ROOT)):sha(p) for p in list(HERE.glob('*.bend'))+list((ROOT/'src/ecs').glob('*.bend'))}"
 assert s.count(old)==1
 new="  sources={str(p.relative_to(ROOT)):p for p in list(HERE.glob('*.bend'))+list((ROOT/'src/ecs').glob('*.bend'))}\n  for p in (HERE/'modules').glob('*.bend'):\n   key='src/ecs/'+p.name;assert key not in sources,'already present live module';sources[key]=p\n  normal={key:sha(p) for key,p in sources.items()}"
 s=s.replace(old,new).replace('shutil.copyfile(ROOT/path,dst)','shutil.copyfile(sources[path],dst)')
 # Mutants act on real staged production modules, never dormant experiment copies.
 for oldname,newname in MAP.items():
  s=s.replace("'experiments/public-relations/promotion-stage/"+oldname+"'", "'src/ecs/"+newname+"'")
 if suite in ['cleanup','reorder','foreign','large']:
  marker="file=stage/'experiments/public-relations/promotion-stage'/filename"
  if marker in s:s=s.replace(marker,"file=stage/'src/ecs'/filename if filename.startswith('relation-') else stage/'experiments/public-relations/promotion-stage'/filename")
  # Tuple-controlled old module filenames are mapped to production basename.
  for oldname,newname in MAP.items():s=s.replace("('"+oldname+"',", "('"+newname+"',")
 if suite in ['cleanup','large']:
  marker="file=stage/'experiments/public-relations/promotion-stage'/filename"
  # V5 joined slash layout.
  s=s.replace("file=stage/'experiments/public-relations/promotion-stage'/filename", "file=stage/'src/ecs'/filename if filename.startswith('relation-') else stage/'experiments/public-relations/promotion-stage'/filename")
 dst=HERE/(suite+'-controls.py');assert not dst.exists();dst.write_text(s);bindings[str(dst.relative_to(ROOT))]={'source':str(source),'sourceSHA256':sha(source),'outputSHA256':sha(dst),'adaptation':'production import/target staging; immutable oracle bodies and limits'}
receipt={'scope':'additive production promotion staging only, no live src edits or acceptance','moduleCount':7,'coreInputPins':{str(p.relative_to(ROOT)):sha(p) for p in sorted((ROOT/'src/ecs').glob('*.bend'))},'bindings':bindings,'patchSHA256':sha(HERE/'additive-modules.patch'),'recipeSHA256':sha(__file__)}
(HERE/'derivation.json').write_text(json.dumps(receipt,indent=2)+'\n');print(HERE)
