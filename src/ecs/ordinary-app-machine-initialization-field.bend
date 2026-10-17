import Base
import ./world.bend as W
import ./system.bend as Sys
import ./transaction.bend as T
import ./machine.bend as M
import ./machine-handlers.bend as H
import ./machine-handler-bundle.bend as B
import ./machine-stream.bend as St
import ./ordinary-machine-initialization.bend as Init
import ./ordinary-machine-initialization-marker.bend as Marker
import ./ordinary-machine-declaration.bend as Machine
import ./ordinary-machine-schedule.bend as Ordinary
import ./ordinary-app-machine-handler.bend as App
import ./ordinary-app-machine-handler-field.bend as Factory
import ./ordinary-app-resource-field-declaration.bend as D
import ./ordinary-resource-field-system.bend as Field
import ./machine-handler-trace.bend as TraceRun
import ./execution-trace.bend as Trace
type Application<S:Data,K:Data,V:Data,Q:Data,C:Type,R:Type,E:Data,-runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,Extra:Type> is Type:
  Application{app:App.Application<S,K,V,Q,C,R,E,runner,Extra>,reader:St.Reader<S,K>}
type Definition<S:Data,K:Data,V:Data,Q:Data,C:Type,R:Type,E:Data,-runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,Extra:Type> is Type:
  Bound{app:Application<S,K,V,Q,C,R,E,runner,Extra>}
  Rejected{app:App.Application<S,K,V,Q,C,R,E,runner,Extra>}
type RunResult<S:Data,K:Data,V:Data,Q:Data,C:Type,R:Type,E:Data,-runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,Extra:Type> is Type:
  RunResult{result:App.RunResult<S,K,V,Q,C,R,E,runner,Extra>,reader:St.Reader<S,K>}
def bound(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~Extra:Type,extra:Extra,debug:Bool,result:Marker.Definition<S,K,V,Q,C,R,E,runner>) -> Definition<S,K,V,Q,C,R,E,runner,Extra>:
  match result:
    case Marker.Bound{Marker.Application{world,bundle,reader,declaration}}:Bound{Application{App.Application{world,bundle,declaration,extra,debug},reader}}
    case Marker.BindRejected{world,bundle,declaration}:Rejected{App.Application{world,bundle,declaration,extra,debug}}
def bind(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~Extra:Type,~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,~initial:Machine.Declaration<S,K,V,R,Init.take_slot(~S,~K,~V,~R,~take,~put)>,app:App.Application<S,K,V,Q,C,R,E,runner,Extra>) -> Definition<S,K,V,Q,C,R,E,runner,Extra>:
  match app:
    case App.Recovering{result,declaration,extra,debug}:Rejected{App.Recovering{result,declaration,extra,debug}}
    case App.Application{world,bundle,declaration,extra,debug}:bound(~S,~K,~V,~Q,~C,~R,~E,~runner,~Extra,extra,debug,Marker.bind(~S,~K,~V,~R,~take,~put,~C,~E,~Q,~runner,~same,~requirement_same,~has,~frame,~initial,declaration,bundle,world))
def enabled(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~Extra:Type,app:Application<S,K,V,Q,C,R,E,runner,Extra>,debug:Bool) -> Application<S,K,V,Q,C,R,E,runner,Extra>:
  match app:
    case Application{app,reader}:Application{App.enabled(~S,~K,~V,~Q,~C,~R,~E,~runner,~Extra,app,debug),reader}
def snapshot_returned(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~Extra:Type,reader:St.Reader<S,K>,pair:App.Application<S,K,V,Q,C,R,E,runner,Extra> & Maybe<&2,App.Description<S,K,V,Q>>) -> Application<S,K,V,Q,C,R,E,runner,Extra> & Maybe<&2,App.Description<S,K,V,Q>>:
  match pair:
    case (app,description):(Application{app,reader},description)
def snapshot(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~Extra:Type,app:Application<S,K,V,Q,C,R,E,runner,Extra>) -> Application<S,K,V,Q,C,R,E,runner,Extra> & Maybe<&2,App.Description<S,K,V,Q>>:
  match app:
    case Application{app,reader}:snapshot_returned(~S,~K,~V,~Q,~C,~R,~E,~runner,~Extra,reader,App.snapshot(~S,~K,~V,~Q,~C,~R,~E,~runner,~Extra,app))
