import Base
import ../../../src/ecs/reader-domains.bend as D
import ../../../src/ecs/event-runtime.bend as Ev
import ./spec.bend as Spec

# DRAFT / UNAPPROVED. Pure Data metadata equations, not World refinement.
law stable_partition:
  for E: Data
  for select: E -> Bool
  for +items: List<&2,E>
  {D.split(~E,~select,items) == (Spec.selected(~E,~select,items),Spec.rejected(~E,~select,items)) : List<&2,E> & List<&2,E>}
law filtered_batch_order:
  for E: Data
  for select: E -> Bool
  for +items: List<&2,Ev.Batch<E>>
  {D.event_batches(~E,~select,items) == Spec.batches(~E,~select,items) : List<&2,Ev.Batch<E>>}
law retained_publication_ticks:
  for E: Data
  for select: E -> Bool
  for +items: List<&2,Ev.Batch<E>>
  {Spec.ticks(~E,D.event_batches(~E,~select,items)) == Spec.ticks(~E,Spec.batches(~E,~select,items)) : List<&2,Nat>}
