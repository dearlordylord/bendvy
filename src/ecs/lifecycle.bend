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

def get_selected(entries: List<&2,Entry>,+id: U32,found: Bool,stamp: Stamp) -> Stamp:
  match entries found:
    case _ True{}: stamp
    case Nil{} False{}: Stamp{0,0}
    case Con{Entry{key,current},rest} False{}: get_selected(rest,id,U32.is_eq(key,id),current)

def get(entries: List<&2,Entry>,id: U32) -> Stamp:
  get_selected(entries,id,False{},Stamp{0,0})


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
