import Base
import /workspace/formal-proofs/bendvy-worktrees/ordinary-system-retention/src/ecs/ordinary-query-observable.bend as O
import /workspace/formal-proofs/bendvy-worktrees/ordinary-system-retention/src/ecs/ordinary-component-binding.bend as B
import /workspace/formal-proofs/bendvy-worktrees/ordinary-system-retention/src/ecs/inspector.bend as I
import /workspace/formal-proofs/bendvy-worktrees/ordinary-system-retention/src/ecs/component.bend as Cmp
import /workspace/formal-proofs/bendvy-worktrees/ordinary-system-retention/src/ecs/inspector-query-projection.bend as P
import ./scenario-schema.bend as S
import ./scenario-body.bend as Body
import ./scenario-dto.bend as DTO
import ../../../../../../../src/ecs/ordinary-query-declaration.bend as N
import ../../../../../../../src/ecs/column.bend as Col
import ../../../../../../../src/ecs/compose.bend as Q
import ../../../../../../../src/ecs/capabilities.bend as Cap
import ../dependencies/experiments/public-simulation/bend-v1/owner-view.bend as View
import ../../../../../../../src/ecs/persistence-declaration.bend as Recipe

def base_view() -> Data:
  P.Product<P.Product<Cmp.Access<View.FullCell>,Cmp.Access<View.FullCell>>,Cmp.Access<View.FullCell>>
def filtered_view() -> Data:
  P.Product<base_view(),Unit>

def plain_position_rest() -> Type:
  ((S.plain_velocity() & S.plain_health()) & Recipe.Plain<S.Schema,Array<U32>,S.identity("Position")>)
def plain_position_take(owner:S.plain_store()) -> ((S.plain_velocity() & S.plain_health()) & Recipe.Plain<S.Schema,Array<U32>,S.identity("Position")>) & Col.Column<S.Schema,Array<U32>>:
  S.position_take(~S.plain_position(),~S.plain_velocity(),~S.plain_health(),~Recipe.Plain<S.Schema,Array<U32>,S.identity("Position")>,~(owner => S.plain_take(~"Position",owner)),owner)
def plain_position_put(rest:((S.plain_velocity() & S.plain_health()) & Recipe.Plain<S.Schema,Array<U32>,S.identity("Position")>),column:Col.Column<S.Schema,Array<U32>>) -> S.plain_store():
  S.position_put(~S.plain_position(),~S.plain_velocity(),~S.plain_health(),~Recipe.Plain<S.Schema,Array<U32>,S.identity("Position")>,~(recipe => column => S.plain_put(~"Position",recipe,column)),rest,column)
def plain_position_binding() -> B.Binding<S.Schema,S.plain_store(),plain_position_rest(),Array<U32>,View.FullCell,Unit,plain_position_take,plain_position_put,View.view>:
  B.bind(~S.Schema,~S.plain_store(),~plain_position_rest(),~Array<U32>,~View.FullCell,~Unit,~plain_position_take,~plain_position_put,~View.view,S.identity("Position"))
def plain_read() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.plain_store(),Unit,Unit>,Cap.Read<Q.Frame<S.Schema,S.plain_store(),Unit,Unit>,View.FullCell>,I.Frame<S.Schema,S.plain_store(),Unit,Unit>,Cmp.Access<View.FullCell>>:
   O.read(~S.Schema,~S.plain_store(),~plain_position_rest(),~Array<U32>,~View.FullCell,~Unit,~plain_position_take,~plain_position_put,~View.view,~Unit,~Unit,~plain_position_binding())
 def plain_added() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.plain_store(),Unit,Unit>,Unit,I.Frame<S.Schema,S.plain_store(),Unit,Unit>,Unit>:
   O.added(~S.Schema,~S.plain_store(),~plain_position_rest(),~Array<U32>,~View.FullCell,~Unit,~plain_position_take,~plain_position_put,~View.view,~Unit,~Unit,~plain_position_binding())
 def plain_changed() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.plain_store(),Unit,Unit>,Unit,I.Frame<S.Schema,S.plain_store(),Unit,Unit>,Unit>:
   O.changed(~S.Schema,~S.plain_store(),~plain_position_rest(),~Array<U32>,~View.FullCell,~Unit,~plain_position_take,~plain_position_put,~View.view,~Unit,~Unit,~plain_position_binding())

def plain_velocity_rest() -> Type:
  ((S.plain_position() & S.plain_health()) & Recipe.Plain<S.Schema,Array<U32>,S.identity("Velocity")>)
