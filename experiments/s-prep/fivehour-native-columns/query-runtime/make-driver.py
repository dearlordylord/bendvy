#!/usr/bin/env python3
from pathlib import Path
H=Path(__file__).resolve().parent
imports='import Base\n'+''.join('import ./'+p+'.bend as '+alias+'\n' for p,alias in [('measurement-bend','M'),('raw-boundaries','RB'),('types','T'),('cache','CC'),('storage','S'),('identity','I'),('query','Q'),('observations','O'),('host','H'),('dispatcher','D'),('readers','R'),('schedule','K'),('host-render','JSON'),('original-raw-observer','RP')])
s=imports+'''\ndef raw_done(-Raw:Type,-View:Data,cached:View,result:Raw & View) -> CC.Cache<Raw,View> & View:
  match result:
    case (raw,view): (CC.Cache{raw,cached},view)
def raw_get(~Raw:Type,~View:Data,~get:Raw -> Raw & View,owner:CC.Cache<Raw,View>) -> CC.Cache<Raw,View> & View:
  match owner:
    case CC.Cache{raw,cached}: raw_done(Raw,View,cached,get(raw))
'''
for schema,main,aux,flag,token,ledger,mode,render,avrender,lrender in [('Motion','Position','Velocity','Selected','PositionToken','MotionLedger','MotionMode','position','velocity','ledger'),('Health','Vitals','Armor','Tracked','VitalsToken','HealthLedger','HealthMode','vitals','armor','ledger')]:
 low=schema.lower();mainlow=main.lower();auxlow=aux.lower();ledgerlow='motion_ledger' if schema=='Motion' else 'health_ledger';mv='T.'+main+'View';av='T.'+aux+'View';lv='T.LedgerView';cm='CC.Cache<T.'+main+','+mv+'>';cl='CC.Cache<T.'+ledger+','+lv+'>';w=f'S.World<T.{schema}Schema,{cm},T.{aux},T.{flag},{cl},T.{mode}>';view=f'O.WorldView<{mv},{av},T.{flag},{lv},T.{mode}>';qr=f'O.QueryRow<T.{schema}Schema,{mv},{av},T.{flag}>';runtime=f'D.Runtime<M.{schema}Bench,S.Handle<T.{schema}Schema>>'
 s+=f'''def {low}_raw(owner:{cm}) -> {cm} & {mv}:
  raw_get(~T.{main},~{mv},~RP.{mainlow}_get,owner)
def {low}_ledger_raw(owner:{cl}) -> {cl} & {lv}:
  raw_get(~T.{ledger},~{lv},~RP.{ledgerlow}_get,owner)
def {low}_world(owner:{w}) -> {w} & {view}:
  O.world(T.{schema}Schema,{cm},T.{aux},T.{flag},{cl},T.{mode},{mv},{av},{lv},{low}_raw,RP.{auxlow}_get,{low}_ledger_raw,owner)
def {low}_emit(total:U32,calls:U32,+clock:R.Clock,before:{view},queries:List<&2,{qr}>,result:{w} & {view}) -> IO(Unit):
  match result:
    case (_,after): IO.print("{{\\"readsum\\":" ++ U32.show(total) ++ ",\\"calls\\":" ++ U32.show(calls) ++ ",\\"tick\\":" ++ U32.show(D.clock_tick(clock)) ++ ",\\"frames\\":" ++ U32.show(M.clock_frame(clock)) ++ ",\\"world\\":" ++ JSON.render_world({mv},{av},T.{flag},JSON.render_{render},JSON.render_{avrender},JSON.render_{flag.lower()},{lv},T.{mode},JSON.render_{lrender},JSON.render_{low}_mode,before) ++ ",\\"query\\":" ++ JSON.render_list({qr},JSON.render_query(~T.{schema}Schema,~{mv},~{av},~T.{flag},~JSON.render_{render},~JSON.render_{avrender},~JSON.render_{flag.lower()}),queries) ++ ",\\"afterQuery\\":" ++ JSON.render_world({mv},{av},T.{flag},JSON.render_{render},JSON.render_{avrender},JSON.render_{flag.lower()},{lv},T.{mode},JSON.render_{lrender},JSON.render_{low}_mode,after) ++ "}}")
def {low}_queried(total:U32,calls:U32,clock:R.Clock,before:{view},result:{w} & List<&2,{qr}>) -> IO(Unit):
  match result:
    case (owner,queries): {low}_emit(total,calls,clock,before,queries,{low}_world(owner))
def {low}_observed(total:U32,calls:U32,clock:R.Clock,result:{w} & {view}) -> IO(Unit):
  match result:
    case (owner,before): {low}_queried(total,calls,clock,before,Q.each(T.{schema}Schema,{cm},T.{aux},T.{flag},T.{token},{mv},{av},{qr},{cl},T.{mode},{low}_raw,RP.{auxlow}_get,O.client(~T.{schema}Schema,~T.{token},~{mv},~{av},~T.{flag},~T.{token}{{}}),Q.Optional{{}},owner))
def {low}_dump(state:{runtime}) -> IO(Unit):
  match state:
    case D.Runtime{{M.{schema}Bench{{H.Host{{world,_,_,_,_,_,_}},_,total,calls}},_,_,clock,_,_,_,_,_}}: {low}_observed(total,calls,clock,{low}_world(world))
def {low}_run(result:{runtime} & K.System) -> IO(Unit):
  match result:
    case (state,system): IO.bind({runtime},Unit,M.{low}_loops(64n,system,state),{low}_dump)
def {low}_start(count:U32,sparse:Bool) -> IO(Unit):
  IO.bind({runtime} & K.System,Unit,M.{low}_created(count,sparse,RB.{low}_create(M.{low}_ledger,I.factory(),T.{schema}On{{}})),{low}_run)
'''
s+='''def choose(schema:U32,sparse:U32,count:U32) -> IO(Unit):
  match schema:
    case 0: motion_start(count,U32.is_eq(sparse,1))
    case 1: health_start(count,U32.is_eq(sparse,1))
    case _: IO.die(Unit,2,"schema")
def parsed(schema:Maybe<&2,U32>,sparse:Maybe<&2,U32>,count:Maybe<&2,U32>) -> IO(Unit):
  match schema sparse count:
    case Some{schema} Some{sparse} Some{count}: choose(schema,sparse,count)
    case _ _ _: IO.die(Unit,2,"args")
def args(values:List<String>) -> IO(Unit):
  match values:
    case Con{_,Con{schema,Con{sparse,Con{count,_}}}}: parsed(U32.read(schema),U32.read(sparse),U32.read(count))
    case _: IO.die(Unit,2,"args")
def main() -> IO(Unit):
  do IO<Unit>:
    values : List<String> <- IO.args()
    args(values)
'''
(H/'query-workload.bend').write_text(s)
