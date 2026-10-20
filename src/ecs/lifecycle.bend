import Base
import ./change-tick.bend as Tick

# Metadata is Data; payload ownership stays in the typed column. Identity is
# the caller's closed typed column lens, never the family's display name.
type Stamp is Data:
  Stamp{added: Maybe<&2,Tick.Tick>,changed: Maybe<&2,Tick.Tick>}
type Entry is Data:
  Entry{id: U32,stamp: Stamp}

def choose(found: Bool,stamp: Stamp,other: Stamp) -> Stamp:
  match found:
    case True{}: stamp
    case False{}: other

def get_selected(entries: List<&2,Entry>,+id: U32,found: Bool,stamp: Stamp) -> Stamp:
  match entries found:
    case _ True{}: stamp
    case Nil{} False{}: Stamp{None{},None{}}
    case Con{Entry{key,current},rest} False{}: get_selected(rest,id,U32.is_eq(key,id),current)

def get(entries: List<&2,Entry>,id: U32) -> Stamp:
  get_selected(entries,id,False{},Stamp{None{},None{}})


def keep(equal: Bool,entry: Entry,rest: List<&2,Entry>) -> List<&2,Entry>:
  match equal:
    case True{}: rest
    case False{}: entry <> rest

def entry_id(entry:Entry) -> U32:
  match entry:
    case Entry{id,_}:id

def clear_reversed(entries: List<&2,Entry>,+id: U32,acc: List<&2,Entry>) -> List<&2,Entry>:
  match entries:
    case []: List.reverse(&2,Entry,acc)
    case +entry <> rest: clear_reversed(rest,id,keep(U32.is_eq(entry_id(entry),id),entry,acc))

def clear(entries: List<&2,Entry>,id: U32) -> List<&2,Entry>:
  clear_reversed(entries,id,[])

def set(entries: List<&2,Entry>,+id: U32,stamp: Stamp) -> List<&2,Entry>:
  Entry{id,stamp} <> clear(entries,id)

def written(wasPresent: Bool,stamp: Stamp,+tick: Tick.Tick) -> Stamp:
  match wasPresent stamp:
    case False{} _: Stamp{Some{tick},Some{tick}}
    case True{} Stamp{added,_}: Stamp{added,Some{tick}}

def after_write(incoming: Bool,wasPresent: Bool,stamp: Stamp,tick: Tick.Tick) -> Stamp:
  match incoming:
    case False{}: Stamp{None{},None{}}
    case True{}: written(wasPresent,stamp,tick)

# Presence is explicit: wrapped tick zero is a valid component timestamp.
def selected_age(+stamp:Tick.Tick,cursor:Maybe<&2,Tick.Tick>,+this:Tick.Tick) -> Bool:
  match cursor:
    case None{}:Bool.and(Tick.not_future(stamp,this),U32.is_lt(Tick.age(stamp,this),Tick.max_change_age()))
    case Some{last}:Tick.newer(stamp,last,this)
def selected(stamp:Maybe<&2,Tick.Tick>,cursor:Maybe<&2,Tick.Tick>,this:Tick.Tick) -> Bool:
  match stamp:
    case None{}:False{}
    case Some{tick}:selected_age(tick,cursor,this)

# Compare bounded true ages against this captured run; None is a first-run cursor.
def added(stamp:Stamp,cursor:Maybe<&2,Tick.Tick>,this:Tick.Tick) -> Bool:
  match stamp:
    case Stamp{value,_}:selected(value,cursor,this)
def changed(stamp:Stamp,cursor:Maybe<&2,Tick.Tick>,this:Tick.Tick) -> Bool:
  match stamp:
    case Stamp{_,value}:selected(value,cursor,this)
