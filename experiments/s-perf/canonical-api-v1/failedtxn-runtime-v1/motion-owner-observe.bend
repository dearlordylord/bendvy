import Base
import ../../../../src/ecs/world.bend as W
import ../dense-runtime-v1/types.bend as T
import motion.bend as F
import events.bend as E
import motion-registration.bend as Reg
import motion-local.bend as L
import motion-systems.bend as S
import motion-dispose.bend as D
import motion-publications.bend as Publications
import motion-render.bend as R
import motion-observe.bend as O
import motion-runtime-observe.bend as RT
import motion-reader-owner-observe.bend as RO
import ../../../../src/ecs/system.bend as Sys

def registered_join(+tick:Nat,a:L.Instance() & String,b:L.Instance() & String,pub:Publications.Provider() & String,meta:L.Meta() & String) -> Reg.Owners & String:
  (a,sa)=a
  (b,sb)=b
  (pub,sp)=pub
  (meta,sm)=meta
  (Reg.Owners{a,b,pub,meta,tick},"a={" ++ sa ++ "};b={" ++ sb ++ "};publications={" ++ sp ++ "};meta={" ++ sm ++ "};tick=" ++ Nat.show(tick))
def registered(owner:Reg.Owners) -> Reg.Owners & String:
  match owner:
    case Reg.Owners{a,b,pub,meta,tick}:registered_join(tick,R.instance(a),R.instance(b),RO.publications(pub),RT.meta(meta))
def registry(owner:D.Registry()) -> D.Registry() & String:
  match owner:
    case Sys.Registry{+ns,+id,+name,+access,+cursor}:(Sys.Registry{ns,id,name,access,cursor},"namespace=" ++ U32.show(ns) ++ ";id=" ++ U32.show(id) ++ ";name=" ++ O.audit_effect(name) ++ ";access=" ++ List.show(&2,String,O.audit_effect,access) ++ ";cursor=" ++ U32.show(cursor))
def maybe_handle(value:Maybe<&2,W.Handle<T.MotionSchema>>) -> String:
  match value:
    case None{}:"None"
    case Some{value}:"Some{" ++ O.handle(value) ++ "}"
def frame(value:S.Frame) -> String:
  match value:
    case S.Frame{first,second,iteration,phase,pending,retry,failed,calls}:"first=" ++ O.handle(first) ++ ";second=" ++ O.handle(second) ++ ";iteration=" ++ U32.show(iteration) ++ ";phase=" ++ U32.show(phase) ++ ";pendingA=" ++ maybe_handle(pending) ++ ";retryB=" ++ maybe_handle(retry) ++ ";failed=" ++ List.show(&2,W.Handle<T.MotionSchema>,O.handle,failed) ++ ";calls=" ++ List.show(&2,String,O.audit_effect,calls)
def joined(+state:S.Frame,left:Reg.Owners & String,right:D.Registry() & String) -> S.Owners & String:
  (registered,sr)=left
  (dispose,sd)=right
  (S.Owners{registered,dispose,state},"registered={" ++ sr ++ "};dispose={" ++ sd ++ "};frame={" ++ frame(state) ++ "}")
def owners(value:S.Owners) -> S.Owners & String:
  match value:
    case S.Owners{owner,dispose,frame}:joined(frame,registered(owner),registry(dispose))
