import Base
import fixture-schema.bend as D
import fixture-specs.bend as Spec
import fixture-query.bend as Decl
import fixture-observe.bend as O
import families.bend as Family
import selection.bend as Select
import core-v1/src/ecs/world.bend as W
import core-v1/src/ecs/inspector.bend as I
import core-v1/src/ecs/component.bend as C
import core-v1/src/ecs/relation-query.bend as RQ
import core-v1/src/ecs/relation-commands.bend as A

type Entry<S:Data> is Data:
  Entry{stockRequired:Bool,titleRequired:Bool,shape:Spec.RelationShape,observation:O.Observation<S,Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>>}
def appended(~S:Data,stockRequired:Bool,titleRequired:Bool,shape:Spec.RelationShape,entries:List<&2,Entry<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & O.Observation<S,Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,observation)=observed
  (frame,List.append(&2,Entry<S>,entries,[Entry{stockRequired,titleRequired,shape,observation}]))
def step_0(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,False{},False{},Spec.OptionalBoth{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Optional{},~Family.Optional{},~Spec.OptionalBoth{}),frame,targets))
def step_1(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,False{},False{},Spec.RequiredOut{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Optional{},~Family.Optional{},~Spec.RequiredOut{}),frame,targets))
def step_2(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,False{},False{},Spec.RequiredIn{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Optional{},~Family.Optional{},~Spec.RequiredIn{}),frame,targets))
def step_3(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,False{},False{},Spec.RequiredBoth{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Optional{},~Family.Optional{},~Spec.RequiredBoth{}),frame,targets))
def step_4(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,False{},False{},Spec.WithOut{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Optional{},~Family.Optional{},~Spec.WithOut{}),frame,targets))
def step_5(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,False{},False{},Spec.WithoutOut{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Optional{},~Family.Optional{},~Spec.WithoutOut{}),frame,targets))
def step_6(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,False{},False{},Spec.WithIn{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Optional{},~Family.Optional{},~Spec.WithIn{}),frame,targets))
def step_7(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,False{},False{},Spec.WithoutIn{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Optional{},~Family.Optional{},~Spec.WithoutIn{}),frame,targets))
def step_8(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,True{},False{},Spec.OptionalBoth{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Required{},~Family.Optional{},~Spec.OptionalBoth{}),frame,targets))
def step_9(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,True{},False{},Spec.RequiredOut{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Required{},~Family.Optional{},~Spec.RequiredOut{}),frame,targets))
def step_10(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,True{},False{},Spec.RequiredIn{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Required{},~Family.Optional{},~Spec.RequiredIn{}),frame,targets))
def step_11(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,True{},False{},Spec.RequiredBoth{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Required{},~Family.Optional{},~Spec.RequiredBoth{}),frame,targets))
def step_12(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,True{},False{},Spec.WithOut{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Required{},~Family.Optional{},~Spec.WithOut{}),frame,targets))
def step_13(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,True{},False{},Spec.WithoutOut{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Required{},~Family.Optional{},~Spec.WithoutOut{}),frame,targets))
def step_14(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,True{},False{},Spec.WithIn{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Required{},~Family.Optional{},~Spec.WithIn{}),frame,targets))
def step_15(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,True{},False{},Spec.WithoutIn{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Required{},~Family.Optional{},~Spec.WithoutIn{}),frame,targets))
def step_16(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,False{},True{},Spec.OptionalBoth{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Optional{},~Family.Required{},~Spec.OptionalBoth{}),frame,targets))
def step_17(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,False{},True{},Spec.RequiredOut{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Optional{},~Family.Required{},~Spec.RequiredOut{}),frame,targets))
def step_18(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,False{},True{},Spec.RequiredIn{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Optional{},~Family.Required{},~Spec.RequiredIn{}),frame,targets))
def step_19(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,False{},True{},Spec.RequiredBoth{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Optional{},~Family.Required{},~Spec.RequiredBoth{}),frame,targets))
def step_20(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,False{},True{},Spec.WithOut{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Optional{},~Family.Required{},~Spec.WithOut{}),frame,targets))
def step_21(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,False{},True{},Spec.WithoutOut{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Optional{},~Family.Required{},~Spec.WithoutOut{}),frame,targets))
def step_22(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,False{},True{},Spec.WithIn{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Optional{},~Family.Required{},~Spec.WithIn{}),frame,targets))
def step_23(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,False{},True{},Spec.WithoutIn{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Optional{},~Family.Required{},~Spec.WithoutIn{}),frame,targets))
def step_24(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,True{},True{},Spec.OptionalBoth{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Required{},~Family.Required{},~Spec.OptionalBoth{}),frame,targets))
def step_25(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,True{},True{},Spec.RequiredOut{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Required{},~Family.Required{},~Spec.RequiredOut{}),frame,targets))
def step_26(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,True{},True{},Spec.RequiredIn{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Required{},~Family.Required{},~Spec.RequiredIn{}),frame,targets))
def step_27(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,True{},True{},Spec.RequiredBoth{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Required{},~Family.Required{},~Spec.RequiredBoth{}),frame,targets))
def step_28(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,True{},True{},Spec.WithOut{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Required{},~Family.Required{},~Spec.WithOut{}),frame,targets))
def step_29(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,True{},True{},Spec.WithoutOut{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Required{},~Family.Required{},~Spec.WithoutOut{}),frame,targets))
def step_30(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,True{},True{},Spec.WithIn{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Required{},~Family.Required{},~Spec.WithIn{}),frame,targets))
def step_31(~S:Data,targets:List<&2,W.Handle<S>>,observed:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  (frame,entries)=observed
  appended(~S,True{},True{},Spec.WithoutIn{},entries,O.observe(~I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>,~S,~Select.Product<Select.Product<C.Access<U32>,C.Access<String>>,List<&2,RQ.Cell<S>>>,~Decl.declared(~S,~Family.Required{},~Family.Required{},~Spec.WithoutIn{}),frame,targets))
def matrix(~S:Data,+targets:List<&2,W.Handle<S>>,frame:I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>>) -> I.Frame<S,A.Store<S,D.Components<S>>,D.Resources,A.Notice<S,D.FixtureEvent>> & List<&2,Entry<S>>:
  step_31(~S,targets,step_30(~S,targets,step_29(~S,targets,step_28(~S,targets,step_27(~S,targets,step_26(~S,targets,step_25(~S,targets,step_24(~S,targets,step_23(~S,targets,step_22(~S,targets,step_21(~S,targets,step_20(~S,targets,step_19(~S,targets,step_18(~S,targets,step_17(~S,targets,step_16(~S,targets,step_15(~S,targets,step_14(~S,targets,step_13(~S,targets,step_12(~S,targets,step_11(~S,targets,step_10(~S,targets,step_9(~S,targets,step_8(~S,targets,step_7(~S,targets,step_6(~S,targets,step_5(~S,targets,step_4(~S,targets,step_3(~S,targets,step_2(~S,targets,step_1(~S,targets,step_0(~S,targets,(frame,[])))))))))))))))))))))))))))))))))
