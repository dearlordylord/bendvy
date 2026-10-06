from pathlib import Path
import hashlib,json,shutil,re,difflib
BASE=Path('/tmp/bendvy-row-owner-split-reproduced');OUT=Path('/tmp/bendvy-write-row-fold-v2');H=Path('/tmp/bendvy-threehour-held-transport/experiments/s-prep/source-write-row-fold');H.mkdir(exist_ok=True);assert not OUT.exists();shutil.copytree(BASE,OUT)
p=OUT/'experiments/s-integrate/held-adapter.bend';old=p.read_text();text=old
block='\ntype PrototypeWriteFold<-Schema:Data,-M:Type,-A:Type,-F:Data,-L:Type,-Mode:Data> is Type:\n  PrototypeWriteFold{namespace:U32,next:U32,columns:Array<Maybe<M>>,aux:Array<Maybe<A>>,metadata:S.MetadataColumns<F>,capacity:U32,depth:Nat,high:U32,pending:List<S.Command<M,A,F>>,ledger:Maybe<L>,mode:Mode,selected:S.Handle<Schema>,undo:List<&2,X.Inverse<S.Handle<Schema>>>,commands:List<S.Command<M,A,F>>,pings:List<&2,U32>,marks:List<&2,S.Handle<Schema>>,total:U32}\n'
for lane in ('motion','health'):
 raw='T.Position' if lane=='motion' else 'T.Vitals';view=raw+'View';L='T.MotionLedger' if lane=='motion' else 'T.HealthLedger';A='T.Velocity' if lane=='motion' else 'T.Armor';F='T.Selected' if lane=='motion' else 'T.Tracked';Schema='T.MotionSchema' if lane=='motion' else 'T.HealthSchema';Mode='T.MotionMode' if lane=='motion' else 'T.HealthMode';M=f'CC.Cache<{raw},{view}>';Ledger=f'CC.Cache<{L},T.LedgerView>';Handle=f'S.Handle<{Schema}>';Command=f'S.Command<{M},{A},{F}>';World=f'S.World<{Schema},{M},{A},{F},{Ledger},{Mode}>';Tx=f'X.Tx<{World},{Handle},{Command}>';State=f'PrototypeWriteFold<{Schema},{M},{A},{F},{Ledger},{Mode}>';Owner=f'PrototypeRowOwner<{raw},{view},{L},T.LedgerView,{Handle}>';pre='prototype_writefold_'+lane
 header=re.search(r'^def '+lane+r'_row\((.*),owner:',old,re.M).group(1)
 fields=[('ns','U32'),('next','U32'),('columns',f'Array<Maybe<{M}>>'),('aux',f'Array<Maybe<{A}>>'),('metadata',f'S.MetadataColumns<{F}>'),('capacity','U32'),('depth','Nat'),('high','U32'),('pending',f'List<{Command}>'),('ledger',f'Maybe<{Ledger}>'),('mode',Mode),('selected',Handle),('undo',f'List<&2,X.Inverse<{Handle}>>'),('commands',f'List<{Command}>'),('pings','List<&2,U32>'),('marks',f'List<&2,{Handle}>'),('total','U32')]
 def args(exclude=(),plus=()):return ','.join(('+' if n in plus else '')+n+':'+t for n,t in fields if n not in exclude)
 def values(exclude=()):return ','.join(n for n,t in fields if n not in exclude)
 def state(vals=None):return 'PrototypeWriteFold{'+(vals or values())+'}'
 def world():return 'S.World{ns,next,S.Rows{columns,aux,metadata,capacity,depth,high},pending,ledger,mode}'
 def tx():return 'X.Tx{'+world()+',selected,undo,commands,pings,marks}'
 def fallback():return pre+'_unpack(client('+Tx+','+','.join('A.'+lane+'_'+s for s in ('read_main','set_main0','read_ledger','set_ledger0'))+','+tx()+'),total)'
 block+=f"""def {pre}_pack(owner:{Tx},total:U32) -> {State}:\n  match owner:\n    case X.Tx{{S.World{{ns,next,S.Rows{{columns,aux,metadata,capacity,depth,high}},pending,ledger,mode}},selected,undo,commands,pings,marks}}: {state()}\n\n"""
 block+=f"""def {pre}_finish(state:{State}) -> {Tx} & U32:\n  match state:\n    case {state()}: ({tx()},total)\n\n"""
 block+=f"""def {pre}_unpack(result:{Tx} & U32,total:U32) -> {State}:\n  match result:\n    case (X.Tx{{S.World{{ns,next,S.Rows{{columns,aux,metadata,capacity,depth,high}},pending,ledger,mode}},selected,undo,commands,pings,marks}},value): {state(values().replace(",total",",U32.add(total,value)"))}\n\n"""
 context=('ledger','selected','undo','marks')
 block+=f"""def {pre}_returned(result:{Owner} & U32,{args(context)}) -> {State}:\n  match result:\n    case (PrototypeRowOwner{{main_raw,main_cached,ledger_raw,ledger_cached,S.Handle{{+space,+id}},undo,marks}},value):\n      {state(values().replace("columns,aux","Array.set(Maybe<"+M+">,columns,U32.sub(id,1),Some{CC.Cache{main_raw,main_cached}}),aux").replace('pending,ledger,mode,selected','pending,Some{CC.Cache{ledger_raw,ledger_cached}},mode,S.Handle{space,id}').replace(',total',',U32.add(total,value)'))}\n\n"""
 # ledger and columns are consumed from the swap result; other context parameters remain affine.
 block+=f"""def {pre}_taken({header},result:Array<Maybe<{M}>> & Maybe<{M}>,ledger:{Ledger},{args(("columns","ledger"))}) -> {State}:\n  match result ledger:\n    case (columns,Some{{CC.Cache{{main_raw,main_cached}}}}) CC.Cache{{ledger_raw,ledger_cached}}: {pre}_returned(prototype_rowsplit_{lane}_invoke(~client,PrototypeRowOwner{{main_raw,main_cached,ledger_raw,ledger_cached,selected,undo,marks}}),{values(context)})\n    case (columns,_) ledger: {fallback().replace('pending,ledger,mode','pending,Some{ledger},mode')}\n\n"""
 block+=f"""def {pre}_live({header},result:S.MetadataColumns<{F}> & Bool,ledger:{Ledger},{args(("metadata","ledger"),plus=("id",))},+id:U32) -> {State}:\n  match result:\n    case (metadata,False{{}}): {fallback().replace('pending,ledger,mode','pending,Some{ledger},mode')}\n    case (metadata,True{{}}): {pre}_taken(~client,Array.swap(Maybe<{M}>,columns,U32.sub(id,1),None{{}}),ledger,{values(("columns","ledger"))})\n\n"""
 block+=f"""def {pre}_guard({header},valid:Bool,+id:U32,{args(("metadata","ledger"))},metadata:S.MetadataColumns<{F}>,ledger:Maybe<{Ledger}>) -> {State}:\n  match valid ledger:\n    case True{{}} Some{{ledger}}: {pre}_live(~client,S.metadata_live({F},metadata,U32.sub(id,1)),ledger,{values(("metadata","ledger"))},id)\n    case _ ledger: {fallback()}\n\n"""
 # metadata_live takes a zero-based physical index (checked from pinned storage API).
 pattern=state(values().replace('ns,','+ns,',1).replace('capacity,depth,high','+capacity,depth,+high').replace('mode,selected,undo','mode,_,undo'))
 block+=f"""def {pre}_step({header},handle:{Handle},state:{State}) -> {State}:\n  match handle state:\n    case S.Handle{{+space,+id}} {pattern}: {pre}_guard(~client,Bool.and(U32.is_eq(ns,space),Bool.and((0 < id : U32),Bool.and((id <= capacity : U32),(id <= high : U32)))),id,{values(("metadata","ledger")).replace("mode,selected,undo","mode,S.Handle{space,id},undo")},metadata,ledger)\n\n"""
 block+=f"""def {pre}_loop({header},handles:List<&2,{Handle}>,state:{State}) -> {State}:\n  match handles:\n    case Nil{{}}: state\n    case Con{{handle,rest}}: {pre}_loop(~client,rest,{pre}_step(~client,handle,state))\n\n"""
 block+=f"""def {pre}({header},handles:List<&2,{Handle}>,owner:{Tx},total:U32) -> {Tx} & U32:\n  {pre}_finish({pre}_loop(~client,handles,{pre}_pack(owner,total)))\n\n"""
 # Existing single-row APIs exercise this same private family in unchanged actual controls.
 begin=text.index('def '+lane+'_row(');end=text.find('\ndef ',begin+1);end=len(text) if end<0 else end;head=text[begin:text.index('\n',begin)]
 new=head+'\n  match owner:\n    case X.Tx{world,+selected,undo,commands,pings,marks}: '+pre+'(~client,selected <> [],X.Tx{world,selected,undo,commands,pings,marks},0)\n'
 text=text[:begin]+new+text[end:]
