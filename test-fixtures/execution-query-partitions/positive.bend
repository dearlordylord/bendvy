import Base
import ./schema.bend as S
import ../../src/ecs/chunk-partition.bend as Part
import ../../src/ecs/chunk-column.bend as Col
import ../../src/ecs/execution-query-domain.bend as D
import ../../src/ecs/execution-query-slice.bend as Slice
import ../../src/ecs/execution-query-matches.bend as Q
import ../../src/ecs/execution-composer-layout.bend as Layout
import ../../src/ecs/change-tick.bend as Tick
import ../../src/ecs/lifecycle.bend as L

def left() -> D.Domain:D.Domain{[0,2,8,18]}
def right() -> D.Domain:D.Domain{[1,3,9,19]}
type Local is Type:
  Local{label:String,values:Array<U32>}
type Completion is Data:
  BodyError{}
  Success{}
type Body<-N:Data> is Type:
  Body{slot:Slice.Slot<N,Layout.Viewed<S.Position,U32>,S.positions()>,local:Local,completion:Completion,view:Maybe<&2,U32>,unused:List<&1,S.Position -> S.Position & Unit>}
def body_read(~N:Data,local:Local,completion:Completion,unused:List<&1,S.Position -> S.Position & Unit>,result:Slice.Slot<N,Layout.Viewed<S.Position,U32>,S.positions()> & Maybe<&2,U32>) -> Body<N>:
  match result:
    case (slot,view):Body{slot,local,completion,view,unused}
def body_second(~N:Data,index:U32,local:Local,completion:Completion,result:Slice.Edit<N,Layout.Viewed<S.Position,U32>,S.positions(),S.Position,Unit>) -> Body<N>:
  match result:
    case Slice.Edited{slot,_}:body_read(~N,local,completion,[],Slice.read(N,S.Position,U32,S.positions(),slot,index))
    case Slice.Unchanged{slot,unused}:body_read(~N,local,completion,[unused],Slice.read(N,S.Position,U32,S.positions(),slot,index))
def body_first(~N:Data,+tick:Tick.Tick,+second:U32,local:Local,completion:Completion,result:Slice.Edit<N,Layout.Viewed<S.Position,U32>,S.positions(),S.Position,Unit>) -> Body<N>:
  match result:
    case Slice.Edited{slot,_}:body_second(~N,second,local,completion,Slice.edit(~N,~S.positions(),~Layout.AtLeaf{},Unit,slot,second,tick,S.moved))
    case Slice.Unchanged{slot,unused}:body_read(~N,local,completion,[unused],Slice.read(N,S.Position,U32,S.positions(),slot,second))
def body(~N:Data,+tick:Tick.Tick,slot:Slice.Slot<N,Layout.Viewed<S.Position,U32>,S.positions()>,first:U32,second:U32,local:Local,completion:Completion) -> Body<N>:
  body_first(~N,tick,second,local,completion,Slice.edit(~N,~S.positions(),~Layout.AtLeaf{},Unit,slot,first,tick,S.moved))
type Observation<-N:Data> is Type:
  Refused{column:Col.Column<N,Layout.Viewed<S.Position,U32>>,reason:Part.Refusal}
  Returned{joined:Part.Joined<N,Layout.Viewed<S.Position,U32>>,left:Local,right:Local,leftCompletion:Completion,rightCompletion:Completion,leftView:Maybe<&2,U32>,rightView:Maybe<&2,U32>,leftUnused:List<&1,S.Position -> S.Position & Unit>,rightUnused:List<&1,S.Position -> S.Position & Unit>,tick:Tick.Tick,prior:Tick.Tick}
