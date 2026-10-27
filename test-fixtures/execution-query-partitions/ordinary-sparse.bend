import ../../src/ecs/execution-resource-store.bend as ResourceStore
import ../../src/ecs/execution-resource-program.bend as ResourceProgram
import ../../src/ecs/execution-resource-query-leaf.bend as Leaf
import ../../src/ecs/execution-resource-query-execution.bend as Execution
import ../../src/ecs/execution-parallel-scope-registry.bend as Tree
import ../../src/ecs/execution-generalized-root-application.bend as Application
import ../../src/ecs/execution-parallel-root-application.bend as Root
import ../../src/ecs/execution-condition-registry.bend as Conditions
import ../../src/ecs/dependency-application.bend as App
import ../../src/ecs/dependency-executor.bend as Exec
import ../../src/ecs/owner-product.bend as Product
import Base
import ./schema.bend as S
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/execution-query-recipe.bend as Recipe
import ../../src/ecs/execution-query-matches.bend as Match
import ../../src/ecs/execution-query-store.bend as Store
import ../../src/ecs/execution-command-buffer.bend as Commands
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-system.bend as Task
import ../../src/ecs/world.bend as W
import ../../src/ecs/entity-key.bend as Key
import ../../src/ecs/execution-declaration.bend as D
import ../../src/ecs/execution-parallel-scope.bend as Scope
import ../../src/ecs/execution-reservation-task.bend as Effect

def WC() -> Type:L.columns(~S.SchemaA,S.layout_a())
def HStore() -> Type:Store.Storage<S.SchemaA,S.layout_a()>
def HResources() -> Type:ResourceStore.Storage<S.SchemaA,L.EmptyLayout{}>
def World() -> Type:W.World<S.SchemaA,WC(),Unit,Unit>
def Caps(H:Type) -> Type:Q.GeneralOutputWriter<S.SchemaA,H,S.Position,U32,InteractionOutput,String>
def Ops(Permit:Data,H:Type) -> Type:Caps(H)
def eligible_position(value:Maybe<&2,U32>) -> Bool:
  match value:
    case None{}:False{}
    case Some{+value}:Bool.or(U32.is_eq(U32.mod(value,10),0),U32.is_ge(value,19))
type Update is Data:
  Update{target:W.Handle<S.SchemaA>,before:U32,impulse:U32,after:U32}
type InteractionOutput is Data:
  Direct{updates:List<&2,Update>}
  TargetOwned{sources:List<&2,Q.GeneralRow<S.SchemaA,U32>>,updates:List<&2,Update>}
type DerivedEffect is Data:
  DerivedEffect{source:W.Handle<S.SchemaA>,target:W.Handle<S.SchemaA>,impulse:U32}
type SerialRecord is Data:
  SerialRecord{source:W.Handle<S.SchemaA>,target:W.Handle<S.SchemaA>,impulse:U32,before:Q.GeneralLookup<U32>,after:Q.GeneralLookup<U32>,applied:Bool}
type AlgorithmStage is Data:
  TraversalStage{name:String,output:InteractionOutput,report:Q.Report<String>,rows:Q.GeneralReport<S.SchemaA,U32>}
  SerialStage{sources:Q.GeneralReport<S.SchemaA,U32>,effects:List<&2,DerivedEffect>,records:List<&2,SerialRecord>,rows:Q.GeneralReport<S.SchemaA,U32>}
type QueryResult is Data:
  QueryResult{lookup:Q.GeneralLookup<U32>,count:Q.GeneralCount,single:Q.GeneralSingle<S.SchemaA,U32>,algorithms:List<&2,AlgorithmStage>}
type Token is Type:
  Token{array:Array<U32>}
  DeferredToken{transform:S.Position -> S.Position & Array<U32>}
type Local is Type:
  Local{target:W.Handle<S.SchemaA>,token:Token,queue:Commands.Buffer<S.SchemaA,S.Position,Unit>,algorithms:Bool}
def moved(token:Array<U32>,owner:S.Position) -> S.Position & Array<U32>:
  match owner:
    case S.Position{values}:(S.Position{Array.set(U32,values,0,999)},token)
def completed(fail:Bool,lookup:QueryResult) -> Sys.Completion<String,QueryResult>:
  match fail:
    case False{}:Sys.Success{lookup}
    case True{}:Sys.BodyError{"retained-body-error",lookup}
def observed(~fail:Bool,~H:Type,local:Local,+report:Q.GeneralReport<S.SchemaA,U32>,result:H & Q.GeneralLookup<U32>) -> H & (Local & Sys.Completion<String,QueryResult>):
  match result:
    case (scope,lookup):(scope,(local,completed(fail,QueryResult{lookup,Q.general_count(~S.SchemaA,~U32,report),Q.general_single(~S.SchemaA,~U32,report),[]})))
def edited(~fail:Bool,~H:Type,get:H -> W.Handle<S.SchemaA> -> H & Q.GeneralLookup<U32>,+report:Q.GeneralReport<S.SchemaA,U32>,+target:W.Handle<S.SchemaA>,queue:Commands.Buffer<S.SchemaA,S.Position,Unit>,result:H & Q.GeneralEdit<S.Position,Array<U32>>) -> H & (Local & Sys.Completion<String,QueryResult>):
  match result:
    case (scope,Q.GeneralEdited{token}):observed(~fail,~H,Local{target,Token{token},queue,False{}},report,get(scope,target))
    case (scope,Q.GeneralUnchanged{unused}):observed(~fail,~H,Local{target,DeferredToken{unused},queue,False{}},report,get(scope,target))
