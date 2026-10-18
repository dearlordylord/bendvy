import Base
import ./ordinary-event-family.bend as Family
import ./event-publication.bend as Publication

# These are the existing Data-family singleton injections and ordered branch
# projections, specialized to log-local Nat IDs. Equal IDs on sibling branches
# remain distinct because each declaration binds both its route and resource path.
def inject_leaf(id:Nat) -> Nat:Family.inject_leaf(~Nat,id)
def inject_left(~A:Data,~B:Data,~inject:Nat -> A,id:Nat) -> Publication.Publication<A,B>:
  Family.inject_left(~Nat,~A,~B,~inject,id)
def inject_right(~A:Data,~B:Data,~inject:Nat -> B,id:Nat) -> Publication.Publication<A,B>:
  Family.inject_right(~Nat,~A,~B,~inject,id)
def select_leaf(ids:List<&2,Nat>) -> List<&2,Nat>:ids
def select_left(~A:Data,~B:Data,~select:List<&2,A> -> List<&2,Nat>,records:List<&2,Publication.Publication<A,B>>) -> List<&2,Nat>:
  select(Publication.first_values(~A,~B,records))
def select_right(~A:Data,~B:Data,~select:List<&2,B> -> List<&2,Nat>,records:List<&2,Publication.Publication<A,B>>) -> List<&2,Nat>:
  select(Publication.second_values(~A,~B,records))
