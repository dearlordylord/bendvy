import Base
import ../../../src/ecs/reader-domains.bend as D
import ../../../src/ecs/event-runtime.bend as Ev
import ./spec.bend as Spec

type Item is Data:
  Event{id:U32}
  Removal{id:U32}
def select(item:Item) -> Bool:
  match item:
    case Event{_}: True{}
    case Removal{_}: False{}
def show(item:Item) -> String:
  match item:
    case Event{id}: "E" ++ U32.show(id)
    case Removal{id}: "R" ++ U32.show(id)
def values(items:List<&2,Item>) -> String:
  List.show(&2,Item,show,items)
def partition(pair:List<&2,Item> & List<&2,Item>) -> String:
  (a,b)=pair
  values(a) ++ "/" ++ values(b)
def batch(item:Ev.Batch<Item>) -> String:
  match item:
    case Ev.Batch{tick,items}: Nat.show(tick) ++ ":" ++ values(items)
def batches(items:List<&2,Ev.Batch<Item>>) -> String:
  List.show(&2,Ev.Batch<Item>,batch,items)
def pair(name:String,a:String,b:String) -> String:
  name ++ "|" ++ a ++ "|" ++ b ++ "\n"
def sample(+items:List<&2,Item>) -> String:
  pair("stable_partition",partition(D.split(~Item,~select,items)),partition((Spec.selected(~Item,~select,items),Spec.rejected(~Item,~select,items))))
def batch_sample(+items:List<&2,Ev.Batch<Item>>) -> String:
  pair("filtered_batch_order",batches(D.event_batches(~Item,~select,items)),batches(Spec.batches(~Item,~select,items))) ++ pair("retained_publication_ticks",List.show(&2,Nat,Nat.show,Spec.ticks(~Item,D.event_batches(~Item,~select,items))),List.show(&2,Nat,Nat.show,Spec.ticks(~Item,Spec.batches(~Item,~select,items))))
def main() -> IO(Unit):
  IO.print(sample([]) ++ sample([Event{7},Removal{9},Event{2},Removal{9},Event{7}]) ++ sample([Removal{0}]) ++ sample([Event{4294967295}]) ++ batch_sample([]) ++ batch_sample([Ev.Batch{9n,[Removal{3},Event{7},Event{2}]},Ev.Batch{4n,[Removal{1}]},Ev.Batch{9n,[]},Ev.Batch{2n,[Event{7},Removal{3},Event{7}]}]))
