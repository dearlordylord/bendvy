import Base
import ../../src/ecs/execution-reservation-task.bend as Task
import ../../src/ecs/execution-reservation-authority.bend as Permit
import ../../src/ecs/entity-allocator.bend as Allocator
import ../../src/ecs/world.bend as W

# DRAFT, unapproved and unproved. These statements concern the real allocator
# owner in Issuer, not a Data projection or a premise assuming service's answer.
# Bevy's Commands::spawn reserves before enqueueing a bundle:
# https://github.com/bevyengine/bevy/blob/ad678262ce53b5d142fe49ee5e08caff6f00ab60/crates/bevy_ecs/src/system/commands/mod.rs
# Bend adds declaration and prepared-owner authorization before that reservation.
# These two refusals do not establish successful allocation or whole-run effects.
law foreign_namespace_keeps_actual_issuer:
  for -S:Data
  for -Out:Type
  for -allocator:Allocator.Allocator
  for -id:U32
  for -resume:W.Reservation<S> -> Task.Task<S,Permit.Permit,Out>
  {Task.service_generic(S,Permit.Permit,Out,Task.TNeed{Permit.Authorized{1,id},resume},Task.Direct{{==}},Task.Issuer{0,allocator,[id]}) == (Task.Issuer{0,allocator,[id]},Task.TRun{_ => resume(W.ReservationRejected{W.ReservationUnauthorized{}})}) : Task.Issuer<S> & Task.Task<S,Permit.Permit,Out>}

law unprepared_id_keeps_actual_issuer:
  for -S:Data
  for -Out:Type
  for -allocator:Allocator.Allocator
  for -namespace:U32
  for -id:U32
  for -resume:W.Reservation<S> -> Task.Task<S,Permit.Permit,Out>
  {Task.service_generic(S,Permit.Permit,Out,Task.TNeed{Permit.Authorized{namespace,id},resume},Task.Direct{{==}},Task.Issuer{namespace,allocator,[]}) == (Task.Issuer{namespace,allocator,[]},Task.TRun{_ => resume(W.ReservationRejected{W.ReservationUnauthorized{}})}) : Task.Issuer<S> & Task.Task<S,Permit.Permit,Out>}
