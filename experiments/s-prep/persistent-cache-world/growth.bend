import Base
import ./types.bend as T
import ./storage.bend as S
import ./commands.bend as Q
import ./persistent-payload.bend as K
import ./cache.bend as C
import ./prototype.bend as E

def changes(-Z:Data,values:List<&2,S.Change<Z>>) -> String:
  match values:
    case Nil{}: ""
    case Con{S.MainAdded{S.Handle{_,id}},tail}: "A" ++ U32.show(id) ++ ";" ++ changes(Z,tail)
    case Con{S.MainChanged{S.Handle{_,id}},tail}: "C" ++ U32.show(id) ++ ";" ++ changes(Z,tail)
    case Con{S.MainRemoved{S.Handle{_,id}},tail}: "R" ++ U32.show(id) ++ ";" ++ changes(Z,tail)
    case Con{S.Despawned{S.Handle{_,id}},tail}: "D" ++ U32.show(id) ++ ";" ++ changes(Z,tail)

def motion_applied(label:String,result:Q.CheckedApply<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>) -> IO(S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>):
  match result:
    case Q.Applied{world,events}:
      do IO<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>>:
        IO.print(label ++ ":changes:" ++ changes(T.MotionSchema,events))
        return world
    case Q.CapacityRejected{world}:
      do IO<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>>:
        IO.print(label ++ ":rejected")
        return world
    case Q.InvariantFault{world,_,_}:
      do IO<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>>:
        IO.print(label ++ ":fault")
        return world
def motion_shape(world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>) -> IO(S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>):
  match world:
    case S.World{ns,next,S.Rows{m,a,f,+cap,+depth,+high},pending,ledger,mode}:
      do IO<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>>:
        IO.print("motion:shape:" ++ U32.show(cap) ++ ":" ++ Nat.show(depth) ++ ":" ++ U32.show(high))
        return S.World{ns,next,S.Rows{m,a,f,cap,depth,high},pending,ledger,mode}
def motion_bounded(label:String,result:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> & T.Access<T.PositionView>) -> IO(S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>):
  match result:
    case (world,T.Missing{}):
      do IO<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>>:
        IO.print(label ++ ":missing")
        return world
    case (world,_):
      do IO<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>>:
        IO.print(label ++ ":unexpected")
        return world
def motion_foreign(result:T.CommandResult<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>,T.Selected>) -> IO(S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>):
  match result:
    case T.CommandMissing{world,T.Selected{group}}:
      do IO<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>>:
        IO.print("motion:foreign-queue:missing:" ++ U32.show(group))
        return world
    case T.CommandQueued{world}:
      do IO<S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode>>:
        IO.print("motion:foreign-queue:unexpected")
        return world
def motion_growth_case() -> IO(Unit):
  do IO<Unit>:
    world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> = S.publish(T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,S.World{7,9,S.rows_empty(C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected),[],None{},T.MotionOn{}},[S.Spawn{8,S.Bundle{Some{K.position_new(T.Position{E.quad(80),7})},Some{T.Velocity{E.quad(180),True{}}},None{}}},S.Spawn{2,S.Bundle{None{},Some{T.Velocity{E.quad(120),True{}}},None{}}},S.Spawn{1,S.Bundle{Some{K.position_new(T.Position{E.quad(10),7})},Some{T.Velocity{E.quad(110),True{}}},Some{T.Selected{8}}}}])
    world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> <- motion_applied("motion:seed",Q.apply_checked(T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,world,4))
    world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> <- motion_shape(world)
    world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> <- E.motion_snapshot("motion:grown",world)
    world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> <- motion_bounded("motion:zero",E.motion_read_world(world,S.Handle{7,0}))
    world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> <- motion_bounded("motion:out",E.motion_read_world(world,S.Handle{7,9}))
    world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> <- motion_bounded("motion:foreign-point",E.motion_read_world(world,S.Handle{8,1}))
    world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> <- motion_foreign(Q.insert_flag(T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,world,S.Handle{8,1},T.Selected{123}))
    world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> = S.publish(T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,world,[S.InsertMain{2,K.position_new(T.Position{E.quad(20),7})},S.InsertMain{1,K.position_new(T.Position{E.quad(100),7})}])
    world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> <- motion_applied("motion:replace",Q.apply_checked(T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,world,5))
    world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> <- E.motion_snapshot("motion:replaced",world)
    world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> = S.publish(T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,world,[S.Despawn{2},S.InsertFlag{8,T.Selected{9}},S.RemoveMain{1}])
    world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> <- E.motion_snapshot("motion:staged",world)
    world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> <- motion_applied("motion:edit",Q.apply_checked(T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode,world,6))
    world:S.World<T.MotionSchema,C.Cache<T.Position,T.PositionView>,T.Velocity,T.Selected,C.Cache<T.MotionLedger,T.LedgerView>,T.MotionMode> <- E.motion_snapshot("motion:edited",world)
    return Unit{}

