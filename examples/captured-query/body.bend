import Base
import ./schema.bend as S
import ./payload.bend as P
import ../../src/ecs/world.bend as W
import ../../src/ecs/execution-composer-layout.bend as L
import ../../src/ecs/execution-builder.bend as Build
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-reservation-task.bend as Task
import ../../src/ecs/execution-query.bend as Q
import ../../src/ecs/execution-query-recipe.bend as Recipe
import ../../src/ecs/execution-query-matches.bend as Match
import ../../src/ecs/execution-query-store.bend as QueryStore
import ../../src/ecs/execution-resource-store.bend as ResourceStore
import ../../src/ecs/execution-resource-program.bend as Program
import ../../src/ecs/execution-declaration.bend as Decl
import ../../src/ecs/execution-resource-query-leaf.bend as Leaf

def C() -> Type:QueryStore.owner(~S.Workshop,S.components(),QueryStore.Sparse{})
def R() -> Type:ResourceStore.owner(~S.Workshop,S.resources(),ResourceStore.Sparse{})
def Ops(Permit:Data,H:Type) -> Type:Q.GeneralWriter<S.Workshop,H,Array<U32>,P.Tree>
def any(_:Maybe<&2,P.Tree>) -> Bool:True{}
def selection(~Permit:Data,~H:Type,~B:Type,~cr:Build.ComponentRead(~S.Workshop,~C(),~R(),~H,~B),~cw:Build.ComponentWrite(~S.Workshop,~C(),~R(),~H,~B),~rr:Build.ResourceRead(~S.Workshop,~C(),~R(),~H,~B),~rw:Build.ResourceWrite(~S.Workshop,~C(),~R(),~H,~B),~q:Build.Query(~S.Workshop,~S.Store(~S.Workshop),~C(),~R(),~H,~B),~life:Build.Lifecycle(~S.Workshop,~S.Store(~S.Workshop),~C(),~R(),~H,~B),book:B) -> B & Ops(Permit,H):
  Build.general_query(~S.Workshop,~S.Store(~S.Workshop),~C(),~R(),~S.components(),~L.AtLeaf{},~{==},~{==},~QueryStore.Sparse{},~{==},~Recipe.WriteRows{},~Recipe.Changed{L.AtLeaf{}},~Match.Required{},~any,~H,~B,~q,book)
def program(~Permit:Data,~H:Type,~B:Type,~builder:Build.Builder(~S.Workshop,~S.Store(~S.Workshop),~C(),~R(),~Permit,~H,~B),book:B) -> B & Ops(Permit,H):builder(Ops,selection(~Permit,~H,~B),book)
def kernel(~Permit:Data,~token:Permit,~H:Type,~B:Type,~builder:Build.Builder(~S.Workshop,~S.Store(~S.Workshop),~C(),~R(),~Permit,~H,~B),book:B) -> B & Ops(Permit,H):Build.framework_program(~S.Workshop,~S.Store(~S.Workshop),~C(),~R(),~Ops,~program,~Permit,~token,~H,~B,~builder,book)

type Args is Data:Args{failAt:U32}
type Row is Data:Row{before:P.Tree,between:P.Tree,after:P.Tree}
type Error is Data:
  Deliberate{row:Row}
  Missing{}
  AuditMissing{}
type Local is Type:Local{capture:P.Pack,args:Args,rows:List<&2,Row>,unused:List<(Array<U32> -> Array<U32> & Unit)>}
def raised(+delta:U32,value:P.Tree) -> Array<U32>:
  match value:
    case P.Leaf{n}:ALeaf{U32.add(n,delta)}
    case P.Node{a,b}:ANode{raised(delta,a),raised(delta,b)}
def first(value:P.Tree) -> U32:
  match value:
    case P.Leaf{n}:n
    case P.Node{a,_}:first(a)
def row(value:Row) -> String:
  match value:
    case Row{before,between,after}:"Row{" ++ P.text(before) ++ ";" ++ P.text(between) ++ ";" ++ P.text(after) ++ "}"
def error(value:Error) -> String:
  match value:
    case Deliberate{value}:"Deliberate{" ++ row(value) ++ "}"
    case Missing{}:"Missing"
    case AuditMissing{}:"AuditMissing"
