"""Independent finite inputs/oracles for actual generic affine query handoff."""
SCENARIOS=['mixed','all','missing','dead','empty','partial','high-over-cap','cap-low','cap-zero','ledger-none']
SELECTIONS=['Required','Present','Absent','Optional']
def runtime(schema,kind):
 M='Owned' if kind=='owned' else 'Array<U32>';Schema='T.'+schema+'Schema';W=f'S.World<{Schema},{M},Array<U32>,U32,Array<U32>,U32>';Row=f'Q.PrototypeHandoffRows<{Schema},{M}>';Batch=f'Q.PrototypeHandoffBatch<{Schema},{M},Array<U32>,U32,Array<U32>,U32>';base=1000 if schema=='Motion' else 9000
 s='''import Base
import ./types.bend as T
import ./storage.bend as S
import ./query.bend as Q

type Owned is Type:
  Owned{raw:Array<U32>,cache:U32,marker:U32}
def filled(fuel:Nat,+i:U32,+seed:U32,owner:Array<U32>) -> Array<U32>:
  match fuel:
    case Zero{}: owner
    case Succ{rest}: filled(rest,(i + 1 : U32),seed,Array.set(U32,owner,i,(seed + i : U32)))
def cells(+depth:Nat,seed:U32) -> Array<U32>:
  filled(U32.to_nat(U32.pow(2,depth)),0,seed,[0:U32^depth])
def data_list(~A:Type,~render:A -> String,values:List<&1,A>) -> String:
  match values:
    case Nil{}: ""
    case Con{value,rest}: render(value) ++ "," ++ data_list(~A,~render,rest)
def data_ids(values:List<&2,U32>) -> String:
  match values:
    case Nil{}: ""
    case Con{value,rest}: U32.show(value) ++ "," ++ data_ids(rest)
def raw_final(raw:Array<U32>) -> String: "[" ++ data_list(~U32,~U32.show,Array.to_list(~U32,raw)) ++ "]"
def read_next(next:Array<U32> -> String -> Array<U32> & String,text:String,result:Array<U32> & U32) -> Array<U32> & String:
  match result:
    case Tuple{owner,value}: next(owner,text ++ U32.show(value) ++ ",")
def raw_view(fuel:Nat,+i:U32,text:String,owner:Array<U32>) -> Array<U32> & String:
  match fuel:
    case Zero{}: (owner,"[" ++ text ++ "]")
    case Succ{rest}: read_next(a => t => raw_view(rest,(i + 1 : U32),t,a),text,Array.get(U32,owner,i))
'''
 if kind=='owned':s+=f'''def make_main(depth:Nat,+id:U32) -> Owned: Owned{{cells(depth,({base} + (id * 100 : U32) : U32)),(70000 + id : U32),(80000 + id : U32)}}
def main_final(value:Owned) -> String:
  match value:
    case Owned{{raw,cache,marker}}: raw_final(raw) ++ ":" ++ U32.show(cache) ++ ":" ++ U32.show(marker)
def main_view_done(cache:U32,marker:U32,result:Array<U32> & String) -> Owned & String:
  match result:
    case Tuple{{raw,text}}: (Owned{{raw,cache,marker}},text)
def main_view(+depth:Nat,value:Owned) -> Owned & String:
  match value:
    case Owned{{raw,cache,marker}}: main_view_done(cache,marker,raw_view(U32.to_nat(U32.pow(2,depth)),0,"",raw))
'''.replace('cache:U32,marker:U32,result','+cache:U32,+marker:U32,result').replace('(Owned{raw,cache,marker},text)','(Owned{raw,cache,marker},text ++ ":" ++ U32.show(cache) ++ ":" ++ U32.show(marker))')
 else:s+=f'''def make_main(depth:Nat,id:U32) -> Array<U32>: cells(depth,({base} + (id * 100 : U32) : U32))
def main_final(value:Array<U32>) -> String: raw_final(value)
def main_view(+depth:Nat,value:Array<U32>) -> Array<U32> & String: raw_view(U32.to_nat(U32.pow(2,depth)),0,"",value)
'''
 s+=f'''def optional_main(value:Maybe<{M}>) -> String:
  match value:
    case None{{}}: "none"
    case Some{{value}}: main_final(value)
def optional_array(value:Maybe<Array<U32>>) -> String:
  match value:
    case None{{}}: "none"
    case Some{{value}}: raw_final(value)
def optional_flag(value:Maybe<&2,U32>) -> String:
  match value:
    case None{{}}: "none"
    case Some{{value}}: U32.show(value)
def is_main(+case_id:U32,+id:U32) -> Bool: Bool.and(Bool.not(U32.is_eq(case_id,2)),Bool.or(U32.is_eq(case_id,1),Bool.not(U32.is_eq(U32.mod(id,3),2))))
def is_live(+case_id:U32,+id:U32) -> Bool: Bool.and(Bool.not(U32.is_eq(case_id,3)),Bool.or(U32.is_eq(case_id,1),Bool.not(U32.is_eq(U32.mod(id,4),2))))
def maybe_main(present:Bool,depth:Nat,id:U32) -> Maybe<{M}>:
  match present:
    case True{{}}: Some{{make_main(depth,id)}}
    case False{{}}: None{{}}
def maybe_aux(present:Bool,depth:Nat,id:U32) -> Maybe<Array<U32>>:
  match present:
    case True{{}}: Some{{cells(depth,(50000 + (id * 100 : U32) : U32))}}
    case False{{}}: None{{}}
def maybe_flag(present:Bool,id:U32) -> Maybe<&2,U32>:
  match present:
    case True{{}}: Some{{(id * 7 : U32)}}
    case False{{}}: None{{}}
def mains(fuel:Nat,+i:U32,+depth:Nat,+case_id:U32,columns:Array<Maybe<{M}>>) -> Array<Maybe<{M}>>:
  match fuel:
    case Zero{{}}: columns
    case Succ{{rest}}: mains(rest,(i + 1 : U32),depth,case_id,Array.set(Maybe<{M}>,columns,i,maybe_main(is_main(case_id,(i + 1 : U32)),depth,(i + 1 : U32))))
def auxs(fuel:Nat,+i:U32,+depth:Nat,columns:Array<Maybe<Array<U32>>>) -> Array<Maybe<Array<U32>>>:
  match fuel:
    case Zero{{}}: columns
    case Succ{{rest}}: auxs(rest,(i + 1 : U32),depth,Array.set(Maybe<Array<U32>>,columns,i,maybe_aux(U32.is_eq(U32.mod(i,2),0),depth,(i + 1 : U32))))
def metadata(fuel:Nat,+i:U32,+case_id:U32,live:Array<Bool>,flags:Array<Maybe<&2,U32>>,added:Array<U32>,changed:Array<U32>) -> S.MetadataColumns<U32>:
  match fuel:
    case Zero{{}}: S.MetadataColumns{{live,flags,added,changed}}
    case Succ{{rest}}: metadata(rest,(i + 1 : U32),case_id,Array.set(Bool,live,i,is_live(case_id,(i + 1 : U32))),Array.set(Maybe<&2,U32>,flags,i,maybe_flag(U32.is_eq(U32.mod(i,2),1),(i + 1 : U32))),Array.set(U32,added,i,(21 + i : U32)),Array.set(U32,changed,i,(41 + i : U32)))
def cap(+n:U32,case_id:U32) -> U32:
  match case_id:
    case 7: U32.max(1,U32.div(n,2))
    case 8: 0
    case _: n
def high(+n:U32,case_id:U32) -> U32:
  match case_id:
    case 4: 0
    case 5: U32.max(1,U32.div(n,2))
    case 6: (n + 3 : U32)
    case 7: (n + 2 : U32)
    case 8: (n + 1 : U32)
    case _: n
def ledger(case_id:U32,depth:Nat) -> Maybe<Array<U32>>:
  match case_id:
    case 9: None{{}}
    case _: Some{{cells(depth,91000)}}
def make_world(+depth:Nat,+case_id:U32) -> {W}:
  S.World{{7,(U32.pow(2,depth) + 99 : U32),S.Rows{{mains(U32.to_nat(U32.pow(2,depth)),0,depth,case_id,S.slots_empty({M},depth)),auxs(U32.to_nat(U32.pow(2,depth)),0,depth,S.slots_empty(Array<U32>,depth)),metadata(U32.to_nat(U32.pow(2,depth)),0,case_id,[False{{}}:Bool^depth],[None{{}}:Maybe<&2,U32>^depth],[0:U32^depth],[0:U32^depth]),cap(U32.pow(2,depth),case_id),depth,high(U32.pow(2,depth),case_id)}},[S.RemoveMain{{9}},S.RemoveFlag{{8}},S.InsertFlag{{7,77}}],ledger(case_id,depth),555}}
def pending(command:S.Command<{M},Array<U32>,U32>) -> String:
  match command:
    case S.RemoveMain{{id}}: "rm:" ++ U32.show(id)
    case S.RemoveFlag{{id}}: "rf:" ++ U32.show(id)
    case S.InsertFlag{{id,value}}: "if:" ++ U32.show(id) ++ ":" ++ U32.show(value)
    case _: "unexpected"
def final_world(world:{W}) -> String:
  match world:
    case S.World{{namespace,next,S.Rows{{main,aux,S.MetadataColumns{{live,flags,added,changed}},capacity,depth,high}},queue,resource,mode}}:
      U32.show(namespace) ++ ":" ++ U32.show(next) ++ ":" ++ U32.show(capacity) ++ ":" ++ Nat.show(depth) ++ ":" ++ U32.show(high) ++ ":" ++ U32.show(mode) ++ "/M=" ++ data_list(~Maybe<{M}>,~optional_main,Array.to_list(~Maybe<{M}>,main)) ++ "/A=" ++ data_list(~Maybe<Array<U32>>,~optional_array,Array.to_list(~Maybe<Array<U32>>,aux)) ++ "/L=" ++ data_list(~Bool,~Bool.show,Array.to_list(~Bool,live)) ++ "/F=" ++ data_list(~Maybe<&2,U32>,~optional_flag,Array.to_list(~Maybe<&2,U32>,flags)) ++ "/AD=" ++ data_list(~U32,~U32.show,Array.to_list(~U32,added)) ++ "/CH=" ++ data_list(~U32,~U32.show,Array.to_list(~U32,changed)) ++ "/Q=" ++ data_list(~S.Command<{M},Array<U32>,U32>,~pending,queue) ++ "/R=" ++ optional_array(resource)
def main_col_owner(+i:U32,next:Array<Maybe<{M}>> -> String -> Array<Maybe<{M}>> & String,text:String,columns:Array<Maybe<{M}>>,pair:{M} & String) -> Array<Maybe<{M}>> & String:
  match pair:
    case Tuple{{owner,view}}: next(Array.set(Maybe<{M}>,columns,i,Some{{owner}}),text ++ view ++ ",")
def main_col_next(+i:U32,rest:Nat,next:Array<Maybe<{M}>> -> String -> Array<Maybe<{M}>> & String,text:String,pair:Array<Maybe<{M}>> & Maybe<{M}>) -> Array<Maybe<{M}>> & String:
  match pair:
    case Tuple{{columns,None{{}}}}: next(columns,text ++ "none,")
    case Tuple{{columns,Some{{owner}}}}: main_col_owner(i,next,text,columns,main_view(rest,owner))
def main_cols(fuel:Nat,+i:U32,+depth:Nat,text:String,columns:Array<Maybe<{M}>>) -> Array<Maybe<{M}>> & String:
  match fuel:
    case Zero{{}}: (columns,text)
    case Succ{{rest}}: main_col_next(i,depth,cols => t => main_cols(rest,(i + 1 : U32),depth,t,cols),text,Array.swap(Maybe<{M}>,columns,i,None{{}}))
def holes_return(namespace:U32,next:U32,aux:Array<Maybe<Array<U32>>>,metadata:S.MetadataColumns<U32>,capacity:U32,depth:Nat,high:U32,queue:List<S.Command<{M},Array<U32>,U32>>,resource:Maybe<Array<U32>>,mode:U32,pair:Array<Maybe<{M}>> & String) -> {W} & String:
  match pair:
    case Tuple{{main,text}}: (S.World{{namespace,next,S.Rows{{main,aux,metadata,capacity,depth,high}},queue,resource,mode}},text)
def holes_view(world:{W}) -> {W} & String:
  match world:
    case S.World{{namespace,next,S.Rows{{main,aux,metadata,+capacity,+depth,high}},queue,resource,mode}}: holes_return(namespace,next,aux,metadata,capacity,depth,high,queue,resource,mode,main_cols(U32.to_nat(U32.pow(2,depth)),0,depth,"",main))
def rows_reverse(rows:{Row},acc:{Row}) -> {Row}:
  match rows:
    case Q.HandoffNil{{}}: acc
    case Q.HandoffCon{{id,owner,rest}}: rows_reverse(rest,Q.HandoffCon{{id,owner,acc}})
def rows_next(+id:U32,next:{Row} -> String -> {Row} & String,seen:{Row},text:String,pair:{M} & String) -> {Row} & String:
  match pair:
    case Tuple{{owner,view}}: next(Q.HandoffCon{{id,owner,seen}},text ++ U32.show(id) ++ ":" ++ view ++ ";")
def rows_view(fuel:{Row},+depth:Nat,seen:{Row},text:String) -> {Row} & String:
  match fuel:
    case Q.HandoffNil{{}}: (rows_reverse(seen,Q.HandoffNil{{}}),text)
    case Q.HandoffCon{{id,owner,rest}}: rows_next(id,owners => t => rows_view(rest,depth,owners,t),seen,text,main_view(depth,owner))
def recovered_done(before:String,+old_ids:List<&2,U32>,+taken:String,holes:String,namespace:U32,next:U32,aux:Array<Maybe<Array<U32>>>,metadata:S.MetadataColumns<U32>,capacity:U32,depth:Nat,high:U32,queue:List<S.Command<{M},Array<U32>,U32>>,resource:Maybe<Array<U32>>,mode:U32,result:Array<Maybe<{M}>> & List<&2,U32>) -> String:
  match result:
    case Tuple{{main,+ids}}: data_ids(old_ids) ++ "|" ++ taken ++ "|" ++ data_ids(ids) ++ "|" ++ before ++ "|" ++ holes ++ "|" ++ final_world(S.World{{namespace,next,S.Rows{{main,aux,metadata,capacity,depth,high}},queue,resource,mode}}) ++ "|" ++ taken

def recover_world(before:String,old_ids:List<&2,U32>,taken:String,holes:String,world:{W},rows:{Row}) -> String:
  match world:
    case S.World{{namespace,next,S.Rows{{main,aux,metadata,capacity,depth,high}},queue,resource,mode}}: recovered_done(before,old_ids,taken,holes,namespace,next,aux,metadata,capacity,depth,high,queue,resource,mode,Q.prototype_handoff_recover({Schema},{M},rows,main))
def holes_taken(before:String,old_ids:List<&2,U32>,taken:String,rows:{Row},pair:{W} & String) -> String:
  match pair:
    case Tuple{{world,holes}}: recover_world(before,old_ids,taken,holes,world,rows)
def taken_rows(before:String,old_ids:List<&2,U32>,world:{W},pair:{Row} & String) -> String:
  match pair:
    case Tuple{{rows,taken}}: holes_taken(before,old_ids,taken,rows,holes_view(world))
def taken_batch(before:String,old_ids:List<&2,U32>,+depth:Nat,batch:{Batch}) -> String:
  match batch:
    case Q.PrototypeHandoffBatch{{world,rows}}: taken_rows(before,old_ids,world,rows_view(rows,depth,Q.HandoffNil{{}},""))
def cursor_done(before:String,+depth:Nat,selection:Q.Selection,result:{W} & List<&2,U32>) -> String:
  match result:
    case Tuple{{world,ids}}: taken_batch(before,ids,depth,Q.prototype_handoff_each(~{Schema},~{M},~Array<U32>,~U32,~Array<U32>,~U32,selection,world))
def selection(value:U32) -> Q.Selection:
  match value:
    case 1: Q.Present{{}}
    case 2: Q.Absent{{}}
    case 3: Q.Optional{{}}
    case _: Q.Required{{}}
def one(+depth:Nat,+case_id:U32,+sel:U32) -> String:
  U32.show(sel) ++ "|" ++ cursor_done(final_world(make_world(depth,case_id)),depth,selection(sel),Q.prototype_cursor_ids(~{Schema},~{M},~Array<U32>,~U32,~Array<U32>,~U32,selection(sel),make_world(depth,case_id)))
def selections(fuel:Nat,+sel:U32,+depth:Nat,+case_id:U32) -> IO(Unit):
  match fuel:
    case Zero{{}}: IO.pure(Unit,Unit{{}})
    case Succ{{rest}}:
      do IO<Unit>:
        IO.print(Nat.show(depth) ++ "|" ++ U32.show(case_id) ++ "|" ++ one(depth,case_id,sel))
        selections(rest,(sel + 1 : U32),depth,case_id)
def cases(fuel:Nat,+case_id:U32,+depth:Nat) -> IO(Unit):
  match fuel:
    case Zero{{}}: IO.pure(Unit,Unit{{}})
    case Succ{{rest}}:
      do IO<Unit>:
        selections(4n,0,depth,case_id)
        cases(rest,(case_id + 1 : U32),depth)
def depths(fuel:Nat,+depth:Nat) -> IO(Unit):
  match fuel:
    case Zero{{}}: IO.pure(Unit,Unit{{}})
    case Succ{{rest}}:
      do IO<Unit>:
        cases(10n,0,depth)
        depths(rest,1n+depth)
def main() -> IO(Unit): depths(5n,0n)
'''
 return s