def health_applied(label:String,result:Q.CheckedApply<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>) -> IO(S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>):
  match result:
    case Q.Applied{world,events}:
      do IO<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>>:
        IO.print(label ++ ":changes:" ++ changes(T.HealthSchema,events))
        return world
    case Q.CapacityRejected{world}:
      do IO<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>>:
        IO.print(label ++ ":rejected")
        return world
    case Q.InvariantFault{world,_,_}:
      do IO<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>>:
        IO.print(label ++ ":fault")
        return world
def health_shape(world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>) -> IO(S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>):
  match world:
    case S.World{ns,next,S.Rows{m,a,f,+cap,+depth,+high},pending,ledger,mode}:
      do IO<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>>:
        IO.print("health:shape:" ++ U32.show(cap) ++ ":" ++ Nat.show(depth) ++ ":" ++ U32.show(high))
        return S.World{ns,next,S.Rows{m,a,f,cap,depth,high},pending,ledger,mode}
def health_bounded(label:String,result:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> & T.Access<T.VitalsView>) -> IO(S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>):
  match result:
    case (world,T.Missing{}):
      do IO<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>>:
        IO.print(label ++ ":missing")
        return world
    case (world,_):
      do IO<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>>:
        IO.print(label ++ ":unexpected")
        return world
def health_foreign(result:T.CommandResult<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>,T.Tracked>) -> IO(S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>):
  match result:
    case T.CommandMissing{world,T.Tracked{group}}:
      do IO<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>>:
        IO.print("health:foreign-queue:missing:" ++ U32.show(group))
        return world
    case T.CommandQueued{world}:
      do IO<S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode>>:
        IO.print("health:foreign-queue:unexpected")
        return world
def health_growth_case() -> IO(Unit):
  do IO<Unit>:
    world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> = S.publish(T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,S.World{7,9,S.rows_empty(C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked),[],None{},T.HealthOn{}},[S.Spawn{8,S.Bundle{Some{K.vitals_new(T.Vitals{E.quad(80),9,2})},Some{T.Armor{E.quad(180),3}},None{}}},S.Spawn{2,S.Bundle{None{},Some{T.Armor{E.quad(120),3}},None{}}},S.Spawn{1,S.Bundle{Some{K.vitals_new(T.Vitals{E.quad(10),9,2})},Some{T.Armor{E.quad(110),3}},Some{T.Tracked{8}}}}])
    world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> <- health_applied("health:seed",Q.apply_checked(T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,world,4))
    world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> <- health_shape(world)
    world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> <- E.health_snapshot("health:grown",world)
    world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> <- health_bounded("health:zero",E.health_read_world(world,S.Handle{7,0}))
    world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> <- health_bounded("health:out",E.health_read_world(world,S.Handle{7,9}))
    world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> <- health_bounded("health:foreign-point",E.health_read_world(world,S.Handle{8,1}))
    world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> <- health_foreign(Q.insert_flag(T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,world,S.Handle{8,1},T.Tracked{123}))
    world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> = S.publish(T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,world,[S.InsertMain{2,K.vitals_new(T.Vitals{E.quad(20),9,2})},S.InsertMain{1,K.vitals_new(T.Vitals{E.quad(100),9,2})}])
    world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> <- health_applied("health:replace",Q.apply_checked(T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,world,5))
    world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> <- E.health_snapshot("health:replaced",world)
    world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> = S.publish(T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,world,[S.Despawn{2},S.InsertFlag{8,T.Tracked{9}},S.RemoveMain{1}])
    world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> <- E.health_snapshot("health:staged",world)
    world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> <- health_applied("health:edit",Q.apply_checked(T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode,world,6))
    world:S.World<T.HealthSchema,C.Cache<T.Vitals,T.VitalsView>,T.Armor,T.Tracked,C.Cache<T.HealthLedger,T.LedgerView>,T.HealthMode> <- E.health_snapshot("health:edited",world)
    return Unit{}

def main() -> IO(Unit):
  do IO<Unit>:
    motion_growth_case()
    health_growth_case()
