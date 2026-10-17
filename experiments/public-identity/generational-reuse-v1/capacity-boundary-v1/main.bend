import Base
import ../fixture.bend as F
import observe.bend as O
import compact-owner.bend as D
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/entity-key.bend as K
import ../../../../src/ecs/entity-allocator.bend as A
import ../../../../src/ecs/column.bend as Col

def grow(remaining:Nat,slots:Array<A.Slot>,+depth:Nat) -> Array<A.Slot> & Nat:
  match remaining:
    case 0n:(slots,depth)
    case 1n+rest:grow(rest,ANode{slots,Array.new(A.Slot,depth,A.Slot{0,A.Consumed{}})},1n+depth)
def near_sized(~S:Data,namespace:U32,depth:Nat,free:List<&2,U32>,order:List<&2,K.Key>,store:F.Store<S>,resource:Array<U32>,events:List<&2,F.Notice<S>>,pending:List<(F.World(~S) -> F.World(~S))>,regs:List<&2,W.RegistrationMeta>,observed:Array<A.Slot> & U32) -> F.World(~S):
  match observed:
    case (slots,capacity):W.World{namespace,A.Allocator{131072,131071,slots,capacity,depth,free,order},store,resource,events,pending,regs,4294967295,4294967294}
def near_grown(~S:Data,namespace:U32,free:List<&2,U32>,order:List<&2,K.Key>,store:F.Store<S>,resource:Array<U32>,events:List<&2,F.Notice<S>>,pending:List<(F.World(~S) -> F.World(~S))>,regs:List<&2,W.RegistrationMeta>,observed:Array<A.Slot> & Nat) -> F.World(~S):
  match observed:
    case (slots,depth):near_sized(~S,namespace,depth,free,order,store,resource,events,pending,regs,Array.size(A.Slot,slots))
# Same trusted near-boundary setup as the qualified old public-integration case:
# grow actual seeded ownership; reserve holes without inventing live components.
def near(~S:Data,world:F.World(~S)) -> F.World(~S):
  match world:
    case W.World{namespace,A.Allocator{_,_,slots,_,depth,free,order},store,resource,events,pending,regs,_,_}:near_grown(~S,namespace,free,order,store,resource,events,pending,regs,grow(16n,slots,depth))
def checkpoint_join(~S:Data,label:String,log:String,result:F.World(~S) & String) -> F.World(~S) & String:
  match result:
    case (world,text):(world,log ++ label ++ ":{" ++ text ++ "}\n")
def checkpoint(~S:Data,label:String,world:F.World(~S),log:String) -> F.World(~S) & String:checkpoint_join(~S,label,log,O.world(~S,world))
def reservation(~S:Data,log:String,result:F.World(~S) & W.Reservation<S>) -> F.World(~S) & String:
  match result:
    case (world,W.Reserved{handle}):(world,log ++ "reservation=Reserved(" ++ F.handle_text(~S,handle) ++ ")\n")
    case (world,W.ReservationRejected{error}):(world,log ++ "reservation=Rejected(" ++ O.error(error) ++ ")\n")
def registration(~S:Data,log:String,result:F.World(~S) & W.Registration) -> F.World(~S) & String:
  match result:
    case (world,W.Registered{id}):(world,log ++ "registration=Registered(" ++ U32.show(id) ++ ")\n")
    case (world,W.RegistrationRejected{error}):(world,log ++ "registration=Rejected(" ++ O.error(error) ++ ")\n")
def advanced(~S:Data,log:String,result:F.World(~S) & U32) -> F.World(~S) & String:
  match result:
    case (world,tick):(world,log ++ "clock=" ++ U32.show(tick) ++ "\n")
def out_of_range(~S:Data,log:String,result:F.World(~S) & Bool) -> F.World(~S) & String:
  match result:
    case (world,live):(world,log ++ "out-of-range-live=" ++ Bool.show(live) ++ "\n")
def checked_namespace(~S:Data,log:String,result:F.World(~S) & U32) -> F.World(~S) & String:
  match result:
    case (world,ns):out_of_range(~S,log,W.valid(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,world,W.Handle{ns,K.EntityKey{4294967295,0}}))
def final_check(~S:Data,result:F.World(~S) & String) -> F.World(~S) & String:
  match result:
    case (world,log):checked_namespace(~S,log,W.namespace(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,world))
def tick_again(~S:Data,result:F.World(~S) & String) -> F.World(~S) & String:
  match result:
    case (world,log):final_check(~S,advanced(~S,log,W.advance_clock(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,world)))