def plain_velocity_take(owner:S.plain_store()) -> ((S.plain_position() & S.plain_health()) & Recipe.Plain<S.Schema,Array<U32>,S.identity("Velocity")>) & Col.Column<S.Schema,Array<U32>>:
  S.velocity_take(~S.plain_position(),~S.plain_velocity(),~S.plain_health(),~Recipe.Plain<S.Schema,Array<U32>,S.identity("Velocity")>,~(owner => S.plain_take(~"Velocity",owner)),owner)
def plain_velocity_put(rest:((S.plain_position() & S.plain_health()) & Recipe.Plain<S.Schema,Array<U32>,S.identity("Velocity")>),column:Col.Column<S.Schema,Array<U32>>) -> S.plain_store():
  S.velocity_put(~S.plain_position(),~S.plain_velocity(),~S.plain_health(),~Recipe.Plain<S.Schema,Array<U32>,S.identity("Velocity")>,~(recipe => column => S.plain_put(~"Velocity",recipe,column)),rest,column)
def plain_velocity_binding() -> B.Binding<S.Schema,S.plain_store(),plain_velocity_rest(),Array<U32>,View.FullCell,Unit,plain_velocity_take,plain_velocity_put,View.view>:
  B.bind(~S.Schema,~S.plain_store(),~plain_velocity_rest(),~Array<U32>,~View.FullCell,~Unit,~plain_velocity_take,~plain_velocity_put,~View.view,S.identity("Velocity"))
def plain_write() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.plain_store(),Unit,Unit>,Cap.Write<Q.Frame<S.Schema,S.plain_store(),Unit,Unit>,Array<U32>,View.FullCell>,I.Frame<S.Schema,S.plain_store(),Unit,Unit>,Cmp.Access<View.FullCell>>:
   O.write(~S.Schema,~S.plain_store(),~plain_velocity_rest(),~Array<U32>,~View.FullCell,~Unit,~plain_velocity_take,~plain_velocity_put,~View.view,~Unit,~Unit,~plain_velocity_binding())

def plain_health_rest() -> Type:
  ((S.plain_position() & S.plain_velocity()) & Recipe.Plain<S.Schema,Array<U32>,S.identity("Health")>)
def plain_health_take(owner:S.plain_store()) -> ((S.plain_position() & S.plain_velocity()) & Recipe.Plain<S.Schema,Array<U32>,S.identity("Health")>) & Col.Column<S.Schema,Array<U32>>:
  S.health_take(~S.plain_position(),~S.plain_velocity(),~S.plain_health(),~Recipe.Plain<S.Schema,Array<U32>,S.identity("Health")>,~(owner => S.plain_take(~"Health",owner)),owner)
def plain_health_put(rest:((S.plain_position() & S.plain_velocity()) & Recipe.Plain<S.Schema,Array<U32>,S.identity("Health")>),column:Col.Column<S.Schema,Array<U32>>) -> S.plain_store():
  S.health_put(~S.plain_position(),~S.plain_velocity(),~S.plain_health(),~Recipe.Plain<S.Schema,Array<U32>,S.identity("Health")>,~(recipe => column => S.plain_put(~"Health",recipe,column)),rest,column)
def plain_health_binding() -> B.Binding<S.Schema,S.plain_store(),plain_health_rest(),Array<U32>,View.FullCell,Unit,plain_health_take,plain_health_put,View.view>:
  B.bind(~S.Schema,~S.plain_store(),~plain_health_rest(),~Array<U32>,~View.FullCell,~Unit,~plain_health_take,~plain_health_put,~View.view,S.identity("Health"))
def plain_optional() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.plain_store(),Unit,Unit>,Cap.Read<Q.Frame<S.Schema,S.plain_store(),Unit,Unit>,View.FullCell>,I.Frame<S.Schema,S.plain_store(),Unit,Unit>,Cmp.Access<View.FullCell>>:
   O.optional(~S.Schema,~S.plain_store(),~plain_health_rest(),~Array<U32>,~View.FullCell,~Unit,~plain_health_take,~plain_health_put,~View.view,~Unit,~Unit,~plain_health_binding())
 def plain_with_component() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.plain_store(),Unit,Unit>,Unit,I.Frame<S.Schema,S.plain_store(),Unit,Unit>,Unit>:
   O.with_component(~S.Schema,~S.plain_store(),~plain_health_rest(),~Array<U32>,~View.FullCell,~Unit,~plain_health_take,~plain_health_put,~View.view,~Unit,~Unit,~plain_health_binding())
 def plain_without_component() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.plain_store(),Unit,Unit>,Unit,I.Frame<S.Schema,S.plain_store(),Unit,Unit>,Unit>:
   O.without_component(~S.Schema,~S.plain_store(),~plain_health_rest(),~Array<U32>,~View.FullCell,~Unit,~plain_health_take,~plain_health_put,~View.view,~Unit,~Unit,~plain_health_binding())

