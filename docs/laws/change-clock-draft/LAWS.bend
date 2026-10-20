import Base
import ../../../src/ecs/change-tick.bend as Tick
import ../../../src/ecs/lifecycle.bend as L

# DRAFT, unapproved exact statements for #75. No proof definitions or universal
# validity claim are implied by executable boundary controls or --check-only.
# User-approved behavior: continuing writes, bounded Bevy ages, explicit absence,
# and no low-only legacy cursor. These proposals do not specify the whole ECS.

# A complete logical timestamp advances even when its low U32 word wraps.
law logical_progress:
  for +tick: Tick.Tick
  {Tick.total(Tick.next(tick)) == Nat.add(Tick.total(tick),1n) : Nat}

# No timestamp, including a rejected future one, produces an unbounded age.
law bounded_age:
  for +stamp: Tick.Tick
  for +now: Tick.Tick
  {U32.is_le(Tick.age(stamp,now),Tick.max_change_age()) == True{} : Bool}

# Equal stamp and reader time cannot count as a new change.
law equal_not_new:
  for +stamp: Tick.Tick
  for +now: Tick.Tick
  {Tick.newer(stamp,stamp,now) == False{} : Bool}

# Component absence never masquerades as the legitimate wrapped tick zero.
law absent_not_added:
  for +cursor: Maybe<&2,Tick.Tick>
  for +now: Tick.Tick
  {L.added(L.Stamp{None{},None{}},cursor,now) == False{} : Bool}