def ticks(~S:Data,result:F.World(~S) & String) -> F.World(~S) & String:
  match result:
    case (world,log):tick_again(~S,advanced(~S,log,W.advance_clock(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,world)))
def register(~S:Data,result:F.World(~S) & String) -> F.World(~S) & String:
  match result:
    case (world,log):ticks(~S,registration(~S,log,W.register(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,world,"refused",[])))
def second_reserved(~S:Data,result:F.World(~S) & String) -> F.World(~S) & String:
  match result:
    case (world,log):register(~S,checkpoint(~S,"after-capacity-refusal",world,log))
def second(~S:Data,result:F.World(~S) & String) -> F.World(~S) & String:
  match result:
    case (world,log):second_reserved(~S,reservation(~S,log,W.reserve_id(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,world)))
def first_reserved(~S:Data,result:F.World(~S) & String) -> F.World(~S) & String:
  match result:
    case (world,log):second(~S,checkpoint(~S,"before-capacity-refusal",world,log))
def first(~S:Data,result:F.World(~S) & String) -> F.World(~S) & String:
  match result:
    case (world,log):first_reserved(~S,reservation(~S,log,W.reserve_id(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,world)))
def world_run(~S:Data,world:F.World(~S)) -> F.World(~S) & String:first(~S,checkpoint(~S,"near-boundary",near(~S,world),""))
def final_world(~S:Data,result:F.World(~S) & String) -> F.World(~S) & String:
  match result:
    case (world,log):checkpoint(~S,"final-boundary",world,log)
def column_observed(~S:Data,label:String,log:String,column:Col.Column<S,Array<U32>> & String,returned:Maybe<&1,Array<U32>> & String) -> Col.Column<S,Array<U32>> & String:
  (column,ct)=column
  (_,rt)=returned
  (column,log ++ label ++ ":{column=" ++ ct ++ ";returned=" ++ rt ++ "}\n")
def column_swapped(~S:Data,label:String,log:String,result:Col.SwapOutcome<S,Array<U32>>) -> Col.Column<S,Array<U32>> & String:
  match result:
    case Col.Accepted{column,previous}:column_observed(~S,label ++ ":Accepted",log,D.column(~S,~Array<U32>,~D.u32_array,column),D.optional(~Array<U32>,~D.u32_array,previous))
    case Col.Rejected{column,incoming}:column_observed(~S,label ++ ":Rejected",log,D.column(~S,~Array<U32>,~D.u32_array,column),D.optional(~Array<U32>,~D.u32_array,incoming))
def column_complete(~S:Data,result:Col.Column<S,Array<U32>> & String) -> String:
  match result:
    case (_,log):log
def column_last(~S:Data,result:Col.Column<S,Array<U32>> & String) -> String:
  match result:
    case (column,log):column_complete(~S,column_swapped(~S,"column-out-of-range",log,Col.swap(~S,~Array<U32>,column,131073,Some{ANode{ALeaf{88},ALeaf{89}}})))
def columns(~S:Data) -> String:column_last(~S,column_swapped(~S,"column-last","",Col.swap(~S,~Array<U32>,Col.ensure(~S,~Array<U32>,Col.empty(~S,~Array<U32>),131072),131072,Some{ANode{ALeaf{77},ALeaf{78}}})))
def rendered(~S:Data,result:F.World(~S) & String) -> String:
  match result:
    case (_,log):log ++ columns(~S)
def seeded(~S:Data,result:F.World(~S) & Maybe<&2,W.Handle<S>>) -> String:
  match result:
    case (_,None{}):"seed-refused"
    case (world,Some{_}):rendered(~S,final_world(~S,world_run(~S,W.barrier(~S,~F.Store<S>,~Array<U32>,~F.Notice<S>,world))))
def created(result:W.Creation<F.Workshop,F.Store<F.Workshop>,Array<U32>,F.Notice<F.Workshop>>) -> String:
  match result:
    case W.CreateRejected{_,_}:"creation-refused"
    case W.Created{_,world}:seeded(~F.Workshop,F.spawn(~F.Workshop,world,20))
def main() -> IO(Unit):IO.print(created(W.create(~F.Workshop,~F.Store<F.Workshop>,~Array<U32>,~F.Notice<F.Workshop>,~F.empty(~F.Workshop),W.factory(),ANode{ALeaf{61},ALeaf{62}})))
