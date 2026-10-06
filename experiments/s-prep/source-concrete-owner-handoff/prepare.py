#!/usr/bin/env python3
import pathlib,json,hashlib,shutil,re
P=pathlib.Path;base=P('/tmp/bendvy-slot-host-handoff-v8-coherent');out=P('/tmp/bendvy-slot-host-concrete-owner-v3');sha=lambda b:hashlib.sha256(b).hexdigest();closure=lambda d:sha(json.dumps(d,sort_keys=True,separators=(',',':')).encode())
o=json.loads((base/'overlay.json').read_text());pins=o['sources'];c=json.loads((base/'cache-specialization.json').read_text());assert closure(pins)=='4eb71a36304194a1c2764c7301ed59afa9b4d0a4ee7336b8b6c7f8175095f235';assert c==o['cacheSpecialization'];assert c['runtimeClosure']==c['specializedClosure']==pins;assert c['runtimeClosureSHA256']==c['specializedClosureSHA256']==closure(pins);assert not out.exists();assert all(not(base/n).is_symlink() and sha((base/n).read_bytes())==h for n,h in pins.items());shutil.copytree(base,out)
q=out/'experiments/s-integrate/query.bend';h=out/'experiments/s-integrate/held-adapter.bend';old=q.read_text();template=old[old.index('type PrototypeHandoffRows'):];extra='\n\n'
for schema in ['Motion','Health']:
 s=template
 s=re.sub(r'[~-]Schema\s*:\s*Data\s*,\s*[~-]M\s*:\s*Type\s*,?', '',s)
 # Fixed schema/main remove function argument pairs; keep type argument pairs replaced.
 s=s.replace('~Schema,~M,','').replace('Schema,M,','').replace('Schema,M)','')
 s=s.replace('<Schema,M>', '').replace('<Schema,M,','<')
 s=re.sub(r'\bSchema\b','T.'+schema+'Schema',s);s=re.sub(r'\bM\b','CP.Prototype'+schema+'MainSlot',s)
 # World still requires its fixed schema/main because generic headers above also transformed these types.
 s=s.replace('S.World<A,F,L,Mode>','S.World<T.'+schema+'Schema,CP.Prototype'+schema+'MainSlot,A,F,L,Mode>')
 s=s.replace('PrototypeHandoff','PrototypeConcrete'+schema+'Handoff').replace('prototype_handoff','prototype_concrete_'+schema.lower()+'_handoff').replace('HandoffNil','Concrete'+schema+'HandoffNil').replace('HandoffCon','Concrete'+schema+'HandoffCon')
 extra+='\n'+s
q.write_text('import ./cached-payload.bend as CP\n'+old+extra)
s=h.read_text()
for schema in ['Motion','Health']:
 low=schema.lower();s=s.replace(f'Q.PrototypeHandoffRows<T.{schema}Schema,P.Prototype{schema}MainSlot>',f'Q.PrototypeConcrete{schema}HandoffRows')
 start=s.index('def prototype_handoff_'+low+'_drain(');end=s.index('\ndef prototype_handoff_'+low+'_original(',start);part=s[start:end].replace('Q.PrototypeHandoffBatch{','Q.PrototypeConcrete'+schema+'HandoffBatch{').replace('Q.HandoffNil','Q.Concrete'+schema+'HandoffNil').replace('Q.HandoffCon','Q.Concrete'+schema+'HandoffCon').replace(f'Q.prototype_handoff_recover(T.{schema}Schema,P.Prototype{schema}MainSlot,',f'Q.prototype_concrete_{low}_handoff_recover(').replace(f'Q.PrototypeHandoffBatch<T.{schema}Schema,P.Prototype{schema}MainSlot,',f'Q.PrototypeConcrete{schema}HandoffBatch<');s=s[:start]+part+s[end:]
 s=s.replace(f'Q.prototype_handoff_each(T.{schema}Schema,P.Prototype{schema}MainSlot,',f'Q.prototype_concrete_{low}_handoff_each(')
h.write_text(s)
new={n:sha((out/n).read_bytes())for n in pins};changed=[n for n in pins if pins[n]!=new[n]];assert len(changed)==2
c.update(runtimeClosure=new,specializedClosure=new,runtimeClosureSHA256=closure(new),specializedClosureSHA256=closure(new));o.update(sources=new,cacheSpecialization=c)
for name,d in [('overlay.json',o),('cache-specialization.json',c)]: (out/name).write_text(json.dumps(d,indent=2)+'\n')
r={'sourceRoot':str(base),'producerSHA256':sha(P(__file__).read_bytes()),'inputOverlaySHA256':sha((base/'overlay.json').read_bytes()),'inputCacheSHA256':sha((base/'cache-specialization.json').read_bytes()),'baseClosure':closure(pins),'sourceClosureSHA256':closure(new),'inputSources':pins,'sources':new,'changed':changed,'genericQueryBytePrefixPreserved':q.read_bytes().removeprefix(b'import ./cached-payload.bend as CP\n').startswith((base/'experiments/s-integrate/query.bend').read_bytes()),'measurementUnchanged':new['experiments/s-integrate/measurement-bend.bend']==pins['experiments/s-integrate/measurement-bend.bend']};(out/'concrete-owner-recipe.json').write_text(json.dumps(r,indent=2)+'\n');print(closure(new))