def selected(~fail:Bool,~H:Type,get:H -> W.Handle<S.SchemaA> -> H & Q.GeneralLookup<U32>,modify:@-Out:Type -> H -> W.Handle<S.SchemaA> -> (S.Position -> S.Position & Out) -> H & Q.GeneralEdit<S.Position,Out>,+target:W.Handle<S.SchemaA>,token:Array<U32>,queue:Commands.Buffer<S.SchemaA,S.Position,Unit>,result:H & Q.GeneralReport<S.SchemaA,U32>) -> H & (Local & Sys.Completion<String,QueryResult>):
  match result:
    case (scope,report):edited(~fail,~H,get,report,target,queue,modify(Array<U32>,scope,target,owner=>moved(token,owner)))
def run_caps(~fail:Bool,~H:Type,caps:Caps(H),scope:H,local:Local) -> H & (Local & Sys.Completion<String,QueryResult>):
  match caps local:
    case Q.GeneralOutputWriter{Q.GeneralReader{query,get},modify,_} Local{target,Token{token},queue,_}:selected(~fail,~H,get,modify,target,token,queue,query(scope))
    case _ local:(scope,(local,Sys.BodyError{"unavailable-or-deferred",QueryResult{Q.LookupRefused{},Q.CountSelectionRefused{},Q.SingleSelectionRefused{},[]}}))
def read_rows(~H:Type,caps:Caps(H),scope:H) -> H & Q.GeneralReport<S.SchemaA,U32>:
  match caps:
    case Q.GeneralOutputWriter{Q.GeneralReader{query,_},_,_}:query(scope)
    case _:(scope,Q.SelectionRefused{})
def lookup_row(~H:Type,caps:Caps(H),scope:H,target:W.Handle<S.SchemaA>) -> H & Q.GeneralLookup<U32>:
  match caps:
    case Q.GeneralOutputWriter{Q.GeneralReader{_,get},_,_}:get(scope,target)
    case _:(scope,Q.LookupRefused{})
def sources(report:Q.GeneralReport<S.SchemaA,U32>) -> List<&2,Q.GeneralRow<S.SchemaA,U32>>:
  match report:
    case Q.SelectedRows{rows}:rows
    case Q.SelectionRefused{}:[]
def split_output(output:InteractionOutput) -> InteractionOutput & InteractionOutput:
  match output:
    case Direct{updates}:(Direct{updates},Direct{[]})
    case TargetOwned{+rows,updates}:(TargetOwned{rows,updates},TargetOwned{rows,[]})
def output_updates(output:InteractionOutput) -> List<&2,Update>:
  match output:
    case Direct{updates}:updates
    case TargetOwned{_,updates}:updates
def append_updates(output:InteractionOutput,updates:List<&2,Update>) -> InteractionOutput:
  match output:
    case Direct{left}:Direct{List.append(&2,Update,left,updates)}
    case TargetOwned{rows,left}:TargetOwned{rows,List.append(&2,Update,left,updates)}
def merge_output(left:InteractionOutput,right:InteractionOutput) -> InteractionOutput:
  append_updates(left,output_updates(right))
def updated(+target:W.Handle<S.SchemaA>,+before:U32,+impulse:U32,owner:S.Position,output:InteractionOutput) -> S.Position & (InteractionOutput & Maybe<&2,String>):
  match owner:
    case S.Position{values}:(S.Position{Array.set(U32,values,0,U32.add(before,impulse))},(append_updates(output,[Update{target,before,impulse,U32.add(before,impulse)}]),None{}))
def impulse_for(+target:W.Handle<S.SchemaA>,rows:List<&2,Q.GeneralRow<S.SchemaA,U32>>) -> U32:
  match rows:
    case []:0
    case Q.GeneralRow{source,Some{value}} <> rest:U32.add(Bool.pick(U32,U32.is_eq(W.handle_index(~S.SchemaA,source),W.handle_index(~S.SchemaA,target)),0,value),impulse_for(target,rest))
    case _ <> rest:impulse_for(target,rest)
def dispatch_owned(+target:W.Handle<S.SchemaA>,view:U32,owner:S.Position,output:InteractionOutput) -> S.Position & (InteractionOutput & Maybe<&2,String>):
  match output:
    case Direct{updates}:updated(target,view,100,owner,Direct{updates})
    case TargetOwned{+rows,updates}:updated(target,view,impulse_for(target,rows),owner,TargetOwned{rows,updates})
def dispatch_row(target:W.Handle<S.SchemaA>,view:U32,owner:S.Position,output:InteractionOutput) -> S.Position & (InteractionOutput & Maybe<&2,String>):
  dispatch_owned(target,view,owner,output)
