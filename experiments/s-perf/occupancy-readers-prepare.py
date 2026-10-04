#!/usr/bin/env python3
"""Add diagnostic IO snapshots to the unchanged Readers64 operation sequence."""
from pathlib import Path

def enddef(text,name):
 start=text.index('def '+name+'(');end=text.find('\ndef ',start+1)
 return start,len(text) if end<0 else end

def prepare(entry):
 entry=Path(entry);text=entry.read_text();assert 'occupancy-runtime.bend' not in text
 text=text.replace('import Base\n','import Base\nimport ./occupancy-runtime.bend as OCC\n',1)
 text=text.replace('type Systems is Data:', 'def occupancy_system_name(system: K.System) -> String:\n  match system:\n    case K.System{_,name,_,_,_,_,_}: name\n\ntype Systems is Data:',1)
 for schema,ping in [('Motion','MotionPing'),('Health','HealthPing')]:
  low=schema.lower();state=f'L.{schema}State';handle=f'S.Handle<T.{schema}Schema>';runtime=f'D.Runtime<{state},{handle}>';invoked=f'D.Invoked<{state},{handle}>';pair=f'{state} & R.Clock';args=f'T.{schema}Schema,T.{ping},{state},"{schema}"'
  assert text.count('def '+low+'_invoke(')==1
  text=text.replace('def '+low+'_invoke(', 'def '+low+'_invoke_inner(',1)
  start,end=enddef(text,low+'_invoke_inner')
  wrapper=f'''

def {low}_occupancy_invoked(phase: String,result: {invoked}) -> IO({invoked}):
  match result:
    case D.Invoked{{state,audit,run,outcome,+clock,escaped,observations}}:
      do IO<{invoked}>:
        inspected : {state} <- OCC.inspect_state({args},phase,clock,state,OCC.inspect_{low})
        return D.Invoked{{inspected,audit,run,outcome,clock,escaped,observations}}
def {low}_invoke_owners(+system: K.System,mode: K.Mode,capture: U32,clock: R.Clock,audit: Maybe<D.Audit>,owners: {state} & Maybe<R.Run>) -> IO({invoked}):
  match owners:
    case (state,run): IO.bind({invoked},{invoked},{low}_invoke_inner(system,mode,capture,clock,state,audit,run),result => {low}_occupancy_invoked("after-system=" ++ occupancy_system_name(system),result))
def {low}_invoke_inspected(+system: K.System,mode: K.Mode,capture: U32,+clock: R.Clock,state: {state},audit: Maybe<D.Audit>,run: Maybe<R.Run>) -> IO({invoked}):
  do IO<{invoked}>:
    owners : {state} & Maybe<R.Run> <- OCC.inspect_state_run({args},"before-system=" ++ occupancy_system_name(system),clock,state,run,OCC.inspect_{low})
    {low}_invoke_owners(system,mode,capture,clock,audit,owners)
def {low}_invoke(system: K.System,mode: K.Mode,capture: U32,clock: R.Clock,state: {state},audit: Maybe<D.Audit>,run: Maybe<R.Run>) -> IO({invoked}):
  {low}_invoke_inspected(system,mode,capture,clock,state,audit,run)
def {low}_occupancy_barrier_done(result: {pair}) -> IO({pair}):
  match result:
    case (state,+clock):
      do IO<{pair}>:
        after : {state} <- OCC.inspect_state({args},"after-barrier",clock,state,OCC.inspect_{low})
        return (after,clock)
def {low}_occupancy_barrier_inspected(state: {state},+clock: R.Clock) -> IO({pair}):
  do IO<{pair}>:
    before : {state} <- OCC.inspect_state({args},"before-barrier",clock,state,OCC.inspect_{low})
    owners : {pair} <- L.{low}_barrier(before,clock)
    {low}_occupancy_barrier_done(owners)
def {low}_occupancy_barrier(state: {state},clock: R.Clock) -> IO({pair}):
  {low}_occupancy_barrier_inspected(state,clock)
'''
  text=text[:end]+wrapper+text[end:]
  text=text.replace('def '+low+'_tick(', 'def '+low+'_tick_inner(',1)
  start,end=enddef(text,low+'_tick_inner');body=text[start:end]
  assert body.count('L.'+low+'_barrier')==1
  body=body.replace('L.'+low+'_barrier',low+'_occupancy_barrier')
  wrapper=f'''

def {low}_tick(nodes: List<&2,K.Node>,runtime: {runtime}) -> IO({runtime}):
  do IO<{runtime}>:
    before : {runtime} <- OCC.inspect_runtime({args},"before-tick-before-frame",runtime,OCC.inspect_{low})
    after : {runtime} <- {low}_tick_inner(nodes,before)
    OCC.inspect_runtime({args},"after-tick-before-next-frame",after,OCC.inspect_{low})
'''
  text=text[:start]+body+wrapper+text[end:]
 entry.write_text(text)

if __name__=='__main__':
 import sys
 prepare(sys.argv[1])
