import Base
import ../parallel-query/application.bend as Application
import ../parallel-query/declarations.bend as D
import ../parallel-query/payloads.bend as P
import ../parallel-query/body.bend as Body
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-app.bend as Execute
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-query.bend as Query
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/lifecycle.bend as Life
import ../../src/ecs/clock-state.bend as Clock
import ../../src/ecs/chunk-column.bend as Col
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/owner-product.bend as Product

# Trusted historical fixture setup retains the actual payload owners and presence.
# Only stamps, administrative time and the real system's prior cursor are seeded.
def historical_stamp(+tick:Tick.Tick,stamp:Life.Stamp) -> Life.Stamp:
  match stamp:
    case Life.Stamp{None{},None{}}:Life.Stamp{None{},None{}}
    case _:Life.Stamp{Some{tick},Some{tick}}
def historical_stamps(+tick:Tick.Tick,stamps:Array<Life.Stamp>) -> Array<Life.Stamp>:
  match stamps:
    case ALeaf{stamp}:ALeaf{historical_stamp(tick,stamp)}
    case ANode{left,right}:ANode{historical_stamps(tick,left),historical_stamps(tick,right)}
def historical_column(~S:Data,~T:Type,+tick:Tick.Tick,column:Col.Column<S,T>) -> Col.Column<S,T>:
  match column:
    case Col.Leaf{values,stamps}:Col.Leaf{values,historical_stamps(tick,stamps)}
    case Col.Branch{half,left,right}:Col.Branch{half,historical_column(~S,~T,tick,left),historical_column(~S,~T,tick,right)}
def historical_store(~S:Data,+tick:Tick.Tick,store:D.Store(~S)) -> D.Store(~S):
  match store:
    case Product.Owner{Product.Owner{Layout.ColumnSlot{input},Layout.ColumnSlot{output}},rest}:Product.Owner{Product.Owner{Layout.ColumnSlot{historical_column(~S,~Layout.Viewed<P.Input,U32>,tick,input)},Layout.ColumnSlot{historical_column(~S,~Layout.Viewed<P.Output,U32>,tick,output)}},rest}
def error_seed(owner:Layout.Viewed<P.Output,U32>) -> Layout.Viewed<P.Output,U32> & Unit:
  match owner:
    case Layout.Viewed{P.Output{token,_},_}:(Layout.initialize(D.layout(),Layout.InLeft{Layout.InRight{Layout.AtLeaf{}}},P.Output{token,13}),Unit{})
def seeded_column(~S:Data,rest:Unit,input:Layout.ColumnSlot<S,Layout.Viewed<P.Input,U32>,"input",Layout.origin(D.layout(),Layout.InLeft{Layout.InLeft{Layout.AtLeaf{}}})>,result:Col.Column<S,Layout.Viewed<P.Output,U32>> & Maybe<&2,Unit>) -> D.Store(~S):
  match result:
    case (output,_):Product.Owner{Product.Owner{input,Layout.ColumnSlot{output}},rest}
def seeded_store(~S:Data,seedError:Bool,tick:Tick.Tick,store:D.Store(~S)) -> D.Store(~S):
  match seedError store:
    case False{} store:store
    case True{} Product.Owner{Product.Owner{input,Layout.ColumnSlot{output}},rest}:seeded_column(~S,rest,input,Col.modify_runtime(~S,~Layout.Viewed<P.Output,U32>,~Unit,error_seed,output,0,tick))
def historical_world(~S:Data,now:Tick.Tick,+stamp:Tick.Tick,seedError:Bool,world:Application.Runtime(~S)) -> Application.Runtime(~S):
  match world:
    case W.World{namespace,allocator,store,resource,events,pending,registrations,nextSystem,_,lifecycle}:W.World{namespace,allocator,seeded_store(~S,seedError,stamp,historical_store(~S,stamp,store)),resource,events,pending,registrations,nextSystem,Clock.State{now,[]},lifecycle}
