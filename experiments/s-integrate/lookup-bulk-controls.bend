import Base
import ./types.bend as T
import ./storage.bend as S
import ./identity.bend as I
import ./commands.bend as C
import ./query.bend as Q
import ./payload.bend as P
import ./commands-bulk-controls.bend as B
import ./storage-stage-fixture.bend as F

def verify(-W: Type,result: W & Bool,next: W -> String) -> String:
  match result:
    case (world,valid): F.bool(valid) ++ "\n" ++ next(world)

def motion_lookup(world: S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,selection: Q.Selection,handle: S.Handle<T.MotionSchema>) -> S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode> & String:
  F.lookup_text(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,Q.lookup(~T.MotionSchema,~T.Position,~T.Velocity,~T.Selected,~T.PositionToken,~T.PositionView,~T.VelocityView,~String,~T.MotionLedger,~T.MotionMode,~P.position_get,~P.velocity_get,~F.motion_client,selection,world,handle))
def motion_run(+count: U32,+first: S.Handle<T.MotionSchema>,+middle: S.Handle<T.MotionSchema>,+last: S.Handle<T.MotionSchema>,spare: S.Handle<T.MotionSchema>,foreign: S.Handle<T.MotionSchema>,world: S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>) -> String:
  verify(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,B.world(~T.MotionSchema,~T.Position,~T.Velocity,~T.Selected,~T.MotionLedger,~T.MotionMode,~B.position,~B.velocity,~B.selected,~B.motion_ledger,~B.motion_mode,U32.add(count,1),True{},1,count,world),world =>
  F.pair_text(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,motion_lookup(world,Q.Required{},first),world => t0 =>
  F.pair_text(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,motion_lookup(world,Q.Optional{},middle),world => t1 =>
  F.pair_text(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,motion_lookup(world,Q.Present{},last),world => t2 =>
  F.pair_text(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,motion_lookup(world,Q.Optional{},first),world => t3 =>
  F.pair_text(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,motion_lookup(world,Q.Absent{},last),world => t4 =>
  F.pair_text(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,motion_lookup(world,Q.Required{},spare),world => t5 =>
  F.pair_text(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,motion_lookup(world,Q.Required{},foreign),world => t6 =>
  F.queued(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,Unit,C.remove_main(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,middle),world =>
  F.applied(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.MotionSchema,C.apply(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,2),world =>
  F.pair_text(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,motion_lookup(world,Q.Required{},middle),world => t7 =>
  F.pair_text(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,motion_lookup(world,Q.Optional{},middle),world => t8 =>
  F.queued(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.Position,C.insert_main(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,middle,F.motion_main(10)),world =>
  F.applied(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.MotionSchema,C.apply(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,1),world =>
  F.pair_text(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,motion_lookup(world,Q.Required{},middle),world => restored =>
  verify(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,B.world(~T.MotionSchema,~T.Position,~T.Velocity,~T.Selected,~T.MotionLedger,~T.MotionMode,~B.position,~B.velocity,~B.selected,~B.motion_ledger,~B.motion_mode,U32.add(count,1),True{},1,count,world),world => "first=" ++ t0 ++ "\n" ++ "middle=" ++ t1 ++ "\n" ++ "last=" ++ t2 ++ "\n" ++ "first-again=" ++ t3 ++ "\n" ++ "last-flag-mismatch=" ++ t4 ++ "\n" ++ "missing=" ++ t5 ++ "\n" ++ "foreign=" ++ t6 ++ "\n" ++ "aux-only-mismatch=" ++ t7 ++ "\n" ++ "aux-only-mismatch-again=" ++ t8 ++ "\n" ++ "restored=" ++ restored))))))))))))))))
def motion_handles(count: U32,world: S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,foreign: S.Handle<T.MotionSchema>,ok: Bool,first: Maybe<&2,S.Handle<T.MotionSchema>>,middle: Maybe<&2,S.Handle<T.MotionSchema>>,last: Maybe<&2,S.Handle<T.MotionSchema>>,spare: Maybe<&2,S.Handle<T.MotionSchema>>) -> String:
  match ok first middle last spare:
    case True{} Some{first} Some{middle} Some{last} Some{+spare}:
      F.queued(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,Unit,C.despawn(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,spare),world =>
      F.applied(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.MotionSchema,C.apply(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,2),world => motion_run(count,first,middle,last,spare,foreign,world)))
    case _ _ _ _ _: "BAD_HANDLES"
