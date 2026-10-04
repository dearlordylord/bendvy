"""Actual direct-world owner checkpoints; Lifecycle does not construct active Tx owners."""
from pathlib import Path

def prepare(dest):
 dest=Path(dest);o=dest/'occupancy.bend';text=o.read_text().replace('X.Tx{world,selected,undo,commands,pings,marks}', 'X.Tx{world,selected,undo,commands,pings,marks,meter}');text=text.replace('+marks: List<&2,Handle>,result:', '+marks: List<&2,Handle>,meter: String,result:').replace('world,selected,undo,pings,marks,owned_length(', 'world,selected,undo,pings,marks,meter,owned_length(');o.write_text(text)
 p=dest/'measurement-lifecycle.bend';t=p.read_text().replace('import Base\n','import Base\nimport ./occupancy.bend as OCC\n',1)
 for low,schema,main,aux,flag,ledger,mode in [('motion','Motion','Position','Velocity','Selected','MotionLedger','MotionMode'),('health','Health','Vitals','Armor','Tracked','HealthLedger','HealthMode')]:
  world=f'S.World<T.{schema}Schema,T.{main},T.{aux},T.{flag},T.{ledger},T.{mode}>';state=f'{schema}State';invoked=f'D.Invoked<{state},S.Handle<T.{schema}Schema>>'
  helper=f'''def {low}_meter_pair(+count: U32,+i: U32,target: Maybe<&2,S.Handle<T.{schema}Schema>>,pending: Maybe<&2,S.Handle<T.{schema}Schema>>,foreign: S.Handle<T.{schema}Schema>,restore: {world} -> H.{schema}Host(),phase: String,pair: {world} & OCC.WorldStats) -> IO({state}):
  match pair:
    case (world,stats): IO.bind(Unit,{state},IO.print("lifediag:{schema}:" ++ U32.show(count) ++ ":" ++ U32.show(i) ++ ":" ++ phase ++ ":owner=World:" ++ OCC.format_world(stats)),_ => IO.pure({state},{state}{{restore(world),count,i,target,pending,foreign}}))
def {low}_meter(phase: String,state: {state}) -> IO({state}):
  match state:
    case {state}{{H.Host{{world,logs,bindings,name,step,prior,events}},count,i,target,pending,foreign}}: {low}_meter_pair(count,i,target,pending,foreign,w => H.Host{{w,logs,bindings,name,step,prior,events}},phase,OCC.inspect_world(T.{schema}Schema,T.{main},T.{aux},T.{flag},T.{ledger},T.{mode},world))
'''
  at=t.index('def '+low+'_barrier(');t=t[:at]+helper+t[at:];t=t.replace('def '+low+'_invoke(', 'def '+low+'_invoke_original(',1)
  at=t.index('def '+low+'_tick(')
  wrapper=f'''def {low}_meter_invoked(result: {invoked}) -> IO({invoked}):
  match result:
    case D.Invoked{{state,audit,run,outcome,clock,escaped,observations}}: IO.bind({state},{invoked},{low}_meter("after-system",state),s => IO.pure({invoked},D.Invoked{{s,audit,run,outcome,clock,escaped,observations}}))
def {low}_invoke(system: K.System,mode: K.Mode,capture: U32,clock: R.Clock,state: {state},audit: Maybe<D.Audit>,run: Maybe<R.Run>) -> IO({invoked}):
  IO.bind({state},{invoked},{low}_meter("before-system",state),s => IO.bind({invoked},{invoked},{low}_invoke_original(system,mode,capture,clock,s,audit,run),{low}_meter_invoked))
'''
  t=t[:at]+wrapper+t[at:]
  # Barrier callbacks are already actual IO at the indexed seam.
  t=t.replace('def '+low+'_barrier(', 'def '+low+'_barrier_original(',1)
  at=t.index('def '+low+'_transition(')
  wrapper=f'''def {low}_meter_barrier_done(pair: {state} & R.Clock) -> IO({state} & R.Clock):
  match pair:
    case (state,clock): IO.bind({state},{state} & R.Clock,{low}_meter("after-barrier",state),s => IO.pure({state} & R.Clock,(s,clock)))
def {low}_barrier(state: {state},clock: R.Clock) -> IO({state} & R.Clock):
  IO.bind({state},{state} & R.Clock,{low}_meter("before-barrier",state),s => IO.bind({state} & R.Clock,{state} & R.Clock,{low}_barrier_original(s,clock),{low}_meter_barrier_done))
'''
  t=t[:at]+wrapper+t[at:]
 p.write_text(t)
