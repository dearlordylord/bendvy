from pathlib import Path
import shutil,json,hashlib,re,difflib
BASE=Path('/tmp/bendvy-query-frozen-provider-native-v3'); OUT=Path('/tmp/bendvy-held-flat-main-v2')
if OUT.exists(): raise SystemExit('fresh only')
shutil.copytree(BASE,OUT)
p=OUT/'experiments/s-integrate/held-adapter.bend'; original=p.read_text()
start=original.index('def prototype_boxed_motion_get('); end=original.index('\ndef motion_get(',start)
block=original[start:end].replace('prototype_boxed_','prototype_flatmain_')
# Concrete owner headers retain rank2 abstraction; only private owner shape changes.
for raw,view in [('T.Position','T.PositionView'),('T.Vitals','T.VitalsView')]:
    block=block.replace('>>,CC.Cache<'+raw+','+view+'>,CC.Cache<','>>,'+raw+','+view+',CC.Cache<')
block=block.replace('H.Held<','PrototypeFlatHeld<').replace('H.Held{','PrototypeFlatHeld{')
# Main cache is split in the owner. Ledger cache remains untouched.
block=block.replace('world,CC.Cache{raw,+cached},ledger','world,raw,+cached,ledger')
block=block.replace('world,CC.Cache{raw,cached},ledger','world,raw,cached,ledger')
block=block.replace('world,CC.Cache{raw,P.position_patch(cached,value)},ledger','world,raw,P.position_patch(cached,value),ledger')
block=block.replace('world,CC.Cache{raw,P.vitals_patch(cached,value)},ledger','world,raw,P.vitals_patch(cached,value),ledger')
block=block.replace('world,main,','world,main_raw,main_cached,')
# Main cache transported by ledger writer continuation as independent affine raw/view fields.
for raw,view in [('T.Position','T.PositionView'),('T.Vitals','T.VitalsView')]:
    block=block.replace('main:CC.Cache<'+raw+','+view+'>','main_raw:'+raw+',main_cached:'+view)
block=block.replace('_setledger_fused_done(world,main,','_setledger_fused_done(world,main_raw,main_cached,')
# Return boundary reconstructs only once.
block=block.replace('case (PrototypeFlatHeld{box,main,ledger,handle,undo,commands,pings,marks},total):','case (PrototypeFlatHeld{box,main_raw,main_cached,ledger,handle,undo,commands,pings,marks},total):')
block=block.replace('_return_world(main,ledger,','_return_world(main_raw,main_cached,ledger,')
# return_world header now receives fields; actual storage publication uses Cache.
block=block.replace('Some{main})','Some{CC.Cache{main_raw,main_cached}})')
# ingress unwraps Cache. untouched fallback still receives public Tx.
block=block.replace('case (rows,S.Taken{main}):','case (rows,S.Taken{CC.Cache{main_raw,main_cached}}):')
block=block.replace('}},main,ledger,handle,undo,commands,pings,marks}','}},main_raw,main_cached,ledger,handle,undo,commands,pings,marks}')
type_= '\ntype PrototypeFlatHeld<-W:Type,-Raw:Type,-View:Data,-L:Type,-H:Data,-C:Type> is Type:\n  PrototypeFlatHeld{world:W,main_raw:Raw,main_cached:View,ledger:L,handle:H,undo:List<&2,X.Inverse<H>>,commands:List<C>,pings:List<&2,U32>,marks:List<&2,H>}\n'
new=original[:start]+type_+block+original[end:]
# Select actual new provider only at existing checked valid route.
new=new.replace('case True{} Some{ledger}: prototype_boxed_motion_taken','case True{} Some{ledger}: prototype_flatmain_motion_taken').replace('case True{} Some{ledger}: prototype_boxed_health_taken','case True{} Some{ledger}: prototype_flatmain_health_taken')
p.write_text(new)
HERE=Path(__file__).resolve().parent
(HERE/'held-adapter.patch').write_text(''.join(difflib.unified_diff(original.splitlines(True),new.splitlines(True),fromfile='a/experiments/s-integrate/held-adapter.bend',tofile='b/experiments/s-integrate/held-adapter.bend')))
pins={str(x.relative_to(OUT)):hashlib.sha256(x.read_bytes()).hexdigest() for x in OUT.rglob('*.bend')}
cache=json.loads((OUT/'cache-specialization.json').read_text()); cache['runtimeClosure']=pins;cache['specializedClosure']=pins;cache['runtimeClosureSHA256']=hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest()
over=json.loads((OUT/'overlay.json').read_text());over['sources']=pins;over['cacheSpecialization']=cache
(OUT/'cache-specialization.json').write_text(json.dumps(cache,indent=2)+'\n');(OUT/'overlay.json').write_text(json.dumps(over,indent=2)+'\n')
print(OUT)
