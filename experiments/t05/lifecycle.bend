import Base
import ../rc1-query/api.bend as A
import ../rc1-query/schemas.bend as S

type TagCell is Type:
  TagCell{label: String, tag: Maybe<&2, S.Tag>}
type TagData is Data:
  TagData{label: String, tag: Maybe<&2, S.Tag>}
def tag_get(c: TagCell) -> TagCell & TagData:
  match c:
    case TagCell{+label, +tag}: (TagCell{label, tag}, TagData{label, tag})
def tag_has(c: TagCell) -> TagCell & Bool:
  match c:
    case TagCell{label, +tag}: (TagCell{label, tag}, S.present(~S.Tag, tag))
def tag_set(c: TagCell, tag: Maybe<&2, S.Tag>) -> TagCell:
  match c:
    case TagCell{label, _}: TagCell{label, tag}
def read_aux(-P: Type, -M: Type, p: P, x: U32, value: M & TagData) -> P & (M & String):
  match value:
    case (m, TagData{label, tag}): (p, (m, label ++ ":" ++ U32.show(x) ++ ":" ++ S.tag_show(tag) ++ ";"))
def read_position(-P: Type, -M: Type, value: P & U32, aux: M & TagData) -> P & (M & String):
  match value:
    case (p, x): read_aux(P, M, p, x, aux)
def read(-P: Type, -M: Type, get: P -> S.MotionToken -> P & U32, aux: M -> M & TagData, label: String, p: P, m: M) -> P & (M & String):
  read_position(P, M, get(p, S.Position{}), aux(m))

type Handle<-Schema: Data> is Data:
  Handle{world: U32, slot: U32}
type Factory is Type:
  Factory{next: U32}
type Command is Data:
  Spawn{slot: U32, label: String, x: U32}
  Insert{slot: U32}
  Remove{slot: U32}
  Despawn{slot: U32}
type World<-Schema: Data> is Type:
  World{id: U32, next: U32, rows: A.World<Schema, TagCell>, pending: List<Command>}

def create_available(~Schema: Data, ok: Bool, +n: U32) -> Factory & Maybe<&1, World<Schema>>:
  match ok:
    case False{}: (Factory{n}, None{})
    case True{}: (Factory{(n + 1 : U32)}, Some{World{n, 0, A.World{[]}, []}})
def create(~Schema: Data, f: Factory) -> Factory & Maybe<&1, World<Schema>>:
  match f:
    case Factory{+n}: create_available(~Schema, U32.is_lt(n, 4294967295), n)
def reserve_available(~Schema: Data, ok: Bool, +id: U32, +next: U32, rows: A.World<Schema, TagCell>, pending: List<Command>, label: String, x: U32) -> World<Schema> & Maybe<&2, Handle<Schema>>:
  match ok:
    case False{}: (World{id, next, rows, pending}, None{})
    case True{}: (World{id, (next + 1 : U32), rows, Spawn{next, label, x} <> pending}, Some{Handle{id, next}})
def reserve(~Schema: Data, w: World<Schema>, label: String, x: U32) -> World<Schema> & Maybe<&2, Handle<Schema>>:
  match w:
    case World{+id, +next, rows, pending}: reserve_available(~Schema, U32.is_lt(next, 4294967295), id, next, rows, pending, label, x)
def enqueue_if(~Schema: Data, ok: Bool, id: U32, next: U32, rows: A.World<Schema, TagCell>, pending: List<Command>, command: Command) -> World<Schema>:
  match ok:
    case False{}: World{id, next, rows, pending}
    case True{}: World{id, next, rows, command <> pending}
def enqueue(~Schema: Data, w: World<Schema>, h: Handle<Schema>, command: Command) -> World<Schema>:
  match w h:
    case World{+id, next, rows, pending} Handle{world, _}: enqueue_if(~Schema, U32.is_eq(id, world), id, next, rows, pending, command)
def insert(~Schema: Data, w: World<Schema>, h: Handle<Schema>) -> World<Schema>:
  match h:
    case Handle{+id, +slot}: enqueue(~Schema, w, Handle{id, slot}, Insert{slot})
def remove(~Schema: Data, w: World<Schema>, h: Handle<Schema>) -> World<Schema>:
  match h:
    case Handle{+id, +slot}: enqueue(~Schema, w, Handle{id, slot}, Remove{slot})
def despawn(~Schema: Data, w: World<Schema>, h: Handle<Schema>) -> World<Schema>:
  match h:
    case Handle{+id, +slot}: enqueue(~Schema, w, Handle{id, slot}, Despawn{slot})
