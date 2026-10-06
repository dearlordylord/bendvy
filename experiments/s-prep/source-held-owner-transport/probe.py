from pathlib import Path
import shutil,json,hashlib,re,difflib
BASE=Path('/tmp/bendvy-query-frozen-provider-native-v3'); OUT=Path('/tmp/bendvy-held-flat-both-v5')
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
# Split the ledger cache too; private ingress still takes the public Cache.
for raw,view in [('T.MotionLedger','T.LedgerView'),('T.HealthLedger','T.LedgerView')]:
    block=block.replace(',CC.Cache<'+raw+','+view+'>,S.Handle<',','+raw+','+view+',S.Handle<')
lines=block.splitlines(True)
for i,line in enumerate(lines):
    if line.startswith('def ') and '_taken(' not in line:
        for raw,view in [('T.MotionLedger','T.LedgerView'),('T.HealthLedger','T.LedgerView')]:
            line=line.replace('ledger:CC.Cache<'+raw+','+view+'>','ledger_raw:'+raw+',ledger_cached:'+view)
    if not line.startswith('def '):
        line=line.replace(',ledger,',',ledger_raw,ledger_cached,')
    line=line.replace('main_raw,main_cached,CC.Cache{raw,+cached}', 'main_raw,main_cached,raw,+cached')
    line=line.replace('main_raw,main_cached,CC.Cache{raw,cached}', 'main_raw,main_cached,raw,cached')
    line=line.replace('main_raw,main_cached,CC.Cache{raw,P.motion_ledger_patch(cached,value)}','main_raw,main_cached,raw,P.motion_ledger_patch(cached,value)')
    line=line.replace('main_raw,main_cached,CC.Cache{raw,P.health_ledger_patch(cached,value)}','main_raw,main_cached,raw,P.health_ledger_patch(cached,value)')
    line=line.replace('pending,Some{ledger},mode},S.Handle{space,id},undo,commands,pings,marks},total)', 'pending,Some{CC.Cache{ledger_raw,ledger_cached}},mode},S.Handle{space,id},undo,commands,pings,marks},total)')
    line=line.replace('  match pair:', '  match pair ledger:')
    line=line.replace('case (rows,S.Taken{CC.Cache{main_raw,main_cached}}):','case (rows,S.Taken{CC.Cache{main_raw,main_cached}}) CC.Cache{ledger_raw,ledger_cached}:')
    line=line.replace('case (rows,_): client(', 'case (rows,_) ledger: client(')
    lines[i]=line
block=''.join(lines)
# Private binder order follows the head match order: pair precedes ledger.
for schema in ('motion','health'):
    name='prototype_flatmain_'+schema+'_taken'
    line=next(x for x in block.splitlines() if x.startswith('def '+name+'('))
    at=line.index(',pair:S.Rows'); stop=line.index(') ->',at)
    pairdecl=line[at:stop]
    revised=line[:at]+line[stop:]
    revised=revised.replace(',ledger:CC.Cache',pairdecl+',ledger:CC.Cache',1)
    block=block.replace(line,revised)

type_= '\ntype PrototypeFlatHeld<-W:Type,-Raw:Type,-View:Data,-L:Type,-LV:Data,-H:Data,-C:Type> is Type:\n  PrototypeFlatHeld{world:W,main_raw:Raw,main_cached:View,ledger_raw:L,ledger_cached:LV,handle:H,undo:List<&2,X.Inverse<H>>,commands:List<C>,pings:List<&2,U32>,marks:List<&2,H>}\n'
new=original[:start]+type_+block+original[end:]
# Select actual new provider only at existing checked valid route.
new=new.replace('case True{} Some{ledger}: prototype_boxed_motion_taken','case True{} Some{ledger}: prototype_flatmain_motion_taken').replace('case True{} Some{ledger}: prototype_boxed_health_taken','case True{} Some{ledger}: prototype_flatmain_health_taken')
for schema in ('motion','health'):
    name='prototype_flatmain_'+schema+'_taken'
    line=next(x for x in new.splitlines() if 'case True{} Some{ledger}: '+name+'(' in x)
    prefix, pair=line.rsplit(',S.take_rows(',1)
    assert pair.endswith('))')
    pair='S.take_rows('+pair[:-1]
    revised=prefix.replace(',pending,ledger,',',pending,'+pair+',ledger,')+')'
    new=new.replace(line,revised)
p.write_text(new)
HERE=Path(__file__).resolve().parent
(HERE/'held-adapter.patch').write_text(''.join(difflib.unified_diff(original.splitlines(True),new.splitlines(True),fromfile='a/experiments/s-integrate/held-adapter.bend',tofile='b/experiments/s-integrate/held-adapter.bend')))
pins={str(x.relative_to(OUT)):hashlib.sha256(x.read_bytes()).hexdigest() for x in OUT.rglob('*.bend')}
cache=json.loads((OUT/'cache-specialization.json').read_text()); cache['runtimeClosure']=pins;cache['specializedClosure']=pins;cache['runtimeClosureSHA256']=hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest()
over=json.loads((OUT/'overlay.json').read_text());over['sources']=pins;over['cacheSpecialization']=cache
(OUT/'cache-specialization.json').write_text(json.dumps(cache,indent=2)+'\n');(OUT/'overlay.json').write_text(json.dumps(over,indent=2)+'\n')
print(OUT)
