import Base
import ./schedule.bend as Sch
import ./world.bend as W
import ./system.bend as Sys
# Declaration lowering owns fixed group order; closed callbacks retain failure outcomes.
# Detached ordinary marker schedule name; phase lowering is fixed by the library.
type Declaration<-S:Data> is Data: Declaration{name:String}
# Declare the marker schedule label without building or executing handlers.
def declare(~S:Data,name:String) -> Declaration<S>:Declaration{name}
def phase_name(id:U32) -> String:
  match id:
    case 1:"apply"
    case 2:"exit"
    case 3:"transition"
    case _:"enter"
# Fixed sequence: structural barrier, then apply, exit, transition and enter
# system groups with their phase labels and condition slot zero.
def steps() -> List<&2,Sch.Step>:[Sch.Barrier{},Sch.Phase{phase_name(1)},Sch.System{1,0},Sch.Phase{phase_name(2)},Sch.System{2,0},Sch.Phase{phase_name(3)},Sch.System{3,0},Sch.Phase{phase_name(4)},Sch.System{4,0}]
# Build the fixed four-group schedule retaining actual H owners. Group ids 1..4
# are internal dispatch slots, not newly registered gameplay system identities.
def install(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,declaration:Declaration<S>,namespace:U32,owners:H) -> Sch.Build<S,C,R,E,H>:
  match declaration:
    case Declaration{name}:Sch.build(~S,~C,~R,~E,~H,namespace,name,steps(),[1,2,3,4],owners)
# Advanced fixed-group router: ids 1/2/3 call apply/exit/transition; the remaining
# case calls enter. Use with steps(), not arbitrary ids assumed validated here.
# Closed callbacks must return actual owners/World and their failure outcome.
def dispatch(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,~apply:H -> W.World<S,C,R,E> -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~exit:H -> W.World<S,C,R,E> -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~transition:H -> W.World<S,C,R,E> -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~enter:H -> W.World<S,C,R,E> -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,owners:H,world:W.World<S,C,R,E>,id:U32) -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>:
  match id:
    case 1:apply(owners,world)
    case 2:exit(owners,world)
    case 3:transition(owners,world)
    case _:enter(owners,world)
# Fixed marker group condition returns World unchanged and True.
def condition(~S:Data,~C:Type,~R:Type,~E:Data,world:W.World<S,C,R,E>,_:U32) -> W.World<S,C,R,E> & Bool:(world,True{})
# Run the fixed schedule after namespace admission, preserving H and World in
# all results. Stop on first failed callback; earlier successful transactions are
# not one marker-wide rollback. Explicit initial barrier precedes group dispatch.
# See docs/parity/handlers.md for the higher-level transition-marker contract.
def run(~S:Data,~C:Type,~R:Type,~E:Data,~H:Type,~Error:Data,~apply:H -> W.World<S,C,R,E> -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~exit:H -> W.World<S,C,R,E> -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~transition:H -> W.World<S,C,R,E> -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,~enter:H -> W.World<S,C,R,E> -> H & Sys.Outcome<W.World<S,C,R,E>,Error,Unit>,schedule:Sch.Schedule<S,C,R,E,H>,world:W.World<S,C,R,E>) -> Sch.RunResult<S,C,R,E,H,Error>:Sch.run(~S,~C,~R,~E,~H,~Error,~dispatch(~S,~C,~R,~E,~H,~Error,~apply,~exit,~transition,~enter),~condition(~S,~C,~R,~E),schedule,world)