def chosen(value:Row,prior:Maybe<&2,Error>,fail:Bool) -> Maybe<&2,Error>:
  match fail:
    case True{}:Some{Deliberate{value}}
    case False{}:prior
def decision(args:Args,+value:Row,prior:Maybe<&2,Error>) -> Maybe<&2,Error>:
  match args value:
    case Args{failAt} Row{before,_,_}:chosen(value,prior,U32.is_eq(first(before),failAt))
def completed(~Permit:Data,~H:Type,next:H -> Local -> Maybe<&2,Error> -> Task.Task<S.Workshop,Permit,H & (Local & Sys.Completion<Error,String>)>,+before:P.Tree,+between:P.Tree,local:Local,prior:Maybe<&2,Error>,result:H & Q.GeneralLookup<P.Tree>) -> Task.Task<S.Workshop,Permit,H & (Local & Sys.Completion<Error,String>)>:
  match local result:
    case Local{capture,+args,rows,unused}, (scope,Q.Matched{Some{+after}}):next(scope,Local{P.update(1,capture),args,List.append(&2,Row,rows,[Row{before,between,after}]),unused},decision(args,Row{before,between,after},prior))
    case local, (scope,_):next(scope,local,Some{Missing{}})
def wrote(~Permit:Data,~H:Type,next:H -> Local -> Task.Task<S.Workshop,Permit,H & (Local & Sys.Completion<Error,String>)>,local:Local,result:H & Q.GeneralEdit<Array<U32>,Unit>) -> Task.Task<S.Workshop,Permit,H & (Local & Sys.Completion<Error,String>)>:
  match local result:
    case local, (scope,Q.GeneralEdited{_}):next(scope,local)
    case Local{capture,args,rows,unused}, (scope,Q.GeneralUnchanged{operation}):Task.TDone{(scope,(Local{capture,args,rows,operation <> unused},Sys.BodyError{Missing{},"operation retained"}))}
def replace(+delta:U32,+value:P.Tree,_:Array<U32>) -> Array<U32> & Unit:(raised(delta,value),Unit{})
def between(~Permit:Data,~H:Type,~read:H -> W.Handle<S.Workshop> -> H & Q.GeneralLookup<P.Tree>,~modify:@-Out:Type -> H -> W.Handle<S.Workshop> -> (Array<U32> -> Array<U32> & Out) -> H & Q.GeneralEdit<Array<U32>,Out>,+target:W.Handle<S.Workshop>,+before:P.Tree,local:Local,prior:Maybe<&2,Error>,next:H -> Local -> Maybe<&2,Error> -> Task.Task<S.Workshop,Permit,H & (Local & Sys.Completion<Error,String>)>,result:H & Q.GeneralLookup<P.Tree>) -> Task.Task<S.Workshop,Permit,H & (Local & Sys.Completion<Error,String>)>:
  match result:
    case (scope,Q.Matched{Some{between}}):wrote(~Permit,~H,scope => local => completed(~Permit,~H,next,before,between,local,prior,read(scope,target)),local,modify(Unit,scope,target,replace(20,before)))
    case (scope,_):next(scope,local,Some{Missing{}})
def visit(~Permit:Data,~H:Type,~read:H -> W.Handle<S.Workshop> -> H & Q.GeneralLookup<P.Tree>,~modify:@-Out:Type -> H -> W.Handle<S.Workshop> -> (Array<U32> -> Array<U32> & Out) -> H & Q.GeneralEdit<Array<U32>,Out>,+target:W.Handle<S.Workshop>,local:Local,prior:Maybe<&2,Error>,next:H -> Local -> Maybe<&2,Error> -> Task.Task<S.Workshop,Permit,H & (Local & Sys.Completion<Error,String>)>,result:H & Q.GeneralLookup<P.Tree>) -> Task.Task<S.Workshop,Permit,H & (Local & Sys.Completion<Error,String>)>:
  match result:
    case (scope,Q.Matched{Some{+before}}):wrote(~Permit,~H,scope => local => between(~Permit,~H,~read,~modify,target,before,local,prior,next,read(scope,target)),local,modify(Unit,scope,target,replace(10,before)))
    case (scope,_):next(scope,local,Some{Missing{}})
