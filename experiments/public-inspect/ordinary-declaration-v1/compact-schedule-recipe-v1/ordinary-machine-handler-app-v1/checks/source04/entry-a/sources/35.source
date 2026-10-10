import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/machine.bend as M
import /workspace/formal-proofs/bendvy/src/ecs/machine-handlers.bend as H
import /workspace/formal-proofs/bendvy/src/ecs/machine-handler-bundle.bend as B
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-handler-bundle.bend as Operation
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-machine-schedule.bend as Ordinary
import /workspace/formal-proofs/bendvy/src/ecs/schedule.bend as Sch

type EntryView<S:Data,K:Data,V:Data,Q:Data> is Data:
  EntryView{selector:B.Selector<S,K,V>,requirements:List<&2,Q>,namespace:U32,entryId:U32,id:U32,name:String,access:List<&2,String>,cursor:U32}
type Description<S:Data,K:Data,V:Data,Q:Data> is Data:
  Description{namespace:U32,name:String,steps:List<&2,Sch.Step>,entries:List<&2,EntryView<S,K,V,Q>>}
type Application<S:Data,K:Data,V:Data,Q:Data,C:Type,R:Type,E:Data,-runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,Extra:Type> is Type:
  Application{world:W.World<S,C,R,E>,bundle:B.Bundle<S,K,V,Q,C,R,E,runner>,declaration:Ordinary.Declaration<S>,extra:Extra,debug:Bool}
  Recovering{result:Operation.MarkerResult<S,K,V,Q,C,R,E,runner>,declaration:Ordinary.Declaration<S>,extra:Extra,debug:Bool}
def entries_returned(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,+selector:B.Selector<S,K,V>,+requirements:List<&2,Q>,+namespace:U32,+entryId:U32,+id:U32,+name:String,+access:List<&2,String>,+cursor:U32,result:List<&1,B.Scheduled<S,K,V,Q,C,R,E,runner>> & List<&2,EntryView<S,K,V,Q>>) -> List<&1,B.Scheduled<S,K,V,Q,C,R,E,runner>> & List<&2,EntryView<S,K,V,Q>>:
  (rest,views)=result
  (B.Scheduled{selector,requirements,H.Entry{entryId,Sys.Registry{namespace,id,name,access,cursor}}} <> rest,EntryView{selector,requirements,namespace,entryId,id,name,access,cursor} <> views)
def entries(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,items:List<&1,B.Scheduled<S,K,V,Q,C,R,E,runner>>) -> List<&1,B.Scheduled<S,K,V,Q,C,R,E,runner>> & List<&2,EntryView<S,K,V,Q>>:
  match items:
    case []:([],[])
    case B.Scheduled{selector,requirements,H.Entry{entryId,Sys.Registry{namespace,id,name,access,cursor}}} <> rest:entries_returned(~S,~K,~V,~Q,~C,~R,~E,~runner,selector,requirements,namespace,entryId,id,name,access,cursor,entries(~S,~K,~V,~Q,~C,~R,~E,~runner,rest))
def bind(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~Extra:Type,world:W.World<S,C,R,E>,bundle:B.Bundle<S,K,V,Q,C,R,E,runner>,declaration:Ordinary.Declaration<S>,extra:Extra) -> Application<S,K,V,Q,C,R,E,runner,Extra>:
  Application{world,bundle,declaration,extra,False{}}
def enabled(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~Extra:Type,app:Application<S,K,V,Q,C,R,E,runner,Extra>,debug:Bool) -> Application<S,K,V,Q,C,R,E,runner,Extra>:
  match app:
    case Application{world,bundle,declaration,extra,_}:Application{world,bundle,declaration,extra,debug}
    case Recovering{result,declaration,extra,_}:Recovering{result,declaration,extra,debug}
def described(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~Extra:Type,world:W.World<S,C,R,E>,+namespace:U32,+name:String,extra:Extra,result:List<&1,B.Scheduled<S,K,V,Q,C,R,E,runner>> & List<&2,EntryView<S,K,V,Q>>) -> Application<S,K,V,Q,C,R,E,runner,Extra> & Maybe<&2,Description<S,K,V,Q>>:
  (items,views)=result
  (Application{world,B.Bundle{namespace,items},Ordinary.Declaration{name},extra,True{}},Some{Description{namespace,name,Ordinary.steps(),views}})
def snapshot(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~Extra:Type,app:Application<S,K,V,Q,C,R,E,runner,Extra>) -> Application<S,K,V,Q,C,R,E,runner,Extra> & Maybe<&2,Description<S,K,V,Q>>:
  match app:
    case Application{world,B.Bundle{namespace,items},Ordinary.Declaration{name},extra,True{}}:described(~S,~K,~V,~Q,~C,~R,~E,~runner,~Extra,world,namespace,name,extra,entries(~S,~K,~V,~Q,~C,~R,~E,~runner,items))
    case app:(app,None{})

type RunResult<S:Data,K:Data,V:Data,Q:Data,C:Type,R:Type,E:Data,-runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,Extra:Type> is Type:
  RunResult{result:Operation.MarkerResult<S,K,V,Q,C,R,E,runner>,declaration:Ordinary.Declaration<S>,extra:Extra,debug:Bool}
def run_app(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~take:W.World<S,C,R,E> -> W.World<S,C,R,E> & M.Slot<S,K,V>,~put:W.World<S,C,R,E> -> M.Slot<S,K,V> -> W.World<S,C,R,E>,~publish:W.World<S,C,R,E> -> M.Transition<V> -> W.World<S,C,R,E>,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,~Extra:Type,app:Application<S,K,V,Q,C,R,E,runner,Extra>) -> RunResult<S,K,V,Q,C,R,E,runner,Extra>:
  match app:
    case Recovering{result,declaration,extra,debug}:RunResult{result,declaration,extra,debug}
    case Application{world,bundle,+declaration,extra,debug}:RunResult{Operation.run(~S,~K,~V,~Q,~C,~R,~E,~runner,~take,~put,~publish,~same,~requirement_same,~has,~frame,declaration,bundle,world),declaration,extra,debug}
