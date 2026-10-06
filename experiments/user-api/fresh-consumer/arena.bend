import Base
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/column.bend as Col
import ../../../src/ecs/component.bend as Cmp
import ../../../src/ecs/query.bend as Q
import ../../../src/ecs/provider.bend as Pv
import ../../../src/ecs/system.bend as Sys
import ../../../src/ecs/transaction.bend as T

type Arena is Data:
  Arena{}
type Fault is Data:
  Abort{}
type Hit is Data:
  Hit{remaining: U32}
type Position is Type:
  Position{cells: Array<U32>}
type PositionToken is Data:
  PositionToken{}
type Velocity is Type:
  Velocity{cells: Array<U32>}
type VelocityToken is Data:
  VelocityToken{}
type Health is Type:
  Health{cells: Array<U32>}
type HealthToken is Data:
  HealthToken{}
type Armor is Type:
  Armor{cells: Array<U32>}
type ArmorToken is Data:
  ArmorToken{}
type Store is Type:
  Store{position: Col.Column<Arena,Position>,velocity: Col.Column<Arena,Velocity>,health: Col.Column<Arena,Health>,armor: Col.Column<Arena,Armor>}
type PositionRest is Type:
  PositionRest{velocity: Col.Column<Arena,Velocity>,health: Col.Column<Arena,Health>,armor: Col.Column<Arena,Armor>}
def take_Position(store: Store) -> PositionRest & Col.Column<Arena,Position>:
  match store:
    case Store{position,velocity,health,armor}: (PositionRest{velocity,health,armor},position)
def put_Position(rest: PositionRest,column: Col.Column<Arena,Position>) -> Store:
  match rest:
    case PositionRest{velocity,health,armor}: Store{column,velocity,health,armor}
def restore_Position(view: Array<U32> & U32) -> Position & U32:
  (cells,value) = view
  (Position{cells},value)
def project_Position(owner: Position) -> Position & U32:
  match owner:
    case Position{cells}: restore_Position(Array.get(U32,cells,0))
def family_Position() -> Cmp.Family<Arena,Store,PositionRest,Position,U32,PositionToken,take_Position,put_Position,project_Position>:
  Cmp.define(~Arena,~Store,~U32,~Hit,~PositionRest,~Position,~U32,~PositionToken,~take_Position,~put_Position,~project_Position,"Position")
type VelocityRest is Type:
  VelocityRest{position: Col.Column<Arena,Position>,health: Col.Column<Arena,Health>,armor: Col.Column<Arena,Armor>}
def take_Velocity(store: Store) -> VelocityRest & Col.Column<Arena,Velocity>:
  match store:
    case Store{position,velocity,health,armor}: (VelocityRest{position,health,armor},velocity)
def put_Velocity(rest: VelocityRest,column: Col.Column<Arena,Velocity>) -> Store:
  match rest:
    case VelocityRest{position,health,armor}: Store{position,column,health,armor}
def restore_Velocity(view: Array<U32> & U32) -> Velocity & U32:
  (cells,value) = view
  (Velocity{cells},value)
def project_Velocity(owner: Velocity) -> Velocity & U32:
  match owner:
    case Velocity{cells}: restore_Velocity(Array.get(U32,cells,0))
def family_Velocity() -> Cmp.Family<Arena,Store,VelocityRest,Velocity,U32,VelocityToken,take_Velocity,put_Velocity,project_Velocity>:
  Cmp.define(~Arena,~Store,~U32,~Hit,~VelocityRest,~Velocity,~U32,~VelocityToken,~take_Velocity,~put_Velocity,~project_Velocity,"Velocity")
type HealthRest is Type:
  HealthRest{position: Col.Column<Arena,Position>,velocity: Col.Column<Arena,Velocity>,armor: Col.Column<Arena,Armor>}
def take_Health(store: Store) -> HealthRest & Col.Column<Arena,Health>:
  match store:
    case Store{position,velocity,health,armor}: (HealthRest{position,velocity,armor},health)
def put_Health(rest: HealthRest,column: Col.Column<Arena,Health>) -> Store:
  match rest:
    case HealthRest{position,velocity,armor}: Store{position,velocity,column,armor}
def restore_Health(view: Array<U32> & U32) -> Health & U32:
  (cells,value) = view
  (Health{cells},value)