def modify_row(~Schema: Data, equal: Bool, mode: U32, row: A.Row<Schema, TagCell>, tail: List<A.Row<Schema, TagCell>>) -> List<A.Row<Schema, TagCell>>:
  match equal mode row:
    case False{} _ r: r <> tail
    case True{} 0 A.Row{label, cell, tag}: A.Row{label, cell, tag_set(tag, Some{S.Tag{}})} <> tail
    case True{} 1 A.Row{label, cell, tag}: A.Row{label, cell, tag_set(tag, None{})} <> tail
    case True{} _ _: tail
def modify_rows(~Schema: Data, +label: String, +mode: U32, rows: List<A.Row<Schema, TagCell>>) -> List<A.Row<Schema, TagCell>>:
  match rows:
    case Nil{}: []
    case Con{A.Row{+name, cell, tag}, tail}: modify_row(~Schema, String.eq(label, name), mode, A.Row{name, cell, tag}, modify_rows(~Schema, label, mode, tail))
def modify_world(~Schema: Data, label: String, mode: U32, rows: A.World<Schema, TagCell>) -> A.World<Schema, TagCell>:
  match rows:
    case A.World{rows}: A.World{modify_rows(~Schema, label, mode, rows)}
def append_spawn(~Schema: Data, slot: U32, label: String, x: U32, w: A.World<Schema, TagCell>) -> A.World<Schema, TagCell>:
  match w:
    case A.World{rows}: A.World{List.append(&1, A.Row<Schema, TagCell>, rows, [A.Row{U32.show(slot), A.Cell{x}, TagCell{label, None{}}}])}
def apply_found(~Schema: Data, mode: U32, slot: U32, rows: A.World<Schema, TagCell>) -> A.World<Schema, TagCell>:
  modify_world(~Schema, U32.show(slot), mode, rows)
def apply_one(~Schema: Data, cmd: Command, rows: A.World<Schema, TagCell>) -> A.World<Schema, TagCell>:
  match cmd:
    case Spawn{slot, label, x}: append_spawn(~Schema, slot, label, x, rows)
    case Insert{slot}: apply_found(~Schema, 0, slot, rows)
    case Remove{slot}: apply_found(~Schema, 1, slot, rows)
    case Despawn{slot}: apply_found(~Schema, 2, slot, rows)
def apply_commands(~Schema: Data, commands: List<Command>, rows: A.World<Schema, TagCell>) -> A.World<Schema, TagCell>:
  match commands:
    case Nil{}: rows
    case Con{cmd, tail}: apply_commands(~Schema, tail, apply_one(~Schema, cmd, rows))
def flush(~Schema: Data, w: World<Schema>) -> World<Schema>:
  match w:
    case World{id, next, rows, pending}: World{id, next, apply_commands(~Schema, List.reverse(&1, Command, pending), rows), []}
# An empty schedule deliberately preserves the complete pending queue.
def tick(~Schema: Data, w: World<Schema>) -> World<Schema>:
  w

def query_restore(id: U32, next: U32, pending: List<Command>, result: A.World<S.MotionToken, TagCell> & String) -> World<S.MotionToken> & String:
  match result:
    case (rows, text): (World{id, next, rows, pending}, text)
def query(selection: A.Selection, w: World<S.MotionToken>) -> World<S.MotionToken> & String:
  match w:
    case World{id, next, rows, pending}: query_restore(id, next, pending, A.query(~S.MotionToken, ~TagCell, ~TagData, ~read, ~tag_get, ~tag_has, selection, rows))
def lookup_restore(id: U32, next: U32, pending: List<Command>, result: A.World<S.MotionToken, TagCell> & A.LookupResult) -> World<S.MotionToken> & A.LookupResult:
  match result:
    case (rows, result): (World{id, next, rows, pending}, result)
def lookup_identity(ok: Bool, selection: A.Selection, id: U32, next: U32, rows: A.World<S.MotionToken, TagCell>, pending: List<Command>, slot: U32) -> World<S.MotionToken> & A.LookupResult:
  match ok:
    case False{}: (World{id, next, rows, pending}, A.MissingEntity{})
    case True{}: lookup_restore(id, next, pending, A.lookup(~S.MotionToken, ~TagCell, ~TagData, ~read, ~tag_get, ~tag_has, selection, U32.show(slot), rows))
def lookup(selection: A.Selection, w: World<S.MotionToken>, h: Handle<S.MotionToken>) -> World<S.MotionToken> & A.LookupResult:
  match w h:
    case World{+id, next, rows, pending} Handle{world, slot}: lookup_identity(U32.is_eq(id, world), selection, id, next, rows, pending, slot)
