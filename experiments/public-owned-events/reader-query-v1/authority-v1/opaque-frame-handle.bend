import Base
import ../../family-readers-v1/schema.bend as Families
import ../../family-readers-v1/fixture.bend as Readers
import ../../families-v1/schema.bend as Bind
import ../../families-v1/fixture.bend as Pub
import ../../ordinary-v1/payload.bend as Payload
import ../../../../src/ecs/ordinary-owned-event-family-reader-query.bend as O
import ../../../../src/ecs/owned-event-family-reader-query.bend as Core
import ../../../../src/ecs/compose.bend as Q
import ../../../../src/ecs/component.bend as Cmp
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/capabilities.bend as Cap
import ../../../../src/ecs/transaction.bend as T
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/event-runtime.bend as Ev
import ../../../../src/ecs/event-family-routing.bend as Route
import ../../../../src/ecs/event-family-runtime.bend as FR
import ../../../../src/ecs/owner-product.bend as Product
import ../../../../src/ecs/owned-event-log.bend as Log
import ../fixture.bend as Fixture
import ../../../../src/ecs/ordinary-query-declaration.bend as D
import ../../../../src/ecs/ordinary-owned-event.bend as Owned
type A is Data:A{}
def Args() -> Type:Fixture.Args
def Observation() -> Type:Fixture.Observation
def Error() -> Data:Fixture.Error
def Ops(H:Type) -> Type:Cap.Read<H,U32>
def query(~S:Data) -> D.Declaration<S,Q.Frame<S,Col.Column<S,U32>,Families.Resources(),Families.E()>,Ops(Q.Frame<S,Col.Column<S,U32>,Families.Resources(),Families.E()>)>:
  D.read(~S,~U32,~Col.Column<S,U32>,~Families.Resources(),~Families.E(),~Unit,~U32,~Pub.Token,~Pub.identity(~S),~Pub.view,~Pub.take(~S),~Pub.put(~S))
def finished(~H:Type,observation:Observation(),args:Args(),owner:H) -> H & (Observation() & (Args() & (T.Outcome<Error()> & U32))):
  (owner,(observation,(args,(T.Success{},0))))
def body(~H:Type,~caps:Ops(H),observation:Observation(),args:Args(),owner:H) -> H & (Observation() & (Args() & (T.Outcome<Error()> & U32))):
  finished(~H,observation,args,Q.handle_get(~A,~Col.Column<A,U32>,~Families.Resources(),~Families.E(),owner))
def Registration(~S:Data) -> Type:Route.Registration<S,Col.Column<S,U32>,Families.Resources(),Families.E(),Nat,FR.State<Families.E(),Families.Streams(~S),Unit>,Args() & U32,Unit,Core.Reply<Args(),Observation(),Error(),U32>,FR.take(~S,~Nat,~Families.E(),~Families.Streams(~S),~Unit,~Families.a_take(~S)),FR.put(~S,~Nat,~Families.E(),~Families.Streams(~S),~Unit,~Families.a_put(~S)),Core.runner(~S,~Col.Column<S,U32>,~Families.Resources(),~Array<U32>,~(Array<U32> & (Product.Owner<Log.Log<Array<U32>>,Log.Log<Array<Array<U32>>>> & Unit)),~Families.E(),~Bind.a_path(),~Payload.Request,~Payload.Projection,~Args(),~Observation(),~Error(),~U32,~Ops,~Payload.at,~Fixture.project,~query(~S),~body)>
def register(~S:Data,runtime:Fixture.Runtime(~S)) -> Registration(~S):O.register(~S,~Col.Column<S,U32>,~Families.Resources(),~Array<U32>,~(Array<U32> & (Product.Owner<Log.Log<Array<U32>>,Log.Log<Array<Array<U32>>>> & Unit)),~Families.E(),~Families.Domains(~S),~Families.Streams(~S),~Bind.a_path(),~Bind.a_inject(),~Bind.a_select(),~Bind.a_domain(~S),~Families.make(~S),~Families.sync(~S),~Families.frame(~S),~Families.retain(~S),~Families.inventory(~S),~Families.a_take(~S),~Families.a_put(~S),~Families.a_setup(~S),~Unit,~Payload.Request,~Payload.Projection,~Args(),~Observation(),~Error(),~U32,~Ops,~Payload.at,~Fixture.project,~query(~S),~body,runtime,"read-cargo-with-query")
def actual(runtime:Fixture.Runtime(~A)) -> Registration(~A):register(~A,runtime)
