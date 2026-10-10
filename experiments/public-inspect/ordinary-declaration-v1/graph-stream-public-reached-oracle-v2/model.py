"""Independent source-derived complete reached controls. No actual outputs."""
from pathlib import Path
import types
HERE=Path(__file__).resolve().parent
m=types.ModuleType('normal');m.__file__=str(HERE/'normal-model.py.source');exec(compile((HERE/'normal-model.py.source').read_bytes(),m.__file__,'exec'),m.__dict__)
m.ROOT=m.ROOT/'reached-controls-v1'/'namespace-normal'
c=m.c;l=m.l;t=m.t
normal_world=m.world
normal_runtime=m.runtime
normal_observation=m.observation

def report(kind):
 if kind=='namespace-normal':return m.report(31,100)
 if kind=='failure-order':
  r=normal_runtime(31,100);o=normal_observation();selected=m.events()[2]
  old=l(selected);new=l(list(reversed(selected)));assert o.count(old)==2;o=o.replace(old,new)
  return (c('Some',c('consumer.Report',c('consumer.ReaderView','31','1','2'),c('consumer.RegistryView','31','2',t('NoticeReader'),l([t('relationFailures'),t('transitionEvents')]),'0'),r,o,r,o,r))+'\n').encode()
 if kind=='stream-consumption':
  before=normal_runtime(31,100);after=before.replace('[5:1:1]','[5:3:1]');assert before!=after
  o=normal_observation();old=c(m.named('event-runtime','Position'),'5','1n','1n');new=c(m.named('event-runtime','Position'),'5','3n','1n');assert o.count(old)==1;o=o.replace(old,new)
  return (c('Some',c('consumer.Report',c('consumer.ReaderView','31','1','2'),c('consumer.RegistryView','31','2',t('NoticeReader'),l([t('relationFailures'),t('transitionEvents')]),'0'),before,o,after,o,after))+'\n').encode()
 raise ValueError(kind)