def rejoined(~N:Data,tick:Tick.Tick,prior:Tick.Tick,remainder:Col.Column<N,Layout.Viewed<S.Position,U32>>,join:Part.JoinOwner<N,Layout.Viewed<S.Position,U32>>,leftBody:Body<N>,rightBody:Body<N>) -> Observation<N>:
  match leftBody rightBody:
    case Body{Slice.Slot{left},ll,lc,lv,lu} Body{Slice.Slot{right},rl,rc,rv,ru}:Returned{Part.join(N,Layout.Viewed<S.Position,U32>,join,remainder,left,right),ll,rl,lc,rc,lv,rv,lu,ru,tick,prior}
def run_cut(~N:Data,+tick:Tick.Tick,prior:Tick.Tick,result:Part.Cut<N,Layout.Viewed<S.Position,U32>>) -> Observation<N>:
  match result:
    case Part.Refused{column,reason}:Refused{column,reason}
    case Part.Split{remainder,left,right,join}:
      l r = body(~N,tick,Slice.Slot{left},0,8,Local{"left",[10 : U32^2n]},BodyError{}) body(~N,tick,Slice.Slot{right},1,9,Local{"right",[20 : U32^1n]},Success{})
      rejoined(~N,tick,prior,remainder,join,l,r)
def schema_a() -> Observation<S.SchemaA>:run_cut(~S.SchemaA,Tick.Tick{0n,5},Tick.Tick{0n,2},Part.cut(S.SchemaA,Layout.Viewed<S.Position,U32>,S.position_tree(~S.SchemaA),left(),right()))
def schema_b() -> Observation<S.SchemaB>:run_cut(~S.SchemaB,Tick.Tick{0n,5},Tick.Tick{0n,2},Part.cut(S.SchemaB,Layout.Viewed<S.Position,U32>,S.position_tree(~S.SchemaB),left(),right()))
def shield_a() -> Slice.Cut<S.SchemaA,Layout.Viewed<S.Shield,U32>,"Shield",S.shields()>:
  Slice.cut(~S.SchemaA,~S.shields(),~Layout.AtLeaf{},Layout.ColumnSlot{S.shield_tree(~S.SchemaA)},D.Domain{[0,8]},D.Domain{[2,10]})
def unlike_write(slot:Slice.Slot<S.SchemaB,Layout.Viewed<S.Shield,U32>,S.shields()>) -> Slice.Edit<S.SchemaB,Layout.Viewed<S.Shield,U32>,S.shields(),S.Shield,Unit>:
  Slice.edit(~S.SchemaB,~S.shields(),~Layout.AtLeaf{},Unit,slot,8,Tick.Tick{0n,6},S.shielded)
def any(value:Maybe<&2,U32>) -> Bool:True{}
def below(value:Maybe<&2,U32>) -> Bool:
  match value:
    case None{}:False{}
    case Some{n}:U32.is_lt(n,50)
def query_current(slot:Slice.Slot<S.SchemaA,Layout.Viewed<S.Position,U32>,S.positions()>) -> Q.Query<S.SchemaA,S.Position,U32,S.positions()>:
  Q.query(~S.SchemaA,~S.Position,~U32,~S.positions(),~below,slot,left(),Q.Required{})
def optional_shields(slot:Slice.Slot<S.SchemaA,Layout.Viewed<S.Shield,U32>,S.shields()>) -> Q.Query<S.SchemaA,S.Shield,U32,S.shields()>:
  Q.query(~S.SchemaA,~S.Shield,~U32,~S.shields(),~any,slot,D.Domain{[0,1,8]},Q.Optional{})
def broad_recipe() -> Q.Compiled<S.SchemaA,S.positions()>:
  Q.compile(S.SchemaA,S.positions(),Q.Both{Q.Read{left()},Q.Write{D.Domain{[0,1,2,3,8,9,18,19]}}})
def read_read() -> Bool:D.conflicts(D.Access{left(),D.Domain{[]}},D.Access{left(),D.Domain{[]}})
def read_write() -> Bool:D.conflicts(D.Access{left(),D.Domain{[]}},D.Access{D.Domain{[]},left()})