def project_Health(owner: Health) -> Health & U32:
  match owner:
    case Health{cells}: restore_Health(Array.get(U32,cells,0))
def family_Health() -> Cmp.Family<Arena,Store,HealthRest,Health,U32,HealthToken,take_Health,put_Health,project_Health>:
  Cmp.define(~Arena,~Store,~U32,~Hit,~HealthRest,~Health,~U32,~HealthToken,~take_Health,~put_Health,~project_Health,"Health")
type ArmorRest is Type:
  ArmorRest{position: Col.Column<Arena,Position>,velocity: Col.Column<Arena,Velocity>,health: Col.Column<Arena,Health>}
def take_Armor(store: Store) -> ArmorRest & Col.Column<Arena,Armor>:
  match store:
    case Store{position,velocity,health,armor}: (ArmorRest{position,velocity,health},armor)
def put_Armor(rest: ArmorRest,column: Col.Column<Arena,Armor>) -> Store:
  match rest:
    case ArmorRest{position,velocity,health}: Store{position,velocity,health,column}
def restore_Armor(view: Array<U32> & U32) -> Armor & U32:
  (cells,value) = view
  (Armor{cells},value)
def project_Armor(owner: Armor) -> Armor & U32:
  match owner:
    case Armor{cells}: restore_Armor(Array.get(U32,cells,0))
def family_Armor() -> Cmp.Family<Arena,Store,ArmorRest,Armor,U32,ArmorToken,take_Armor,put_Armor,project_Armor>:
  Cmp.define(~Arena,~Store,~U32,~Hit,~ArmorRest,~Armor,~U32,~ArmorToken,~take_Armor,~put_Armor,~project_Armor,"Armor")
def empty(unit: Unit) -> Store:
  Store{Col.empty(~Arena,~Position),Col.empty(~Arena,~Velocity),Col.empty(~Arena,~Health),Col.empty(~Arena,~Armor)}
def resource(dt: U32) -> U32 & U32:
  +value = dt
  (value,value)
def clear_Position_swap(rest: PositionRest,result: Col.SwapOutcome<Arena,Position>) -> Store:
  match result:
    case Col.Accepted{column,_}: put_Position(rest,column)
    case Col.Rejected{column,_}: put_Position(rest,column)
def clear_Position_taken(id: U32,taken: PositionRest & Col.Column<Arena,Position>) -> Store:
  (rest,column) = taken
  clear_Position_swap(rest,Col.remove(~Arena,~Position,column,id))
def clear_Position(store: Store,id: U32) -> Store:
  clear_Position_taken(id,take_Position(store))
def clear_Velocity_swap(rest: VelocityRest,result: Col.SwapOutcome<Arena,Velocity>) -> Store:
  match result:
    case Col.Accepted{column,_}: put_Velocity(rest,column)
    case Col.Rejected{column,_}: put_Velocity(rest,column)
def clear_Velocity_taken(id: U32,taken: VelocityRest & Col.Column<Arena,Velocity>) -> Store:
  (rest,column) = taken
  clear_Velocity_swap(rest,Col.remove(~Arena,~Velocity,column,id))
def clear_Velocity(store: Store,id: U32) -> Store:
  clear_Velocity_taken(id,take_Velocity(store))
def clear_Health_swap(rest: HealthRest,result: Col.SwapOutcome<Arena,Health>) -> Store:
  match result:
    case Col.Accepted{column,_}: put_Health(rest,column)
    case Col.Rejected{column,_}: put_Health(rest,column)
def clear_Health_taken(id: U32,taken: HealthRest & Col.Column<Arena,Health>) -> Store:
  (rest,column) = taken
  clear_Health_swap(rest,Col.remove(~Arena,~Health,column,id))
def clear_Health(store: Store,id: U32) -> Store:
  clear_Health_taken(id,take_Health(store))
def clear_Armor_swap(rest: ArmorRest,result: Col.SwapOutcome<Arena,Armor>) -> Store:
  match result:
    case Col.Accepted{column,_}: put_Armor(rest,column)
    case Col.Rejected{column,_}: put_Armor(rest,column)
def clear_Armor_taken(id: U32,taken: ArmorRest & Col.Column<Arena,Armor>) -> Store:
  (rest,column) = taken
  clear_Armor_swap(rest,Col.remove(~Arena,~Armor,column,id))