def plain_base() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.plain_store(),Unit,Unit>,Body.Ops(Q.Frame<S.Schema,S.plain_store(),Unit,Unit>),I.Frame<S.Schema,S.plain_store(),Unit,Unit>,base_view()>:
  O.pair(~S.Schema,~Q.Frame<S.Schema,S.plain_store(),Unit,Unit>,~(Cap.Read<Q.Frame<S.Schema,S.plain_store(),Unit,Unit>,View.FullCell> & Cap.Write<Q.Frame<S.Schema,S.plain_store(),Unit,Unit>,Array<U32>,View.FullCell>),~Cap.Read<Q.Frame<S.Schema,S.plain_store(),Unit,Unit>,View.FullCell>,~I.Frame<S.Schema,S.plain_store(),Unit,Unit>,~P.Product<Cmp.Access<View.FullCell>,Cmp.Access<View.FullCell>>,~Cmp.Access<View.FullCell>,~O.pair(~S.Schema,~Q.Frame<S.Schema,S.plain_store(),Unit,Unit>,~Cap.Read<Q.Frame<S.Schema,S.plain_store(),Unit,Unit>,View.FullCell>,~Cap.Write<Q.Frame<S.Schema,S.plain_store(),Unit,Unit>,Array<U32>,View.FullCell>,~I.Frame<S.Schema,S.plain_store(),Unit,Unit>,~Cmp.Access<View.FullCell>,~Cmp.Access<View.FullCell>,~plain_read(),~plain_write()),~plain_optional())
def plain_base_added() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.plain_store(),Unit,Unit>,Body.FilterOps(Q.Frame<S.Schema,S.plain_store(),Unit,Unit>),I.Frame<S.Schema,S.plain_store(),Unit,Unit>,filtered_view()>:
  O.pair(~S.Schema,~Q.Frame<S.Schema,S.plain_store(),Unit,Unit>,~Body.Ops(Q.Frame<S.Schema,S.plain_store(),Unit,Unit>),~Unit,~I.Frame<S.Schema,S.plain_store(),Unit,Unit>,~base_view(),~Unit,~plain_base(),~plain_added())
def plain_base_changed() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.plain_store(),Unit,Unit>,Body.FilterOps(Q.Frame<S.Schema,S.plain_store(),Unit,Unit>),I.Frame<S.Schema,S.plain_store(),Unit,Unit>,filtered_view()>:
  O.pair(~S.Schema,~Q.Frame<S.Schema,S.plain_store(),Unit,Unit>,~Body.Ops(Q.Frame<S.Schema,S.plain_store(),Unit,Unit>),~Unit,~I.Frame<S.Schema,S.plain_store(),Unit,Unit>,~base_view(),~Unit,~plain_base(),~plain_changed())
def plain_base_without_component() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.plain_store(),Unit,Unit>,Body.FilterOps(Q.Frame<S.Schema,S.plain_store(),Unit,Unit>),I.Frame<S.Schema,S.plain_store(),Unit,Unit>,filtered_view()>:
  O.pair(~S.Schema,~Q.Frame<S.Schema,S.plain_store(),Unit,Unit>,~Body.Ops(Q.Frame<S.Schema,S.plain_store(),Unit,Unit>),~Unit,~I.Frame<S.Schema,S.plain_store(),Unit,Unit>,~base_view(),~Unit,~plain_base(),~plain_without_component())
def plain_base_with_component() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.plain_store(),Unit,Unit>,Body.FilterOps(Q.Frame<S.Schema,S.plain_store(),Unit,Unit>),I.Frame<S.Schema,S.plain_store(),Unit,Unit>,filtered_view()>:
  O.pair(~S.Schema,~Q.Frame<S.Schema,S.plain_store(),Unit,Unit>,~Body.Ops(Q.Frame<S.Schema,S.plain_store(),Unit,Unit>),~Unit,~I.Frame<S.Schema,S.plain_store(),Unit,Unit>,~base_view(),~Unit,~plain_base(),~plain_with_component())

def transient_position_rest() -> Type:
  ((S.transient_velocity() & S.transient_health()) & Recipe.Transient<S.Schema,Array<U32>,S.identity("Position")>)
