import Base
import types.bend as T
import application.bend as App
import observe.bend as Observe
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
def finished(factory:W.Factory,items:List<&2,String>) -> List<&2,String>:
  match factory:
    case W.Factory{next}:List.append(&2,String,items,["Factory:" ++ U32.show(next)])
def step7(factory:W.Factory,prior:List<&2,String>,pair:App.Application<T.SchemaA> & String) -> List<&2,String>:
  (app,text)=pair
  finished(factory,List.append(&2,String,prior,[text]))
def step6(factory:W.Factory,prior:List<&2,String>,pair:App.Application<T.SchemaA> & String) -> List<&2,String>:
  (app,text)=pair
  step7(factory,List.append(&2,String,prior,[text]),Observe.snapshot(~T.SchemaA,App.marker_second(~T.SchemaA,app),"later-second-marker"))
def step5(factory:W.Factory,prior:List<&2,String>,pair:App.Application<T.SchemaA> & String) -> List<&2,String>:
  (app,text)=pair
  step6(factory,List.append(&2,String,prior,[text]),Observe.snapshot(~T.SchemaA,App.marker_first(~T.SchemaA,app),"later-first-marker"))
def step4(factory:W.Factory,prior:List<&2,String>,pair:App.Application<T.SchemaA> & String) -> List<&2,String>:
  (app,text)=pair
  step5(factory,List.append(&2,String,prior,[text]),Observe.snapshot(~T.SchemaA,App.read_second(~T.SchemaA,app),"second-reader"))
def step3(factory:W.Factory,prior:List<&2,String>,pair:App.Application<T.SchemaA> & String) -> List<&2,String>:
  (app,text)=pair
  step4(factory,List.append(&2,String,prior,[text]),Observe.snapshot(~T.SchemaA,App.read_first(~T.SchemaA,app),"first-reader"))
def step2(factory:W.Factory,prior:List<&2,String>,pair:App.Application<T.SchemaA> & String) -> List<&2,String>:
  (app,text)=pair
  step3(factory,List.append(&2,String,prior,[text]),Observe.snapshot(~T.SchemaA,App.marker_second(~T.SchemaA,app),"second-marker"))
def step1(factory:W.Factory,prior:List<&2,String>,pair:App.Application<T.SchemaA> & String) -> List<&2,String>:
  (app,text)=pair
  step2(factory,List.append(&2,String,prior,[text]),Observe.snapshot(~T.SchemaA,App.marker_first(~T.SchemaA,app),"first-marker"))
def step0(factory:W.Factory,prior:List<&2,String>,pair:App.Application<T.SchemaA> & String) -> List<&2,String>:
  (app,text)=pair
  step1(factory,List.append(&2,String,prior,[text]),Observe.snapshot(~T.SchemaA,App.queue(~T.SchemaA,app),"queued"))
def constructed(result:App.Construction<T.SchemaA>) -> List<&2,String>:
  match result:
    case App.Constructed{factory,app}:step0(factory,[],Observe.snapshot(~T.SchemaA,app,"before"))
    case App.Refused{factory}:finished(factory,["ConstructionRefused"])
def main() -> List<&2,String>:constructed(App.create(~T.SchemaA,W.Factory{1}))