def motion_reserved(+count: U32,foreign: S.Handle<T.MotionSchema>,state: B.Batch<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>) -> String:
  match state:
    case B.Batch{world,+handles,ok}:
      F.applied(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,T.MotionSchema,C.apply(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,world,1),world =>
      motion_handles(count,world,foreign,ok,List.get(&2,S.Handle<T.MotionSchema>,handles,0n),List.get(&2,S.Handle<T.MotionSchema>,handles,U32.to_nat(U32.div(count,2))),List.get(&2,S.Handle<T.MotionSchema>,handles,U32.to_nat(U32.sub(count,1))),List.get(&2,S.Handle<T.MotionSchema>,handles,U32.to_nat(count))))
def motion(+count: U32) -> String:
  F.created(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,I.create(~T.MotionSchema,~T.Position,~T.Velocity,~T.Selected,~T.MotionLedger,~T.MotionMode,~F.motion_ledger,I.factory(),T.MotionOn{}),factory => world =>
  F.created(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,I.create(~T.MotionSchema,~T.Position,~T.Velocity,~T.Selected,~T.MotionLedger,~T.MotionMode,~F.motion_ledger,factory,T.MotionOn{}),factory => beta =>
  F.reserved(S.World<T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode>,S.Handle<T.MotionSchema>,S.Bundle<T.Position,T.Velocity,T.Selected>,C.reserve(T.MotionSchema,T.Position,T.Velocity,T.Selected,T.MotionLedger,T.MotionMode,beta,B.motion_bundle(Unit{})),beta => foreign =>
  motion_reserved(count,foreign,B.reserve(~T.MotionSchema,~T.Position,~T.Velocity,~T.Selected,~T.MotionLedger,~T.MotionMode,~B.motion_bundle,U32.to_nat(U32.add(count,1)),B.Batch{world,[],True{}})))))

def health_lookup(world: S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,selection: Q.Selection,handle: S.Handle<T.HealthSchema>) -> S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode> & String:
  F.lookup_text(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,Q.lookup(~T.HealthSchema,~T.Vitals,~T.Armor,~T.Tracked,~T.VitalsToken,~T.VitalsView,~T.ArmorView,~String,~T.HealthLedger,~T.HealthMode,~P.vitals_get,~P.armor_get,~F.health_client,selection,world,handle))
def health_run(+count: U32,+first: S.Handle<T.HealthSchema>,+middle: S.Handle<T.HealthSchema>,+last: S.Handle<T.HealthSchema>,spare: S.Handle<T.HealthSchema>,foreign: S.Handle<T.HealthSchema>,world: S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>) -> String:
  verify(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,B.world(~T.HealthSchema,~T.Vitals,~T.Armor,~T.Tracked,~T.HealthLedger,~T.HealthMode,~B.vitals,~B.armor,~B.tracked,~B.health_ledger,~B.health_mode,U32.add(count,1),True{},1,count,world),world =>
  F.pair_text(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,health_lookup(world,Q.Required{},first),world => t0 =>
  F.pair_text(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,health_lookup(world,Q.Optional{},middle),world => t1 =>
  F.pair_text(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,health_lookup(world,Q.Present{},last),world => t2 =>
  F.pair_text(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,health_lookup(world,Q.Optional{},first),world => t3 =>
  F.pair_text(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,health_lookup(world,Q.Absent{},last),world => t4 =>
  F.pair_text(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,health_lookup(world,Q.Required{},spare),world => t5 =>
  F.pair_text(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,health_lookup(world,Q.Required{},foreign),world => t6 =>
  F.queued(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,Unit,C.remove_main(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,middle),world =>
  F.applied(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.HealthSchema,C.apply(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,2),world =>
  F.pair_text(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,health_lookup(world,Q.Required{},middle),world => t7 =>
  F.pair_text(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,health_lookup(world,Q.Optional{},middle),world => t8 =>
  F.queued(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.Vitals,C.insert_main(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,middle,F.health_main(10)),world =>
  F.applied(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.HealthSchema,C.apply(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,1),world =>
  F.pair_text(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,health_lookup(world,Q.Required{},middle),world => restored =>
  verify(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,B.world(~T.HealthSchema,~T.Vitals,~T.Armor,~T.Tracked,~T.HealthLedger,~T.HealthMode,~B.vitals,~B.armor,~B.tracked,~B.health_ledger,~B.health_mode,U32.add(count,1),True{},1,count,world),world => "first=" ++ t0 ++ "\n" ++ "middle=" ++ t1 ++ "\n" ++ "last=" ++ t2 ++ "\n" ++ "first-again=" ++ t3 ++ "\n" ++ "last-flag-mismatch=" ++ t4 ++ "\n" ++ "missing=" ++ t5 ++ "\n" ++ "foreign=" ++ t6 ++ "\n" ++ "aux-only-mismatch=" ++ t7 ++ "\n" ++ "aux-only-mismatch-again=" ++ t8 ++ "\n" ++ "restored=" ++ restored))))))))))))))))