def transient_position_take(owner:S.transient_store()) -> ((S.transient_velocity() & S.transient_health()) & Recipe.Transient<S.Schema,Array<U32>,S.identity("Position")>) & Col.Column<S.Schema,Array<U32>>:
  S.position_take(~S.transient_position(),~S.transient_velocity(),~S.transient_health(),~Recipe.Transient<S.Schema,Array<U32>,S.identity("Position")>,~(owner => S.transient_take(~"Position",owner)),owner)
def transient_position_put(rest:((S.transient_velocity() & S.transient_health()) & Recipe.Transient<S.Schema,Array<U32>,S.identity("Position")>),column:Col.Column<S.Schema,Array<U32>>) -> S.transient_store():
  S.position_put(~S.transient_position(),~S.transient_velocity(),~S.transient_health(),~Recipe.Transient<S.Schema,Array<U32>,S.identity("Position")>,~(recipe => column => S.transient_put(~"Position",recipe,column)),rest,column)
def transient_position_binding() -> B.Binding<S.Schema,S.transient_store(),transient_position_rest(),Array<U32>,View.FullCell,Unit,transient_position_take,transient_position_put,View.view>:
  B.bind(~S.Schema,~S.transient_store(),~transient_position_rest(),~Array<U32>,~View.FullCell,~Unit,~transient_position_take,~transient_position_put,~View.view,S.identity("Position"))
def transient_read() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.transient_store(),Unit,Unit>,Cap.Read<Q.Frame<S.Schema,S.transient_store(),Unit,Unit>,View.FullCell>,I.Frame<S.Schema,S.transient_store(),Unit,Unit>,Cmp.Access<View.FullCell>>:
   O.read(~S.Schema,~S.transient_store(),~transient_position_rest(),~Array<U32>,~View.FullCell,~Unit,~transient_position_take,~transient_position_put,~View.view,~Unit,~Unit,~transient_position_binding())
 def transient_added() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.transient_store(),Unit,Unit>,Unit,I.Frame<S.Schema,S.transient_store(),Unit,Unit>,Unit>:
   O.added(~S.Schema,~S.transient_store(),~transient_position_rest(),~Array<U32>,~View.FullCell,~Unit,~transient_position_take,~transient_position_put,~View.view,~Unit,~Unit,~transient_position_binding())
 def transient_changed() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.transient_store(),Unit,Unit>,Unit,I.Frame<S.Schema,S.transient_store(),Unit,Unit>,Unit>:
   O.changed(~S.Schema,~S.transient_store(),~transient_position_rest(),~Array<U32>,~View.FullCell,~Unit,~transient_position_take,~transient_position_put,~View.view,~Unit,~Unit,~transient_position_binding())

def transient_velocity_rest() -> Type:
  ((S.transient_position() & S.transient_health()) & Recipe.Transient<S.Schema,Array<U32>,S.identity("Velocity")>)
def transient_velocity_take(owner:S.transient_store()) -> ((S.transient_position() & S.transient_health()) & Recipe.Transient<S.Schema,Array<U32>,S.identity("Velocity")>) & Col.Column<S.Schema,Array<U32>>:
  S.velocity_take(~S.transient_position(),~S.transient_velocity(),~S.transient_health(),~Recipe.Transient<S.Schema,Array<U32>,S.identity("Velocity")>,~(owner => S.transient_take(~"Velocity",owner)),owner)
def transient_velocity_put(rest:((S.transient_position() & S.transient_health()) & Recipe.Transient<S.Schema,Array<U32>,S.identity("Velocity")>),column:Col.Column<S.Schema,Array<U32>>) -> S.transient_store():
  S.velocity_put(~S.transient_position(),~S.transient_velocity(),~S.transient_health(),~Recipe.Transient<S.Schema,Array<U32>,S.identity("Velocity")>,~(recipe => column => S.transient_put(~"Velocity",recipe,column)),rest,column)
def transient_velocity_binding() -> B.Binding<S.Schema,S.transient_store(),transient_velocity_rest(),Array<U32>,View.FullCell,Unit,transient_velocity_take,transient_velocity_put,View.view>:
  B.bind(~S.Schema,~S.transient_store(),~transient_velocity_rest(),~Array<U32>,~View.FullCell,~Unit,~transient_velocity_take,~transient_velocity_put,~View.view,S.identity("Velocity"))