def clear_Armor(store: Store,id: U32) -> Store:
  clear_Armor_taken(id,take_Armor(store))
def clear(store: Store,handle: W.Handle<Arena>) -> Store:
  match handle:
    case W.Handle{_,+id}: clear_Armor(clear_Health(clear_Velocity(clear_Position(store,id),id),id),id)
def populate(world: W.World<Arena,Store,U32,Hit>,handle: W.Handle<Arena>,unit: Unit) -> W.World<Arena,Store,U32,Hit>:
  world

def move_values(~H: Type,~set: H -> Position -> H,dt: U32,position: Cmp.Access<U32>,velocity: Cmp.Access<U32>,ctx: H) -> H & T.Outcome<Fault>:
  match position velocity:
    case Cmp.Found{x} Cmp.Found{v}: (set(ctx,Position{ALeaf{(x + (v * dt : U32) : U32)}}),T.Success{})
    case _ _: (ctx,T.Failure{Abort{}})
def move_dt(~H: Type,~set: H -> Position -> H,position: Cmp.Access<U32>,velocity: Cmp.Access<U32>,observed: H & U32) -> H & T.Outcome<Fault>:
  (ctx,dt) = observed
  move_values(~H,~set,dt,position,velocity,ctx)
def move_velocity(~H: Type,~set: H -> Position -> H,~resource_get: H -> H & U32,position: Cmp.Access<U32>,observed: H & Cmp.Access<U32>) -> H & T.Outcome<Fault>:
  (ctx,velocity) = observed
  move_dt(~H,~set,position,velocity,resource_get(ctx))
def move_position(~H: Type,~set: H -> Position -> H,~aux: H -> H & Cmp.Access<U32>,~resource_get: H -> H & U32,observed: H & Cmp.Access<U32>) -> H & T.Outcome<Fault>:
  (ctx,position) = observed
  move_velocity(~H,~set,~resource_get,position,aux(ctx))
def movement(~H: Type,~get: H -> H & Cmp.Access<U32>,~set: H -> Position -> H,~aux: H -> H & Cmp.Access<U32>,~resource_get: H -> H & U32,args: Unit,handle: W.Handle<Arena>,ctx: H) -> H & T.Outcome<Fault>:
  move_position(~H,~set,~aux,~resource_get,get(ctx))
def armor_value(armor: Cmp.Access<U32>) -> U32:
  match armor:
    case Cmp.Found{a}: a
    case _: 0

def damage_done(~H: Type,fail: Bool,ctx: H) -> H & T.Outcome<Fault>:
  match fail:
    case True{}: (ctx,T.Failure{Abort{}})
    case False{}: (ctx,T.Success{})
def damage_values(~H: Type,~set: H -> Health -> H,~emit: H -> Hit -> H,fail: Bool,armor: U32,health: Cmp.Access<U32>,ctx: H) -> H & T.Outcome<Fault>:
  match health:
    case Cmp.Found{hp}:
      +remaining = (hp - (5 - armor : U32) : U32)
      damage_done(~H,fail,emit(set(ctx,Health{ALeaf{remaining}}),Hit{remaining}))
    case _: (ctx,T.Failure{Abort{}})
def damage_armor(~H: Type,~set: H -> Health -> H,~emit: H -> Hit -> H,fail: Bool,health: Cmp.Access<U32>,observed: H & Cmp.Access<U32>) -> H & T.Outcome<Fault>:
  (ctx,armor) = observed
  damage_values(~H,~set,~emit,fail,armor_value(armor),health,ctx)
def damage_health(~H: Type,~set: H -> Health -> H,~aux: H -> H & Cmp.Access<U32>,~emit: H -> Hit -> H,fail: Bool,observed: H & Cmp.Access<U32>) -> H & T.Outcome<Fault>:
  (ctx,health) = observed
  damage_armor(~H,~set,~emit,fail,health,aux(ctx))
def damage(~H: Type,~get: H -> H & Cmp.Access<U32>,~set: H -> Health -> H,~aux: H -> H & Cmp.Access<U32>,~emit: H -> Hit -> H,~despawn: H -> H,fail: Bool,handle: W.Handle<Arena>,ctx: H) -> H & T.Outcome<Fault>:
  damage_health(~H,~set,~aux,~emit,fail,get(ctx))

