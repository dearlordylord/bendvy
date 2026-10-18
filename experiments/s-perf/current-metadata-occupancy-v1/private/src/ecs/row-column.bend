import Base
import column.bend as Col
import lifecycle.bend as L

# The captured ID and actual column travel with the owner in one affine token.
# No attach API accepts a different column or an external target ID.
type Cold<-S:Data,-C:Type> is Type:
  Cold{column:Col.Column<S,C>}
  Wrapped{inner:Cold<S,C>}
type Cell<-S:Data,-C:Type> is Type:
  Taken{id:U32,owner:Maybe<&1,C>,stamp:L.Stamp,dirty:Bool,cold:Cold<S,C>}
  Untaken{column:Col.Column<S,C>,incoming:Maybe<&1,C>,error:Unit}
type Projected<-S:Data,-C:Type,-V:Data> is Type:
  Projected{cell:Cell<S,C>,value:Maybe<&2,V>}
  Deferred{cell:Cell<S,C>}

def cold_column(~S:Data,~C:Type,cold:Cold<S,C>) -> Col.Column<S,C>:
  match cold:
    case Cold{column}: column
    case Wrapped{inner}: cold_column(~S,~C,inner)
def detached(~S:Data,~C:Type,+id:U32,stamp:L.Stamp,result:Col.SwapOutcome<S,C>) -> Cell<S,C>:
  match result:
    case Col.Accepted{column,owner}: Taken{id,owner,stamp,False{},Cold{column}}
    case Col.Rejected{column,incoming}: Untaken{column,incoming,Unit{}}
def detach_stamped(~S:Data,~C:Type,+id:U32,result:Col.Column<S,C> & L.Stamp) -> Cell<S,C>:
  match result:
    case (column,stamp): detached(~S,~C,id,stamp,Col.swap(~S,~C,column,id,None{}))
def detach(~S:Data,~C:Type,column:Col.Column<S,C>,+id:U32) -> Cell<S,C>:
  detach_stamped(~S,~C,id,Col.lifecycle(~S,~C,column,id))

def projected_owner(~S:Data,~C:Type,~V:Data,+id:U32,stamp:L.Stamp,dirty:Bool,cold:Cold<S,C>,result:C & V) -> Projected<S,C,V>:
  match result:
    case (owner,value): Projected{Taken{id,Some{owner},stamp,dirty,cold},Some{value}}
def project(~S:Data,~C:Type,~V:Data,~project:C -> C & V,cell:Cell<S,C>) -> Projected<S,C,V>:
  match cell:
    case Taken{id,None{},stamp,dirty,cold}: Projected{Taken{id,None{},stamp,dirty,cold},None{}}
    case Taken{id,Some{owner},stamp,dirty,cold}: projected_owner(~S,~C,~V,id,stamp,dirty,cold,project(owner))
    case Untaken{column,incoming,error}: Deferred{Untaken{column,incoming,error}}

# Even a malformed token's attachment refusal returns its actual incoming owner.
# Trusted row adapters must handle this outcome before exposing a World.
def attach_marked(~S:Data,~C:Type,+id:U32,stamp:L.Stamp,dirty:Bool,result:Col.SwapOutcome<S,C>) -> Col.SwapOutcome<S,C>:
  match dirty result:
    case False{} result: result
    case True{} Col.Accepted{column,previous}: Col.Accepted{Col.restore_stamp(~S,~C,column,id,stamp),previous}
    case True{} Col.Rejected{column,incoming}: Col.Rejected{column,incoming}
def attach(~S:Data,~C:Type,cell:Cell<S,C>) -> Col.SwapOutcome<S,C>:
  match cell:
    case Untaken{column,incoming,_}: Col.Rejected{column,incoming}
    case Taken{+id,owner,stamp,dirty,cold}: attach_marked(~S,~C,id,stamp,dirty,Col.swap(~S,~C,cold_column(~S,~C,cold),id,owner))

type Replacement<-S:Data,-C:Type> is Type:
  Replaced{cell:Cell<S,C>,previous:Maybe<&1,C>,stamp:L.Stamp}
  Refused{cell:Cell<S,C>,incoming:C}
def replacement_present(~S:Data,~C:Type,+id:U32,+stamp:L.Stamp,cold:Cold<S,C>,incoming:C,+tick:U32,observed:Maybe<&1,C> & Bool) -> Replacement<S,C>:
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
    case Untaken{column,held,error}: Refused{Untaken{column,held,error},incoming}
