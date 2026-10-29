import Base
import ./schema.bend as S
import ./registration.bend as Registration
import ../../src/ecs/execution-composer-schema.bend as Init
import ../../src/ecs/world.bend as W
import ../../src/ecs/dependency-composer-program.bend as Scoped

type Outcome is Type:
  Registered{result:Registration.Outcome}
  InitializationRefused{result:Init.Initialized<S.Nominal,S.components(),S.resources(),Unit>}
  ReservationRefused{world:S.World(),reservation:W.Reservation<S.Nominal>}
  ActivationRefused{world:S.World(),status:W.Status}
def second_activated(nesting:List<&2,Scoped.Nested>,first:W.Handle<S.Nominal>,second:W.Handle<S.Nominal>,result:S.World() & W.Status) -> Outcome:
  match result:
    case (world,W.Accepted{}):Registered{Registration.define(world,first,second,nesting)}
    case (world,status):ActivationRefused{world,status}
def second_reserved(nesting:List<&2,Scoped.Nested>,first:W.Handle<S.Nominal>,result:S.World() & W.Reservation<S.Nominal>) -> Outcome:
  match result:
    case (world,W.Reserved{+handle}):second_activated(nesting,first,handle,W.activate(~S.Nominal,~S.Store(),~S.Resources(),~Unit,world,handle))
    case (world,reservation):ReservationRefused{world,reservation}
def first_activated(nesting:List<&2,Scoped.Nested>,first:W.Handle<S.Nominal>,result:S.World() & W.Status) -> Outcome:
  match result:
    case (world,W.Accepted{}):second_reserved(nesting,first,W.reserve_id(~S.Nominal,~S.Store(),~S.Resources(),~Unit,world))
    case (world,status):ActivationRefused{world,status}
def first_reserved(nesting:List<&2,Scoped.Nested>,result:S.World() & W.Reservation<S.Nominal>) -> Outcome:
  match result:
    case (world,W.Reserved{+handle}):first_activated(nesting,handle,W.activate(~S.Nominal,~S.Store(),~S.Resources(),~Unit,world,handle))
    case (world,reservation):ReservationRefused{world,reservation}
def created(nesting:List<&2,Scoped.Nested>,result:Init.Initialized<S.Nominal,S.components(),S.resources(),Unit>) -> Outcome:
  match result:
    case Init.SchemaCreated{_,world}:first_reserved(nesting,W.reserve_id(~S.Nominal,~S.Store(),~S.Resources(),~Unit,world))
    case result:InitializationRefused{result}
def run(nesting:List<&2,Scoped.Nested>) -> Outcome:
  created(nesting,Init.trusted_create_seeded(~S.Nominal,~S.components(),~S.resources(),~Unit,~S.seed,W.factory(),S.resource_seed()))
def run_optional_none(nesting:List<&2,Scoped.Nested>) -> Outcome:
  created(nesting,Init.trusted_create_seeded(~S.Nominal,~S.components(),~S.resources(),~Unit,~S.seed,W.factory(),S.absent_optional_seed()))
