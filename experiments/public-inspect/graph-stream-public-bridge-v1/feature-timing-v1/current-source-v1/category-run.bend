import Base
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/relation-commands.bend as A
import ../../../../../src/ecs/ordinary-inspector-relation.bend as Decl
import ../../../../../src/ecs/inspector.bend as I
import ../../../../../src/ecs/check.bend as K
import ../../../../../src/ecs/system.bend as Sys
import ../../../../../src/ecs/schedule.bend as Sch
import ../../../../../src/ecs/schedule-checked.bend as Checked
import ./state.bend as State
import ./category.bend as C
import ./render.bend as Render
import ./guard.bend as Guard
import ./dump.bend as Dump

def World(~S:Data) -> Type: C.World(~S)
type Inspected is Data: Inspected{rows:String,instance:String}
type Entry is Data: Entry{logical:String,physical:String}
def instance_text(~S:Data,value:I.Instance<S>) -> String:
  match value:
    case I.Fresh{}:"Fresh"
    case I.Active{cursor,registeredAt}:"Active(" ++ U32.show(cursor) ++ "," ++ U32.show(registeredAt) ++ ")"
def instance_if(~S:Data,physical:Bool,instance:I.Instance<S>) -> String:
  match physical:
    case True{}:instance_text(~S,instance)
    case False{}:""
def inspect_done(~S:Data,+physical:Bool,observed:I.Observed<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,Unit,String>) -> World(~S) & Inspected:
  match observed:
    case I.Observed{world,instance,Done{rows}}:(world,Inspected{rows,instance_if(~S,physical,instance)})
    case I.Observed{world,instance,Fail{_}}:(world,Inspected{"{\"inspectorFailure\":true}",instance_if(~S,physical,instance)})
# Each call is a distinct fresh once-read view. No prior Instance is reused.
def inspect(~S:Data,~physical:Bool,~declaration:Decl.Declaration<S>,world:World(~S)) -> World(~S) & Inspected:
  inspect_done(~S,physical,I.run(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~(H => C.Query(~S,~H)),~Unit,~Unit,~String,~C.inspect_plan(~S,~declaration),~C.inspect_body(~S),I.Fresh{},Unit{},world))
def captured(~S:Data,logical:String,cursor:String,observed:World(~S) & String) -> World(~S) & Entry:
  (world,text)=observed
  (world,Entry{logical,"{\"instance\":" ++ Render.quoted(cursor) ++ ",\"world\":" ++ Render.quoted(text) ++ "}"})
def capture(~S:Data,physical:Bool,logical:String,cursor:String,world:World(~S)) -> World(~S) & Entry:
  match physical:
    case True{}:captured(~S,logical,cursor,Dump.world(~S,world))
    case False{}:(world,Entry{logical,""})
def continue(~S:Data,next:World(~S) -> Entry -> World(~S) & List<&2,Entry>,observed:World(~S) & Entry) -> World(~S) & List<&2,Entry>:
  (world,entry)=observed
  next(world,entry)
def predicate_done(~S:Data,observed:K.Checked<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>) -> World(~S) & Result<K.Error,Bool>:
  match observed:
    case K.Checked{world,Done{value}}:(world,Done{value})
    case K.Checked{world,Fail{error}}:(world,Fail{error})
def predicate(~S:Data,~declaration:Decl.Declaration<S>,~expected:Nat,world:World(~S),_:U32) -> World(~S) & Result<K.Error,Bool>:
  predicate_done(~S,K.run(~S,~A.Store<S,State.Components<S>>,~State.Resources<S>,~A.Notice<S,U32>,~(H => C.Query(~S,~H)),~Nat,~C.condition_body(~S),~C.condition_plan(~S,~declaration),expected,world))
def check_noop(~S:Data,~physical:Bool,~declaration:Decl.Declaration<S>,~expected:Nat,name:String,world:World(~S)) -> World(~S) & Guard.Value:
  Guard.run(~S,~predicate(~S,~declaration,~expected),physical,name,world)
def second_check_done(~S:Data,~physical:Bool,schema:String,relation:String,mode:String,prefix:List<&2,Entry>,observed:World(~S) & Guard.Value) -> World(~S) & List<&2,Entry>:
  (world,Guard.Value{text,registry})=observed
  continue(~S,world => entry => (world,List.append(&2,Entry,prefix,[entry])),capture(~S,physical,Render.check_record(schema,relation,mode,"second",text),registry,world))