def oracle(schema,kind):
 base=1000 if schema=='Motion' else 9000;lines=[]
 for d in range(5):
  n=2**d
  for ci,c in enumerate(SCENARIOS):
   cap=max(1,n//2) if ci==7 else 0 if ci==8 else n
   high=0 if ci==4 else max(1,n//2) if ci==5 else n+3 if ci==6 else n+2 if ci==7 else n+1 if ci==8 else n
   main=[None if ci==2 or not(ci==1 or i%3!=2) else '['+''.join(str(base+i*100+j)+','for j in range(n))+']'+(':'+str(70000+i)+':'+str(80000+i) if kind=='owned' else '')for i in range(1,n+1)]
   aux=[ '['+''.join(str(50000+i*100+j)+','for j in range(n))+']' if i%2 else 'none' for i in range(1,n+1)]
   live=[ci!=3 and (ci==1 or i%4!=2)for i in range(1,n+1)];flags=[i*7 if i%2==0 else None for i in range(1,n+1)]
   listing=lambda xs:''.join(('none' if x is None else str(x))+','for x in xs)
   world=f'7:{n+99}:{cap}:{d}:{high}:555/M='+listing(main)+'/A='+listing(aux)+'/L='+listing(['True'if x else'False'for x in live])+'/F='+listing(flags)+'/AD='+listing(list(range(21,21+n)))+'/CH='+listing(list(range(41,41+n)))+'/Q=rm:9,rf:8,if:7:77,/R='+('none'if ci==9 else '['+''.join(str(91000+j)+','for j in range(n))+']')
   for si,sel in enumerate(SELECTIONS):
    ids=[i for i in range(1,min(high,cap,n)+1)if live[i-1] and main[i-1] is not None and (sel!='Present' or flags[i-1] is not None) and (sel!='Absent' or flags[i-1] is None)]
    idtext=''.join(str(i)+','for i in ids);taken=''.join(str(i)+':'+main[i-1]+';'for i in ids);holes=listing([None if i in ids else main[i-1]for i in range(1,n+1)])
    lines.append(f'{d}|{ci}|{si}|{idtext}|{taken}|{idtext}|{world}|{holes}|{world}|{taken}')
 return '\n'.join(lines)+'\n'

def negative(kind):
 W='Q.PrototypeHandoffBatch<T.MotionSchema,Array<U32>,Array<U32>,U32,Array<U32>,U32>'
 head='import Base\nimport ./types.bend as T\nimport ./storage.bend as S\nimport ./query.bend as Q\n'
 if kind=='clone':return head+f'def clone(batch:{W}) -> {W} & {W}: (batch,batch)\ndef main() -> IO(Unit): IO.pure(Unit,Unit{{}})\n'
 return head+'def wrong(rows:Q.PrototypeHandoffRows<T.MotionSchema,Array<U32>>,columns:Array<Maybe<Array<U32>>>) -> Array<Maybe<Array<U32>>> & List<&2,U32>:\n  Q.prototype_handoff_recover(T.HealthSchema,Array<U32>,rows,columns)\ndef main() -> IO(Unit): IO.pure(Unit,Unit{})\n'