def move_result(result: T.Returned<W.World<Arena,Store,U32,Hit>,Pv.Error<Fault>>) -> Sys.Outcome<W.World<Arena,Store,U32,Hit>,Pv.Error<Fault>,Unit>:
  match result:
    case T.Returned{world,T.Success{}}: Sys.Succeeded{world,Unit{}}
    case T.Returned{world,T.Failure{error}}: Sys.Failed{world,error}
def move_runner(world: W.World<Arena,Store,U32,Hit>,args: Unit) -> Sys.Outcome<W.World<Arena,Store,U32,Hit>,Pv.Error<Fault>,Unit>:
  move_result(Q.each_rw_read_resource(~Arena,~Store,~U32,~Hit,~PositionRest,~Position,~U32,~PositionToken,~take_Position,~put_Position,~project_Position,~VelocityRest,~Velocity,~U32,~VelocityToken,~take_Velocity,~put_Velocity,~project_Velocity,~U32,~resource,~Unit,~populate,~clear,~Unit,~Fault,~movement,family_Position(),family_Velocity(),Q.Required{},world,args))

def hurt_result(result: T.Returned<W.World<Arena,Store,U32,Hit>,Pv.Error<Fault>>) -> Sys.Outcome<W.World<Arena,Store,U32,Hit>,Pv.Error<Fault>,Unit>:
  match result:
    case T.Returned{world,T.Success{}}: Sys.Succeeded{world,Unit{}}
    case T.Returned{world,T.Failure{error}}: Sys.Failed{world,error}
def hurt_runner(world: W.World<Arena,Store,U32,Hit>,args: Bool) -> Sys.Outcome<W.World<Arena,Store,U32,Hit>,Pv.Error<Fault>,Unit>:
  hurt_result(Q.each_rw_read_events(~Arena,~Store,~U32,~Hit,~HealthRest,~Health,~U32,~HealthToken,~take_Health,~put_Health,~project_Health,~ArmorRest,~Armor,~U32,~ArmorToken,~take_Armor,~put_Armor,~project_Armor,~U32,~resource,~Unit,~populate,~clear,~Bool,~Fault,~damage,family_Health(),family_Armor(),Q.Optional{},world,args))

def write_Position_result(result: Cmp.Replacement<W.World<Arena,Store,U32,Hit>,Position>) -> W.World<Arena,Store,U32,Hit>:
  match result:
    case Cmp.Replaced{world,_}: world
    case Cmp.ReplaceRejected{world,_,_}: world
def write_Position(world: W.World<Arena,Store,U32,Hit>,handle: W.Handle<Arena>,value: U32) -> W.World<Arena,Store,U32,Hit>:
  write_Position_result(Cmp.replace(~Arena,~Store,~U32,~Hit,~PositionRest,~Position,~U32,~PositionToken,~take_Position,~put_Position,~project_Position,family_Position(),world,handle,Some{Position{ALeaf{value}}}))

def write_Velocity_result(result: Cmp.Replacement<W.World<Arena,Store,U32,Hit>,Velocity>) -> W.World<Arena,Store,U32,Hit>:
  match result:
    case Cmp.Replaced{world,_}: world
    case Cmp.ReplaceRejected{world,_,_}: world
def write_Velocity(world: W.World<Arena,Store,U32,Hit>,handle: W.Handle<Arena>,value: U32) -> W.World<Arena,Store,U32,Hit>:
  write_Velocity_result(Cmp.replace(~Arena,~Store,~U32,~Hit,~VelocityRest,~Velocity,~U32,~VelocityToken,~take_Velocity,~put_Velocity,~project_Velocity,family_Velocity(),world,handle,Some{Velocity{ALeaf{value}}}))

def write_Health_result(result: Cmp.Replacement<W.World<Arena,Store,U32,Hit>,Health>) -> W.World<Arena,Store,U32,Hit>:
  match result:
    case Cmp.Replaced{world,_}: world
    case Cmp.ReplaceRejected{world,_,_}: world