def historical_app(~S:Data,~mode:Query.Mode,prior:Maybe<&2,Tick.Tick>,application:Application.QueryApp(~S,~mode)) -> Application.QueryApp(~S,~mode):
  match application:
    case Execute.Application{world,Sys.Owner{namespace,id,name,access,_,local}}:Execute.Application{world,Sys.Owner{namespace,id,name,access,prior,local}}
def built(~S:Data,~mode:Query.Mode,factory:W.Factory,prior:Maybe<&2,Tick.Tick>,result:Execute.Built<Application.QueryApp(~S,~mode),Application.Runtime(~S),Body.Local>) -> IO(String):
  match result:
    case Execute.Built{application}:IO.bind(Application.QueryApp(~S,~mode) & Execute.Status<String,String>,String,Application.run_once(~S,~mode,historical_app(~S,~mode,prior,application)),Application.first(~S,~mode,factory))
    case Execute.BuildRefused{_,_}:IO.pure(String,"ERROR: definition")
def created(~S:Data,~mode:Query.Mode,now:Tick.Tick,stamp:Tick.Tick,prior:Maybe<&2,Tick.Tick>,seedError:Bool,result:W.Creation<S,D.Store(~S),D.Resources(~S),Unit>) -> IO(String):
  match result:
    case W.Created{factory,world}:built(~S,~mode,factory,prior,Execute.define_framework(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.Ops(~S),~Body.Local,~String,~String,~Application.program(~S,~mode),~Body.run(~S),historical_world(~S,now,stamp,seedError,Application.spawn(~S,18n,world)),"query",Body.Local{ALeaf{900},0}))
    case W.CreateRejected{_,_}:IO.pure(String,"ERROR: creation")
def scenario(~S:Data,~mode:Query.Mode,now:Tick.Tick,stamp:Tick.Tick,prior:Maybe<&2,Tick.Tick>,seedError:Bool) -> IO(String):
  created(~S,~mode,now,stamp,prior,seedError,W.create(~S,~D.Store(~S),~D.Resources(~S),~Unit,~D.empty(~S),W.factory(),D.resource(~S)))

type First is Data:
  First{}
type Second is Data:
  Second{}
def main() -> IO(Unit):
  IO.bind(String,Unit,scenario(~First,~Query.ParallelWhere{Life.Added{}},Tick.Tick{0n,0},Tick.Tick{0n,0},Some{Tick.Tick{0n,0}},False{}),zero => IO.bind(String,Unit,scenario(~First,~Query.ParallelWhere{Life.Changed{}},Tick.Tick{0n,4294967295},Tick.Tick{0n,4294967295},Some{Tick.Tick{0n,4294967294}},False{}),wrap => IO.bind(String,Unit,scenario(~Second,~Query.SerialWhere{Life.Changed{}},Tick.Tick{3n,0},Tick.Tick{0n,0},Some{Tick.Tick{0n,0}},False{}),old => IO.bind(String,Unit,scenario(~Second,~Query.ParallelWhere{Life.Changed{}},Tick.Tick{3n,0},Tick.Tick{3n,0},Some{Tick.Tick{0n,0}},False{}),recent => IO.bind(String,Unit,scenario(~First,~Query.ParallelWhere{Life.Changed{}},Tick.Tick{0n,0},Tick.Tick{0n,0},None{},True{}),error => IO.bind(String,Unit,scenario(~Second,~Query.SerialWhere{Life.Added{}},Tick.Tick{0n,0},Tick.Tick{0n,0},None{},True{}),serial => IO.print("First/zero-cursor=" ++ zero ++ "\nFirst/wrap=" ++ wrap ++ "\nSecond/dormant-old=" ++ old ++ "\nSecond/dormant-recent=" ++ recent ++ "\nFirst/error=" ++ error ++ "\nSecond/error-serial=" ++ serial)))))))
