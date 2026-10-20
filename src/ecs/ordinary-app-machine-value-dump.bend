import Base
import ./world.bend as W
import ./machine.bend as M
import ./machine-world.bend as MW
import ./ordinary-machine-declaration.bend as OD
import ./ordinary-app-machine.bend as Machine
import ./ordinary-app-composer.bend as Build
import ./ordinary-app-registration-fields.bend as Fields
import ./ordinary-app-observation-data.bend as DTO
# Full existing Data slot; no state transition, structural flush or reader work.
# Name and slot lens come from the SAME operative ordinary declaration.
# Detached full existing machine Slot plus declaration name, including queued and
# previous state metadata. This is a Data observation, not an execution capability.
type View<S:Data,K:Data,V:Data> is Data:
  View{name:String,slot:M.Slot<S,K,V>}
def returned(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,~same:V -> V -> Bool,~declaration:OD.Declaration<S,K,V,R,take>,~render:V -> String,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,owners:Owners,recipe:Machine.Recipe(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold),result:W.World<S,C,R,E> & M.Slot<S,K,V>) -> Machine.Application(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold) & Maybe<&2,View<S,K,V>>:
  match result:
    case (world,slot):(Build.Registered{world,owners,recipe,True{}},Some{View{OD.name(~S,~K,~V,~R,~take,declaration),slot}})
# Return App with optional full declared machine Slot. Disabled returns None
# before slot projection; enabled retains actual World/registration owners and
# recipe. No state transition, queue flush, barrier or reader advancement occurs.
def snapshot(~S:Data,~K:Data,~V:Data,~C:Type,~R:Type,~E:Data,~take:R -> R & M.Slot<S,K,V>,~put:R -> M.Slot<S,K,V> -> R,~same:V -> V -> Bool,~declaration:OD.Declaration<S,K,V,R,take>,~render:V -> String,~Owners:Type,~Rows:Data,~prior:W.World<S,C,R,E> -> W.World<S,C,R,E> & DTO.Observation<Rows>,~fold:Owners -> Owners & List<&2,Fields.Fields<S>>,app:Machine.Application(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold)) -> Machine.Application(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold) & Maybe<&2,View<S,K,V>>:
  match app:
    case Build.Registered{world,owners,recipe,True{}}:returned(~S,~K,~V,~C,~R,~E,~take,~put,~same,~declaration,~render,~Owners,~Rows,~prior,~fold,owners,recipe,MW.take(~S,~K,~V,~C,~R,~E,~take,world))
    case app:(app,None{})