def selection(~bound:Recipe.Bound,~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S.SchemaA,~HStore(),~HResources(),~H,~B),~cw:Build.ComponentWrite(~S.SchemaA,~HStore(),~HResources(),~H,~B),~rr:Build.ResourceRead(~S.SchemaA,~HStore(),~HResources(),~H,~B),~rw:Build.ResourceWrite(~S.SchemaA,~HStore(),~HResources(),~H,~B),~query:Build.Query(~S.SchemaA,~WC(),~HStore(),~HResources(),~H,~B),~life:Build.Lifecycle(~S.SchemaA,~WC(),~HStore(),~HResources(),~H,~B),book:B) -> B & Ops(Permit,H):
  Build.general_output_query(~S.SchemaA,~WC(),~HStore(),~HResources(),~S.layout_a(),~L.InLeft{L.AtLeaf{}},~{==},~{==},~Store.Sparse{},~{==},~bound,~Match.Optional{},~eligible_position,~InteractionOutput,~String,~split_output,~merge_output,~dispatch_row,~H,~B,~query,book)
def program(~bound:Recipe.Bound,~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~S.SchemaA,~WC(),~HStore(),~HResources(),~Permit,~H,~B),book:B) -> B & Ops(Permit,H):
  builder(Ops,selection(~bound,~Permit,~H,~B),book)
def left_program(~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~S.SchemaA,~WC(),~HStore(),~HResources(),~Permit,~H,~B),book:B) -> B & Ops(Permit,H):
  program(~Recipe.With{L.InRight{L.AtLeaf{}}},~Permit,~H,~B,~builder,book)
def right_program(~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~S.SchemaA,~WC(),~HStore(),~HResources(),~Permit,~H,~B),book:B) -> B & Ops(Permit,H):
  program(~Recipe.Without{L.InRight{L.AtLeaf{}}},~Permit,~H,~B,~builder,book)
def other_selected(handle:W.Handle<S.SchemaA>,rest:Maybe<&2,W.Handle<S.SchemaA>>,same:Bool) -> Maybe<&2,W.Handle<S.SchemaA>>:
  match same:
    case True{}:rest
    case False{}:Some{handle}
def other_target(+source:W.Handle<S.SchemaA>,rows:List<&2,Q.GeneralRow<S.SchemaA,U32>>) -> Maybe<&2,W.Handle<S.SchemaA>>:
  match rows:
    case []:None{}
    case Q.GeneralRow{+target,Some{_}} <> rest:other_selected(target,other_target(source,rest),U32.is_eq(W.handle_index(~S.SchemaA,source),W.handle_index(~S.SchemaA,target)))
    case _ <> rest:other_target(source,rest)
def added(impulse:U32,result:S.Position & U32) -> S.Position & Unit:
  match result:
    case (S.Position{values},value):(S.Position{Array.set(U32,values,0,U32.add(value,impulse))},Unit{})
def serial_modify(~H:Type,caps:Caps(H),scope:H,target:W.Handle<S.SchemaA>,impulse:U32) -> H & Q.GeneralEdit<S.Position,Unit>:
  match caps:
    case Q.GeneralOutputWriter{_,modify,_}:modify(Unit,scope,target,owner=>added(impulse,S.position_view(owner)))
    case _:(scope,Q.GeneralUnchanged{owner=>added(impulse,S.position_view(owner))})
def edit_applied(~H:Type,result:H & Q.GeneralEdit<S.Position,Unit>) -> H & Bool:
  match result:
    case (scope,Q.GeneralEdited{Unit{}}):(scope,True{})
    case (scope,Q.GeneralUnchanged{_}):(scope,False{})
def serial_after(~H:Type,source:W.Handle<S.SchemaA>,target:W.Handle<S.SchemaA>,impulse:U32,before:Q.GeneralLookup<U32>,applied:Bool,result:H & Q.GeneralLookup<U32>) -> H & List<&2,SerialRecord>:
  match result:
    case (scope,after):(scope,[SerialRecord{source,target,impulse,before,after,applied}])
def serial_edited(~H:Type,~caps:Caps(H),source:W.Handle<S.SchemaA>,+target:W.Handle<S.SchemaA>,impulse:U32,before:Q.GeneralLookup<U32>,result:H & Bool) -> H & List<&2,SerialRecord>:
  match result:
    case (scope,applied):serial_after(~H,source,target,impulse,before,applied,lookup_row(~H,caps,scope,target))
def serial_before(~H:Type,~caps:Caps(H),source:W.Handle<S.SchemaA>,+target:W.Handle<S.SchemaA>,+impulse:U32,result:H & Q.GeneralLookup<U32>) -> H & List<&2,SerialRecord>:
  match result:
    case (scope,before):serial_edited(~H,~caps,source,target,impulse,before,edit_applied(~H,serial_modify(~H,caps,scope,target,impulse)))
def serial_one(~H:Type,~caps:Caps(H),scope:H,source:W.Handle<S.SchemaA>,impulse:U32,target:Maybe<&2,W.Handle<S.SchemaA>>) -> H & List<&2,SerialRecord>:
  match target:
    case None{}:(scope,[])
    case Some{+target}:serial_before(~H,~caps,source,target,impulse,lookup_row(~H,caps,scope,target))
def serial_join(~H:Type,left:List<&2,SerialRecord>,result:H & List<&2,SerialRecord>) -> H & List<&2,SerialRecord>:
  match result:
    case (scope,right):(scope,List.append(&2,SerialRecord,left,right))
