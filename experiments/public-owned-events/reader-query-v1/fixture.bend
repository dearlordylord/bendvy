import Base
import ../family-readers-v1/schema.bend as Families
import ../family-readers-v1/fixture.bend as Readers
import ../families-v1/schema.bend as Bind
import ../families-v1/fixture.bend as Pub
import ../ordinary-v1/payload.bend as Payload
import ../../../src/ecs/ordinary-owned-event-family-reader-query.bend as O
import ../../../src/ecs/owned-event-family-reader-query.bend as Core
import ../../../src/ecs/compose.bend as Q
import ../../../src/ecs/component.bend as Cmp
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/capabilities.bend as Cap
import ../../../src/ecs/transaction.bend as T
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/event-runtime.bend as Ev
import ../../../src/ecs/event-family-routing.bend as Route
import ../../../src/ecs/event-family-runtime.bend as FR
import ../../../src/ecs/owner-product.bend as Product
import ../../../src/ecs/owned-event-log.bend as Log

type Args is Type:Args{delta:U32,failValue:U32,scratch:Array<U32>}
type Observation is Type:Observation{projection:Payload.Projection,entered:Array<U32>}
type Error is Data:
  FailedAt{value:U32}
  Missing{}
def args(+delta:U32,failValue:U32) -> Args:Args{delta,failValue,ANode{ALeaf{1},ALeaf{2}}}
def projection_returned(~H:Type,args:Args,result:H & Payload.Projection) -> H & Core.Projected<Args,Observation,Error>:
  match result:
    case (owner,value):(owner,Core.Ready{args,Observation{value,ANode{ALeaf{0},ALeaf{100}}}})
def project(~H:Type,~read:Cap.Request<H,Payload.Request,Payload.Projection>,owner:H,args:Args) -> H & Core.Projected<Args,Observation,Error>:
  projection_returned(~H,args,Cap.request(~H,~Payload.Request,~Payload.Projection,~read,owner,Payload.Request{0,ANode{ALeaf{90},ALeaf{91}}}))
def bumped(result:Array<U32> & U32) -> Array<U32>:
  match result:
    case (owner,value):Array.set(U32,owner,0,(value + 1 : U32))
def bump(owner:Array<U32>) -> Array<U32>:bumped(Array.get(U32,owner,0))
def decision(fail:Bool,value:U32) -> T.Outcome<Error>:
  match fail:
    case True{}:T.Failure{FailedAt{value}}
    case False{}:T.Success{}
def counted(~H:Type,~caps:Pub.Ops(H),observation:Observation,args:Args,+old:U32,result:H & U32) -> H & (Observation & (Args & (T.Outcome<Error> & U32))):
  match observation args result:
    case Observation{projection,entered}, Args{+delta,+failValue,scratch}, (owner,+counter):
      (Cap.value_set(~H,~Array<U32>,~U32,~Pair.snd(Cap.Write<H,U32,U32>,Cap.ValueWrite<H,Array<U32>,U32>,caps),Cap.set(~H,~U32,~U32,~Pair.fst(Cap.Write<H,U32,U32>,Cap.ValueWrite<H,Array<U32>,U32>,caps),owner,(old + delta : U32)),ANode{ALeaf{(counter + 1 : U32)},ALeaf{(counter + 2 : U32)}}),(Observation{projection,bump(entered)},(Args{delta,failValue,bump(scratch)},(decision(U32.is_eq(old,failValue),old),old))))
def got(~H:Type,~caps:Pub.Ops(H),observation:Observation,args:Args,result:H & Cmp.Access<U32>) -> H & (Observation & (Args & (T.Outcome<Error> & U32))):
  match result:
    case (owner,Cmp.Found{value}):counted(~H,~caps,observation,args,value,Cap.value_get(~H,~Array<U32>,~U32,~Pair.snd(Cap.Write<H,U32,U32>,Cap.ValueWrite<H,Array<U32>,U32>,caps),owner))
    case (owner,_):(owner,(observation,(args,(T.Failure{Missing{}},0))))
def body(~H:Type,~caps:Pub.Ops(H),observation:Observation,args:Args,owner:H) -> H & (Observation & (Args & (T.Outcome<Error> & U32))):
  got(~H,~caps,observation,args,Cap.get(~H,~U32,~U32,~Pair.fst(Cap.Write<H,U32,U32>,Cap.ValueWrite<H,Array<U32>,U32>,caps),owner))