def health_handles(count: U32,world: S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,foreign: S.Handle<T.HealthSchema>,ok: Bool,first: Maybe<&2,S.Handle<T.HealthSchema>>,middle: Maybe<&2,S.Handle<T.HealthSchema>>,last: Maybe<&2,S.Handle<T.HealthSchema>>,spare: Maybe<&2,S.Handle<T.HealthSchema>>) -> String:
  match ok first middle last spare:
    case True{} Some{first} Some{middle} Some{last} Some{+spare}:
      F.queued(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,Unit,C.despawn(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,spare),world =>
      F.applied(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.HealthSchema,C.apply(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,2),world => health_run(count,first,middle,last,spare,foreign,world)))
    case _ _ _ _ _: "BAD_HANDLES"
def health_reserved(+count: U32,foreign: S.Handle<T.HealthSchema>,state: B.Batch<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>) -> String:
  match state:
    case B.Batch{world,+handles,ok}:
      F.applied(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,T.HealthSchema,C.apply(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,world,1),world =>
      health_handles(count,world,foreign,ok,List.get(&2,S.Handle<T.HealthSchema>,handles,0n),List.get(&2,S.Handle<T.HealthSchema>,handles,U32.to_nat(U32.div(count,2))),List.get(&2,S.Handle<T.HealthSchema>,handles,U32.to_nat(U32.sub(count,1))),List.get(&2,S.Handle<T.HealthSchema>,handles,U32.to_nat(count))))
def health(+count: U32) -> String:
  F.created(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,I.create(~T.HealthSchema,~T.Vitals,~T.Armor,~T.Tracked,~T.HealthLedger,~T.HealthMode,~F.health_ledger,I.factory(),T.HealthOn{}),factory => world =>
  F.created(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,I.create(~T.HealthSchema,~T.Vitals,~T.Armor,~T.Tracked,~T.HealthLedger,~T.HealthMode,~F.health_ledger,factory,T.HealthOn{}),factory => beta =>
  F.reserved(S.World<T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode>,S.Handle<T.HealthSchema>,S.Bundle<T.Vitals,T.Armor,T.Tracked>,C.reserve(T.HealthSchema,T.Vitals,T.Armor,T.Tracked,T.HealthLedger,T.HealthMode,beta,B.health_bundle(Unit{})),beta => foreign =>
  health_reserved(count,foreign,B.reserve(~T.HealthSchema,~T.Vitals,~T.Armor,~T.Tracked,~T.HealthLedger,~T.HealthMode,~B.health_bundle,U32.to_nat(U32.add(count,1)),B.Batch{world,[],True{}})))))

def choose(schema: U32,count: U32) -> String:
  match schema:
    case 0: motion(count)
    case 1: health(count)
    case _: "BAD_SCHEMA"
def bounded(schema: U32,count: U32,valid: Bool) -> IO(Unit):
  match valid:
    case True{}: IO.print(choose(schema,count))
    case False{}: IO.die(Unit,2,"count must be between 3 and 65537")
def parsed(schema: Maybe<&2,U32>,count: Maybe<&2,U32>) -> IO(Unit):
  match schema count:
    case Some{schema} Some{+count}: bounded(schema,count,Bool.and(U32.is_ge(count,3),U32.is_le(count,65537)))
    case _ _: IO.die(Unit,2,"invalid arguments")
def args(values: List<String>) -> IO(Unit):
  match values:
    case Con{_,Con{schema,Con{count,_}}}: parsed(U32.read(schema),U32.read(count))
    case _: IO.die(Unit,2,"schema count required")
def main() -> IO(Unit):
  do IO<Unit>:
    values : List<String> <- IO.args()
    args(values)
