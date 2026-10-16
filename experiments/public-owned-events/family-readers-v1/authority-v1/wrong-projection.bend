import Base
import ../schema.bend as Schema
import ../catalog.bend as Catalog
import ../../families-v1/schema.bend as Bind
import ../../families-v1/fixture.bend as Publisher
import ../../ordinary-v1/payload.bend as Payload
import ../../../../src/ecs/ordinary-owned-event-family-reader.bend as O
import ../../../../src/ecs/owned-event-family-reader-runtime.bend as Core
import ../../../../src/ecs/owned-event-family-lifecycle.bend as Life
import ../../../../src/ecs/event-runtime.bend as Ev
import ../../../../src/ecs/event-family-runtime.bend as FR
import ../../../../src/ecs/event-family-routing.bend as Route
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/owner-product.bend as Product
import ../../../../src/ecs/owned-event-log.bend as Log
import ../../../../src/ecs/capabilities.bend as Cap
import ../../../../src/ecs/transaction.bend as T
import ../fixture.bend as Fixture
type A is Data:A{}
def finish(~H:Type,args:Payload.Args,result:H & Payload.Projection) -> H & (T.Outcome<Payload.Error> & Payload.Args):
  match result:
    case (owner,projection):(owner,(T.Success{},args))
def body(~H:Type,~grant:Cap.Request<H,Payload.Request,Payload.Projection>,owner:H,args:Payload.Args) -> H & (T.Outcome<Payload.Error> & Payload.Args):
  finish(~H,args,Cap.request(~H,~Payload.Request,~U32,~grant,owner,Payload.Request{0,Payload.payload(2)}))
def Registered(~S:Data) -> Type:Route.Registration<S,Col.Column<S,U32>,Schema.Resources(),Schema.E(),Nat,Fixture.State(~S),Payload.Args,Unit,Core.Reply<Payload.Error,Payload.Args>,FR.take(~S,~Nat,~Schema.E(),~Schema.Streams(~S),~Unit,~Schema.a_take(~S)),FR.put(~S,~Nat,~Schema.E(),~Schema.Streams(~S),~Unit,~Schema.a_put(~S)),Core.runner(~S,~Col.Column<S,U32>,~Schema.Resources(),~Array<U32>,~(Array<U32> & (Product.Owner<Log.Log<Array<U32>>,Log.Log<Array<Array<U32>>>> & Unit)),~Schema.E(),~Bind.a_path(),~Payload.Request,~Payload.Projection,~Payload.Args,~Payload.Error,~Payload.at,~body)>
def registered(~S:Data,runtime:Fixture.Runtime(~S),name:String) -> Registered(~S):
  O.register(~S,~Col.Column<S,U32>,~Schema.Resources(),~Array<U32>,~(Array<U32> & (Product.Owner<Log.Log<Array<U32>>,Log.Log<Array<Array<U32>>>> & Unit)),~Schema.E(),~Schema.Domains(~S),~Schema.Streams(~S),~Bind.a_path(),~Bind.a_inject(),~Bind.a_select(),~Bind.a_domain(~S),~Schema.make(~S),~Schema.sync(~S),~Schema.frame(~S),~Schema.retain(~S),~Schema.inventory(~S),~Schema.a_take(~S),~Schema.a_put(~S),~Schema.a_setup(~S),~Unit,~Payload.Request,~Payload.Projection,~Payload.Args,~Payload.Error,~Payload.at,~body,runtime,name)
def actual(runtime:Fixture.Runtime(~A)) -> Registered(~A):registered(~A,runtime,"scoped")
