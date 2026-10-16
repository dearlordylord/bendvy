import Base
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/relation-commands.bend as A
import ../../../../../src/ecs/relation-query.bend as RQ
import ../../../../../src/ecs/inspector.bend as I
import ../../../../../src/ecs/check.bend as K
import ../../../../../src/ecs/inspector-query.bend as IQ
import ../../../../../src/ecs/inspector-query-projection.bend as Q
import ../../../../../src/ecs/ordinary-app-relation.bend as Relation
import ../../../../../src/ecs/ordinary-inspector-relation.bend as Decl
import state.bend as State
import ./declarations.bend as D
import ./render.bend as Render

def World(~S:Data) -> Type:
  W.World<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>
def Rows(~S:Data) -> Data:
  List<&2,Relation.Row(~S)>
def Query(~S:Data,~H:Type) -> Type:
  IQ.ComposedReadQuery<H,S,Q.Product<Unit,List<&2,RQ.Cell<S>>>>
def link_required_out(~S:Data) -> Decl.Declaration<S>:
  Decl.required_out(~S,"link_required_out",D.declared_link(~S))
def link_optional_out(~S:Data) -> Decl.Declaration<S>:
  Decl.optional_out(~S,"link_optional_out",D.declared_link(~S))
def link_present_out(~S:Data) -> Decl.Declaration<S>:
  Decl.present_out(~S,D.declared_link(~S))
def link_absent_out(~S:Data) -> Decl.Declaration<S>:
  Decl.absent_out(~S,D.declared_link(~S))
def link_required_in(~S:Data) -> Decl.Declaration<S>:
  Decl.required_in(~S,"link_required_in",D.declared_link(~S))
def link_optional_in(~S:Data) -> Decl.Declaration<S>:
  Decl.optional_in(~S,"link_optional_in",D.declared_link(~S))
def link_present_in(~S:Data) -> Decl.Declaration<S>:
  Decl.present_in(~S,D.declared_link(~S))
def link_absent_in(~S:Data) -> Decl.Declaration<S>:
  Decl.absent_in(~S,D.declared_link(~S))
def parent_required_out(~S:Data) -> Decl.Declaration<S>:
  Decl.required_out(~S,"parent_required_out",D.declared_parent(~S))
def parent_optional_out(~S:Data) -> Decl.Declaration<S>:
  Decl.optional_out(~S,"parent_optional_out",D.declared_parent(~S))
def parent_present_out(~S:Data) -> Decl.Declaration<S>:
  Decl.present_out(~S,D.declared_parent(~S))
def parent_absent_out(~S:Data) -> Decl.Declaration<S>:
  Decl.absent_out(~S,D.declared_parent(~S))
def parent_required_in(~S:Data) -> Decl.Declaration<S>:
  Decl.required_in(~S,"parent_required_in",D.declared_parent(~S))
def parent_optional_in(~S:Data) -> Decl.Declaration<S>:
  Decl.optional_in(~S,"parent_optional_in",D.declared_parent(~S))
def parent_present_in(~S:Data) -> Decl.Declaration<S>:
  Decl.present_in(~S,D.declared_parent(~S))
def parent_absent_in(~S:Data) -> Decl.Declaration<S>:
  Decl.absent_in(~S,D.declared_parent(~S))
type Context<S:Data> is Type:
  Context{world:World(~S),instance:I.Instance<S>}
def inspect_rows(~S:Data,~H:Type,result:H & Rows(~S)) -> H & Result<&2,&2,Unit,String>:
  (owner,rows)=result
  (owner,Done{Render.row_array(~S,rows)})
def inspect_body(~S:Data,~H:Type,~caps:Query(~S,~H),_:Unit,owner:H) -> H & Result<&2,&2,Unit,String>:
  inspect_rows(~S,~H,IQ.each_composed(~H,~S,~Q.Product<Unit,List<&2,RQ.Cell<S>>>,~caps,owner))
def condition_rows(~S:Data,~H:Type,expected:Nat,result:H & Rows(~S)) -> H & Bool:
  (owner,rows)=result
  (owner,Nat.is_eq(List.length(&2,Relation.Row(~S),rows),expected))
def condition_body(~S:Data,~H:Type,~caps:Query(~S,~H),expected:Nat,owner:H) -> H & Bool:
  condition_rows(~S,~H,expected,IQ.each_composed(~H,~S,~Q.Product<Unit,List<&2,RQ.Cell<S>>>,~caps,owner))
def required(~S:Data,world:World(~S)) -> World(~S) & List<&2,String>:
  (world,[])
def inspect_plan(~S:Data,~declaration:Decl.Declaration<S>) -> I.Plan<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,H => Query(~S,~H)>:
  I.Plan{Decl.inspect(~S,~State.Components<S>,~State.Resources<S>,~U32,~Unit,~Q.empty(~I.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,~S),~declaration)}
def condition_plan(~S:Data,~declaration:Decl.Declaration<S>) -> K.Plan<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>,H => Query(~S,~H)>:
  K.Plan{required(~S),Decl.condition(~S,~State.Components<S>,~State.Resources<S>,~U32,~Unit,~Q.empty(~K.Frame<S,A.Store<S,State.Components<S>>,State.Resources<S>,A.Notice<S,U32>>,~S),~declaration)}