def derived_effect(source:W.Handle<S.SchemaA>,impulse:U32,target:Maybe<&2,W.Handle<S.SchemaA>>,rest:List<&2,DerivedEffect>) -> List<&2,DerivedEffect>:
  match target:
    case None{}:rest
    case Some{target}:DerivedEffect{source,target,impulse} <> rest
def derive_effects(rows:List<&2,Q.GeneralRow<S.SchemaA,U32>>,+all:List<&2,Q.GeneralRow<S.SchemaA,U32>>) -> List<&2,DerivedEffect>:
  match rows:
    case []:[]
    case Q.GeneralRow{+source,Some{value}} <> rest:derived_effect(source,value,other_target(source,all),derive_effects(rest,all))
    case _ <> rest:derive_effects(rest,all)
def effects_continue(~H:Type,next:H -> H & List<&2,SerialRecord>,result:H & List<&2,SerialRecord>) -> H & List<&2,SerialRecord>:
  match result:
    case (scope,records):serial_join(~H,records,next(scope))
def apply_effects(~H:Type,~caps:Caps(H),effects:List<&2,DerivedEffect>,scope:H) -> H & List<&2,SerialRecord>:
  match effects:
    case []:(scope,[])
    case DerivedEffect{source,target,impulse} <> rest:effects_continue(~H,scope=>apply_effects(~H,~caps,rest,scope),serial_one(~H,~caps,scope,source,impulse,Some{target}))
def unique_targets(rows:List<&2,Q.GeneralRow<S.SchemaA,U32>>) -> List<&2,W.Handle<S.SchemaA>>:
  match rows:
    case []:[]
    case Q.GeneralRow{target,Some{_}} <> rest:target <> unique_targets(rest)
    case _ <> rest:unique_targets(rest)
def duplicate_targets(rows:List<&2,Q.GeneralRow<S.SchemaA,U32>>) -> List<&2,W.Handle<S.SchemaA>>:
  match rows:
    case []:[]
    case Q.GeneralRow{+target,Some{_}} <> _:[target,target]
    case _ <> rest:duplicate_targets(rest)
def traversal_observed(~H:Type,name:String,output:InteractionOutput,report:Q.Report<String>,result:H & Q.GeneralReport<S.SchemaA,U32>) -> H & AlgorithmStage:
  match result:
    case (scope,rows):(scope,TraversalStage{name,output,report,rows})
def traversal_done(~H:Type,~caps:Caps(H),name:String,result:H & (InteractionOutput & Q.Report<String>)) -> H & AlgorithmStage:
  match result:
    case (scope,(output,report)):traversal_observed(~H,name,output,report,read_rows(~H,caps,scope))
def serial_observed(~H:Type,sources:Q.GeneralReport<S.SchemaA,U32>,effects:List<&2,DerivedEffect>,records:List<&2,SerialRecord>,result:H & Q.GeneralReport<S.SchemaA,U32>) -> H & AlgorithmStage:
  match result:
    case (scope,rows):(scope,SerialStage{sources,effects,records,rows})
def algorithms_complete(~H:Type,direct:AlgorithmStage,serial:AlgorithmStage,duplicate:AlgorithmStage,result:H & AlgorithmStage) -> H & List<&2,AlgorithmStage>:
  match result:
    case (scope,parallel):(scope,[direct,serial,duplicate,parallel])
def algorithms_duplicate(~H:Type,~caps:Caps(H),direct:AlgorithmStage,serial:AlgorithmStage,+rows:List<&2,Q.GeneralRow<S.SchemaA,U32>>,result:H & AlgorithmStage) -> H & List<&2,AlgorithmStage>:
  match result:
    case (scope,duplicate):algorithms_complete(~H,direct,serial,duplicate,traversal_done(~H,~caps,"target-reduction",Q.general_traverse(~S.SchemaA,~H,~S.Position,~U32,~InteractionOutput,~String,caps,Q.Parallel{},scope,TargetOwned{rows,[]},Q.ExplicitHandles{unique_targets(rows)})))
def algorithms_serial(~H:Type,~caps:Caps(H),direct:AlgorithmStage,+rows:List<&2,Q.GeneralRow<S.SchemaA,U32>>,result:H & AlgorithmStage) -> H & List<&2,AlgorithmStage>:
  match result:
    case (scope,serial):algorithms_duplicate(~H,~caps,direct,serial,rows,traversal_done(~H,~caps,"duplicate",Q.general_traverse(~S.SchemaA,~H,~S.Position,~U32,~InteractionOutput,~String,caps,Q.Parallel{},scope,TargetOwned{rows,[]},Q.ExplicitHandles{duplicate_targets(rows)})))
def algorithms_applied(~H:Type,~caps:Caps(H),direct:AlgorithmStage,rows:List<&2,Q.GeneralRow<S.SchemaA,U32>>,detached:Q.GeneralReport<S.SchemaA,U32>,effects:List<&2,DerivedEffect>,result:H & List<&2,SerialRecord>) -> H & List<&2,AlgorithmStage>:
  match result:
    case (scope,records):algorithms_serial(~H,~caps,direct,rows,serial_observed(~H,detached,effects,records,read_rows(~H,caps,scope)))
