import Base
import ./input.bend as Input
import ./sequence.bend as Sequence
import ./observable-resource.bend as D
import ./bridge.bend as B
import ./owner-observer.bend as OwnerProbe
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-resource-system.bend as P
import ./fixture.bend as C
import ../automatic-app-observation-v1/app.bend as App
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-query-declaration.bend as Query
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/system.bend as Sys
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
# Affine invocation input and output, in addition to affine resource state.
def body_flag(~H:Type,~caps:D.write_ops(~C.Counter,~U32,H),owner:H,result:Array<Bool> & Bool) -> H & (T.Outcome<C.Error> & C.Output):
  match result:
    case (_,fail):C.body(~H,~caps,fail,owner)
def body(~H:Type,~caps:D.write_ops(~C.Counter,~U32,H),args:Input.Args,owner:H) -> H & (T.Outcome<C.Error> & C.Output):
  match args:
    case Input.Args{flags}:body_flag(~H,~caps,owner,Array.get(Bool,flags,0))
def declaration(~S:Data) -> D.Declaration<S,Col.Column<S,Unit>,C.Counter,U32,D.write_ops(~C.Counter,~U32),U32>:
  D.write(~S,~Col.Column<S,Unit>,~C.Counter,~U32,~U32,~C.view,~U32.show,Schema.resource(~S,~C.Counter,"Counter"))
def mode(value:Query.Mode) -> String:
  match value:
    case Query.Read{}:"Read"
    case Query.Write{}:"Write"
    case _:"OTHER"
def clause(~S:Data,value:Query.Clause<S>) -> String:
  match value:
    case Query.Clause{name,kind}:name ++ ":" ++ mode(kind)
def binding(~S:Data,value:App.Binding<S>) -> String:
  match value:
    case App.Binding{namespace,id,name,access,cursor,slot,clauses}:U32.show(namespace) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":access=" ++ List.show(&2,String,(s=>s),access) ++ ":cursor=" ++ U32.show(cursor) ++ ":slot=" ++ slot ++ ":clauses=" ++ List.show(&2,Query.Clause<S>,clause(~S),clauses)
def debug(~S:Data,~Rows:Data,value:Maybe<&2,App.Product<List<&2,App.Binding<S>>,App.Observation<Rows>>>) -> String:
  match value:
    case None{}:"Disabled"
    case Some{App.Product{bindings,App.Observation{_,rendered}}}:"Debug{bindings=" ++ List.show(&2,App.Binding<S>,binding(~S),bindings) ++ "|resources=" ++ List.show(&2,String,(s=>s),rendered) ++ "}"
def args_value(result:Array<Bool> & Bool) -> String:
  match result:
    case (_,value):"RegistrationRejected{arg=" ++ Bool.show(value) ++ "}"
def rejected_args(args:Input.Args) -> String:
  match args:
    case Input.Args{flags}:args_value(Array.get(Bool,flags,0))
def restore(~S:Data,~Owners:Type,~Rows:Data,~fold:W.World<S,Col.Column<S,Unit>,C.Counter,U32> -> W.World<S,Col.Column<S,Unit>,C.Counter,U32> & App.Observation<Rows>,~describe:Owners -> Owners & List<&2,App.Binding<S>>,world:W.World<S,Col.Column<S,Unit>,C.Counter,U32>,owners:Owners,enabled:Bool) -> App.ApplicationType<S,Col.Column<S,Unit>,C.Counter,U32,Owners,Rows,fold,describe>:
  App.Application{world,owners,enabled}
def labels_joined(~S:Data,~Owners:Type,result:Owners & List<&2,App.Binding<S>>) -> Owners & String:
  match result:
    case (owners,values):(owners,List.show(&2,App.Binding<S>,binding(~S),values))
def owner_labels(~S:Data,~Owners:Type,describe:Owners -> Owners & List<&2,App.Binding<S>>,owners:Owners) -> Owners & String:
  labels_joined(~S,~Owners,describe(owners))