def refused_overlap() -> Part.Cut<S.SchemaA,Layout.Viewed<S.Position,U32>>:
  Part.cut(S.SchemaA,Layout.Viewed<S.Position,U32>,S.position_tree(~S.SchemaA),D.Domain{[0,8]},D.Domain{[8,9]})
def refused_duplicate() -> Part.Cut<S.SchemaA,Layout.Viewed<S.Position,U32>>:
  Part.cut(S.SchemaA,Layout.Viewed<S.Position,U32>,S.position_tree(~S.SchemaA),D.Domain{[0,0]},right())
def refused_range() -> Part.Cut<S.SchemaA,Layout.Viewed<S.Position,U32>>:
  Part.cut(S.SchemaA,Layout.Viewed<S.Position,U32>,S.position_tree(~S.SchemaA),D.Domain{[32]},right())
def refused_tree() -> Part.Cut<S.SchemaA,Layout.Viewed<S.Position,U32>>:
  Part.cut(S.SchemaA,Layout.Viewed<S.Position,U32>,Col.Branch{7,S.position_leaf(~S.SchemaA,0),S.position_leaf(~S.SchemaA,8)},D.Domain{[0]},D.Domain{[1]})
def refused_leaf() -> Part.Cut<S.SchemaA,Layout.Viewed<S.Position,U32>>:
  Part.cut(S.SchemaA,Layout.Viewed<S.Position,U32>,Col.Leaf{Col.absent(~Layout.Viewed<S.Position,U32>,2n),[L.Stamp{None{},None{}} : L.Stamp^3n]},D.Domain{[0]},D.Domain{[1]})
def forged_slice_return(join:Part.JoinOwner<S.SchemaA,Layout.Viewed<S.Position,U32>>,remainder:Col.Column<S.SchemaA,Layout.Viewed<S.Position,U32>>,left:Part.Slice<S.SchemaA,Layout.Viewed<S.Position,U32>>,right:Part.Slice<S.SchemaA,Layout.Viewed<S.Position,U32>>) -> Part.Joined<S.SchemaA,Layout.Viewed<S.Position,U32>>:
  match left:
    case Part.Slice{domain,cells}:Part.join(S.SchemaA,Layout.Viewed<S.Position,U32>,join,remainder,Part.Slice{domain,Part.Cell{100,Some{S.position(100)},L.Stamp{None{},None{}}} <> cells},right)
def range_escape(slot:Slice.Slot<S.SchemaA,Layout.Viewed<S.Position,U32>,S.positions()>) -> Slice.Edit<S.SchemaA,Layout.Viewed<S.Position,U32>,S.positions(),S.Position,Unit>:
  Slice.edit(~S.SchemaA,~S.positions(),~Layout.AtLeaf{},Unit,slot,4294967295,Tick.Tick{0n,5},S.moved)
def broad_query_no_truncation(slot:Slice.Slot<S.SchemaA,Layout.Viewed<S.Position,U32>,S.positions()>) -> Q.Query<S.SchemaA,S.Position,U32,S.positions()>:
  Q.query(~S.SchemaA,~S.Position,~U32,~S.positions(),~any,slot,D.Domain{[0,1,2,3,8,9,18,19]},Q.Required{})
def share_cached(+rows:List<&2,Q.Row<U32>>) -> List<&2,Q.Row<U32>> & List<&2,Q.Row<U32>>:(rows,rows)
type ShieldRun<-N:Data> is Type:
  ShieldRefused{column:Col.Column<N,Layout.Viewed<S.Shield,U32>>,reason:Part.Refusal}
  ShieldReturned{remainder:Col.Column<N,Layout.Viewed<S.Shield,U32>>,join:Part.JoinOwner<N,Layout.Viewed<S.Shield,U32>>,left:Slice.Edit<N,Layout.Viewed<S.Shield,U32>,S.shields(),S.Shield,Unit>,right:Slice.Edit<N,Layout.Viewed<S.Shield,U32>,S.shields(),S.Shield,Unit>}