def algorithms_effects(~H:Type,~caps:Caps(H),scope:H,direct:AlgorithmStage,rows:List<&2,Q.GeneralRow<S.SchemaA,U32>>,detached:Q.GeneralReport<S.SchemaA,U32>,+effects:List<&2,DerivedEffect>) -> H & List<&2,AlgorithmStage>:
  algorithms_applied(~H,~caps,direct,rows,detached,effects,apply_effects(~H,~caps,effects,scope))
def algorithms_sources(~H:Type,~caps:Caps(H),scope:H,direct:AlgorithmStage,detached:Q.GeneralReport<S.SchemaA,U32>,+rows:List<&2,Q.GeneralRow<S.SchemaA,U32>>) -> H & List<&2,AlgorithmStage>:
  algorithms_effects(~H,~caps,scope,direct,rows,detached,derive_effects(rows,rows))
def algorithms_detached(~H:Type,~caps:Caps(H),direct:AlgorithmStage,result:H & Q.GeneralReport<S.SchemaA,U32>) -> H & List<&2,AlgorithmStage>:
  match result:
    case (scope,+detached):algorithms_sources(~H,~caps,scope,direct,detached,sources(detached))
def algorithms_direct(~H:Type,~caps:Caps(H),result:H & AlgorithmStage) -> H & List<&2,AlgorithmStage>:
  match result:
    case (scope,direct):algorithms_detached(~H,~caps,direct,read_rows(~H,caps,scope))
def algorithms(~H:Type,~caps:Caps(H),scope:H) -> H & List<&2,AlgorithmStage>:
  algorithms_direct(~H,~caps,traversal_done(~H,~caps,"direct",Q.general_traverse(~S.SchemaA,~H,~S.Position,~U32,~InteractionOutput,~String,caps,Q.Parallel{},scope,Direct{[]},Q.AllMatched{})))
def traced(value:QueryResult,trace:List<&2,AlgorithmStage>) -> QueryResult:
  match value:
    case QueryResult{lookup,count,single,_}:QueryResult{lookup,count,single,trace}
def traced_completion(value:Sys.Completion<String,QueryResult>,trace:List<&2,AlgorithmStage>) -> Sys.Completion<String,QueryResult>:
  match value:
    case Sys.Success{value}:Sys.Success{traced(value,trace)}
    case Sys.BodyError{error,value}:Sys.BodyError{error,traced(value,trace)}
def traced_run(~H:Type,trace:List<&2,AlgorithmStage>,result:H & (Local & Sys.Completion<String,QueryResult>)) -> H & (Local & Sys.Completion<String,QueryResult>):
  match result:
    case (scope,(local,value)):(scope,(local,traced_completion(value,trace)))
def baseline_observed(~fail:Bool,~H:Type,~caps:Caps(H),local:Local,trace:List<&2,AlgorithmStage>,result:H & Q.GeneralReport<S.SchemaA,U32>) -> H & (Local & Sys.Completion<String,QueryResult>):
  match local result:
    case Local{+target,token,queue,enabled}, (scope,report):traced_run(~H,trace,observed(~fail,~H,Local{target,token,queue,enabled},report,lookup_row(~H,caps,scope,target)))
def algorithm_run(~fail:Bool,~H:Type,~caps:Caps(H),local:Local,result:H & List<&2,AlgorithmStage>) -> H & (Local & Sys.Completion<String,QueryResult>):
  match result:
    case (scope,trace):baseline_observed(~fail,~H,~caps,local,trace,read_rows(~H,caps,scope))
def target_attempt_done(~fail:Bool,~H:Type,~caps:Caps(H),local:Local,result:H & AlgorithmStage) -> H & (Local & Sys.Completion<String,QueryResult>):
  match result:
    case (scope,attempt):traced_run(~H,[attempt],run_caps(~fail,~H,caps,scope,local))
def target_attempt(~fail:Bool,~H:Type,~caps:Caps(H),scope:H,local:Local,failed:Bool) -> H & (Local & Sys.Completion<String,QueryResult>):
  match local failed:
    case Local{+target,token,queue,enabled} False{}:target_attempt_done(~fail,~H,~caps,Local{target,token,queue,enabled},traversal_done(~H,~caps,"target-attempt",Q.general_traverse(~S.SchemaA,~H,~S.Position,~U32,~InteractionOutput,~String,caps,Q.Parallel{},scope,Direct{[]},Q.ExplicitHandles{[target]})))
    case local _:run_caps(~fail,~H,caps,scope,local)
def run_selected(~fail:Bool,~H:Type,~caps:Caps(H),scope:H,local:Local) -> H & (Local & Sys.Completion<String,QueryResult>):
  match local:
    case Local{target,token,queue,True{}}:algorithm_run(~fail,~H,~caps,Local{target,token,queue,True{}},algorithms(~H,~caps,scope))
    case local:target_attempt(~fail,~H,~caps,scope,local,fail)
def body(~fail:Bool,~Permit:Data,~H:Type,~caps:Ops(Permit,H),scope:H,local:Local) -> Effect.Task<S.SchemaA,Permit,H & (Local & Sys.Completion<String,QueryResult>)>:
  Effect.TDone{run_selected(~fail,~H,~caps,scope,local)}
