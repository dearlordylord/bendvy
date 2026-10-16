import Base
import ../fixture.bend as F
import ../observe.bend as Obs
import ../scenario.bend as Prior
import ../../payload.bend as P
import ../../../../../src/ecs/ordinary-app-capture-query-fields.bend as A
import ../../../../../src/ecs/ordinary-app-composer.bend as Build
import ../../../../../src/ecs/ordinary-app-records.bend as Records
import ../../../../../src/ecs/ordinary-app-records.bend as Pair
import ../../../../../src/ecs/ordinary-app-observation-data.bend as DTO
import ../../../../../src/ecs/ordinary-query-declaration.bend as D
import ../../../../../src/ecs/ordinary-capture-query.bend as O
import ../../../../../src/ecs/column.bend as Col
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/compose.bend as Q
import ../../../../../src/ecs/ordinary-app-recipe.bend as Tree

def mode(value:D.Mode) -> String:
  match value:
    case D.Read{}:"read"
    case D.Write{}:"write"
    case D.Optional{}:"optional"
    case D.With{}:"with"
    case D.Without{}:"without"
    case D.Added{}:"added"
    case D.Changed{}:"changed"
def clause(~S:Data,value:D.Clause<S>) -> String:
  match value:
    case D.Clause{name,kind}:name ++ ":" ++ mode(kind)
def binding(~S:Data,value:DTO.Binding<S>) -> String:
  match value:
    case DTO.Binding{ns,id,name,access,cursor,slot,clauses}:U32.show(ns) ++ ":" ++ U32.show(id) ++ ":" ++ name ++ ":" ++ List.show(~&2,~String,~Obs.text,access) ++ ":" ++ U32.show(cursor) ++ ":" ++ slot ++ ":" ++ List.show(~&2,~D.Clause<S>,~clause(~S),clauses)
def debug(~S:Data,value:Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Unit>>>) -> String:
  match value:
    case None{}:"disabled"
    case Some{DTO.Product{bindings,DTO.Observation{Unit{},text}}}:List.show(~&2,~DTO.Binding<S>,~binding(~S),bindings) ++ "/" ++ List.show(~&2,~String,~Obs.text,text)
def CapturedApp(~S:Data) -> Type:
  Build.Registered<S,W.World<S,Col.Column<S,U32>,Unit,Unit>,(Unit & F.Owned(S)) & F.Owned(S),Unit,Build.empty_observe(~W.World<S,Col.Column<S,U32>,Unit,Unit>),Pair.fold_pair(~S,~(Unit & F.Owned(S)),~F.Owned(S),~Pair.fold_pair(~S,~Unit,~F.Owned(S),~Records.empty(~S),~A.fold(~S,~Col.Column<S,U32>,~Unit,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body)),~A.fold(~S,~Col.Column<S,U32>,~Unit,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body))>
type State<S:Data> is Type:
  State{app:CapturedApp(~S),text:String}
def snapshot_done(~S:Data,+flag:Bool,label:String,old:String,view:String,w:W.World<S,Col.Column<S,U32>,Unit,Unit> & String,a:F.Owned(S) & String,b:F.Owned(S) & String) -> State<S>:
  match w a b:
    case (world,wt), (first,at), (second,bt):State{Build.Registered{world,((Unit{},first),second),Tree.Recipe{},flag},old ++ label ++ "|" ++ view ++ "|" ++ wt ++ "|" ++ at ++ "|" ++ bt ++ "\n"}
def snapshot_view(~S:Data,label:String,text:String,returned:CapturedApp(~S) & Maybe<&2,DTO.Product<List<&2,DTO.Binding<S>>,DTO.Observation<Unit>>>) -> State<S>:
  match returned:
    case (Build.Registered{world,((Unit{},first),second),_,flag},view):snapshot_done(~S,flag,label,text,debug(~S,view),Obs.world(~S,world),Obs.owner(~S,first),Obs.owner(~S,second))