def transient_write() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.transient_store(),Unit,Unit>,Cap.Write<Q.Frame<S.Schema,S.transient_store(),Unit,Unit>,Array<U32>,View.FullCell>,I.Frame<S.Schema,S.transient_store(),Unit,Unit>,Cmp.Access<View.FullCell>>:
   O.write(~S.Schema,~S.transient_store(),~transient_velocity_rest(),~Array<U32>,~View.FullCell,~Unit,~transient_velocity_take,~transient_velocity_put,~View.view,~Unit,~Unit,~transient_velocity_binding())

def transient_health_rest() -> Type:
  ((S.transient_position() & S.transient_velocity()) & Recipe.Transient<S.Schema,Array<U32>,S.identity("Health")>)
def transient_health_take(owner:S.transient_store()) -> ((S.transient_position() & S.transient_velocity()) & Recipe.Transient<S.Schema,Array<U32>,S.identity("Health")>) & Col.Column<S.Schema,Array<U32>>:
  S.health_take(~S.transient_position(),~S.transient_velocity(),~S.transient_health(),~Recipe.Transient<S.Schema,Array<U32>,S.identity("Health")>,~(owner => S.transient_take(~"Health",owner)),owner)
def transient_health_put(rest:((S.transient_position() & S.transient_velocity()) & Recipe.Transient<S.Schema,Array<U32>,S.identity("Health")>),column:Col.Column<S.Schema,Array<U32>>) -> S.transient_store():
  S.health_put(~S.transient_position(),~S.transient_velocity(),~S.transient_health(),~Recipe.Transient<S.Schema,Array<U32>,S.identity("Health")>,~(recipe => column => S.transient_put(~"Health",recipe,column)),rest,column)
def transient_health_binding() -> B.Binding<S.Schema,S.transient_store(),transient_health_rest(),Array<U32>,View.FullCell,Unit,transient_health_take,transient_health_put,View.view>:
  B.bind(~S.Schema,~S.transient_store(),~transient_health_rest(),~Array<U32>,~View.FullCell,~Unit,~transient_health_take,~transient_health_put,~View.view,S.identity("Health"))
def transient_optional() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.transient_store(),Unit,Unit>,Cap.Read<Q.Frame<S.Schema,S.transient_store(),Unit,Unit>,View.FullCell>,I.Frame<S.Schema,S.transient_store(),Unit,Unit>,Cmp.Access<View.FullCell>>:
   O.optional(~S.Schema,~S.transient_store(),~transient_health_rest(),~Array<U32>,~View.FullCell,~Unit,~transient_health_take,~transient_health_put,~View.view,~Unit,~Unit,~transient_health_binding())
 def transient_with_component() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.transient_store(),Unit,Unit>,Unit,I.Frame<S.Schema,S.transient_store(),Unit,Unit>,Unit>:
   O.with_component(~S.Schema,~S.transient_store(),~transient_health_rest(),~Array<U32>,~View.FullCell,~Unit,~transient_health_take,~transient_health_put,~View.view,~Unit,~Unit,~transient_health_binding())
 def transient_without_component() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.transient_store(),Unit,Unit>,Unit,I.Frame<S.Schema,S.transient_store(),Unit,Unit>,Unit>:
   O.without_component(~S.Schema,~S.transient_store(),~transient_health_rest(),~Array<U32>,~View.FullCell,~Unit,~transient_health_take,~transient_health_put,~View.view,~Unit,~Unit,~transient_health_binding())

def transient_base() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.transient_store(),Unit,Unit>,Body.Ops(Q.Frame<S.Schema,S.transient_store(),Unit,Unit>),I.Frame<S.Schema,S.transient_store(),Unit,Unit>,base_view()>:
  O.pair(~S.Schema,~Q.Frame<S.Schema,S.transient_store(),Unit,Unit>,~(Cap.Read<Q.Frame<S.Schema,S.transient_store(),Unit,Unit>,View.FullCell> & Cap.Write<Q.Frame<S.Schema,S.transient_store(),Unit,Unit>,Array<U32>,View.FullCell>),~Cap.Read<Q.Frame<S.Schema,S.transient_store(),Unit,Unit>,View.FullCell>,~I.Frame<S.Schema,S.transient_store(),Unit,Unit>,~P.Product<Cmp.Access<View.FullCell>,Cmp.Access<View.FullCell>>,~Cmp.Access<View.FullCell>,~O.pair(~S.Schema,~Q.Frame<S.Schema,S.transient_store(),Unit,Unit>,~Cap.Read<Q.Frame<S.Schema,S.transient_store(),Unit,Unit>,View.FullCell>,~Cap.Write<Q.Frame<S.Schema,S.transient_store(),Unit,Unit>,Array<U32>,View.FullCell>,~I.Frame<S.Schema,S.transient_store(),Unit,Unit>,~Cmp.Access<View.FullCell>,~Cmp.Access<View.FullCell>,~transient_read(),~transient_write()),~transient_optional())
