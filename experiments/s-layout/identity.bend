import Base
import ./core.bend as B
import ./seams.bend as S
import ../t08/core.bend as C
import ../t05/lifecycle.bend as L

type World<-Schema: Data> is Type:
  World{namespace: U32, next: U32, store: B.World}
def created(~Schema: Data, capacity: U32, result: L.Factory & Maybe<L.World<Schema>>) -> L.Factory & Maybe<World<Schema>>:
  match result:
    case (f, None{}): (f, None{})
    case (f, Some{L.World{id, _, _, _}}): (f, Some{World{id, 0, S.empty(capacity)}})
def create(~Schema: Data, capacity: U32, f: L.Factory) -> L.Factory & Maybe<World<Schema>>:
  created(~Schema, capacity, L.create(~Schema, f))
def reserved(~Schema: Data, valid: Bool, +namespace: U32, +next: U32, store: B.World, value: U32) -> World<Schema> & Maybe<&2, L.Handle<Schema>>:
  match valid:
    case False{}: (World{namespace, next, store}, None{})
    case True{}: (World{namespace, (next + 1 : U32), B.queue([C.Spawn{next, value}], store)}, Some{L.Handle{namespace, next}})
def reserve(~Schema: Data, value: U32, w: World<Schema>) -> World<Schema> & Maybe<&2, L.Handle<Schema>>:
  match w:
    case World{namespace, +next, B.World{+limit, rows, members, meta}}: reserved(~Schema, Bool.and((next < limit : U32), (next < 4294967295 : U32)), namespace, next, B.World{limit, rows, members, meta}, value)
def flush(~Schema: Data, w: World<Schema>) -> World<Schema>:
  match w:
    case World{namespace, next, store}: World{namespace, next, B.flush(store)}
def tick(~Schema: Data, w: World<Schema>) -> World<Schema>:
  w
def lookup_value(live: Bool, value: Maybe<&2, U32>) -> String:
  match live value:
    case False{} _: "MissingEntity"
    case True{} None{}: "QueryMismatch"
    case True{} Some{x}: "Matched:" ++ U32.show(x)
def lookup_row(~Schema: Data, namespace: U32, next: U32, limit: U32, members: List<&2, U32>, meta: C.World, +id: U32, result: Array<C.Row> & C.Row) -> World<Schema> & String:
  match result:
    case (rows, C.Row{key, value, _, _}): (World{namespace, next, B.World{limit, rows, members, meta}}, lookup_value(U32.is_eq(key, id), value))
def lookup_valid(~Schema: Data, valid: Bool, +id: U32, w: World<Schema>) -> World<Schema> & String:
  match valid w:
    case False{} w: (w, "MissingEntity")
    case True{} World{namespace, next, B.World{+limit, rows, members, meta}}: lookup_row(~Schema, namespace, next, limit, members, meta, id, B.get(limit, rows, id))
def lookup(~Schema: Data, w: World<Schema>, handle: L.Handle<Schema>) -> World<Schema> & String:
  match w handle:
    case World{+namespace, next, B.World{+limit, rows, members, meta}} L.Handle{foreign, +id}: lookup_valid(~Schema, Bool.and(U32.is_eq(namespace, foreign), (id < limit : U32)), id, World{namespace, next, B.World{limit, rows, members, meta}})
def command(mode: U32, id: U32, value: U32) -> C.Command:
  match mode:
    case 0: C.Insert{id, value}
    case 1: C.Remove{id}
    case _: C.Despawn{id}
def queue_valid(~Schema: Data, valid: Bool, id: U32, mode: U32, value: U32, w: World<Schema>) -> World<Schema>:
  match valid w:
    case False{} w: w
    case True{} World{namespace, next, store}: World{namespace, next, B.queue([command(mode, id, value)], store)}
def enqueue(~Schema: Data, +mode: U32, value: U32, w: World<Schema>, handle: L.Handle<Schema>) -> World<Schema>:
  match w handle:
    case World{+namespace, next, store} L.Handle{foreign, id}: queue_valid(~Schema, U32.is_eq(namespace, foreign), id, mode, value, World{namespace, next, store})