def first_check_done(~S:Data,~physical:Bool,~declaration:Decl.Declaration<S>,~expected:Nat,+schema:String,+relation:String,+mode:String,prefix:List<&2,Entry>,observed:World(~S) & Guard.Value) -> World(~S) & List<&2,Entry>:
  (world,Guard.Value{text,registry})=observed
  continue(~S,world => entry => second_check_done(~S,~physical,schema,relation,mode,List.append(&2,Entry,prefix,[entry]),check_noop(~S,~physical,~declaration,~expected,schema ++ "/" ++ relation ++ "/" ++ mode ++ "/second/Noop",world)),capture(~S,physical,Render.check_record(schema,relation,mode,"first",text),registry,world))
def second_inspect_done(~S:Data,~physical:Bool,~declaration:Decl.Declaration<S>,~expected:Nat,+schema:String,+relation:String,+mode:String,prefix:List<&2,Entry>,observed:World(~S) & Inspected) -> World(~S) & List<&2,Entry>:
  match observed:
    case (world,Inspected{text,cursor}):continue(~S,world => entry => first_check_done(~S,~physical,~declaration,~expected,schema,relation,mode,List.append(&2,Entry,prefix,[entry]),check_noop(~S,~physical,~declaration,~expected,schema ++ "/" ++ relation ++ "/" ++ mode ++ "/first/Noop",world)),capture(~S,physical,Render.inspect_record(schema,relation,mode,"second",text),cursor,world))
def first_inspect_done(~S:Data,~physical:Bool,~declaration:Decl.Declaration<S>,~expected:Nat,+schema:String,+relation:String,+mode:String,observed:World(~S) & Inspected) -> World(~S) & List<&2,Entry>:
  match observed:
    case (world,Inspected{text,cursor}):continue(~S,world => entry => second_inspect_done(~S,~physical,~declaration,~expected,schema,relation,mode,[entry],inspect(~S,~physical,~declaration,world)),capture(~S,physical,Render.inspect_record(schema,relation,mode,"first",text),cursor,world))
def run_case(~S:Data,~physical:Bool,~declaration:Decl.Declaration<S>,~expected:Nat,schema:String,relation:String,mode:String,world:World(~S)) -> World(~S) & List<&2,Entry>:
  first_inspect_done(~S,~physical,~declaration,~expected,schema,relation,mode,inspect(~S,~physical,~declaration,world))
def run_15(~S:Data,~physical:Bool,+schema:String,prefix:List<&2,Entry>,observed:World(~S) & List<&2,Entry>) -> World(~S) & List<&2,Entry>:
  (world,records)=observed
  (world,List.append(&2,Entry,prefix,records))
def run_14(~S:Data,~physical:Bool,+schema:String,prefix:List<&2,Entry>,observed:World(~S) & List<&2,Entry>) -> World(~S) & List<&2,Entry>:
  (world,records)=observed
  run_15(~S,~physical,schema,List.append(&2,Entry,prefix,records),run_case(~S,~physical,~C.parent_absent_in(~S),~2n,schema,"Parent","absent_in",world))
def run_13(~S:Data,~physical:Bool,+schema:String,prefix:List<&2,Entry>,observed:World(~S) & List<&2,Entry>) -> World(~S) & List<&2,Entry>:
  (world,records)=observed
  run_14(~S,~physical,schema,List.append(&2,Entry,prefix,records),run_case(~S,~physical,~C.parent_present_in(~S),~1n,schema,"Parent","present_in",world))
def run_12(~S:Data,~physical:Bool,+schema:String,prefix:List<&2,Entry>,observed:World(~S) & List<&2,Entry>) -> World(~S) & List<&2,Entry>:
  (world,records)=observed
  run_13(~S,~physical,schema,List.append(&2,Entry,prefix,records),run_case(~S,~physical,~C.parent_optional_in(~S),~3n,schema,"Parent","optional_in",world))
def run_11(~S:Data,~physical:Bool,+schema:String,prefix:List<&2,Entry>,observed:World(~S) & List<&2,Entry>) -> World(~S) & List<&2,Entry>:
  (world,records)=observed
  run_12(~S,~physical,schema,List.append(&2,Entry,prefix,records),run_case(~S,~physical,~C.parent_required_in(~S),~1n,schema,"Parent","required_in",world))
def run_10(~S:Data,~physical:Bool,+schema:String,prefix:List<&2,Entry>,observed:World(~S) & List<&2,Entry>) -> World(~S) & List<&2,Entry>:
  (world,records)=observed
  run_11(~S,~physical,schema,List.append(&2,Entry,prefix,records),run_case(~S,~physical,~C.parent_absent_out(~S),~1n,schema,"Parent","absent_out",world))