def transient_base_added() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.transient_store(),Unit,Unit>,Body.FilterOps(Q.Frame<S.Schema,S.transient_store(),Unit,Unit>),I.Frame<S.Schema,S.transient_store(),Unit,Unit>,filtered_view()>:
  O.pair(~S.Schema,~Q.Frame<S.Schema,S.transient_store(),Unit,Unit>,~Body.Ops(Q.Frame<S.Schema,S.transient_store(),Unit,Unit>),~Unit,~I.Frame<S.Schema,S.transient_store(),Unit,Unit>,~base_view(),~Unit,~transient_base(),~transient_added())
def transient_base_changed() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.transient_store(),Unit,Unit>,Body.FilterOps(Q.Frame<S.Schema,S.transient_store(),Unit,Unit>),I.Frame<S.Schema,S.transient_store(),Unit,Unit>,filtered_view()>:
  O.pair(~S.Schema,~Q.Frame<S.Schema,S.transient_store(),Unit,Unit>,~Body.Ops(Q.Frame<S.Schema,S.transient_store(),Unit,Unit>),~Unit,~I.Frame<S.Schema,S.transient_store(),Unit,Unit>,~base_view(),~Unit,~transient_base(),~transient_changed())
def transient_base_without_component() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.transient_store(),Unit,Unit>,Body.FilterOps(Q.Frame<S.Schema,S.transient_store(),Unit,Unit>),I.Frame<S.Schema,S.transient_store(),Unit,Unit>,filtered_view()>:
  O.pair(~S.Schema,~Q.Frame<S.Schema,S.transient_store(),Unit,Unit>,~Body.Ops(Q.Frame<S.Schema,S.transient_store(),Unit,Unit>),~Unit,~I.Frame<S.Schema,S.transient_store(),Unit,Unit>,~base_view(),~Unit,~transient_base(),~transient_without_component())
def transient_base_with_component() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.transient_store(),Unit,Unit>,Body.FilterOps(Q.Frame<S.Schema,S.transient_store(),Unit,Unit>),I.Frame<S.Schema,S.transient_store(),Unit,Unit>,filtered_view()>:
  O.pair(~S.Schema,~Q.Frame<S.Schema,S.transient_store(),Unit,Unit>,~Body.Ops(Q.Frame<S.Schema,S.transient_store(),Unit,Unit>),~Unit,~I.Frame<S.Schema,S.transient_store(),Unit,Unit>,~base_view(),~Unit,~transient_base(),~transient_with_component())

def constructed_position_rest() -> Type:
  ((S.constructed_velocity() & S.constructed_health()) & Recipe.Constructed<S.Schema,Array<U32>,S.identity("Position"),S.save>)
def constructed_position_take(owner:S.constructed_store()) -> ((S.constructed_velocity() & S.constructed_health()) & Recipe.Constructed<S.Schema,Array<U32>,S.identity("Position"),S.save>) & Col.Column<S.Schema,Array<U32>>:
  S.position_take(~S.constructed_position(),~S.constructed_velocity(),~S.constructed_health(),~Recipe.Constructed<S.Schema,Array<U32>,S.identity("Position"),S.save>,~(owner => S.constructed_take(~"Position",owner)),owner)
def constructed_position_put(rest:((S.constructed_velocity() & S.constructed_health()) & Recipe.Constructed<S.Schema,Array<U32>,S.identity("Position"),S.save>),column:Col.Column<S.Schema,Array<U32>>) -> S.constructed_store():
  S.position_put(~S.constructed_position(),~S.constructed_velocity(),~S.constructed_health(),~Recipe.Constructed<S.Schema,Array<U32>,S.identity("Position"),S.save>,~(recipe => column => S.constructed_put(~"Position",recipe,column)),rest,column)
def constructed_position_binding() -> B.Binding<S.Schema,S.constructed_store(),constructed_position_rest(),Array<U32>,View.FullCell,Unit,constructed_position_take,constructed_position_put,View.view>:
  B.bind(~S.Schema,~S.constructed_store(),~constructed_position_rest(),~Array<U32>,~View.FullCell,~Unit,~constructed_position_take,~constructed_position_put,~View.view,S.identity("Position"))
