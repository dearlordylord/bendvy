import Base

# Feasibility only: the Type owner is arbitrary and never duplicated.
def fuel_first(fuel: Nat,-Owner: Type,owner: Owner) -> Owner:
  match fuel:
    case 0n: owner
    case 1n+rest: fuel_first(rest,Owner,owner)
def erased_first(-Owner: Type,fuel: Nat,owner: Owner) -> Owner:
  match fuel:
    case 0n: owner
    case 1n+rest: erased_first(Owner,rest,owner)
def frozen_first(~Owner: Type,fuel: Nat,owner: Owner) -> Owner:
  match fuel:
    case 0n: owner
    case 1n+rest: frozen_first(~Owner,rest,owner)
type ArrayOwner is Type:
  ArrayOwner{values: Array<U32>}
def show_owner(owner: ArrayOwner) -> String:
  match owner:
    case ArrayOwner{values}: List.show(&1,U32,U32.show,Array.to_list(U32,values))
def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(show_owner(fuel_first(3n,ArrayOwner,ArrayOwner{ANode{ALeaf{51},ALeaf{52}}})))
    IO.print(show_owner(erased_first(ArrayOwner,3n,ArrayOwner{ANode{ALeaf{61},ALeaf{62}}})))
    IO.print(show_owner(frozen_first(~ArrayOwner,3n,ArrayOwner{ANode{ALeaf{71},ALeaf{72}}})))