def write_Health(world: W.World<Arena,Store,U32,Hit>,handle: W.Handle<Arena>,value: U32) -> W.World<Arena,Store,U32,Hit>:
  write_Health_result(Cmp.replace(~Arena,~Store,~U32,~Hit,~HealthRest,~Health,~U32,~HealthToken,~take_Health,~put_Health,~project_Health,family_Health(),world,handle,Some{Health{ALeaf{value}}}))

def write_Armor_result(result: Cmp.Replacement<W.World<Arena,Store,U32,Hit>,Armor>) -> W.World<Arena,Store,U32,Hit>:
  match result:
    case Cmp.Replaced{world,_}: world
    case Cmp.ReplaceRejected{world,_,_}: world
def write_Armor(world: W.World<Arena,Store,U32,Hit>,handle: W.Handle<Arena>,value: U32) -> W.World<Arena,Store,U32,Hit>:
  write_Armor_result(Cmp.replace(~Arena,~Store,~U32,~Hit,~ArmorRest,~Armor,~U32,~ArmorToken,~take_Armor,~put_Armor,~project_Armor,family_Armor(),world,handle,Some{Armor{ALeaf{value}}}))

def actor_armor(armored: Bool,handle: W.Handle<Arena>,world: W.World<Arena,Store,U32,Hit>) -> W.World<Arena,Store,U32,Hit>:
  match armored:
    case True{}: write_Armor(world,handle,2)
    case False{}: world

def actor_active(+handle: W.Handle<Arena>,armored: Bool,position: U32,velocity: U32,hp: U32,active: W.World<Arena,Store,U32,Hit> & W.Status) -> W.World<Arena,Store,U32,Hit>:
  match active:
    case (world,W.Rejected{_}): world
    case (world,W.Accepted{}): actor_armor(armored,handle,write_Health(write_Velocity(write_Position(world,handle,position),handle,velocity),handle,hp))

def actor_reserved(armored: Bool,position: U32,velocity: U32,hp: U32,reserved: W.World<Arena,Store,U32,Hit> & W.Reservation<Arena>) -> W.World<Arena,Store,U32,Hit>:
  match reserved:
    case (world,W.ReservationRejected{_}): world
    case (world,W.Reserved{+handle}): actor_active(handle,armored,position,velocity,hp,W.activate(~Arena,~Store,~U32,~Hit,world,handle))
def actor(world: W.World<Arena,Store,U32,Hit>,armored: Bool,position: U32,velocity: U32,hp: U32) -> W.World<Arena,Store,U32,Hit>:
  actor_reserved(armored,position,velocity,hp,W.reserve_id(~Arena,~Store,~U32,~Hit,world))

def show_access(value: Cmp.Access<U32>) -> String:
  match value:
    case Cmp.Found{value}: U32.show(value)
    case _: "absent"

def observe_events(prefix: String,observed: W.World<Arena,Store,U32,Hit> & List<&2,Hit>) -> String:
  (world,events) = observed
  prefix ++ ",events=" ++ Nat.show(List.length(&2,Hit,events))

def observe_3(prefix: String,+ns: U32,observed: W.World<Arena,Store,U32,Hit> & Cmp.Access<U32>) -> String:
  (world,value) = observed
  observe_events(prefix ++ show_access(value),W.events_view(~Arena,~Store,~U32,~Hit,world))

def observe_2(prefix: String,+ns: U32,observed: W.World<Arena,Store,U32,Hit> & Cmp.Access<U32>) -> String:
  (world,value) = observed
  observe_3(prefix ++ show_access(value) ++ ",",ns,Cmp.get(~Arena,~Store,~U32,~Hit,~HealthRest,~Health,~U32,~HealthToken,~take_Health,~put_Health,~project_Health,family_Health(),world,W.Handle{ns,2}))

def observe_1(prefix: String,+ns: U32,observed: W.World<Arena,Store,U32,Hit> & Cmp.Access<U32>) -> String:
  (world,value) = observed
  observe_2(prefix ++ show_access(value) ++ ",",ns,Cmp.get(~Arena,~Store,~U32,~Hit,~HealthRest,~Health,~U32,~HealthToken,~take_Health,~put_Health,~project_Health,family_Health(),world,W.Handle{ns,1}))

