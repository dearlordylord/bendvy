import Base
import ./fixture.bend as F
import ./observe.bend as Obs
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/recoverable-component.bend as RC
import ../../../src/ecs/ordinary-recovery-system.bend as O
import ../../../src/ecs/recoverable-component-family.bend as Family
import ./schema.bend as Schema
import ../../../src/ecs/ordinary-component-binding.bend as Binding
import ../../../src/ecs/transaction.bend as T
type State<S:Data> is Type:
  State{world:F.World(~S),foreign:F.World(~S),owner:F.Instance(~S),foreignOwner:F.Instance(~S),target:W.Handle<S>,absent:W.Handle<S>,other:W.Handle<S>,text:String}
  Broken{text:String}
def status(value:T.Outcome<F.Error>) -> String:
  match value:
    case T.Success{}:"success"
    case T.Failure{F.Failed{}}:"failed"
def observed(~S:Data,label:String,target:W.Handle<S>,absent:W.Handle<S>,other:W.Handle<S>,text:String,a:F.World(~S) & String,b:F.World(~S) & String,c:F.Instance(~S) & String,d:F.Instance(~S) & String) -> State<S>:
  match a b c d:
    case (world,wt),(foreign,ft),(owner,ot),(foreignOwner,fto):State{world,foreign,owner,foreignOwner,target,absent,other,text ++ label ++ "|" ++ wt ++ "|" ++ ft ++ "|" ++ ot ++ "|" ++ fto ++ "\n"}
def snapshot(~S:Data,label:String,state:State<S>) -> State<S>:
  match state:
    case State{world,foreign,owner,foreignOwner,target,absent,other,text}:observed(~S,label,target,absent,other,text,Obs.world(~S,world),Obs.world(~S,foreign),Obs.owner(~S,owner),Obs.owner(~S,foreignOwner))
    case Broken{text}:Broken{text}
def completed(~S:Data,label:String,state:State<S>,out:F.Output & String,recovery:F.Recovery(~S) & String) -> State<S>:
  match out recovery:
    case (_,ot),(_,rt):snapshot(~S,label ++ "|output=" ++ ot ++ "|recovery=" ++ rt,state)
def refused(~S:Data,label:String,state:State<S>,args:F.Args<S> & String) -> State<S>:
  match args:
    case (_,text):snapshot(~S,label ++ "|args-returned=" ++ text,state)
def returned(~S:Data,label:String,foreign:F.World(~S),foreignOwner:F.Instance(~S),target:W.Handle<S>,absent:W.Handle<S>,other:W.Handle<S>,text:String,result:F.Run(~S)) -> State<S>:
  match result:
    case O.Completed{world,owner,outcome,output,recovery}:completed(~S,label ++ ":" ++ status(outcome),State{world,foreign,owner,foreignOwner,target,absent,other,text},Obs.output(output),Obs.recovery(~S,recovery))
    case O.RegistrationRejected{world,owner,args}:refused(~S,label ++ ":refused",State{world,foreign,owner,foreignOwner,target,absent,other,text},Obs.args(~S,args))
    case O.TransportFailed{_}:Broken{text ++ "BUG:transport"}
def arguments(~S:Data,+label:String,state:State<S>,args:F.Args<S> & String) -> State<S>:
  match state args:
    case State{world,foreign,owner,foreignOwner,target,absent,other,text},(args,at):returned(~S,label,foreign,foreignOwner,target,absent,other,text ++ "input:" ++ label ++ "|" ++ at ++ "\n",F.run(~S,owner,world,args))
    case Broken{text},_:Broken{text}
def run(~S:Data,label:String,seed:U32,fail:Bool,useAbsent:Bool,state:State<S>) -> State<S>:
  match useAbsent state:
    case False{},State{world,foreign,owner,foreignOwner,+target,+absent,+other,text}:arguments(~S,label,State{world,foreign,owner,foreignOwner,target,absent,other,text},Obs.args(~S,F.args(~S,target,seed,fail)))
    case True{},State{world,foreign,owner,foreignOwner,+target,+absent,+other,text}:arguments(~S,label,State{world,foreign,owner,foreignOwner,target,absent,other,text},Obs.args(~S,F.args(~S,absent,seed,fail)))
    case _,Broken{text}:Broken{text}
def foreign_returned(~S:Data,world:F.World(~S),foreignOwner:F.Instance(~S),target:W.Handle<S>,absent:W.Handle<S>,other:W.Handle<S>,text:String,result:F.Run(~S)) -> State<S>:
  match result:
    case O.RegistrationRejected{foreign,owner,args}:refused(~S,"foreign-world:refused",State{world,foreign,owner,foreignOwner,target,absent,other,text},Obs.args(~S,args))
    case O.Completed{foreign,owner,outcome,output,recovery}:completed(~S,"BUG:foreign-entered:" ++ status(outcome),State{world,foreign,owner,foreignOwner,target,absent,other,text},Obs.output(output),Obs.recovery(~S,recovery))
    case O.TransportFailed{_}:Broken{text ++ "BUG:foreign-transport"}
def foreign_arguments(~S:Data,state:State<S>,args:F.Args<S> & String) -> State<S>:
  match state args:
    case State{world,foreign,owner,foreignOwner,target,absent,other,text},(args,at):foreign_returned(~S,world,foreignOwner,target,absent,other,text ++ "input:foreign-world|" ++ at ++ "\n",F.run(~S,owner,foreign,args))
    case Broken{text},_:Broken{text}