def shield_cut(~N:Data,result:Part.Cut<N,Layout.Viewed<S.Shield,U32>>) -> ShieldRun<N>:
  match result:
    case Part.Refused{column,reason}:ShieldRefused{column,reason}
    case Part.Split{remainder,left,right,join}:ShieldReturned{remainder,join,Slice.edit(~N,~S.shields(),~Layout.AtLeaf{},Unit,Slice.Slot{left},8,Tick.Tick{0n,5},S.shielded),Slice.edit(~N,~S.shields(),~Layout.AtLeaf{},Unit,Slice.Slot{right},10,Tick.Tick{0n,5},S.shielded)}
def shield_schema_a() -> ShieldRun<S.SchemaA>:shield_cut(~S.SchemaA,Part.cut(S.SchemaA,Layout.Viewed<S.Shield,U32>,S.shield_tree(~S.SchemaA),D.Domain{[0,8]},D.Domain{[2,10]}))
def shield_schema_b() -> ShieldRun<S.SchemaB>:shield_cut(~S.SchemaB,Part.cut(S.SchemaB,Layout.Viewed<S.Shield,U32>,S.shield_tree(~S.SchemaB),D.Domain{[0,8]},D.Domain{[2,10]}))

def at_least(value:Maybe<&2,U32>) -> Bool:
  match value:
    case None{}:False{}
    case Some{n}:U32.is_le(50,n)
type Fresh is Type:
  Fresh{before:List<&2,Q.Row<U32>>,after:Q.Query<S.SchemaA,S.Position,U32,S.positions()>,unused:List<&1,S.Position -> S.Position & Unit>}
  InitialRefused{query:Q.Query<S.SchemaA,S.Position,U32,S.positions()>}
def queried_after(before:List<&2,Q.Row<U32>>,result:Slice.Edit<S.SchemaA,Layout.Viewed<S.Position,U32>,S.positions(),S.Position,Unit>) -> Fresh:
  match result:
    case Slice.Edited{slot,_}:Fresh{before,Q.query(~S.SchemaA,~S.Position,~U32,~S.positions(),~at_least,slot,left(),Q.Required{}),[]}
    case Slice.Unchanged{slot,unused}:Fresh{before,Q.query(~S.SchemaA,~S.Position,~U32,~S.positions(),~at_least,slot,left(),Q.Required{}),[unused]}
def queried_before(result:Q.Query<S.SchemaA,S.Position,U32,S.positions()>) -> Fresh:
  match result:
    case Q.Selected{slot,rows}:queried_after(rows,Slice.edit(~S.SchemaA,~S.positions(),~Layout.AtLeaf{},Unit,slot,8,Tick.Tick{0n,5},S.moved))
    case query:InitialRefused{query}
def fresh_operation(slot:Slice.Slot<S.SchemaA,Layout.Viewed<S.Position,U32>,S.positions()>) -> Fresh:
  queried_before(Q.query(~S.SchemaA,~S.Position,~U32,~S.positions(),~at_least,slot,left(),Q.Required{}))
def broad_book_conflict(result:Q.Compiled<S.SchemaA,S.positions()>) -> Q.Compiled<S.SchemaA,S.positions()> & Bool:
  match result:
    case Q.Compiled{+access,grants}:(Q.Compiled{access,grants},D.conflicts(access,D.Access{D.Domain{[]},D.Domain{[1]}}))
def broad_conflict() -> Q.Compiled<S.SchemaA,S.positions()> & Bool:broad_book_conflict(broad_recipe())
def prepared_broad() -> Q.Preparation<S.SchemaA,S.positions()>:
  Q.prepare(S.SchemaA,S.positions(),32,Q.Both{Q.Read{left()},Q.Write{D.Domain{[0,1,2,3,8,9,18,19]}}})

def full_schema_a() -> Layout.columns(~S.SchemaA,S.layout_a()):S.full_a()
def full_schema_b() -> Layout.columns(~S.SchemaB,S.layout_b()):S.full_b()