def observe_0(prefix: String,+ns: U32,observed: W.World<Arena,Store,U32,Hit> & Cmp.Access<U32>) -> String:
  (world,value) = observed
  observe_1(prefix ++ show_access(value) ++ ",",ns,Cmp.get(~Arena,~Store,~U32,~Hit,~PositionRest,~Position,~U32,~PositionToken,~take_Position,~put_Position,~project_Position,family_Position(),world,W.Handle{ns,2}))

def observe_named(prefix: String,named: W.World<Arena,Store,U32,Hit> & U32) -> String:
  (world,+ns) = named
  observe_0(prefix,ns,Cmp.get(~Arena,~Store,~U32,~Hit,~PositionRest,~Position,~U32,~PositionToken,~take_Position,~put_Position,~project_Position,family_Position(),world,W.Handle{ns,1}))
def observe(prefix: String,world: W.World<Arena,Store,U32,Hit>) -> String:
  observe_named(prefix,W.namespace(~Arena,~Store,~U32,~Hit,world))

def outcome_5(prefix: String,move: Sys.Registry<Arena,Store,U32,Hit,Unit,Pv.Error<Fault>,Unit,move_runner>,hurt: Sys.Registry<Arena,Store,U32,Hit,Bool,Pv.Error<Fault>,Unit,hurt_runner>,outcome: Sys.Outcome<W.World<Arena,Store,U32,Hit>,Pv.Error<Fault>,Unit>) -> String:
  match outcome:
    case Sys.Succeeded{world,_}: observe(prefix ++ "S:position1,position2,health1,health2=",world)
    case Sys.Failed{world,_}: observe(prefix ++ "F:position1,position2,health1,health2=",world)

def completed_5(prefix: String,move: Sys.Registry<Arena,Store,U32,Hit,Unit,Pv.Error<Fault>,Unit,move_runner>,result: Sys.RunResult<Arena,Store,U32,Hit,Bool,Pv.Error<Fault>,Unit,hurt_runner>) -> String:
  match result:
    case Sys.RegistrationRejected{_,world,_}: observe("registration-refused:",world)
    case Sys.Completed{hurt,outcome}: outcome_5(prefix,move,hurt,outcome)

def run_5(prefix: String,world: W.World<Arena,Store,U32,Hit>,move: Sys.Registry<Arena,Store,U32,Hit,Unit,Pv.Error<Fault>,Unit,move_runner>,hurt: Sys.Registry<Arena,Store,U32,Hit,Bool,Pv.Error<Fault>,Unit,hurt_runner>) -> String:
  completed_5(prefix,move,Sys.run(~Arena,~Store,~U32,~Hit,~Bool,~Pv.Error<Fault>,~Unit,~hurt_runner,hurt,world,False{}))

def outcome_4(prefix: String,move: Sys.Registry<Arena,Store,U32,Hit,Unit,Pv.Error<Fault>,Unit,move_runner>,hurt: Sys.Registry<Arena,Store,U32,Hit,Bool,Pv.Error<Fault>,Unit,hurt_runner>,outcome: Sys.Outcome<W.World<Arena,Store,U32,Hit>,Pv.Error<Fault>,Unit>) -> String:
  match outcome:
    case Sys.Succeeded{world,_}: run_5(prefix ++ "S",world,move,hurt)
    case Sys.Failed{world,_}: run_5(prefix ++ "F",world,move,hurt)

def completed_4(prefix: String,move: Sys.Registry<Arena,Store,U32,Hit,Unit,Pv.Error<Fault>,Unit,move_runner>,result: Sys.RunResult<Arena,Store,U32,Hit,Bool,Pv.Error<Fault>,Unit,hurt_runner>) -> String:
  match result:
    case Sys.RegistrationRejected{_,world,_}: observe("registration-refused:",world)
    case Sys.Completed{hurt,outcome}: outcome_4(prefix,move,hurt,outcome)

def run_4(prefix: String,world: W.World<Arena,Store,U32,Hit>,move: Sys.Registry<Arena,Store,U32,Hit,Unit,Pv.Error<Fault>,Unit,move_runner>,hurt: Sys.Registry<Arena,Store,U32,Hit,Bool,Pv.Error<Fault>,Unit,hurt_runner>) -> String:
  completed_4(prefix,move,Sys.run(~Arena,~Store,~U32,~Hit,~Bool,~Pv.Error<Fault>,~Unit,~hurt_runner,hurt,world,True{}))