def constructed_read() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>,Cap.Read<Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>,View.FullCell>,I.Frame<S.Schema,S.constructed_store(),Unit,Unit>,Cmp.Access<View.FullCell>>:
   O.read(~S.Schema,~S.constructed_store(),~constructed_position_rest(),~Array<U32>,~View.FullCell,~Unit,~constructed_position_take,~constructed_position_put,~View.view,~Unit,~Unit,~constructed_position_binding())
 def constructed_added() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>,Unit,I.Frame<S.Schema,S.constructed_store(),Unit,Unit>,Unit>:
   O.added(~S.Schema,~S.constructed_store(),~constructed_position_rest(),~Array<U32>,~View.FullCell,~Unit,~constructed_position_take,~constructed_position_put,~View.view,~Unit,~Unit,~constructed_position_binding())
 def constructed_changed() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>,Unit,I.Frame<S.Schema,S.constructed_store(),Unit,Unit>,Unit>:
   O.changed(~S.Schema,~S.constructed_store(),~constructed_position_rest(),~Array<U32>,~View.FullCell,~Unit,~constructed_position_take,~constructed_position_put,~View.view,~Unit,~Unit,~constructed_position_binding())

def constructed_velocity_rest() -> Type:
  ((S.constructed_position() & S.constructed_health()) & Recipe.Constructed<S.Schema,Array<U32>,S.identity("Velocity"),S.save>)
def constructed_velocity_take(owner:S.constructed_store()) -> ((S.constructed_position() & S.constructed_health()) & Recipe.Constructed<S.Schema,Array<U32>,S.identity("Velocity"),S.save>) & Col.Column<S.Schema,Array<U32>>:
  S.velocity_take(~S.constructed_position(),~S.constructed_velocity(),~S.constructed_health(),~Recipe.Constructed<S.Schema,Array<U32>,S.identity("Velocity"),S.save>,~(owner => S.constructed_take(~"Velocity",owner)),owner)
def constructed_velocity_put(rest:((S.constructed_position() & S.constructed_health()) & Recipe.Constructed<S.Schema,Array<U32>,S.identity("Velocity"),S.save>),column:Col.Column<S.Schema,Array<U32>>) -> S.constructed_store():
  S.velocity_put(~S.constructed_position(),~S.constructed_velocity(),~S.constructed_health(),~Recipe.Constructed<S.Schema,Array<U32>,S.identity("Velocity"),S.save>,~(recipe => column => S.constructed_put(~"Velocity",recipe,column)),rest,column)
def constructed_velocity_binding() -> B.Binding<S.Schema,S.constructed_store(),constructed_velocity_rest(),Array<U32>,View.FullCell,Unit,constructed_velocity_take,constructed_velocity_put,View.view>:
  B.bind(~S.Schema,~S.constructed_store(),~constructed_velocity_rest(),~Array<U32>,~View.FullCell,~Unit,~constructed_velocity_take,~constructed_velocity_put,~View.view,S.identity("Velocity"))
def constructed_write() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>,Cap.Write<Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>,Array<U32>,View.FullCell>,I.Frame<S.Schema,S.constructed_store(),Unit,Unit>,Cmp.Access<View.FullCell>>:
   O.write(~S.Schema,~S.constructed_store(),~constructed_velocity_rest(),~Array<U32>,~View.FullCell,~Unit,~constructed_velocity_take,~constructed_velocity_put,~View.view,~Unit,~Unit,~constructed_velocity_binding())

def constructed_health_rest() -> Type:
  ((S.constructed_position() & S.constructed_velocity()) & Recipe.Constructed<S.Schema,Array<U32>,S.identity("Health"),S.save>)
def constructed_health_take(owner:S.constructed_store()) -> ((S.constructed_position() & S.constructed_velocity()) & Recipe.Constructed<S.Schema,Array<U32>,S.identity("Health"),S.save>) & Col.Column<S.Schema,Array<U32>>:
  S.health_take(~S.constructed_position(),~S.constructed_velocity(),~S.constructed_health(),~Recipe.Constructed<S.Schema,Array<U32>,S.identity("Health"),S.save>,~(owner => S.constructed_take(~"Health",owner)),owner)
def constructed_health_put(rest:((S.constructed_position() & S.constructed_velocity()) & Recipe.Constructed<S.Schema,Array<U32>,S.identity("Health"),S.save>),column:Col.Column<S.Schema,Array<U32>>) -> S.constructed_store():
  S.health_put(~S.constructed_position(),~S.constructed_velocity(),~S.constructed_health(),~Recipe.Constructed<S.Schema,Array<U32>,S.identity("Health"),S.save>,~(recipe => column => S.constructed_put(~"Health",recipe,column)),rest,column)
