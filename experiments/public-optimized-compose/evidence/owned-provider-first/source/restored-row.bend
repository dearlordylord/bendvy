import Base
import column.bend as Col
import lifecycle.bend as L
import captured-column.bend as K

# Closed provisioning supplies affine restoration; universal gameplay sees H.
type Cell<-S:Data,-C:Type> is Type:
  Taken{id:U32,owner:Maybe<&1,C>,stamp:L.Stamp,dirty:Bool,restore:K.Slot<C> -> Col.Column<S,C>}
  Untaken{column:Col.Column<S,C>}
type Projected<-S:Data,-C:Type,-V:Data> is Type:
  Projected{cell:Cell<S,C>,value:Maybe<&2,V>}
  Deferred{cell:Cell<S,C>}

def captured(~S:Data,~C:Type,result:K.Capture<S,C>) -> Cell<S,C>:
  match result:
    case K.Captured{id,owner,stamp,restore}: Taken{id,owner,stamp,False{},restore}
    case K.Unavailable{column}: Untaken{column}
def detach(~S:Data,~C:Type,column:Col.Column<S,C>,+id:U32) -> Cell<S,C>:
  captured(~S,~C,K.capture(~S,~C,column,id))
def attach(~S:Data,~C:Type,cell:Cell<S,C>) -> Col.Column<S,C>:
  match cell:
    case Taken{_,owner,stamp,dirty,restore}: restore(K.Slot{owner,stamp,dirty})
    case Untaken{column}: column
def projected_owner(~S:Data,~C:Type,~V:Data,+id:U32,stamp:L.Stamp,dirty:Bool,cold:K.Slot<C> -> Col.Column<S,C>,result:C & V) -> Projected<S,C,V>:
  match result:
    case (owner,value): Projected{Taken{id,Some{owner},stamp,dirty,cold},Some{value}}
def project(~S:Data,~C:Type,~V:Data,~project:C -> C & V,cell:Cell<S,C>) -> Projected<S,C,V>:
  match cell:
    case Taken{id,None{},stamp,dirty,cold}: Projected{Taken{id,None{},stamp,dirty,cold},None{}}
    case Taken{id,Some{owner},stamp,dirty,cold}: projected_owner(~S,~C,~V,id,stamp,dirty,cold,project(owner))
    case Untaken{column}: Deferred{Untaken{column}}

type Replacement<-S:Data,-C:Type> is Type:
  Replaced{cell:Cell<S,C>,previous:Maybe<&1,C>,stamp:L.Stamp}
  Refused{cell:Cell<S,C>,incoming:C}
def replacement_present(~S:Data,~C:Type,+id:U32,+stamp:L.Stamp,cold:K.Slot<C> -> Col.Column<S,C>,incoming:C,+tick:U32,observed:Maybe<&1,C> & Bool) -> Replacement<S,C>:
  match observed:
    case (previous,present): Replaced{Taken{id,Some{incoming},L.after_write(True{},present,stamp,tick),True{},cold},previous,stamp}
def owner_present(~C:Type,owner:Maybe<&1,C>) -> Maybe<&1,C> & Bool:
  match owner:
    case None{}: (None{},False{})
    case Some{owner}: (Some{owner},True{})
# Caller validates entity/clock first and journals returned previous+stamp now.
def replace(~S:Data,~C:Type,cell:Cell<S,C>,incoming:C,+tick:U32) -> Replacement<S,C>:
  match cell:
    case Taken{+id,owner,+stamp,_,cold}: replacement_present(~S,~C,id,stamp,cold,incoming,tick,owner_present(~C,owner))
    case Untaken{column}: Refused{Untaken{column},incoming}
