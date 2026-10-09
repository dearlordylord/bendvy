import Base

# Metadata is Data; payload ownership stays in the typed column. Identity is
# the caller's closed typed column lens, never the family's display name.
type Stamp is Data:
  Stamp{added: U32,changed: U32}
type Entry is Data:
  Entry{id: U32,stamp: Stamp}

def choose(found: Bool,stamp: Stamp,other: Stamp) -> Stamp:
  match found:
    case True{}: stamp
    case False{}: other

def get(entries: List<&2,Entry>,+id: U32) -> Stamp:
  match entries:
    case []: Stamp{0,0}
    case Entry{key,stamp} <> rest: choose(U32.is_eq(key,id),stamp,get(rest,id))


def keep(equal: Bool,entry: Entry,rest: List<&2,Entry>) -> List<&2,Entry>:
  match equal:
    case True{}: rest
    case False{}: entry <> rest

def clear(entries: List<&2,Entry>,+id: U32) -> List<&2,Entry>:
  match entries:
    case []: []
    case Entry{+key,stamp} <> rest: keep(U32.is_eq(key,id),Entry{key,stamp},clear(rest,id))

def set(entries: List<&2,Entry>,+id: U32,stamp: Stamp) -> List<&2,Entry>:
  Entry{id,stamp} <> clear(entries,id)

def written(wasPresent: Bool,stamp: Stamp,+tick: U32) -> Stamp:
  match wasPresent stamp:
    case False{} _: Stamp{tick,tick}
    case True{} Stamp{added,_}: Stamp{added,tick}

def after_write(incoming: Bool,wasPresent: Bool,stamp: Stamp,tick: U32) -> Stamp:
  match incoming:
    case False{}: Stamp{0,0}
    case True{}: written(wasPresent,stamp,tick)

def added(stamp: Stamp,cursor: U32) -> Bool:
  match stamp:
    case Stamp{value,_}: U32.is_gt(value,cursor)

def changed(stamp: Stamp,cursor: U32) -> Bool:
  match stamp:
    case Stamp{_,value}: U32.is_gt(value,cursor)