def constructed_health_binding() -> B.Binding<S.Schema,S.constructed_store(),constructed_health_rest(),Array<U32>,View.FullCell,Unit,constructed_health_take,constructed_health_put,View.view>:
  B.bind(~S.Schema,~S.constructed_store(),~constructed_health_rest(),~Array<U32>,~View.FullCell,~Unit,~constructed_health_take,~constructed_health_put,~View.view,S.identity("Health"))
def constructed_optional() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>,Cap.Read<Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>,View.FullCell>,I.Frame<S.Schema,S.constructed_store(),Unit,Unit>,Cmp.Access<View.FullCell>>:
   O.optional(~S.Schema,~S.constructed_store(),~constructed_health_rest(),~Array<U32>,~View.FullCell,~Unit,~constructed_health_take,~constructed_health_put,~View.view,~Unit,~Unit,~constructed_health_binding())
 def constructed_with_component() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>,Unit,I.Frame<S.Schema,S.constructed_store(),Unit,Unit>,Unit>:
   O.with_component(~S.Schema,~S.constructed_store(),~constructed_health_rest(),~Array<U32>,~View.FullCell,~Unit,~constructed_health_take,~constructed_health_put,~View.view,~Unit,~Unit,~constructed_health_binding())
 def constructed_without_component() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>,Unit,I.Frame<S.Schema,S.constructed_store(),Unit,Unit>,Unit>:
   O.without_component(~S.Schema,~S.constructed_store(),~constructed_health_rest(),~Array<U32>,~View.FullCell,~Unit,~constructed_health_take,~constructed_health_put,~View.view,~Unit,~Unit,~constructed_health_binding())

def constructed_base() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>,Body.Ops(Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>),I.Frame<S.Schema,S.constructed_store(),Unit,Unit>,base_view()>:
  O.pair(~S.Schema,~Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>,~(Cap.Read<Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>,View.FullCell> & Cap.Write<Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>,Array<U32>,View.FullCell>),~Cap.Read<Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>,View.FullCell>,~I.Frame<S.Schema,S.constructed_store(),Unit,Unit>,~P.Product<Cmp.Access<View.FullCell>,Cmp.Access<View.FullCell>>,~Cmp.Access<View.FullCell>,~O.pair(~S.Schema,~Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>,~Cap.Read<Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>,View.FullCell>,~Cap.Write<Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>,Array<U32>,View.FullCell>,~I.Frame<S.Schema,S.constructed_store(),Unit,Unit>,~Cmp.Access<View.FullCell>,~Cmp.Access<View.FullCell>,~constructed_read(),~constructed_write()),~constructed_optional())
def constructed_base_added() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>,Body.FilterOps(Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>),I.Frame<S.Schema,S.constructed_store(),Unit,Unit>,filtered_view()>:
  O.pair(~S.Schema,~Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>,~Body.Ops(Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>),~Unit,~I.Frame<S.Schema,S.constructed_store(),Unit,Unit>,~base_view(),~Unit,~constructed_base(),~constructed_added())
def constructed_base_changed() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>,Body.FilterOps(Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>),I.Frame<S.Schema,S.constructed_store(),Unit,Unit>,filtered_view()>:
  O.pair(~S.Schema,~Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>,~Body.Ops(Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>),~Unit,~I.Frame<S.Schema,S.constructed_store(),Unit,Unit>,~base_view(),~Unit,~constructed_base(),~constructed_changed())
def constructed_base_without_component() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>,Body.FilterOps(Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>),I.Frame<S.Schema,S.constructed_store(),Unit,Unit>,filtered_view()>:
  O.pair(~S.Schema,~Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>,~Body.Ops(Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>),~Unit,~I.Frame<S.Schema,S.constructed_store(),Unit,Unit>,~base_view(),~Unit,~constructed_base(),~constructed_without_component())
def constructed_base_with_component() -> O.Declaration<S.Schema,Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>,Body.FilterOps(Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>),I.Frame<S.Schema,S.constructed_store(),Unit,Unit>,filtered_view()>:
  O.pair(~S.Schema,~Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>,~Body.Ops(Q.Frame<S.Schema,S.constructed_store(),Unit,Unit>),~Unit,~I.Frame<S.Schema,S.constructed_store(),Unit,Unit>,~base_view(),~Unit,~constructed_base(),~constructed_with_component())
