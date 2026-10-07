"""Exact staged-only integration seams; original consumer and core stay unchanged."""
from pathlib import Path
HERE=Path(__file__).resolve().parent

def stage(contents):
 contents=dict(contents)
 stream=(HERE/'stream.bend').read_text()
 for old,new in [('import ../../machine.bend as M','import ./machine.bend as M'),('import ../../../../src/ecs/event-runtime.bend as Ev','import ../../src/ecs/event-runtime.bend as Ev')]:
  assert stream.count(old)==1;stream=stream.replace(old,new)
 stream_name='experiments/public-machines/stream.bend';observer_name='experiments/public-machines/observe.bend';queue_name='experiments/public-machines/queue.bend'
 assert queue_name not in contents
 contents[stream_name]=stream.encode();contents[queue_name]=(HERE/'queue.bend').read_bytes()
 old=contents[observer_name].decode()
 start='def stream(~V: Data,~show: V -> String,value: St.Stream<V>) -> String:\n  match value:\n    case St.Stream{batches,positions,dropped,frameStart}:'
 assert old.count(start)==1
 replacement='def stream_snapshot(~V: Data,~show: V -> String,value: List<&2,Ev.Batch<M.Transition<V>>> & (List<&2,Ev.Position> & (Nat & Nat))) -> String:\n  match value:\n    case (batches,(positions,(dropped,frameStart))):'
 observed=old.replace(start,replacement)
 anchor='\ndef entry(';assert observed.count(anchor)==1
 observed=observed.replace(anchor,'\ndef stream(~V: Data,~show: V -> String,value: St.Stream<V>) -> String:\n  stream_snapshot(~V,~show,St.snapshot(~V,value))\n'+anchor)
 anchor='import stream.bend as St';assert observed.count(anchor)==1
 observed=observed.replace(anchor,anchor+'\nimport format.bend as Fmt')
 old_render='List.show(&2,Ev.Batch<M.Transition<V>>,value => batch(~V,~show,value),batches)'
 assert observed.count(old_render)==1
 observed=observed.replace(old_render,'Fmt.show(~Ev.Batch<M.Transition<V>>,~(value => batch(~V,~show,value)),batches)')
 contents[observer_name]=observed.encode()
 core_name='experiments/public-machines/followup/overflow-core.bend'
 core=contents[core_name].decode()
 anchor='import ../observe.bend as O';assert core.count(anchor)==1
 core=core.replace(anchor,anchor+'\nimport ../format.bend as Fmt')
 old_render='List.show(&2,M.Transition<U32>,value => O.transition(~U32,~U32.show,value),values)';assert core.count(old_render)==1
 core=core.replace(old_render,'Fmt.show(~M.Transition<U32>,~(value => O.transition(~U32,~U32.show,value)),values)')
 contents[core_name]=core.encode()
 format_name='experiments/public-machines/format.bend';assert format_name not in contents
 contents[format_name]=(HERE/'format-linear.bend').read_bytes()
 return contents,[stream_name,observer_name,queue_name,core_name,format_name]
