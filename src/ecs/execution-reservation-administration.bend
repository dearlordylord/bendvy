import Base
import ./execution-state.bend as State
import ./execution-reservation-task.bend as Task
import ./execution-lifecycle-notices.bend as Notice
import ./world.bend as W
import ./clock-state.bend as Clock
import ./deferred-command.bend as Deferred

# Administrative owners retained while its one allocator is serviced.
type Remainder<-S:Data,-C:Type,-R:Type,-E:Data> is Type:
  Remainder{events:List<&2,E>,pending:List<Deferred.Command<W.World<S,C,R,E>>>,registrations:List<&2,W.RegistrationMeta>,nextSystemId:U32,clock:Clock.State,lifecycle:Notice.Journal<S>}
def take(~S:Data,~C:Type,~R:Type,~E:Data,admin:State.Administration<S,C,R,E>) -> Remainder<S,C,R,E> & Task.Issuer<S>:
  match admin:
    case State.Administration{namespace,allocator,events,pending,registrations,nextSystemId,clock,lifecycle}:(Remainder{events,pending,registrations,nextSystemId,clock,lifecycle},Task.Issuer{namespace,allocator})
def put(~S:Data,~C:Type,~R:Type,~E:Data,remainder:Remainder<S,C,R,E>,issuer:Task.Issuer<S>) -> State.Administration<S,C,R,E>:
  match remainder issuer:
    case Remainder{events,pending,registrations,nextSystemId,clock,lifecycle} Task.Issuer{namespace,allocator}:State.Administration{namespace,allocator,events,pending,registrations,nextSystemId,clock,lifecycle}
