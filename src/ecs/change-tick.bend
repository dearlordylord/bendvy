import Base

# Logical change timestamp. low wraps modulo 2^32; epoch preserves the history
# needed to age dormant components/readers across low wraps within runtime limits.
# Raw constructors are trusted: execution must not supply future stamps/cursors.
type Tick is Data:
  Tick{epoch:Nat,low:U32}

# Pinned Bevy ad678262 change_detection/mod.rs MAX_CHANGE_AGE.
# Exact epochs replace periodic storage sweeps, not this observable age bound.
def max_change_age() -> U32:3258167296

# Initial administrative timestamp. Zero is valid, not component absence or a
# fabricated first-run cursor; first-run reader policy is supplied separately.
def zero() -> Tick:Tick{0n,0}

def incremented(wrapped:Bool,epoch:Nat,low:U32) -> Tick:
  match wrapped:
    case False{}:Tick{epoch,U32.add(low,1)}
    case True{}:Tick{1n+epoch,0}

# Advance one logical execution boundary, carrying the epoch on low-word wrap.
def next(tick:Tick) -> Tick:
  match tick:
    case Tick{epoch,+low}:incremented(U32.is_eq(low,4294967295),epoch,low)

# Diagnostic low word only; never use this projection as an independent cursor.
def low(tick:Tick) -> U32:
  match tick:
    case Tick{_,value}:value

# Monotone logical ordinal for existing Nat-based observation/runtime domains.
# Backend Nat representation limits still apply to consumers of this projection.
def total(tick:Tick) -> Nat:
  match tick:
    case Tick{epoch,value}:Nat.add(Nat.mul(epoch,1n+4294967295n),U32.to_nat(value))

def ordered_epochs(equal:Bool,earlier:Bool,stamp:U32,this:U32) -> Bool:
  match equal:
    case True{}:U32.is_le(stamp,this)
    case False{}:earlier

# Explicit validity of a timestamp relative to this execution. Future values
# are not made recent by saturating Nat subtraction.
def not_future(stamp:Tick,this:Tick) -> Bool:
  match stamp this:
    case Tick{+se,sl} Tick{+te,tl}:ordered_epochs(Nat.is_eq(se,te),Nat.is_lt(se,te),sl,tl)

def crossing_age(lowWrapped:Bool,stamp:U32,this:U32) -> U32:
  match lowWrapped:
    case False{}:max_change_age()
    case True{}:U32.min(U32.sub(this,stamp),max_change_age())

def distance(same:Bool,adjacent:Bool,+stamp:U32,+this:U32) -> U32:
  match same adjacent:
    case True{} _:U32.min(U32.sub(this,stamp),max_change_age())
    case False{} True{}:crossing_age(U32.is_lt(this,stamp),stamp,this)
    case False{} False{}:max_change_age()

def valid_age(valid:Bool,stamp:Tick,this:Tick) -> U32:
  match valid stamp this:
    case False{} _ _:max_change_age()
    case True{} Tick{+se,sl} Tick{+te,tl}:distance(Nat.is_eq(se,te),Nat.is_eq(1n+se,te),sl,tl)

# True elapsed age capped at Bevy's MAX_CHANGE_AGE, including multiple wraps.
# Invalid future stamps return MAX; use not_future when distinguishing invalid
# inputs from legitimately old data. No global storage maintenance is required.
def age(+stamp:Tick,+this:Tick) -> U32:
  valid_age(not_future(stamp,this),stamp,this)

def valid_newer(valid:Bool,stamp:Tick,last:Tick,+this:Tick) -> Bool:
  match valid:
    case False{}:False{}
    case True{}:U32.is_gt(age(last,this),age(stamp,this))

# Compare component age with independent reader age. Equality and two maximally
# old timestamps are not new. A future stamp OR reader cursor rejects as False;
# callers separately establish component presence and first-run reader policy.
def newer(+stamp:Tick,+last:Tick,+this:Tick) -> Bool:
  valid_newer(Bool.and(not_future(stamp,this),not_future(last,this)),stamp,last,this)

# Detached full-timestamp diagnostic; the epoch is never discarded.
def show(tick:Tick) -> String:
  match tick:
    case Tick{epoch,low}:Nat.show(epoch) ++ ":" ++ U32.show(low)
# Distinguish an uninitialized lifecycle cursor from the legitimate zero tick.
def cursor_show(cursor:Maybe<&2,Tick>) -> String:
  match cursor:
    case None{}:"never"
    case Some{tick}:show(tick)
