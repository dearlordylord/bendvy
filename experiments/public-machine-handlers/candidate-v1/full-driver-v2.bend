# Runtime descriptor iteration avoids 24 literal Native entry instantiations.
# Existing registered handlers/world pipeline and complete observations reused.
import Base
import full-main.bend as Full
import full-provider.bend as P
import full-actions.bend as A
import full-observe.bend as O

type Case is Data:
  Case{phase:U32,position:U32,name:String}
def cases() -> List<&2,Case>:
  [Case{0,0,"exit0"},Case{0,1,"exit1"},Case{1,0,"transition0"},Case{1,1,"transition1"},Case{2,0,"enter0"},Case{2,1,"enter1"}]
def positive(~S:Data,phase:U32,position:U32) -> List<&2,String>:
  match phase position:
    case 0,0: Full.run(~S,~Full.exit0_failure)
    case 0,_: Full.run(~S,~Full.exit1_failure)
    case 1,0: Full.run(~S,~Full.transition0_failure)
    case 1,_: Full.run(~S,~Full.transition1_failure)
    case 2,0: Full.run(~S,~Full.enter0_failure)
    case _,_: Full.run(~S,~Full.enter1_failure)
# Missing requirement observation runs the same actual entry before any callback.
# Observable names/access/owner metadata are identical; predicate/owner TYPE
# identity is not claimed. Two closed refusal instantiations repeat under twelve
# actual labels/executions. No runtime capture contract.
def observation(~S:Data,phase:U32,position:U32,missing:Bool) -> List<&2,String>:
  match missing:
    case True{}: Full.run_missing(~S,~A.success)
    case False{}: positive(~S,phase,position)
def rows(~S:Data,+schema:String,inputs:List<&2,Case>) -> List<&2,String>:
  match inputs:
    case []: []
    case Case{+phase,+position,+name} <> rest:
      List.append(&2,String,[schema ++ "_" ++ name ++ "|" ++ List.show(&2,String,O.text,observation(~S,phase,position,False{})),schema ++ "_" ++ name ++ "_missing|" ++ List.show(&2,String,O.text,observation(~S,phase,position,True{}))],rows(~S,schema,rest))
def all_observations() -> List<&2,String>:
  List.append(&2,String,rows(~P.SchemaA,"schemaA",cases()),rows(~P.SchemaB,"schemaB",cases()))
def print_rows(rows:List<&2,String>) -> IO(Unit):
  match rows:
    case []: IO.pure(Unit,Unit{})
    case row <> rest:
      do IO<Unit>:
        IO.print(row)
        print_rows(rest)
def main() -> IO(Unit):
  print_rows(all_observations())
