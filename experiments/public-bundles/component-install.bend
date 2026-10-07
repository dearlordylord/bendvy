import Base
import ../../src/ecs/world.bend as W
import ../../src/ecs/component.bend as C
import ../../src/ecs/column.bend as Col
import ../../src/ecs/lifecycle.bend as L
import fallible-install.bend as F

type Entry<S:Data,Owner:Type> is Type:
  Entry{handle:W.Handle<S>,owner:Maybe<&1,Owner>}
type Recovery<S:Data,Owner:Type> is Type:
  Recovery{previous:Entry<S,Owner>,stamp:L.Stamp}
def undone(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,+handle:W.Handle<S>,+stamp:L.Stamp,observed:W.World<S,Store,R,E> & C.Swap<C>) -> F.Restore<W.World<S,Store,R,E>,Entry<S,C>,Recovery<S,C>>:
  match observed:
    case (world,C.Swapped{incoming}): F.Restored{C.restore_stamp(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,handle,stamp,world),Entry{handle,incoming}}
    case (world,C.SwapRejected{old}): F.Pending{world,Recovery{Entry{handle,old},stamp},W.CapacityExceeded{}}
def undo_present(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,+handle:W.Handle<S>,+id:U32,stamp:L.Stamp,world:W.World<S,Store,R,E>,observed:Maybe<&1,C> & Bool) -> F.Restore<W.World<S,Store,R,E>,Entry<S,C>,Recovery<S,C>>:
  (previous,present)=observed
  undone(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,handle,stamp,C.swap_world(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,id,previous,present,0,world))
def undo_checked(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,+handle:W.Handle<S>,+id:U32,stamp:L.Stamp,previous:Maybe<&1,C>,observed:W.World<S,Store,R,E> & Bool) -> F.Restore<W.World<S,Store,R,E>,Entry<S,C>,Recovery<S,C>>:
  match observed:
    case (world,False{}): F.Pending{world,Recovery{Entry{handle,previous},stamp},W.MissingEntity{}}
    case (world,True{}): undo_present(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,handle,id,stamp,world,C.owner_present(~C,previous))
def undo(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,recovery:Recovery<S,C>,world:W.World<S,Store,R,E>) -> F.Restore<W.World<S,Store,R,E>,Entry<S,C>,Recovery<S,C>>:
  match recovery:
    case Recovery{Entry{W.Handle{+ns,+id},previous},stamp}: undo_checked(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,W.Handle{ns,id},id,stamp,previous,W.valid(~S,~Store,~R,~E,world,W.Handle{ns,id}))
def replaced(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,+handle:W.Handle<S>,+stamp:L.Stamp,result:C.Replacement<W.World<S,Store,R,E>,C>) -> F.Attempt<W.World<S,Store,R,E>,Entry<S,C>,Recovery<S,C>>:
  match result:
    case C.ReplaceRejected{world,incoming,error}: F.Refused{world,Entry{handle,incoming},error}
    case C.Replaced{world,previous}: F.Installed{world,w => undo(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,Recovery{Entry{handle,previous},stamp},w)}
def stamped(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,+family:C.Family<S,Store,Rest,C,V,Token,take,put,project>,+handle:W.Handle<S>,incoming:Maybe<&1,C>,observed:W.World<S,Store,R,E> & L.Stamp) -> F.Attempt<W.World<S,Store,R,E>,Entry<S,C>,Recovery<S,C>>:
  (world,stamp)=observed
  replaced(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,handle,stamp,C.replace(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,world,handle,incoming))
def install(~S:Data,~Store:Type,~R:Type,~E:Data,~Rest:Type,~C:Type,~V:Data,~Token:Data,~take:Store -> Rest & Col.Column<S,C>,~put:Rest -> Col.Column<S,C> -> Store,~project:C -> C & V,+family:C.Family<S,Store,Rest,C,V,Token,take,put,project>,world:W.World<S,Store,R,E>,entry:Entry<S,C>) -> F.Attempt<W.World<S,Store,R,E>,Entry<S,C>,Recovery<S,C>>:
  match entry:
    case Entry{+handle,incoming}: stamped(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,handle,incoming,C.lifecycle(~S,~Store,~R,~E,~Rest,~C,~V,~Token,~take,~put,~project,family,world,handle))
