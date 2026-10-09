import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-56-query-proposal/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/query-candidate-v1/app-run-v1/nominal-carrier-v1/accumulated-v1/without-description-mutant-v1/scenario-dto.bend as DTO
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as Cmp
import /workspace/formal-proofs/bendvy/src/ecs/transaction.bend as T
import /workspace/formal-proofs/bendvy/experiments/public-simulation/bend-v1/owner-view.bend as View

def Ops(H:Type) -> Type:
  (Cap.Read<H,View.FullCell> & Cap.Write<H,Array<U32>,View.FullCell>) & Cap.Read<H,View.FullCell>
def FilterOps(H:Type) -> Type:
  Ops(H) & Unit
def read_position(~H:Type,caps:Ops(H)) -> Cap.Read<H,View.FullCell>:
  match caps:
    case ((position,_),_):position
def write_velocity(~H:Type,caps:Ops(H)) -> Cap.Write<H,Array<U32>,View.FullCell>:
  match caps:
    case ((_,velocity),_):velocity
def read_health(~H:Type,caps:Ops(H)) -> Cap.Read<H,View.FullCell>:
  match caps:
    case (_,health):health
def filtered(~H:Type,caps:FilterOps(H)) -> Ops(H):
  match caps:
    case (caps,_):caps
def first(cell:View.FullCell) -> U32:
  match cell:
    case View.FullCell{_,[]}:0
    case View.FullCell{_,head <> _}:head
def depth_step(small:Bool,done:Nat,next:Unit -> Nat) -> Nat:
  match small:
    case True{}:done
    case False{}:next(Unit{})
def depth(fuel:Nat,+remaining:U32,+done:Nat) -> Nat:
  match fuel:
    case 0n:done
    case 1n+rest:depth_step(U32.is_le(remaining,1),done,(_ => depth(rest,(remaining / 2 : U32),1n+done)))
def copy(values:List<&2,U32>,+index:U32,owner:Array<U32>) -> Array<U32>:
  match values:
    case []:owner
    case value <> rest:copy(rest,(index + 1 : U32),Array.set(U32,owner,index,value))
def replacement(+cell:View.FullCell,newFirst:U32) -> Array<U32>:
  match cell:
    case View.FullCell{+length,[]}:Array.new(U32,0n,newFirst)
    case View.FullCell{+length,_ <> tail}:copy(newFirst <> tail,0,Array.new(U32,depth(length,U32.from_nat(length),0n),0))
def completed(~H:Type,fail:Bool,owner:H,position:View.FullCell,velocity:View.FullCell,health:Cmp.Access<View.FullCell>) -> H & (T.Outcome<Unit> & DTO.RowValues):
  match fail:
    case True{}:(owner,(T.Failure{Unit{}},DTO.RowValues{position,velocity,health}))
    case False{}:(owner,(T.Success{},DTO.RowValues{position,velocity,health}))
def health_read(~H:Type,~caps:Ops(H),fail:Bool,+position:View.FullCell,+velocity:View.FullCell,observed:H & Cmp.Access<View.FullCell>) -> H & (T.Outcome<Unit> & DTO.RowValues):
  match observed:
    case (owner,health):completed(~H,fail,Cap.set(~H,~Array<U32>,~View.FullCell,~write_velocity(~H,caps),owner,replacement(velocity,(first(velocity) + first(position) : U32))),position,velocity,health)
def velocity_read(~H:Type,~caps:Ops(H),fail:Bool,position:View.FullCell,observed:H & Cmp.Access<View.FullCell>) -> H & (T.Outcome<Unit> & DTO.RowValues):
  match observed:
    case (owner,Cmp.Found{velocity}):health_read(~H,~caps,fail,position,velocity,Cap.read(~H,~View.FullCell,~read_health(~H,caps),owner))
    case (owner,_):(owner,(T.Failure{Unit{}},DTO.RowValues{position,View.FullCell{0n,[]},Cmp.ComponentAbsent{}}))
def position_read(~H:Type,~caps:Ops(H),fail:Bool,observed:H & Cmp.Access<View.FullCell>) -> H & (T.Outcome<Unit> & DTO.RowValues):
  match observed:
    case (owner,Cmp.Found{position}):velocity_read(~H,~caps,fail,position,Cap.get(~H,~Array<U32>,~View.FullCell,~write_velocity(~H,caps),owner))
    case (owner,_):(owner,(T.Failure{Unit{}},DTO.RowValues{View.FullCell{0n,[]},View.FullCell{0n,[]},Cmp.ComponentAbsent{}}))
def body(~H:Type,~caps:Ops(H),fail:Bool,owner:H) -> H & (T.Outcome<Unit> & DTO.RowValues):
  position_read(~H,~caps,fail,Cap.read(~H,~View.FullCell,~read_position(~H,caps),owner))
def filter_body(~H:Type,~caps:FilterOps(H),fail:Bool,owner:H) -> H & (T.Outcome<Unit> & DTO.RowValues):
  body(~H,~filtered(~H,caps),fail,owner)