def outcome_3(prefix: String,move: Sys.Registry<Arena,Store,U32,Hit,Unit,Pv.Error<Fault>,Unit,move_runner>,hurt: Sys.Registry<Arena,Store,U32,Hit,Bool,Pv.Error<Fault>,Unit,hurt_runner>,outcome: Sys.Outcome<W.World<Arena,Store,U32,Hit>,Pv.Error<Fault>,Unit>) -> String:
  match outcome:
    case Sys.Succeeded{world,_}: run_4(prefix ++ "S",world,move,hurt)
    case Sys.Failed{world,_}: run_4(prefix ++ "F",world,move,hurt)

def completed_3(prefix: String,move: Sys.Registry<Arena,Store,U32,Hit,Unit,Pv.Error<Fault>,Unit,move_runner>,result: Sys.RunResult<Arena,Store,U32,Hit,Bool,Pv.Error<Fault>,Unit,hurt_runner>) -> String:
  match result:
    case Sys.RegistrationRejected{_,world,_}: observe("registration-refused:",world)
    case Sys.Completed{hurt,outcome}: outcome_3(prefix,move,hurt,outcome)

def run_3(prefix: String,world: W.World<Arena,Store,U32,Hit>,move: Sys.Registry<Arena,Store,U32,Hit,Unit,Pv.Error<Fault>,Unit,move_runner>,hurt: Sys.Registry<Arena,Store,U32,Hit,Bool,Pv.Error<Fault>,Unit,hurt_runner>) -> String:
  completed_3(prefix,move,Sys.run(~Arena,~Store,~U32,~Hit,~Bool,~Pv.Error<Fault>,~Unit,~hurt_runner,hurt,world,False{}))

def outcome_2(prefix: String,move: Sys.Registry<Arena,Store,U32,Hit,Unit,Pv.Error<Fault>,Unit,move_runner>,hurt: Sys.Registry<Arena,Store,U32,Hit,Bool,Pv.Error<Fault>,Unit,hurt_runner>,outcome: Sys.Outcome<W.World<Arena,Store,U32,Hit>,Pv.Error<Fault>,Unit>) -> String:
  match outcome:
    case Sys.Succeeded{world,_}: run_3(prefix ++ "S",world,move,hurt)
    case Sys.Failed{world,_}: run_3(prefix ++ "F",world,move,hurt)

def completed_2(prefix: String,hurt: Sys.Registry<Arena,Store,U32,Hit,Bool,Pv.Error<Fault>,Unit,hurt_runner>,result: Sys.RunResult<Arena,Store,U32,Hit,Unit,Pv.Error<Fault>,Unit,move_runner>) -> String:
  match result:
    case Sys.RegistrationRejected{_,world,_}: observe("registration-refused:",world)
    case Sys.Completed{move,outcome}: outcome_2(prefix,move,hurt,outcome)

def run_2(prefix: String,world: W.World<Arena,Store,U32,Hit>,move: Sys.Registry<Arena,Store,U32,Hit,Unit,Pv.Error<Fault>,Unit,move_runner>,hurt: Sys.Registry<Arena,Store,U32,Hit,Bool,Pv.Error<Fault>,Unit,hurt_runner>) -> String:
  completed_2(prefix,hurt,Sys.run(~Arena,~Store,~U32,~Hit,~Unit,~Pv.Error<Fault>,~Unit,~move_runner,move,world,Unit{}))

def outcome_1(prefix: String,move: Sys.Registry<Arena,Store,U32,Hit,Unit,Pv.Error<Fault>,Unit,move_runner>,hurt: Sys.Registry<Arena,Store,U32,Hit,Bool,Pv.Error<Fault>,Unit,hurt_runner>,outcome: Sys.Outcome<W.World<Arena,Store,U32,Hit>,Pv.Error<Fault>,Unit>) -> String:
  match outcome:
    case Sys.Succeeded{world,_}: run_2(prefix ++ "S",world,move,hurt)
    case Sys.Failed{world,_}: run_2(prefix ++ "F",world,move,hurt)