def app_observed(~S:Data,~Owners:Type,~Rows:Data,~fold:W.World<S,Col.Column<S,Unit>,C.Counter,U32> -> W.World<S,Col.Column<S,Unit>,C.Counter,U32> & App.Observation<Rows>,~describe:Owners -> Owners & List<&2,App.Binding<S>>,app:App.ApplicationType<S,Col.Column<S,Unit>,C.Counter,U32,Owners,Rows,fold,describe>,label:String) -> App.ApplicationType<S,Col.Column<S,Unit>,C.Counter,U32,Owners,Rows,fold,describe> & String:
  match app:
    case App.Application{world,owners,enabled}:OwnerProbe.observed(~W.World<S,Col.Column<S,Unit>,C.Counter,U32>,~Owners,~App.ApplicationType<S,Col.Column<S,Unit>,C.Counter,U32,Owners,Rows,fold,describe>,restore(~S,~Owners,~Rows,~fold,~describe),C.world(~S),owner_labels(~S,~Owners,describe),world,owners,enabled,label)
def snapshot_observed(~S:Data,~Owners:Type,~Rows:Data,~fold:W.World<S,Col.Column<S,Unit>,C.Counter,U32> -> W.World<S,Col.Column<S,Unit>,C.Counter,U32> & App.Observation<Rows>,~describe:Owners -> Owners & List<&2,App.Binding<S>>,result:App.ApplicationType<S,Col.Column<S,Unit>,C.Counter,U32,Owners,Rows,fold,describe> & Maybe<&2,App.Product<List<&2,App.Binding<S>>,App.Observation<Rows>>>) -> App.ApplicationType<S,Col.Column<S,Unit>,C.Counter,U32,Owners,Rows,fold,describe> & String:
  match result:
    case (app,value):app_observed(~S,~Owners,~Rows,~fold,~describe,app,debug(~S,~Rows,value))
def snapshot(~S:Data,~Owners:Type,~Rows:Data,~fold:W.World<S,Col.Column<S,Unit>,C.Counter,U32> -> W.World<S,Col.Column<S,Unit>,C.Counter,U32> & App.Observation<Rows>,~describe:Owners -> Owners & List<&2,App.Binding<S>>,app:App.ApplicationType<S,Col.Column<S,Unit>,C.Counter,U32,Owners,Rows,fold,describe>) -> App.ApplicationType<S,Col.Column<S,Unit>,C.Counter,U32,Owners,Rows,fold,describe> & String:
  snapshot_observed(~S,~Owners,~Rows,~fold,~describe,App.snapshot(~S,~Col.Column<S,Unit>,~C.Counter,~U32,~Owners,~Rows,~fold,~describe,app))