def snapshot(~S:Data,label:String,state:State<S>) -> State<S>:
  match state:
    case State{app,text}:snapshot_view(~S,label,text,Build.snapshot(~S,~W.World<S,Col.Column<S,U32>,Unit,Unit>,~((Unit & F.Owned(S)) & F.Owned(S)),~Unit,~Build.empty_observe(~W.World<S,Col.Column<S,U32>,Unit,Unit>),~Pair.fold_pair(~S,~(Unit & F.Owned(S)),~F.Owned(S),~Pair.fold_pair(~S,~Unit,~F.Owned(S),~Records.empty(~S),~A.fold(~S,~Col.Column<S,U32>,~Unit,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body)),~A.fold(~S,~Col.Column<S,U32>,~Unit,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body)),app))
def enable(~S:Data,state:State<S>) -> State<S>:
  match state:
    case State{app,text}:snapshot(~S,"enabled",State{Build.enabled(~S,~W.World<S,Col.Column<S,U32>,Unit,Unit>,~((Unit & F.Owned(S)) & F.Owned(S)),~Unit,~Build.empty_observe(~W.World<S,Col.Column<S,U32>,Unit,Unit>),~Pair.fold_pair(~S,~(Unit & F.Owned(S)),~F.Owned(S),~Pair.fold_pair(~S,~Unit,~F.Owned(S),~Records.empty(~S),~A.fold(~S,~Col.Column<S,U32>,~Unit,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body)),~A.fold(~S,~Col.Column<S,U32>,~Unit,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body)),app,True{}),text})
def after_first(~S:Data,second:F.Owned(S),flag:Bool,text:String,label:String,returned:O.Run<W.World<S,Col.Column<S,U32>,Unit,Unit>,F.Owned(S),F.Args,Q.Error<F.Error>,U32>) -> State<S>:
  match returned:
    case O.Completed{world,first,result}:snapshot(~S,label ++ ":" ++ Prior.result(result),State{Build.Registered{world,((Unit{},first),second),Tree.Recipe{},flag},text})
    case O.Refused{world,first,_}:snapshot(~S,"BUG:refused",State{Build.Registered{world,((Unit{},first),second),Tree.Recipe{},flag},text})
def run_first(~S:Data,label:String,args:F.Args,state:State<S>) -> State<S>:
  match state:
    case State{Build.Registered{world,((Unit{},first),second),_,flag},text}:after_first(~S,second,flag,text,label,F.run(~S,first,world,args))
def after_second(~S:Data,first:F.Owned(S),flag:Bool,text:String,label:String,returned:O.Run<W.World<S,Col.Column<S,U32>,Unit,Unit>,F.Owned(S),F.Args,Q.Error<F.Error>,U32>) -> State<S>:
  match returned:
    case O.Completed{world,second,result}:snapshot(~S,label ++ ":" ++ Prior.result(result),State{Build.Registered{world,((Unit{},first),second),Tree.Recipe{},flag},text})
    case O.Refused{world,second,_}:snapshot(~S,"BUG:refused",State{Build.Registered{world,((Unit{},first),second),Tree.Recipe{},flag},text})
def run_second(~S:Data,label:String,args:F.Args,state:State<S>) -> State<S>:
  match state:
    case State{Build.Registered{world,((Unit{},first),second),_,flag},text}:after_second(~S,first,flag,text,label,F.run(~S,second,world,args))
def finished(~S:Data,old:String,w:W.World<S,Col.Column<S,U32>,Unit,Unit> & String,a:P.Pack & P.Observation,b:P.Pack & P.Observation) -> String:
  match w a b:
    case (_,wt), (_,at), (_,bt):old ++ "removed|" ++ wt ++ "|" ++ Obs.pack(at) ++ "|" ++ Obs.pack(bt) ++ "\n"
def removed_second(~S:Data,first:P.Pack,text:String,result:O.Removal<W.World<S,Col.Column<S,U32>,Unit,Unit>,F.Owned(S),P.Pack>) -> String:
  match result:
    case O.Removed{world,second}:finished(~S,text,Obs.world(~S,world),P.project(first),P.project(second))
    case _:text ++ "BUG:remove-second\n"