def left_body(~Permit:Data,~H:Type,~caps:Ops(Permit,H),scope:H,local:Local) -> Effect.Task<S.SchemaA,Permit,H & (Local & Sys.Completion<String,QueryResult>)>:body(~True{},~Permit,~H,~caps,scope,local)
def right_body(~Permit:Data,~H:Type,~caps:Ops(Permit,H),scope:H,local:Local) -> Effect.Task<S.SchemaA,Permit,H & (Local & Sys.Completion<String,QueryResult>)>:body(~False{},~Permit,~H,~caps,scope,local)
def LeftOwner() -> Type:Sys.Owner<S.SchemaA,WC(),HStore(),HResources(),Unit,Ops,Local,String,QueryResult,left_program,left_body>
def RightOwner() -> Type:Sys.Owner<S.SchemaA,WC(),HStore(),HResources(),Unit,Ops,Local,String,QueryResult,right_program,right_body>
def Compilation() -> Type:D.Compilation<S.SchemaA,WC(),HStore(),HResources(),Ops>
def left_compiled() -> Compilation():ResourceProgram.compile_framework(~S.SchemaA,~WC(),~HStore(),~HResources(),~Ops,~left_program)
def right_compiled() -> Compilation():ResourceProgram.compile_framework(~S.SchemaA,~WC(),~HStore(),~HResources(),~Ops,~right_program)
def LeftNode() -> Type:Leaf.node_type(~S.SchemaA,~S.layout_a(),~L.EmptyLayout{},~Unit,~String,~QueryResult,~Ops,~Local,~left_program,~left_body)
def RightNode() -> Type:Leaf.node_type(~S.SchemaA,~S.layout_a(),~L.EmptyLayout{},~Unit,~String,~QueryResult,~Ops,~Local,~right_program,~right_body)
def Nodes() -> Type:Product.Owner<LeftNode(),RightNode()>
def RegisteredLeft() -> Type:Scope.CompiledBinding<Compilation(),LeftOwner()>
def RegisteredRight() -> Type:Scope.CompiledBinding<Compilation(),RightOwner()>
def Scheduled() -> Type:Root.Scheduled<App.State<Application.Storage<S.SchemaA,S.layout_a(),L.EmptyLayout{},Unit>,Nodes(),Unit,U32>>
type WorldResult is Type:
  WorldReturned{storage:Application.Storage<S.SchemaA,S.layout_a(),L.EmptyLayout{},Unit>,nodes:Nodes(),handler:U32,report:App.Report<String,QueryResult>,previous:Maybe<&2,App.Report<String,QueryResult>>}
  TargetsRefused{world:World()}
  LeftDefinitionRefused{world:World(),compilation:Compilation(),left:Local,right:Local}
  RightDefinitionRefused{world:World(),left:RegisteredLeft(),compilation:Compilation(),right:Local}
def dispatch(nodes:Nodes(),world:World(),ids:List<&2,U32>) -> IO(Execution.RunResult<S.SchemaA,S.layout_a(),L.EmptyLayout{},Unit,Nodes(),String,QueryResult>):
  match nodes:
    case Product.Owner{left,right}:Tree.run_generalized(~S.SchemaA,~S.layout_a(),~L.EmptyLayout{},~Unit,~String,~QueryResult,LeftNode(),RightNode(),ids,world,Tree.GeneralizedPair{Tree.compile_retained_generalized_leaf(~S.SchemaA,~S.layout_a(),~L.EmptyLayout{},~Unit,~String,~QueryResult,~Ops,~Local,~left_program,~left_body,~left_compiled(),left),Tree.compile_retained_generalized_leaf(~S.SchemaA,~S.layout_a(),~L.EmptyLayout{},~Unit,~String,~QueryResult,~Ops,~Local,~right_program,~right_body,~right_compiled(),right)})
def publish(_:List<&2,U32>,world:World(),nodes:Nodes()) -> World() & (Nodes() & List<&2,U32>):(world,(nodes,[]))
def handle(count:U32,_:String) -> U32 & Exec.Handling:(U32.add(count,1),Exec.Continue{})
def available(_:String) -> Bool:True{}
def finished(previous:Maybe<&2,App.Report<String,QueryResult>>,result:Scheduled() & App.Report<String,QueryResult>) -> WorldResult:
  match result:
    case (Root.Scheduled{App.State{storage,nodes,Unit{},handler,_},_,_,_,_},report):WorldReturned{storage,nodes,handler,report,previous}
def repeated(repeat:Bool,result:Scheduled() & App.Report<String,QueryResult>) -> IO(WorldResult):
  match repeat result:
    case False{} result:IO.pure(WorldResult,finished(None{},result))
    case True{}, (scheduled,previous):IO.bind(Scheduled() & App.Report<String,QueryResult>,WorldResult,Application.run(~S.SchemaA,~S.layout_a(),~L.EmptyLayout{},~Unit,~Nodes(),~Unit,~U32,~String,~QueryResult,~dispatch,~Conditions.empty_dispatch(~World(),~String),~handle,~publish,scheduled),result=>IO.pure(WorldResult,finished(Some{previous},result)))
