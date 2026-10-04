import Base
import ./types.bend as T
import ./observations.bend as O
import ./storage-stage-fixture.bend as F

# Lossless rendering of all declared Data observation fields; no owner access.
def row(~V:Data,~AV:Data,~Flag:Data,~main:V -> String,~aux:AV -> String,~flag:Flag -> String,value:O.RowView<V,AV,Flag>) -> String:
  match value:
    case O.RowView{id,m,a,f,added,changed}: "row(" ++ U32.show(id) ++ "," ++ Maybe.show(&2,V,main,m) ++ "," ++ Maybe.show(&2,AV,aux,a) ++ "," ++ Maybe.show(&2,Flag,flag,f) ++ "," ++ U32.show(added) ++ "," ++ U32.show(changed) ++ ")"
def bundle(~V:Data,~AV:Data,~Flag:Data,~main:V -> String,~aux:AV -> String,~flag:Flag -> String,value:O.BundleView<V,AV,Flag>) -> String:
  match value:
    case O.BundleView{m,a,f}: "bundle(" ++ Maybe.show(&2,V,main,m) ++ "," ++ Maybe.show(&2,AV,aux,a) ++ "," ++ Maybe.show(&2,Flag,flag,f) ++ ")"
def pending(~V:Data,~AV:Data,~Flag:Data,~main:V -> String,~aux:AV -> String,~flag:Flag -> String,value:O.PendingView<V,AV,Flag>) -> String:
  match value:
    case O.SpawnView{id,b}: "spawn(" ++ U32.show(id) ++ "," ++ bundle(V,AV,Flag,main,aux,flag,b) ++ ")"
    case O.MainView{id,m}: "main(" ++ U32.show(id) ++ "," ++ main(m) ++ ")"
    case O.FlagView{id,f}: "flag(" ++ U32.show(id) ++ "," ++ flag(f) ++ ")"
    case O.RemoveMainView{id}: "remove-main(" ++ U32.show(id) ++ ")"
    case O.RemoveFlagView{id}: "remove-flag(" ++ U32.show(id) ++ ")"
    case O.DespawnView{id}: "despawn(" ++ U32.show(id) ++ ")"
def world(~V:Data,~AV:Data,~Flag:Data,~LV:Data,~Mode:Data,~main:V -> String,~aux:AV -> String,~flag:Flag -> String,~ledger:LV -> String,~mode:Mode -> String,value:O.WorldView<V,AV,Flag,LV,Mode>) -> String:
  match value:
    case O.WorldView{ns,next,rs,ps,l,m}: "world(" ++ U32.show(ns) ++ "," ++ U32.show(next) ++ "," ++ List.show(&2,O.RowView<V,AV,Flag>,row(V,AV,Flag,main,aux,flag),rs) ++ "," ++ List.show(&2,O.PendingView<V,AV,Flag>,pending(V,AV,Flag,main,aux,flag),ps) ++ "," ++ Maybe.show(&2,LV,ledger,l) ++ "," ++ mode(m) ++ ")"
def motion(value:O.WorldView<T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode>) -> String:
  world(T.PositionView,T.VelocityView,T.Selected,T.LedgerView,T.MotionMode,F.position,F.velocity,F.selected,F.ledger_show,F.motion_mode,value)
def health(value:O.WorldView<T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode>) -> String:
  world(T.VitalsView,T.ArmorView,T.Tracked,T.LedgerView,T.HealthMode,F.vitals,F.armor,F.tracked,F.ledger_show,F.health_mode,value)
