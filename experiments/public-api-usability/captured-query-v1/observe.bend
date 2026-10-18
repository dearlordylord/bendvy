import Base
import ./schema.bend as S
import ./body.bend as B
import ./app.bend as A
import ../../public-captures/ordinary-owner-v1/payload.bend as P
import ../../../src/ecs/ordinary-app-capture-query.bend as Captured
import ../../../src/ecs/ordinary-app-execution-recipe.bend as Exec
import ../../../src/ecs/ordinary-app-records.bend as Leaf
import ../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ../../../src/ecs/ordinary-capture-query.bend as O
import ../../../src/ecs/local.bend as L
import ../../../src/ecs/ordinary-query-declaration.bend as Q
import ../../../src/ecs/world.bend as W
def mode(value:Q.Mode) -> String:
  match value:
    case Q.Read{}:"Read"
    case Q.Write{}:"Write"
    case Q.Optional{}:"Optional"
    case Q.With{}:"With"
    case Q.Without{}:"Without"
    case Q.Added{}:"Added"
    case Q.Changed{}:"Changed"
def clause(~Schema:Data,value:Q.Clause<Schema>) -> String:
  match value:
    case Q.Clause{key,kind}:key ++ ":" ++ mode(kind)
def fields(~Schema:Data,value:Fields.Fields<Schema>) -> String:
  match value:
    case Fields.Fields{ns,id,name,access,cursor,slot,clauses,Fields.ComponentKind{}}:"ns=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ List.show(&2,String,x=>x,access) ++ ";cursor=" ++ U32.show(cursor) ++ ";slot=" ++ slot ++ ";clauses=" ++ List.show(&2,Q.Clause<Schema>,clause(~Schema),clauses) ++ ";kind=Component"
    case _:"INVALID_FIELDS_KIND"
def audit(~Schema:Data,value:A.FirstOwners(~Schema)) -> A.FirstOwners(~Schema) & String:
  match value:
    case (Unit{},Exec.Invocation{Leaf.Record{token,+metadata},args,+outputs}):((Unit{},Exec.Invocation{Leaf.Record{token,metadata},args,outputs}),"fields={" ++ fields(~Schema,metadata) ++ "};args=Unit;outputs=" ++ List.show(&2,P.Tree,B.tree,outputs))
def pack(value:P.Observation) -> String:
  match value:
    case P.Observation{first,second}:"{" ++ B.tree(first) ++ ";" ++ B.tree(second) ++ "}"
def args_text(value:B.Args) -> String:
  match value:
    case B.Args{failAt}:"Args{" ++ U32.show(failAt) ++ "}"
def packed(~Schema:Data,+ns:U32,+id:U32,+name:String,+access:List<&2,String>,+cursor:U32,+metadata:Fields.Fields<Schema>,+args:B.Args,retained:List<&2,B.Row>,outputs:List<&2,B.Row>,result:P.Pack & P.Observation) -> Captured.Invocation(~Schema,~S.Store(~Schema),~Unit,~Unit,~P.Pack,~B.Ops,~B.Args,~B.Error,~B.Row,~B.query(~Schema),~B.body) & String:
  match result:
    case (capture,view):(Exec.Invocation{Leaf.Record{O.Owner{L.Instance{ns,id,name,access,capture},cursor},metadata},args,retained},"fields={" ++ fields(~Schema,metadata) ++ "};actualOwner={ns=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ name ++ ";access=" ++ List.show(&2,String,x=>x,access) ++ ";cursor=" ++ U32.show(cursor) ++ ";capture=" ++ pack(view) ++ "};args=" ++ args_text(args) ++ ";outputs=" ++ List.show(&2,B.Row,B.row,outputs))
def captured_outputs(~Schema:Data,result:Captured.Invocation(~Schema,~S.Store(~Schema),~Unit,~Unit,~P.Pack,~B.Ops,~B.Args,~B.Error,~B.Row,~B.query(~Schema),~B.body) & List<&2,B.Row>) -> Captured.Invocation(~Schema,~S.Store(~Schema),~Unit,~Unit,~P.Pack,~B.Ops,~B.Args,~B.Error,~B.Row,~B.query(~Schema),~B.body) & String:
  match result:
    case (Exec.Invocation{Leaf.Record{O.Owner{L.Instance{ns,id,name,access,capture},cursor},metadata},args,retained},outputs):packed(~Schema,ns,id,name,access,cursor,metadata,args,retained,outputs,P.project(capture))
def captured(~Schema:Data,value:Captured.Invocation(~Schema,~S.Store(~Schema),~Unit,~Unit,~P.Pack,~B.Ops,~B.Args,~B.Error,~B.Row,~B.query(~Schema),~B.body)) -> Captured.Invocation(~Schema,~S.Store(~Schema),~Unit,~Unit,~P.Pack,~B.Ops,~B.Args,~B.Error,~B.Row,~B.query(~Schema),~B.body) & String:captured_outputs(~Schema,Captured.outputs(~Schema,~S.Store(~Schema),~Unit,~Unit,~P.Pack,~B.Ops,~B.Args,~B.Error,~B.Row,~B.query(~Schema),~B.body,value))
def owners_join(~Schema:Data,left:A.FirstOwners(~Schema) & String,right:Captured.Invocation(~Schema,~S.Store(~Schema),~Unit,~Unit,~P.Pack,~B.Ops,~B.Args,~B.Error,~B.Row,~B.query(~Schema),~B.body) & String) -> A.Owners(~Schema) & String:
  match left right:
    case (left,a),(right,b):((left,right),"audit={" ++ a ++ "}|captured={" ++ b ++ "}")
def owners(~Schema:Data,value:A.Owners(~Schema)) -> A.Owners(~Schema) & String:
  match value:
    case (left,right):owners_join(~Schema,audit(~Schema,left),captured(~Schema,right))