def captured_returned(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~Extra:Type,reader:St.Reader<S,K>,pair:App.RunResult<S,K,V,Q,C,R,E,runner,Extra> & Trace.Batch<String>) -> RunResult<S,K,V,Q,C,R,E,runner,Extra> & Trace.Batch<String>:
  match pair:
    case (result,batch):(RunResult{result,reader},batch)
def captured(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~Extra:Type,declaration:Ordinary.Declaration<S>,extra:Extra,debug:Bool,name:String,value:Marker.ObservedMarkerRun<S,K,V,Q,C,R,E,runner>) -> RunResult<S,K,V,Q,C,R,E,runner,Extra> & Trace.Batch<String>:
  match value:
    case Marker.ObservedMarkerRun{reader,result}:captured_returned(~S,~K,~V,~Q,~C,~R,~E,~runner,~Extra,reader,Factory.returned(~S,~K,~V,~Q,~C,~R,~E,~runner,~Extra,declaration,extra,debug,TraceRun.captured(~S,~K,~V,~Q,~C,~R,~E,~runner,name,result)))
def run(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~Ops:Type -> Type,~Value:Data,~declaration:D.Declaration<S,C,R,E,Ops,Value>,~body:@-H:Type -> @-caps:Ops(H) -> H.Invocation<V> -> H -> H & (T.Outcome<String> & Unit),~take:R -> R & Init.State<S,K,V>,~put:R -> Init.State<S,K,V> -> R,~same:V -> V -> Bool,~requirement_same:Q -> Q -> Bool,~has:W.World<S,C,R,E> -> Q -> W.World<S,C,R,E> & Bool,~frame:W.World<S,C,R,E> -> W.World<S,C,R,E>,~initial:Machine.Declaration<S,K,V,R,Init.take_slot(~S,~K,~V,~R,~take,~put)>,~Extra:Type,app:Application<S,K,V,Q,C,R,E,Field.runner(~S,~C,~R,~E,~Ops,~H.Invocation<V>,~String,~Unit,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body),Extra>) -> RunResult<S,K,V,Q,C,R,E,Field.runner(~S,~C,~R,~E,~Ops,~H.Invocation<V>,~String,~Unit,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body),Extra> & Trace.Batch<String>:
  match app:
    case Application{App.Recovering{result,declaration,extra,debug},reader}:(RunResult{App.RunResult{result,declaration,extra,debug},reader},Trace.Disabled{})
    case Application{App.Application{world,bundle,Ordinary.Declaration{+name},extra,+debug},reader}:captured(~S,~K,~V,~Q,~C,~R,~E,~Field.runner(~S,~C,~R,~E,~Ops,~H.Invocation<V>,~String,~Unit,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body),~Extra,Ordinary.Declaration{name},extra,debug,name,Marker.run_observed(~S,~K,~V,~R,~take,~put,~C,~E,~Q,~Field.runner(~S,~C,~R,~E,~Ops,~H.Invocation<V>,~String,~Unit,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body),~Field.runner_observed(~S,~C,~R,~E,~Ops,~H.Invocation<V>,~String,~Unit,~D.ordinary(~S,~C,~R,~E,~Ops,~Value,declaration),~body),~Machine.name(~S,~K,~V,~R,~Init.take_slot(~S,~K,~V,~R,~take,~put),initial),~same,~requirement_same,~has,~frame,Ordinary.Declaration{name},bundle,reader,world,Factory.state(debug)))
def resumed(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~Extra:Type,reader:St.Reader<S,K>,pair:App.Application<S,K,V,Q,C,R,E,runner,Extra> & B.Status<Q>) -> Application<S,K,V,Q,C,R,E,runner,Extra> & B.Status<Q>:
  match pair:
    case (app,status):(Application{app,reader},status)
def resume(~S:Data,~K:Data,~V:Data,~Q:Data,~C:Type,~R:Type,~E:Data,~runner:W.World<S,C,R,E> -> H.Invocation<V> -> Sys.Outcome<W.World<S,C,R,E>,String,Unit>,~Extra:Type,value:RunResult<S,K,V,Q,C,R,E,runner,Extra>) -> Application<S,K,V,Q,C,R,E,runner,Extra> & B.Status<Q>:
  match value:
    case RunResult{result,reader}:resumed(~S,~K,~V,~Q,~C,~R,~E,~runner,~Extra,reader,Factory.resume(~S,~K,~V,~Q,~C,~R,~E,~runner,~Extra,result))