def removed_first(~S:Data,second:F.Owned(S),text:String,result:O.Removal<W.World<S,Col.Column<S,U32>,Unit,Unit>,F.Owned(S),P.Pack>) -> String:
  match result:
    case O.Removed{world,first}:removed_second(~S,first,text,O.unregister(~S,~Col.Column<S,U32>,~Unit,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body,second,world))
    case _:text ++ "BUG:remove-first\n"
def finish(~S:Data,state:State<S>) -> String:
  match state:
    case State{Build.Registered{world,((Unit{},first),second),_,_},text}:removed_first(~S,second,text,O.unregister(~S,~Col.Column<S,U32>,~Unit,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body,first,world))
def sequence(~S:Data,app:CapturedApp(~S)) -> String:
  finish(~S,run_first(~S,"first-no-changes",F.Args{99,0},run_first(~S,"first-sees-second",F.Args{1,0},run_second(~S,"second",F.Args{10,0},run_first(~S,"first",F.Args{1,0},enable(~S,snapshot(~S,"disabled",State{app,""})))))))
def second_defined(~S:Data,result:A.Appended<Build.Registered<S,W.World<S,Col.Column<S,U32>,Unit,Unit>,Unit & F.Owned(S),Unit,Build.empty_observe(~W.World<S,Col.Column<S,U32>,Unit,Unit>),Pair.fold_pair(~S,~Unit,~F.Owned(S),~Records.empty(~S),~A.fold(~S,~Col.Column<S,U32>,~Unit,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body))>,Build.Registered<S,W.World<S,Col.Column<S,U32>,Unit,Unit>,(Unit & F.Owned(S)) & F.Owned(S),Unit,Build.empty_observe(~W.World<S,Col.Column<S,U32>,Unit,Unit>),Pair.fold_pair(~S,~(Unit & F.Owned(S)),~F.Owned(S),~Pair.fold_pair(~S,~Unit,~F.Owned(S),~Records.empty(~S),~A.fold(~S,~Col.Column<S,U32>,~Unit,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body)),~A.fold(~S,~Col.Column<S,U32>,~Unit,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body))>,P.Pack>) -> String:
  match result:
    case A.Appended{app}:sequence(~S,app)
    case _:"BUG:second-register"
def first_defined(~S:Data,result:A.Appended<Build.Registered<S,W.World<S,Col.Column<S,U32>,Unit,Unit>,Unit,Unit,Build.empty_observe(~W.World<S,Col.Column<S,U32>,Unit,Unit>),Records.empty(~S)>,Build.Registered<S,W.World<S,Col.Column<S,U32>,Unit,Unit>,Unit & F.Owned(S),Unit,Build.empty_observe(~W.World<S,Col.Column<S,U32>,Unit,Unit>),Pair.fold_pair(~S,~Unit,~F.Owned(S),~Records.empty(~S),~A.fold(~S,~Col.Column<S,U32>,~Unit,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body))>,P.Pack>) -> String:
  match result:
    case A.Appended{app}:second_defined(~S,A.register(~S,~Col.Column<S,U32>,~Unit,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body,~(Unit & F.Owned(S)),~Unit,~Build.empty_observe(~W.World<S,Col.Column<S,U32>,Unit,Unit>),~Pair.fold_pair(~S,~Unit,~F.Owned(S),~Records.empty(~S),~A.fold(~S,~Col.Column<S,U32>,~Unit,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body)),app,"query-b",P.initial(100)))
    case _:"BUG:first-register"
def start(~S:Data,world:W.World<S,Col.Column<S,U32>,Unit,Unit>) -> String:
  first_defined(~S,A.register(~S,~Col.Column<S,U32>,~Unit,~Unit,~P.Pack,~F.Ops,~F.Args,~F.Error,~U32,~F.query(~S),~F.body,~Unit,~Unit,~Build.empty_observe(~W.World<S,Col.Column<S,U32>,Unit,Unit>),~Records.empty(~S),Build.empty(~S,~W.World<S,Col.Column<S,U32>,Unit,Unit>,F.populate(~S,F.populate(~S,F.spawn(~S,F.spawn(~S,F.spawn(~S,world))),1,10),2,20)),"query-a",P.initial(1)))
