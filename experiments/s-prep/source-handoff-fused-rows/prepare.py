#!/usr/bin/env python3
import pathlib,shutil,json,hashlib
P=pathlib.Path
base=P('/tmp/bendvy-slot-host-handoff-v7'); out=P('/tmp/bendvy-slot-host-handoff-v8')
shutil.copytree(base,out)
q=out/'experiments/s-integrate/query.bend'; h=out/'experiments/s-integrate/held-adapter.bend'
old=q.read_text(); s=old.replace('type PrototypeHandoffRow<-Schema:Data,-M:Type> is Type:\n  PrototypeHandoffRow{id:U32,owner:M}', 'type PrototypeHandoffRows<-Schema:Data,-M:Type> is Type:\n  HandoffNil{}\n  HandoffCon{id:U32,owner:M,rest:PrototypeHandoffRows<Schema,M>}')
s=s.replace('List<&1,PrototypeHandoffRow<Schema,M>>','PrototypeHandoffRows<Schema,M>').replace('PrototypeHandoffRow{id,owner} <> values','HandoffCon{id,owner,values}').replace('PrototypeHandoffState{main,aux,live,flags,added,changed,[]})','PrototypeHandoffState{main,aux,live,flags,added,changed,HandoffNil{}})').replace('case Nil{}: (columns,List.reverse(&2,U32,ids))','case HandoffNil{}: (columns,List.reverse(&2,U32,ids))').replace('case Con{PrototypeHandoffRow{+id,owner},rest}:','case HandoffCon{+id,owner,rest}:')
assert 'PrototypeHandoffRow<' not in s
q.write_text(s)
s=h.read_text()
for schema in ['Motion','Health']:
 s=s.replace(f'List<&1,Q.PrototypeHandoffRow<T.{schema}Schema,P.Prototype{schema}MainSlot>>',f'Q.PrototypeHandoffRows<T.{schema}Schema,P.Prototype{schema}MainSlot>')
start=s.index('# Private motion producer/drain')
prefix=s[:start]; tail=s[start:]
tail=tail.replace('case Nil{} state: state','case Q.HandoffNil{} state: state').replace('case Con{Q.PrototypeHandoffRow{id,owner},rest}', 'case Q.HandoffCon{id,owner,rest}').replace('case Con{row,rest} PrototypeFlatFold','case Q.HandoffCon{id,owner,rest} PrototypeFlatFold').replace('Con{row,rest},columns))','Q.HandoffCon{id,owner,rest},columns))')
h.write_text(prefix+tail)
sha=lambda x:hashlib.sha256(x).hexdigest()
pins=json.loads((base/'overlay.json').read_text())['sources']; assert len(pins)==29
new={n:sha((out/n).read_bytes()) for n in pins}; changed=[n for n in pins if pins[n]!=new[n]]; assert changed==['experiments/s-integrate/held-adapter.bend','experiments/s-integrate/query.bend'] or set(changed)=={'experiments/s-integrate/held-adapter.bend','experiments/s-integrate/query.bend'}
closure=lambda d:sha(json.dumps(d,sort_keys=True,separators=(',',':')).encode())
for name,key in [('overlay.json','sources'),('cache-specialization.json','runtimeClosure')]:
 d=json.loads((out/name).read_text());d[key]=new;(out/name).write_text(json.dumps(d,indent=2)+'\n')
recipe={'scope':'Nominal affine fused row carrier only; no production confinement, proof or performance acceptance.','baseSourceClosureSHA256':closure(pins),'sourceClosureSHA256':closure(new),'inputSources':pins,'sources':new,'changedSources':changed,'unchangedSourceCount':27,'queryOriginalPrefixSHA256':sha(old.split('# Private two-phase affine ownership handoff;')[0].encode()),'heldAdapterOriginalPrefixSHA256':sha(prefix.encode()),'measurementUnchangedSHA256':new['experiments/s-integrate/measurement-bend.bend'],'rewrite':'Row wrapper plus affine List is replaced by HandoffNil/HandoffCon; complete None recovery node, ID reverse-once, callbacks and guards unchanged.'}
(out/'fused-rows-recipe.json').write_text(json.dumps(recipe,indent=2)+'\n')
(out/'handoff-source-pins.json').write_text(json.dumps({'input':{'sources':pins},'output':{'sources':new},'sourceClosureSHA256':closure(new),'recipe':'fused-rows-recipe.json'},indent=2)+'\n')
print(closure(new))