def foreign_run(~S:Data,state:State<S>) -> State<S>:
  match state:
    case State{world,foreign,owner,foreignOwner,+target,absent,+other,text}:foreign_arguments(~S,State{world,foreign,owner,foreignOwner,target,absent,other,text},Obs.args(~S,F.args(~S,target,500,False{})))
    case Broken{text}:Broken{text}
def finish(~S:Data,state:State<S>) -> String:
  match state:
    case State{_,_,_,_,_,_,_,text}:text
    case Broken{text}:text
def sequence(~S:Data,state:State<S>) -> String:
  finish(~S,foreign_run(~S,run(~S,"absent-failed",600,True{},True{},run(~S,"retry-success",400,False{},False{},run(~S,"retry-failed",300,True{},False{},run(~S,"failed",200,True{},False{},run(~S,"commit",100,False{},False{},snapshot(~S,"registered",state))))))))
def foreign_defined(~S:Data,world:F.World(~S),owner:F.Instance(~S),target:W.Handle<S>,absent:W.Handle<S>,other:W.Handle<S>,result:O.Defined<F.World(~S),F.Instance(~S),Array<Array<U32>>>) -> String:
  match result:
    case O.Defined{foreign,foreignOwner}:sequence(~S,State{world,foreign,owner,foreignOwner,target,absent,other,""})
    case _:"BUG:foreign-register"
def defined(~S:Data,foreign:F.World(~S),target:W.Handle<S>,absent:W.Handle<S>,other:W.Handle<S>,result:O.Defined<F.World(~S),F.Instance(~S),Array<Array<U32>>>) -> String:
  match result:
    case O.Defined{world,owner}:foreign_defined(~S,world,owner,target,absent,other,F.define(~S,foreign,F.array(9000)))
    case _:"BUG:register"
type Prepared<S:Data> is Type:
  Prepared{world:F.World(~S),first:W.Handle<S>,second:W.Handle<S>}
  PreparationFailed{}
def second_populated(~S:Data,first:W.Handle<S>,second:W.Handle<S>,result:RC.Replacement<F.World(~S),S,Array<U32>>) -> Prepared<S>:
  match result:
    case RC.Applied{world,_}:Prepared{world,first,second}
    case _:PreparationFailed{}
def populated(~S:Data,+first:W.Handle<S>,second:W.Handle<S>,seed:U32,result:RC.Replacement<F.World(~S),S,Array<Array<U32>>>) -> Prepared<S>:
  match result:
    case RC.Applied{world,_}:second_populated(~S,first,second,Family.replace(~S,~Schema.Store(~S),~Unit,~Unit,~Col.Column<S,Array<Array<U32>>>,~Array<U32>,~Unit,~Schema.SecondToken,~Schema.second_take(~S),~Schema.second_put(~S),~Schema.second_view,Binding.family(~S,~Schema.Store(~S),~Col.Column<S,Array<Array<U32>>>,~Array<U32>,~Unit,~Schema.SecondToken,~Schema.second_take(~S),~Schema.second_put(~S),~Schema.second_view,Schema.second_binding(~S)),world,first,Some{F.pair((seed + 5 : U32))}))
    case _:PreparationFailed{}
def activated_second(~S:Data,+first:W.Handle<S>,second:W.Handle<S>,+seed:U32,result:F.World(~S) & W.Status) -> Prepared<S>:
  match result:
    case (world,W.Accepted{}):populated(~S,first,second,seed,Family.replace(~S,~Schema.Store(~S),~Unit,~Unit,~Col.Column<S,Array<U32>>,~Array<Array<U32>>,~Unit,~Schema.FirstToken,~Schema.first_take(~S),~Schema.first_put(~S),~Schema.first_view,Binding.family(~S,~Schema.Store(~S),~Col.Column<S,Array<U32>>,~Array<Array<U32>>,~Unit,~Schema.FirstToken,~Schema.first_take(~S),~Schema.first_put(~S),~Schema.first_view,Schema.first_binding(~S)),world,first,Some{F.array(seed)}))
    case _:PreparationFailed{}
def reserved_second(~S:Data,first:W.Handle<S>,seed:U32,result:F.World(~S) & W.Reservation<S>) -> Prepared<S>:
  match result:
    case (world,W.Reserved{+second}):activated_second(~S,first,second,seed,W.activate(~S,~Schema.Store(~S),~Unit,~Unit,world,second))
    case _:PreparationFailed{}
def activated_first(~S:Data,first:W.Handle<S>,seed:U32,result:F.World(~S) & W.Status) -> Prepared<S>:
  match result:
    case (world,W.Accepted{}):reserved_second(~S,first,seed,W.reserve_id(~S,~Schema.Store(~S),~Unit,~Unit,world))
    case _:PreparationFailed{}
def reserved_first(~S:Data,seed:U32,result:F.World(~S) & W.Reservation<S>) -> Prepared<S>:
  match result:
    case (world,W.Reserved{+first}):activated_first(~S,first,seed,W.activate(~S,~Schema.Store(~S),~Unit,~Unit,world,first))
    case _:PreparationFailed{}
def prepare(~S:Data,world:F.World(~S),seed:U32) -> Prepared<S>:reserved_first(~S,seed,W.reserve_id(~S,~Schema.Store(~S),~Unit,~Unit,world))
def prepared(~S:Data,a:Prepared<S>,b:Prepared<S>) -> String:
  match a b:
    case Prepared{world,target,absent},Prepared{foreign,other,_}:defined(~S,foreign,target,absent,other,F.define(~S,world,F.array(1000)))
    case _,_:"BUG:preparation"
def start(~S:Data,world:F.World(~S),foreign:F.World(~S)) -> String:prepared(~S,prepare(~S,world,10),prepare(~S,foreign,900))
