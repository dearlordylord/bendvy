import Base
import event-publication.bend as P
import ordinary-event-family.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/owner-product.bend as Product
def retained(_tick:Nat,values:List<&2,U32>,owner:Unit) -> Unit & List<&2,U32>:(owner,values)
def retain(owner:Unit,tick:Nat,values:List<&2,U32>) -> Unit & List<&2,U32>:retained(tick,values,owner)
def records() -> List<&2,P.Publication<U32,U32>>:[P.Publication{[1,2],[10]},P.Publication{[],[]},P.Publication{[3],[11,12]}]
def main() -> List<&2,U32> & List<&2,U32> & (Product.Owner<Unit,Unit> & List<&2,P.Publication<U32,U32>>):(P.first_values(~U32,~U32,records()),P.second_values(~U32,~U32,records()),C.pair_retain(~U32,~U32,~Unit,~Unit,~retain,~retain,Product.Owner{Unit{},Unit{}},1n,records()))