def run_9(~S:Data,~physical:Bool,+schema:String,prefix:List<&2,Entry>,observed:World(~S) & List<&2,Entry>) -> World(~S) & List<&2,Entry>:
  (world,records)=observed
  run_10(~S,~physical,schema,List.append(&2,Entry,prefix,records),run_case(~S,~physical,~C.parent_present_out(~S),~2n,schema,"Parent","present_out",world))
def run_8(~S:Data,~physical:Bool,+schema:String,prefix:List<&2,Entry>,observed:World(~S) & List<&2,Entry>) -> World(~S) & List<&2,Entry>:
  (world,records)=observed
  run_9(~S,~physical,schema,List.append(&2,Entry,prefix,records),run_case(~S,~physical,~C.parent_optional_out(~S),~3n,schema,"Parent","optional_out",world))
def run_7(~S:Data,~physical:Bool,+schema:String,prefix:List<&2,Entry>,observed:World(~S) & List<&2,Entry>) -> World(~S) & List<&2,Entry>:
  (world,records)=observed
  run_8(~S,~physical,schema,List.append(&2,Entry,prefix,records),run_case(~S,~physical,~C.parent_required_out(~S),~2n,schema,"Parent","required_out",world))
def run_6(~S:Data,~physical:Bool,+schema:String,prefix:List<&2,Entry>,observed:World(~S) & List<&2,Entry>) -> World(~S) & List<&2,Entry>:
  (world,records)=observed
  run_7(~S,~physical,schema,List.append(&2,Entry,prefix,records),run_case(~S,~physical,~C.link_absent_in(~S),~2n,schema,"Link","absent_in",world))
def run_5(~S:Data,~physical:Bool,+schema:String,prefix:List<&2,Entry>,observed:World(~S) & List<&2,Entry>) -> World(~S) & List<&2,Entry>:
  (world,records)=observed
  run_6(~S,~physical,schema,List.append(&2,Entry,prefix,records),run_case(~S,~physical,~C.link_present_in(~S),~1n,schema,"Link","present_in",world))
def run_4(~S:Data,~physical:Bool,+schema:String,prefix:List<&2,Entry>,observed:World(~S) & List<&2,Entry>) -> World(~S) & List<&2,Entry>:
  (world,records)=observed
  run_5(~S,~physical,schema,List.append(&2,Entry,prefix,records),run_case(~S,~physical,~C.link_optional_in(~S),~3n,schema,"Link","optional_in",world))
def run_3(~S:Data,~physical:Bool,+schema:String,prefix:List<&2,Entry>,observed:World(~S) & List<&2,Entry>) -> World(~S) & List<&2,Entry>:
  (world,records)=observed
  run_4(~S,~physical,schema,List.append(&2,Entry,prefix,records),run_case(~S,~physical,~C.link_required_in(~S),~1n,schema,"Link","required_in",world))
def run_2(~S:Data,~physical:Bool,+schema:String,prefix:List<&2,Entry>,observed:World(~S) & List<&2,Entry>) -> World(~S) & List<&2,Entry>:
  (world,records)=observed
  run_3(~S,~physical,schema,List.append(&2,Entry,prefix,records),run_case(~S,~physical,~C.link_absent_out(~S),~1n,schema,"Link","absent_out",world))
def run_1(~S:Data,~physical:Bool,+schema:String,prefix:List<&2,Entry>,observed:World(~S) & List<&2,Entry>) -> World(~S) & List<&2,Entry>:
  (world,records)=observed
  run_2(~S,~physical,schema,List.append(&2,Entry,prefix,records),run_case(~S,~physical,~C.link_present_out(~S),~2n,schema,"Link","present_out",world))
def run_0(~S:Data,~physical:Bool,+schema:String,prefix:List<&2,Entry>,observed:World(~S) & List<&2,Entry>) -> World(~S) & List<&2,Entry>:
  (world,records)=observed
  run_1(~S,~physical,schema,List.append(&2,Entry,prefix,records),run_case(~S,~physical,~C.link_optional_out(~S),~3n,schema,"Link","optional_out",world))
def run(~S:Data,~physical:Bool,+schema:String,world:World(~S)) -> World(~S) & List<&2,Entry>:
  run_0(~S,~physical,schema,[],run_case(~S,~physical,~C.link_required_out(~S),~2n,schema,"Link","required_out",world))
