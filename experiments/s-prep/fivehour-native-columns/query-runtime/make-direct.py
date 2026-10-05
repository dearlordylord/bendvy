#!/usr/bin/env python3
"""Smaller direct full-field query/owner control; actual workload matrix stays intact."""
from pathlib import Path
import re
H=Path(__file__).resolve().parent
imports='import Base\n'+''.join('import ./'+p+'.bend as '+alias+'\n' for p,alias in [('types','T'),('cache','CC'),('cached-payload','CP'),('storage','S'),('query','Q'),('observations','O'),('host-render','JSON'),('original-raw-observer','RP')])
full=(H/'query-workload.bend').read_text();blocks={m[1]:m[0] for m in re.finditer(r'^def (\w+)[\s\S]*?(?=^(?:def|type|import) |\Z)',full,re.M)}
s=imports+blocks['raw_done']+blocks['raw_get']+'''def quad(+n:U32) -> Array<U32>:
  Array.set(U32,Array.set(U32,Array.set(U32,[n:U32^2n],1,U32.add(n,1)),2,U32.add(n,2)),3,U32.add(n,3))
'''
for schema,main,aux,flag,token,ledger,mode,render,avrender in [('Motion','Position','Velocity','Selected','PositionToken','MotionLedger','MotionMode','position','velocity'),('Health','Vitals','Armor','Tracked','VitalsToken','HealthLedger','HealthMode','vitals','armor')]:
 low=schema.lower();mainlow=main.lower();mv='T.'+main+'View';av='T.'+aux+'View';lv='T.LedgerView';cm=f'CC.Cache<T.{main},{mv}>';cl=f'CC.Cache<T.{ledger},{lv}>';w=f'S.World<T.{schema}Schema,{cm},T.{aux},T.{flag},{cl},T.{mode}>';view=f'O.WorldView<{mv},{av},T.{flag},{lv},T.{mode}>';qr=f'O.QueryRow<T.{schema}Schema,{mv},{av},T.{flag}>';mainfields='7' if schema=='Motion' else '9,2';auxfields='True{}' if schema=='Motion' else '3';ledgerlow=low+'_ledger'
 s+=blocks[low+'_raw']+blocks[low+'_ledger_raw']+blocks[low+'_world']
 def rw(v):return f'JSON.render_world({mv},{av},T.{flag},JSON.render_{render},JSON.render_{avrender},JSON.render_{flag.lower()},{lv},T.{mode},JSON.render_ledger,JSON.render_{low}_mode,{v})'
 s+=f'''def {low}_emit(old1:U32,old2:U32,before:{view},queries:List<&2,{qr}>,result:{w} & {view}) -> IO(Unit):
  match result:
    case (_,after): IO.print("{{\\"schema\\":\\"{schema}\\",\\"old0\\":[" ++ U32.show(old1) ++ "," ++ U32.show(old2) ++ "],\\"world\\":" ++ {rw('before')} ++ ",\\"query\\":" ++ JSON.render_list({qr},JSON.render_query(~T.{schema}Schema,~{mv},~{av},~T.{flag},~JSON.render_{render},~JSON.render_{avrender},~JSON.render_{flag.lower()}),queries) ++ ",\\"afterQuery\\":" ++ {rw('after')} ++ "}}")
def {low}_queried(old1:U32,old2:U32,before:{view},result:{w} & List<&2,{qr}>) -> IO(Unit):
  match result:
    case (world,values): {low}_emit(old1,old2,before,values,{low}_world(world))
def {low}_observed(old1:U32,old2:U32,result:{w} & {view}) -> IO(Unit):
  match result:
    case (world,before): {low}_queried(old1,old2,before,Q.each(T.{schema}Schema,{cm},T.{aux},T.{flag},T.{token},{mv},{av},{qr},{cl},T.{mode},{low}_raw,RP.{aux.lower()}_get,O.client(~T.{schema}Schema,~T.{token},~{mv},~{av},~T.{flag},~T.{token}{{}}),Q.Optional{{}},world))
def {low}_written(result:({cm} & U32) & ({cm} & U32)) -> IO(Unit):
  match result:
    case ((one,old1),(two,old2)): {low}_observed(old1,old2,{low}_world(S.World{{7,3,S.Rows{{ANode{{ALeaf{{Some{{one}}}},ALeaf{{Some{{two}}}}}},ANode{{ALeaf{{Some{{T.{aux}{{quad(110),{auxfields}}}}}}},ALeaf{{Some{{T.{aux}{{quad(190),{auxfields}}}}}}}}},ANode{{ALeaf{{S.Metadata{{True{{}},Some{{T.{flag}{{8}}}},3,4}}}},ALeaf{{S.Metadata{{True{{}},None{{}},5,6}}}}}},2,1n,2}},[],Some{{CP.{ledgerlow}_new(T.{ledger}{{quad(100),4}})}},T.{schema}On{{}}}}))
def {low}_one() -> IO(Unit):
  {low}_written((CP.{mainlow}_swap(CP.{mainlow}_new(T.{main}{{quad(10),{mainfields}}}),17),CP.{mainlow}_swap(CP.{mainlow}_new(T.{main}{{quad(900),{mainfields}}}),901)))
'''
s+='''def main() -> IO(Unit):
  do IO<Unit>:
    motion_one()
    health_one()
'''
(H/'direct-query.bend').write_text(s)