def registered(repeat:Bool,world:World(),left:RegisteredLeft(),right:RegisteredRight()) -> IO(WorldResult):
  IO.bind(Scheduled() & App.Report<String,QueryResult>,WorldResult,Application.run(~S.SchemaA,~S.layout_a(),~L.EmptyLayout{},~Unit,~Nodes(),~Unit,~U32,~String,~QueryResult,~dispatch,~Conditions.empty_dispatch(~World(),~String),~handle,~publish,Application.build(~S.SchemaA,~S.layout_a(),~L.EmptyLayout{},~Unit,~Nodes(),~Unit,~U32,~String,~Conditions.empty_dispatch(~World(),~String),~available,world,Tree.generalized_pair_facts(LeftNode(),RightNode(),Tree.generalized_leaf_facts(~S.SchemaA,~S.layout_a(),~L.EmptyLayout{},~Unit,~String,~QueryResult,~Ops,~Local,~left_program,~left_body,left),Tree.generalized_leaf_facts(~S.SchemaA,~S.layout_a(),~L.EmptyLayout{},~Unit,~String,~QueryResult,~Ops,~Local,~right_program,~right_body,right)),Conditions.compile_empty(~String,~World()),0,[],[])),value=>repeated(repeat,value))
def right_defined(repeat:Bool,left:RegisteredLeft(),result:Compilation() & Sys.Defined<World(),RightOwner(),Local>) -> IO(WorldResult):
  match result:
    case (compilation,Sys.Defined{world,owner}):registered(repeat,world,left,Scope.CompiledBinding{compilation,owner})
    case (compilation,Sys.DefinitionRefused{world,local}):IO.pure(WorldResult,RightDefinitionRefused{world,left,compilation,local})
def left_defined(repeat:Bool,right:Local,result:Compilation() & Sys.Defined<World(),LeftOwner(),Local>) -> IO(WorldResult):
  match result:
    case (compilation,Sys.Defined{world,owner}):right_defined(repeat,Scope.CompiledBinding{compilation,owner},Task.define_with_compilation(~S.SchemaA,~WC(),~HStore(),~HResources(),~Unit,~Ops,~Local,~String,~QueryResult,~right_program,~right_body,~Unit,right_compiled(),world,"general-right",right))
    case (compilation,Sys.DefinitionRefused{world,local}):IO.pure(WorldResult,LeftDefinitionRefused{world,compilation,local,right})
def seeded_columns(_:Unit) -> WC():S.full_a()
def reserved(result:W.World<S.SchemaA,WC(),Unit,Unit> & W.Reservation<S.SchemaA>) -> W.World<S.SchemaA,WC(),Unit,Unit>:
  match result:
    case (world,W.Reserved{handle}):W.discard_status(~S.SchemaA,~WC(),~Unit,~Unit,W.activate(~S.SchemaA,~WC(),~Unit,~Unit,world,handle))
    case (world,W.ReservationRejected{_}):world
def live(fuel:Nat,world:W.World<S.SchemaA,WC(),Unit,Unit>) -> W.World<S.SchemaA,WC(),Unit,Unit>:
  match fuel:
    case 0n:world
    case 1n+rest:live(rest,reserved(W.reserve_id(~S.SchemaA,~WC(),~Unit,~Unit,world)))
type Seeded is Type:
  Seeded{factory:W.Factory,world:W.World<S.SchemaA,WC(),Unit,Unit>}
  SeedRefused{factory:W.Factory,resource:Unit}
def created(result:W.Creation<S.SchemaA,WC(),Unit,Unit>) -> Seeded:
  match result:
    case W.Created{factory,world}:Seeded{factory,live(20n,world)}
    case W.CreateRejected{factory,resource}:SeedRefused{factory,resource}
def seeded(factory:W.Factory) -> Seeded:
  created(W.create(~S.SchemaA,~WC(),~Unit,~Unit,~seeded_columns,factory,Unit{}))
def target_local(algorithms:Bool,+handle:W.Handle<S.SchemaA>,+token:U32) -> Local:
  Local{handle,Token{[token : U32^1n]},Commands.insert(~S.SchemaA,~S.Position,~Unit,Commands.empty(~S.SchemaA,~S.Position,~Unit),handle,S.Position{[U32.add(token,100) : U32^1n]}),algorithms}
def chosen(handle:W.Handle<S.SchemaA>,rest:Maybe<&2,W.Handle<S.SchemaA>>,selected:Bool) -> Maybe<&2,W.Handle<S.SchemaA>>:
  match selected:
    case False{}:rest
    case True{}:Some{handle}
def choose(+key:U32,handles:List<&2,W.Handle<S.SchemaA>>) -> Maybe<&2,W.Handle<S.SchemaA>>:
  match handles:
    case []:None{}
    case +handle <> rest:chosen(handle,choose(key,rest),U32.is_eq(key,W.handle_index(~S.SchemaA,handle)))
def targets(+algorithms:Bool,world:World(),left:Maybe<&2,W.Handle<S.SchemaA>>,right:Maybe<&2,W.Handle<S.SchemaA>>) -> IO(WorldResult):
  match left right:
    case Some{lh} Some{rh}:left_defined(algorithms,target_local(algorithms,rh,202),Task.define_with_compilation(~S.SchemaA,~WC(),~HStore(),~HResources(),~Unit,~Ops,~Local,~String,~QueryResult,~left_program,~left_body,~Unit,left_compiled(),world,"general-left",target_local(algorithms,lh,101)))
    case _ _:IO.pure(WorldResult,TargetsRefused{world})