def completed_1(prefix: String,move: Sys.Registry<Arena,Store,U32,Hit,Unit,Pv.Error<Fault>,Unit,move_runner>,result: Sys.RunResult<Arena,Store,U32,Hit,Bool,Pv.Error<Fault>,Unit,hurt_runner>) -> String:
  match result:
    case Sys.RegistrationRejected{_,world,_}: observe("registration-refused:",world)
    case Sys.Completed{hurt,outcome}: outcome_1(prefix,move,hurt,outcome)

def run_1(prefix: String,world: W.World<Arena,Store,U32,Hit>,move: Sys.Registry<Arena,Store,U32,Hit,Unit,Pv.Error<Fault>,Unit,move_runner>,hurt: Sys.Registry<Arena,Store,U32,Hit,Bool,Pv.Error<Fault>,Unit,hurt_runner>) -> String:
  completed_1(prefix,move,Sys.run(~Arena,~Store,~U32,~Hit,~Bool,~Pv.Error<Fault>,~Unit,~hurt_runner,hurt,world,False{}))

def outcome_0(prefix: String,move: Sys.Registry<Arena,Store,U32,Hit,Unit,Pv.Error<Fault>,Unit,move_runner>,hurt: Sys.Registry<Arena,Store,U32,Hit,Bool,Pv.Error<Fault>,Unit,hurt_runner>,outcome: Sys.Outcome<W.World<Arena,Store,U32,Hit>,Pv.Error<Fault>,Unit>) -> String:
  match outcome:
    case Sys.Succeeded{world,_}: run_1(prefix ++ "S",world,move,hurt)
    case Sys.Failed{world,_}: run_1(prefix ++ "F",world,move,hurt)

def completed_0(prefix: String,hurt: Sys.Registry<Arena,Store,U32,Hit,Bool,Pv.Error<Fault>,Unit,hurt_runner>,result: Sys.RunResult<Arena,Store,U32,Hit,Unit,Pv.Error<Fault>,Unit,move_runner>) -> String:
  match result:
    case Sys.RegistrationRejected{_,world,_}: observe("registration-refused:",world)
    case Sys.Completed{move,outcome}: outcome_0(prefix,move,hurt,outcome)

def run_0(prefix: String,world: W.World<Arena,Store,U32,Hit>,move: Sys.Registry<Arena,Store,U32,Hit,Unit,Pv.Error<Fault>,Unit,move_runner>,hurt: Sys.Registry<Arena,Store,U32,Hit,Bool,Pv.Error<Fault>,Unit,hurt_runner>) -> String:
  completed_0(prefix,hurt,Sys.run(~Arena,~Store,~U32,~Hit,~Unit,~Pv.Error<Fault>,~Unit,~move_runner,move,world,Unit{}))

def hurt_registered(move: Sys.Registry<Arena,Store,U32,Hit,Unit,Pv.Error<Fault>,Unit,move_runner>,result: Sys.RegistrationResult<Arena,Store,U32,Hit,Bool,Pv.Error<Fault>,Unit,hurt_runner>) -> String:
  match result:
    case Sys.RegistrationFailed{world}: observe("hurt-registration-failed:",world)
    case Sys.Registered{world,hurt}: run_0("",world,move,hurt)
def move_registered(result: Sys.RegistrationResult<Arena,Store,U32,Hit,Unit,Pv.Error<Fault>,Unit,move_runner>) -> String:
  match result:
    case Sys.RegistrationFailed{world}: observe("move-registration-failed:",world)
    case Sys.Registered{world,move}: hurt_registered(move,Sys.register(~Arena,~Store,~U32,~Hit,~Bool,~Pv.Error<Fault>,~Unit,~hurt_runner,world,"Damage",["write Health","optional read Armor","emit Hit","despawn"]))
def ready(world: W.World<Arena,Store,U32,Hit>) -> String:
  move_registered(Sys.register(~Arena,~Store,~U32,~Hit,~Unit,~Pv.Error<Fault>,~Unit,~move_runner,actor(actor(world,True{},0,2,30),False{},10,1,20),"Movement",["write Position","read Velocity","read resource"]))
def created(creation: W.Creation<Arena,Store,U32,Hit>) -> String:
  match creation:
    case W.CreateRejected{_,_}: "creation-failed"
    case W.Created{_,world}: ready(world)
def scenario() -> String:
  created(W.create(~Arena,~Store,~U32,~Hit,~empty,W.factory(),2))
def main() -> IO(Unit):
  IO.print(scenario())