def registered(~S:Data,~H:Type,~Rows:Data,~kind:Query.Mode,~runFn:W.World<S,Col.Column<S,Unit>,C.Counter,U32> -> Input.Args -> Sys.Outcome<W.World<S,Col.Column<S,Unit>,C.Counter,U32>,C.Error,C.Output>,~fold:W.World<S,Col.Column<S,Unit>,C.Counter,U32> -> W.World<S,Col.Column<S,Unit>,C.Counter,U32> & App.Observation<Rows>,~describe:(H & P.Owner<S,Sys.Registry<S,Col.Column<S,Unit>,C.Counter,U32,Input.Args,C.Error,C.Output,runFn>,kind>) -> (H & P.Owner<S,Sys.Registry<S,Col.Column<S,Unit>,C.Counter,U32,Input.Args,C.Error,C.Output,runFn>,kind>) & List<&2,App.Binding<S>>,app:App.ApplicationType<S,Col.Column<S,Unit>,C.Counter,U32,H & P.Owner<S,Sys.Registry<S,Col.Column<S,Unit>,C.Counter,U32,Input.Args,C.Error,C.Output,runFn>,kind>,Rows,fold,describe>) -> String:
  Sequence.go(~App.ApplicationType<S,Col.Column<S,Unit>,C.Counter,U32,(H & P.Owner<S,Sys.Registry<S,Col.Column<S,Unit>,C.Counter,U32,Input.Args,C.Error,C.Output,runFn>,kind>),Rows,fold,describe>,[Sequence.Enable{True{}},Sequence.Snapshot{},Sequence.Snapshot{},Sequence.Enable{False{}},Sequence.Snapshot{},Sequence.Enable{True{}},Sequence.Invoke{False{}},Sequence.Snapshot{},Sequence.Invoke{True{}},Sequence.Snapshot{},Sequence.Invoke{False{}},Sequence.Snapshot{},Sequence.Snapshot{}],app,Sequence.snapshots(~App.ApplicationType<S,Col.Column<S,Unit>,C.Counter,U32,(H & P.Owner<S,Sys.Registry<S,Col.Column<S,Unit>,C.Counter,U32,Input.Args,C.Error,C.Output,runFn>,kind>),Rows,fold,describe>,~snapshot(~S,~(H & P.Owner<S,Sys.Registry<S,Col.Column<S,Unit>,C.Counter,U32,Input.Args,C.Error,C.Output,runFn>,kind>),~Rows,~fold,~describe),7n),[App.enable_debug(~S,~Col.Column<S,Unit>,~C.Counter,~U32,~(H & P.Owner<S,Sys.Registry<S,Col.Column<S,Unit>,C.Counter,U32,Input.Args,C.Error,C.Output,runFn>,kind>),~Rows,~fold,~describe),App.enable_debug(~S,~Col.Column<S,Unit>,~C.Counter,~U32,~(H & P.Owner<S,Sys.Registry<S,Col.Column<S,Unit>,C.Counter,U32,Input.Args,C.Error,C.Output,runFn>,kind>),~Rows,~fold,~describe),App.enable_debug(~S,~Col.Column<S,Unit>,~C.Counter,~U32,~(H & P.Owner<S,Sys.Registry<S,Col.Column<S,Unit>,C.Counter,U32,Input.Args,C.Error,C.Output,runFn>,kind>),~Rows,~fold,~describe)],[B.run_latest_resource(~S,~Col.Column<S,Unit>,~C.Counter,~U32,~Input.Args,~C.Error,~C.Output,~kind,~runFn,~H,~Rows,~fold,~describe),B.run_latest_resource(~S,~Col.Column<S,Unit>,~C.Counter,~U32,~Input.Args,~C.Error,~C.Output,~kind,~runFn,~H,~Rows,~fold,~describe),B.run_latest_resource(~S,~Col.Column<S,Unit>,~C.Counter,~U32,~Input.Args,~C.Error,~C.Output,~kind,~runFn,~H,~Rows,~fold,~describe)],None{})
def failed(~S:Data,~H:Type,~Rows:Data,~fold:W.World<S,Col.Column<S,Unit>,C.Counter,U32> -> W.World<S,Col.Column<S,Unit>,C.Counter,U32> & App.Observation<Rows>,~describe:H -> H & List<&2,App.Binding<S>>,app:App.ApplicationType<S,Col.Column<S,Unit>,C.Counter,U32,H,Rows,fold,describe>) -> String:
  "DEFINE_FAILED"
def register(~S:Data,~H:Type,~Rows:Data,~fold:W.World<S,Col.Column<S,Unit>,C.Counter,U32> -> W.World<S,Col.Column<S,Unit>,C.Counter,U32> & App.Observation<Rows>,~describe:H -> H & List<&2,App.Binding<S>>,app:App.ApplicationType<S,Col.Column<S,Unit>,C.Counter,U32,H,Rows,fold,describe>) -> String:
  B.register_resource_with(~S,~Col.Column<S,Unit>,~C.Counter,~U32,~D.write_ops(~C.Counter,~U32),~Input.Args,~C.Error,~C.Output,~U32,~declaration(~S),~body,~H,~Rows,~fold,~describe,~String,~registered(~S),~failed(~S,~H,~Rows,~fold,~describe),app,"CounterUpdate","Update")
def created(~S:Data,count:Nat,result:W.Creation<S,Col.Column<S,Unit>,C.Counter,U32>) -> String:
  match result:
    case W.Created{_,world}:App.start(~S,~Col.Column<S,Unit>,~C.Counter,~U32,~String,~register(~S),C.entities(~S,count,world))
    case W.CreateRejected{_,_}:"CREATE_FAILED"
def scenario(~S:Data,count:Nat) -> String:
  created(~S,count,W.create(~S,~Col.Column<S,Unit>,~C.Counter,~U32,~C.empty(~S),W.factory(),C.Counter{Array.new(U32,0n,10)}))