def captured(result:W.World<S.SchemaA,WC(),Unit,Unit> & List<&2,W.Handle<S.SchemaA>>) -> IO(WorldResult):
  match result:
    case (world,+handles):targets(True{},world,choose(1,handles),choose(20,handles))
def run_world(world:W.World<S.SchemaA,WC(),Unit,Unit>) -> IO(WorldResult):
  captured(W.handles(~S.SchemaA,~WC(),~Unit,~Unit,world))
type SeedRun is Type:
  SeedRun{factory:W.Factory,foreign:Maybe<&1,World()>,result:WorldResult}
  SeedRunRefused{factory:W.Factory,resource:Unit}
def run_seeded(result:Seeded) -> IO(SeedRun):
  match result:
    case Seeded{factory,world}:IO.bind(WorldResult,SeedRun,run_world(world),result => IO.pure(SeedRun,SeedRun{factory,None{},result}))
    case SeedRefused{factory,resource}:IO.pure(SeedRun,SeedRunRefused{factory,resource})
def run(factory:W.Factory) -> IO(SeedRun):
  run_seeded(seeded(factory))
type TargetMode is Data:
  Target{key:U32}
  ForeignTarget{}
  StaleTarget{}
  ZeroTarget{}
  OutsideTarget{}
def changed_target(value:Maybe<&2,W.Handle<S.SchemaA>>,mode:TargetMode) -> Maybe<&2,W.Handle<S.SchemaA>>:
  match value mode:
    case None{} _:None{}
    case Some{W.Handle{namespace,Key.EntityKey{_,generation}}} ZeroTarget{}:Some{W.Handle{namespace,Key.EntityKey{0,generation}}}
    case Some{W.Handle{namespace,Key.EntityKey{_,generation}}} OutsideTarget{}:Some{W.Handle{namespace,Key.EntityKey{131073,generation}}}
    case value _:value
def requested(+mode:TargetMode,handles:List<&2,W.Handle<S.SchemaA>>) -> Maybe<&2,W.Handle<S.SchemaA>>:
  match mode:
    case Target{key}:choose(key,handles)
    case mode:changed_target(choose(20,handles),mode)
def captured_mode(mode:TargetMode,result:World() & List<&2,W.Handle<S.SchemaA>>) -> IO(WorldResult):
  match result:
    case (world,+handles):targets(False{},world,choose(1,handles),requested(mode,handles))
def retired_target(world:World(),left:Maybe<&2,W.Handle<S.SchemaA>>,right:Maybe<&2,W.Handle<S.SchemaA>>) -> IO(WorldResult):
  match right:
    case Some{+handle}:targets(False{},W.discard_status(~S.SchemaA,~WC(),~Unit,~Unit,W.deactivate(~S.SchemaA,~WC(),~Unit,~Unit,world,handle)),left,Some{handle})
    case None{}:targets(False{},world,left,None{})
def captured_stale(result:World() & List<&2,W.Handle<S.SchemaA>>) -> IO(WorldResult):
  match result:
    case (world,+handles):retired_target(world,choose(1,handles),choose(20,handles))
def run_world_mode(world:World(),mode:TargetMode) -> IO(WorldResult):
  match mode:
    case StaleTarget{}:captured_stale(W.handles(~S.SchemaA,~WC(),~Unit,~Unit,world))
    case mode:captured_mode(mode,W.handles(~S.SchemaA,~WC(),~Unit,~Unit,world))
def foreign_local_target(right:Maybe<&2,W.Handle<S.SchemaA>>,result:World() & List<&2,W.Handle<S.SchemaA>>) -> IO(WorldResult):
  match result:
    case (world,handles):targets(False{},world,choose(1,handles),right)
def captured_foreign(world:World(),right:Maybe<&2,W.Handle<S.SchemaA>>) -> IO(WorldResult):
  foreign_local_target(right,W.handles(~S.SchemaA,~WC(),~Unit,~Unit,world))
def foreign_captured(factory:W.Factory,world:World(),result:World() & List<&2,W.Handle<S.SchemaA>>) -> IO(SeedRun):
  match result:
    case (foreign,+handles):IO.bind(WorldResult,SeedRun,captured_foreign(world,choose(20,handles)),result => IO.pure(SeedRun,SeedRun{factory,Some{foreign},result}))
def foreign_seeded(world:World(),result:Seeded) -> IO(SeedRun):
  match result:
    case Seeded{factory,foreign}:foreign_captured(factory,world,W.handles(~S.SchemaA,~WC(),~Unit,~Unit,foreign))
    case SeedRefused{factory,resource}:IO.pure(SeedRun,SeedRun{factory,None{},TargetsRefused{world}})
def run_seeded_mode(mode:TargetMode,result:Seeded) -> IO(SeedRun):
  match mode result:
    case ForeignTarget{} Seeded{factory,world}:foreign_seeded(world,seeded(factory))
    case mode Seeded{factory,world}:IO.bind(WorldResult,SeedRun,run_world_mode(world,mode),result => IO.pure(SeedRun,SeedRun{factory,None{},result}))
    case _ SeedRefused{factory,resource}:IO.pure(SeedRun,SeedRunRefused{factory,resource})
def run_mode(factory:W.Factory,mode:TargetMode) -> IO(SeedRun):
  run_seeded_mode(mode,seeded(factory))