def World(~S:Data) -> Type:Pub.World(~S)
def Runtime(~S:Data) -> Type:Readers.Runtime(~S)
def Reader(~S:Data) -> Type:Readers.Reader_a(~S)
def Registry(~S:Data) -> Type:Sys.Registry<S,Col.Column<S,U32>,Families.Resources(),Families.E(),Ev.Input<Nat,Args & U32>,Unit,Core.Reply<Args,Observation,Error,U32>,Core.runner(~S,~Col.Column<S,U32>,~Families.Resources(),~Array<U32>,~(Array<U32> & (Product.Owner<Log.Log<Array<U32>>,Log.Log<Array<Array<U32>>>> & Unit)),~Families.E(),~Bind.a_path(),~Payload.Request,~Payload.Projection,~Args,~Observation,~Error,~U32,~Pub.Ops,~Payload.at,~project,~Pub.query(~S),~body)>
def Registration(~S:Data) -> Type:Route.Registration<S,Col.Column<S,U32>,Families.Resources(),Families.E(),Nat,FR.State<Families.E(),Families.Streams(~S),Unit>,Args & U32,Unit,Core.Reply<Args,Observation,Error,U32>,FR.take(~S,~Nat,~Families.E(),~Families.Streams(~S),~Unit,~Families.a_take(~S)),FR.put(~S,~Nat,~Families.E(),~Families.Streams(~S),~Unit,~Families.a_put(~S)),Core.runner(~S,~Col.Column<S,U32>,~Families.Resources(),~Array<U32>,~(Array<U32> & (Product.Owner<Log.Log<Array<U32>>,Log.Log<Array<Array<U32>>>> & Unit)),~Families.E(),~Bind.a_path(),~Payload.Request,~Payload.Projection,~Args,~Observation,~Error,~U32,~Pub.Ops,~Payload.at,~project,~Pub.query(~S),~body)>
def Ran(~S:Data) -> Type:Route.RunResult<S,Col.Column<S,U32>,Families.Resources(),Families.E(),Nat,FR.State<Families.E(),Families.Streams(~S),Unit>,Args & U32,Unit,Core.Reply<Args,Observation,Error,U32>,FR.take(~S,~Nat,~Families.E(),~Families.Streams(~S),~Unit,~Families.a_take(~S)),FR.put(~S,~Nat,~Families.E(),~Families.Streams(~S),~Unit,~Families.a_put(~S)),Core.runner(~S,~Col.Column<S,U32>,~Families.Resources(),~Array<U32>,~(Array<U32> & (Product.Owner<Log.Log<Array<U32>>,Log.Log<Array<Array<U32>>>> & Unit)),~Families.E(),~Bind.a_path(),~Payload.Request,~Payload.Projection,~Args,~Observation,~Error,~U32,~Pub.Ops,~Payload.at,~project,~Pub.query(~S),~body)>
def register(~S:Data,runtime:Runtime(~S)) -> Registration(~S):O.register(~S,~Col.Column<S,U32>,~Families.Resources(),~Array<U32>,~(Array<U32> & (Product.Owner<Log.Log<Array<U32>>,Log.Log<Array<Array<U32>>>> & Unit)),~Families.E(),~Families.Domains(~S),~Families.Streams(~S),~Bind.a_path(),~Bind.a_inject(),~Bind.a_select(),~Bind.a_domain(~S),~Families.make(~S),~Families.sync(~S),~Families.frame(~S),~Families.retain(~S),~Families.inventory(~S),~Families.a_take(~S),~Families.a_put(~S),~Families.a_setup(~S),~Unit,~Payload.Request,~Payload.Projection,~Args,~Observation,~Error,~U32,~Pub.Ops,~Payload.at,~project,~Pub.query(~S),~body,runtime,"read-cargo-with-query")
def run(~S:Data,runtime:Runtime(~S),reader:Reader(~S),registry:Registry(~S),args:Args) -> Ran(~S):O.run(~S,~Col.Column<S,U32>,~Families.Resources(),~Array<U32>,~(Array<U32> & (Product.Owner<Log.Log<Array<U32>>,Log.Log<Array<Array<U32>>>> & Unit)),~Families.E(),~Families.Domains(~S),~Families.Streams(~S),~Bind.a_path(),~Bind.a_inject(),~Bind.a_select(),~Bind.a_domain(~S),~Families.make(~S),~Families.sync(~S),~Families.frame(~S),~Families.retain(~S),~Families.inventory(~S),~Families.a_take(~S),~Families.a_put(~S),~Families.a_setup(~S),~Unit,~Payload.Request,~Payload.Projection,~Args,~Observation,~Error,~U32,~Pub.Ops,~Payload.at,~project,~Pub.query(~S),~body,runtime,reader,registry,args)