# Bevy ad678262 crates/bevy_ecs/src/system/function_system.rs::run_unsafe
# updates last_run before returning the body result. The library Root retains
# this actual scope and affine capture after our returned error.
def finish(~Permit:Data,~H:Type,scope:H,local:Local,failure:Maybe<&2,Error>) -> Task.Task<S.Workshop,Permit,H & (Local & Sys.Completion<Error,String>)>:
  match local failure:
    case Local{capture,args,+rows,unused} None{}:Task.TDone{(scope,(Local{capture,args,rows,unused},Sys.Success{List.show(&2,Row,row,rows)}))}
    case Local{capture,args,+rows,unused} Some{reason}:Task.TDone{(scope,(Local{capture,args,rows,unused},Sys.BodyError{reason,List.show(&2,Row,row,rows)}))}
def visits(~Permit:Data,~H:Type,~read:H -> W.Handle<S.Workshop> -> H & Q.GeneralLookup<P.Tree>,~modify:@-Out:Type -> H -> W.Handle<S.Workshop> -> (Array<U32> -> Array<U32> & Out) -> H & Q.GeneralEdit<Array<U32>,Out>,rows:List<&2,Q.GeneralRow<S.Workshop,P.Tree>>,scope:H,local:Local,prior:Maybe<&2,Error>) -> Task.Task<S.Workshop,Permit,H & (Local & Sys.Completion<Error,String>)>:
  match rows:
    case []:finish(~Permit,~H,scope,local,prior)
    case Q.GeneralRow{+target,_} <> rest:visit(~Permit,~H,~read,~modify,target,local,prior,scope => local => prior => visits(~Permit,~H,~read,~modify,rest,scope,local,prior),read(scope,target))
def selected(~Permit:Data,~H:Type,~read:H -> W.Handle<S.Workshop> -> H & Q.GeneralLookup<P.Tree>,~modify:@-Out:Type -> H -> W.Handle<S.Workshop> -> (Array<U32> -> Array<U32> & Out) -> H & Q.GeneralEdit<Array<U32>,Out>,local:Local,result:H & Q.GeneralReport<S.Workshop,P.Tree>) -> Task.Task<S.Workshop,Permit,H & (Local & Sys.Completion<Error,String>)>:
  match local result:
    case Local{capture,args,_,unused}, (scope,Q.SelectedRows{rows}):visits(~Permit,~H,~read,~modify,rows,scope,Local{capture,args,[],unused},None{})
    case local, (scope,_):finish(~Permit,~H,scope,local,Some{Missing{}})
def read(~H:Type,caps:Ops(Unit,H)) -> H -> W.Handle<S.Workshop> -> H & Q.GeneralLookup<P.Tree>:
  match caps:
    case Q.GeneralWriter{Q.GeneralReader{_,get},_,_}:get
    case _:scope => _ => (scope,Q.LookupRefused{})
def modify(~H:Type,caps:Ops(Unit,H)) -> @-Out:Type -> H -> W.Handle<S.Workshop> -> (Array<U32> -> Array<U32> & Out) -> H & Q.GeneralEdit<Array<U32>,Out>:
  match caps:
    case Q.GeneralWriter{_,write,_}:write
    case _:Out => scope => _ => operation => (scope,Q.GeneralUnchanged{operation})
def select(~H:Type,caps:Ops(Unit,H)) -> H -> H & Q.GeneralReport<S.Workshop,P.Tree>:
  match caps:
    case Q.GeneralWriter{Q.GeneralReader{query,_},_,_}:query
    case _:scope => (scope,Q.SelectionRefused{})
def body(~Permit:Data,~H:Type,~caps:Ops(Permit,H),scope:H,local:Local) -> Task.Task<S.Workshop,Permit,H & (Local & Sys.Completion<Error,String>)>:selected(~Permit,~H,~read(~H,caps),~modify(~H,caps),local,select(~H,caps)(scope))
def compiled() -> Decl.Compilation<S.Workshop,S.Store(~S.Workshop),C(),R(),Ops>:Program.compile_framework(~S.Workshop,~S.Store(~S.Workshop),~C(),~R(),~Ops,~kernel)
def Owner() -> Type:Sys.Owner<S.Workshop,S.Store(~S.Workshop),C(),R(),Unit,Ops,Local,Error,String,kernel,body>
def Node() -> Type:Leaf.node_type(~S.Workshop,~S.components(),~S.resources(),~Unit,~Error,~String,~Ops,~Local,~kernel,~body)