insert=text.index('def motion_get(');p.write_text(text[:insert]+block+text[insert:])
q=OUT/'experiments/s-integrate/measurement-bend.bend';oldq=q.read_text();newq=oldq
for lane in ('motion','health'):
 at=newq.index('def '+lane+'_rows(');end=newq.index('\ndef ',at+1);head=newq[at:newq.index('\n',at)];kind=lane.title()+'Rows';replacement=head+'\n  match state:\n    case '+kind+'{owner,total}: '+lane+'_rows_next(HA.prototype_writefold_'+lane+'(~SC.'+lane+'_body,handles,owner,total),0)\n';newq=newq[:at]+replacement+newq[end:]
q.write_text(newq)
for path,a,b in [(p,old,p.read_text()),(q,oldq,newq)]:
 relative=str(path.relative_to(OUT));(H/(path.stem+'.patch')).write_text(''.join(difflib.unified_diff(a.splitlines(True),b.splitlines(True),fromfile='a/'+relative,tofile='b/'+relative)))
pins={str(x.relative_to(OUT)):hashlib.sha256(x.read_bytes()).hexdigest() for x in OUT.rglob('*.bend')};cache=json.loads((OUT/'cache-specialization.json').read_text());cache['runtimeClosure']=pins;cache['specializedClosure']=pins;cache['runtimeClosureSHA256']=hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest();overlay=json.loads((OUT/'overlay.json').read_text());overlay['sources']=pins;overlay['cacheSpecialization']=cache
(OUT/'cache-specialization.json').write_text(json.dumps(cache,indent=2)+'\n');(OUT/'overlay.json').write_text(json.dumps(overlay,indent=2)+'\n');(H/'input-pins.json').write_text((BASE/'overlay.json').read_text());print(OUT)
