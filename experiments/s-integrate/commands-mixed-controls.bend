import Base
import ./types.bend as T
import ./storage.bend as S
import ./identity.bend as I
import ./commands.bend as C
import ./storage-stage-fixture.bend as F

def handle(-Schema: Data,value: S.Handle<Schema>) -> String:
  match value:
    case S.Handle{ns,id}: U32.show(ns) ++ ":" ++ U32.show(id)
def changes(-Schema: Data,values: List<&2,S.Change<Schema>>) -> String:
  match values:
    case Nil{}: ""
    case Con{S.MainAdded{h},tail}: "Added:" ++ handle(Schema,h) ++ ";" ++ changes(Schema,tail)
    case Con{S.MainChanged{h},tail}: "Changed:" ++ handle(Schema,h) ++ ";" ++ changes(Schema,tail)
    case Con{S.MainRemoved{h},tail}: "Removed:" ++ handle(Schema,h) ++ ";" ++ changes(Schema,tail)
    case Con{S.Despawned{h},tail}: "Despawned:" ++ handle(Schema,h) ++ ";" ++ changes(Schema,tail)

def motion_done(result: S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & List<&2,S.Change<T.MotionSchema>>) -> String:
  match result:
    case (w,log): F.pair_text(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,F.motion_observe(w),w => text => text ++ "\n" ++ changes(T.MotionSchema,log))
def motion() -> String:
  F.created(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,I.create(~T.MotionSchema,~T.Position,~T.Velocity,~T.Selected,~T.MotionLedger,~T.MotionMode,~F.motion_ledger,I.factory(),T.MotionOn{}),factory => world =>
  F.reserved(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>,C.reserve(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,S.Bundle{Some{F.motion_main(10)},Some{F.motion_aux()},Some{T.Selected{8}}}),world => +h1 =>
  F.reserved(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>,C.reserve(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,S.Bundle{Some{F.motion_main(20)},None{},None{}}),world => +h2 =>
  F.reserved(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>,C.reserve(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,S.Bundle{None{},Some{F.motion_aux()},Some{T.Selected{8}}}),world => +h3 =>
  F.reserved(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>,C.reserve(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,S.Bundle{Some{F.motion_main(50)},None{},Some{T.Selected{8}}}),world => +h4 =>
  F.reserved(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>,C.reserve(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,S.Bundle{Some{F.motion_main(50)},None{},None{}}),world => +h5 =>
  F.reserved(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>,C.reserve(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,S.Bundle{Some{F.motion_main(60)},None{},None{}}),world => +h6 =>
  F.applied(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.MotionSchema,C.apply(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,1),world =>
  F.queued(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,Unit,C.despawn(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,h2),world =>
  F.queued(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,Unit,C.despawn(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,h5),world =>
  F.applied(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.MotionSchema,C.apply(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,1),world =>
  F.queued(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,C.insert_main(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,h4,F.motion_main(71)),world =>
  F.queued(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,C.insert_main(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,h1,F.motion_main(80)),world =>
  F.queued(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,C.insert_main(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,h3,F.motion_main(30)),world =>
  F.queued(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,C.insert_main(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,h1,F.motion_main(81)),world =>
  F.queued(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,C.insert_main(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,h2,F.motion_main(90)),world =>
  F.queued(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,Unit,C.remove_main(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,h4),world =>
  F.queued(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,C.insert_main(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,h4,F.motion_main(72)),world =>
  F.queued(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,Unit,C.despawn(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,h1),world =>
  F.queued(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,C.insert_main(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,h1,F.motion_main(99)),world =>
  F.reserved(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>,C.reserve(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,S.Bundle{Some{F.motion_main(70)},Some{F.motion_aux()},Some{T.Selected{8}}}),world => h7 =>
  motion_done(C.apply(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,8)))))))))))))))))))))))

def health_done(result: S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & List<&2,S.Change<T.HealthSchema>>) -> String:
  match result:
    case (w,log): F.pair_text(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,F.health_observe(w),w => text => text ++ "\n" ++ changes(T.HealthSchema,log))
def health() -> String:
  F.created(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,I.create(~T.HealthSchema,~T.Vitals,~T.Armor,~T.Tracked,~T.HealthLedger,~T.HealthMode,~F.health_ledger,I.factory(),T.HealthOn{}),factory => world =>
  F.reserved(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>,C.reserve(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,S.Bundle{Some{F.health_main(10)},Some{F.health_aux()},Some{T.Tracked{8}}}),world => +h1 =>
  F.reserved(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>,C.reserve(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,S.Bundle{Some{F.health_main(20)},None{},None{}}),world => +h2 =>
  F.reserved(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>,C.reserve(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,S.Bundle{None{},Some{F.health_aux()},Some{T.Tracked{8}}}),world => +h3 =>
  F.reserved(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>,C.reserve(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,S.Bundle{Some{F.health_main(50)},None{},Some{T.Tracked{8}}}),world => +h4 =>
  F.reserved(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>,C.reserve(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,S.Bundle{Some{F.health_main(50)},None{},None{}}),world => +h5 =>
  F.reserved(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>,C.reserve(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,S.Bundle{Some{F.health_main(60)},None{},None{}}),world => +h6 =>
  F.applied(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.HealthSchema,C.apply(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,1),world =>
  F.queued(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,Unit,C.despawn(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,h2),world =>
  F.queued(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,Unit,C.despawn(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,h5),world =>
  F.applied(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.HealthSchema,C.apply(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,1),world =>
  F.queued(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,C.insert_main(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,h4,F.health_main(71)),world =>
  F.queued(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,C.insert_main(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,h1,F.health_main(80)),world =>
  F.queued(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,C.insert_main(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,h3,F.health_main(30)),world =>
  F.queued(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,C.insert_main(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,h1,F.health_main(81)),world =>
  F.queued(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,C.insert_main(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,h2,F.health_main(90)),world =>
  F.queued(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,Unit,C.remove_main(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,h4),world =>
  F.queued(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,C.insert_main(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,h4,F.health_main(72)),world =>
  F.queued(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,Unit,C.despawn(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,h1),world =>
  F.queued(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,C.insert_main(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,h1,F.health_main(99)),world =>
  F.reserved(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>,C.reserve(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,S.Bundle{Some{F.health_main(70)},Some{F.health_aux()},Some{T.Tracked{8}}}),world => h7 =>
  health_done(C.apply(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,8)))))))))))))))))))))))

def main() -> IO(Unit): IO.print(motion() ++ "\n" ++ health())
