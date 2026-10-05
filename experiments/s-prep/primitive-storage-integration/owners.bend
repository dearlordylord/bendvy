import Base

def vacant(+depth: Nat) -> Array<Maybe<U32>>:
  match depth:
    case 0n: ALeaf{None{}}
    case 1n+d: ANode{vacant(d), vacant(d)}
def empty(~M: Type, +depth: Nat) -> Array<Maybe<M>>:
  match depth:
    case 0n: ALeaf{None{}}
    case 1n+d: ANode{empty(~M, d), empty(~M, d)}
def insert_done(~M: Type, r: Array<Maybe<M>> & Maybe<M>) -> Array<Maybe<M>>:
  match r:
    case (col, _): col
def returned(~M: Type, slot: U32, col: Array<Maybe<M>>, r: M & String) -> Array<Maybe<M>> & String:
  match r:
    case (m, text): (insert_done(~M, Array.swap(Maybe<M>, col, slot, Some{m})), text)
def taken(~M: Type, ~f: @-P: Type -> (P -> P & String) -> P -> P & String, observe: M -> M & String, slot: U32, r: Array<Maybe<M>> & Maybe<M>) -> Array<Maybe<M>> & String:
  match r:
    case (col, None{}): (col, "missing")
    case (col, Some{m}): returned(~M, slot, col, f(M, observe, m))
def checked(~M: Type, ~f: @-P: Type -> (P -> P & String) -> P -> P & String, observe: M -> M & String, valid: Bool, +slot: U32, col: Array<Maybe<M>>) -> Array<Maybe<M>> & String:
  match valid:
    case False{}: (col, "rejected")
    case True{}: taken(~M, ~f, observe, slot, Array.swap(Maybe<M>, col, slot, None{}))
def access(~M: Type, ~f: @-P: Type -> (P -> P & String) -> P -> P & String, observe: M -> M & String, +namespace: U32, +slot: U32, +capacity: U32, col: Array<Maybe<M>>) -> Array<Maybe<M>> & String:
  checked(~M, ~f, observe, Bool.and(U32.is_eq(namespace, 7), (slot < capacity : U32)), slot, col)
def callback(~P: Type, get: P -> P & String, p: P) -> P & String:
  get(p)

type Motion is Type:
  Motion{items: Array<U32>, scalar: U32}
def motion_o3(s: U32, text: String, r: Array<U32> & U32) -> Motion & String:
  match r:
    case (a, x): (Motion{a, s}, text ++ U32.show(x))
def motion_o2(s: U32, text: String, r: Array<U32> & U32) -> Motion & String:
  match r:
    case (a, x): motion_o3(s, text ++ U32.show(x) ++ ",", Array.get(U32, a, 3))
def motion_o1(s: U32, text: String, r: Array<U32> & U32) -> Motion & String:
  match r:
    case (a, x): motion_o2(s, text ++ U32.show(x) ++ ",", Array.get(U32, a, 2))
def motion_o0(s: U32, text: String, r: Array<U32> & U32) -> Motion & String:
  match r:
    case (a, x): motion_o1(s, text ++ U32.show(x) ++ ",", Array.get(U32, a, 1))
def motion_observe(m: Motion) -> Motion & String:
  match m:
    case Motion{a, +s}: motion_o0(s, U32.show(s) ++ ":", Array.get(U32, a, 0))
def motion_set(m: Motion, +v: U32) -> Motion:
  match m:
    case Motion{a, _}: Motion{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, a, 0, v), 1, v), 2, v), 3, v), v}
def motion_restore(m: Motion, a: U32, b: U32, c: U32, d: U32, s: U32) -> Motion:
  match m:
    case Motion{items, _}: Motion{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, items, 0, a), 1, b), 2, c), 3, d), s}
def motion_roundtrip(m: Motion) -> Motion & String:
  match m:
    case Motion{ANode{ANode{ALeaf{+a}, ALeaf{+b}}, ANode{ALeaf{+c}, ALeaf{+d}}}, +s}:
      motion_observe(motion_restore(motion_set(motion_set(motion_set(Motion{ANode{ANode{ALeaf{a}, ALeaf{b}}, ANode{ALeaf{c}, ALeaf{d}}}, s}, 19), 23), 19), a, b, c, d, s))
    case m: motion_observe(m)

type Health is Type:
  Health{items: Array<U32>, scalar: U32}
def health_o3(s: U32, text: String, r: Array<U32> & U32) -> Health & String:
  match r:
    case (a, x): (Health{a, s}, text ++ U32.show(x))
def health_o2(s: U32, text: String, r: Array<U32> & U32) -> Health & String:
  match r:
    case (a, x): health_o3(s, text ++ U32.show(x) ++ ",", Array.get(U32, a, 3))
def health_o1(s: U32, text: String, r: Array<U32> & U32) -> Health & String:
  match r:
    case (a, x): health_o2(s, text ++ U32.show(x) ++ ",", Array.get(U32, a, 2))
def health_o0(s: U32, text: String, r: Array<U32> & U32) -> Health & String:
  match r:
    case (a, x): health_o1(s, text ++ U32.show(x) ++ ",", Array.get(U32, a, 1))
def health_observe(m: Health) -> Health & String:
  match m:
    case Health{a, +s}: health_o0(s, U32.show(s) ++ ":", Array.get(U32, a, 0))
def health_set(m: Health, +v: U32) -> Health:
  match m:
    case Health{a, _}: Health{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, a, 0, v), 1, v), 2, v), 3, v), v}
def health_restore(m: Health, a: U32, b: U32, c: U32, d: U32, s: U32) -> Health:
  match m:
    case Health{items, _}: Health{Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, items, 0, a), 1, b), 2, c), 3, d), s}
def health_roundtrip(m: Health) -> Health & String:
  match m:
    case Health{ANode{ANode{ALeaf{+a}, ALeaf{+b}}, ANode{ALeaf{+c}, ALeaf{+d}}}, +s}:
      health_observe(health_restore(health_set(health_set(health_set(Health{ANode{ANode{ALeaf{a}, ALeaf{b}}, ANode{ALeaf{c}, ALeaf{d}}}, s}, 19), 23), 19), a, b, c, d, s))
    case m: health_observe(m)

def snap_leaf(~M: Type, r: M & String) -> Array<Maybe<M>> & String:
  match r:
    case (m, text): (ALeaf{Some{m}}, text)
def snap_join(~M: Type, both: (Array<Maybe<M>> & String) & (Array<Maybe<M>> & String)) -> Array<Maybe<M>> & String:
  match both:
    case ((l, lt), (r, rt)): (ANode{l, r}, lt ++ ";" ++ rt)
def snapshot(~M: Type, ~observe: M -> M & String, col: Array<Maybe<M>>) -> Array<Maybe<M>> & String:
  match col:
    case ALeaf{None{}}: (ALeaf{None{}}, "none")
    case ALeaf{Some{m}}: snap_leaf(~M, observe(m))
    case ANode{l, r}: snap_join(~M, (snapshot(~M, ~observe, l), snapshot(~M, ~observe, r)))
def queue_join(both: (Motion & String) & (List<Motion> & String)) -> List<Motion> & String:
  match both:
    case ((m, text), (tail, rest)): (m <> tail, text ++ ";" ++ rest)
def queue_snapshot(q: List<Motion>) -> List<Motion> & String:
  match q:
    case Nil{}: ([], "end")
    case Con{m, tail}: queue_join((motion_observe(m), queue_snapshot(tail)))
type Placement is Type:
  Placement{main: Array<Maybe<Motion>>, aux: Array<Maybe<Health>>, meta: Array<U32>, incoming: Motion, incoming_aux: Health, pending: List<Motion>}
def preflight_decide(valid: Bool, p: Placement) -> Placement & String:
  match valid:
    case False{}: (p, "unsupported")
    case True{}: (p, "supported-canary-only")
def preflight(+namespace: U32, +id: U32, p: Placement) -> Placement & String:
  preflight_decide(Bool.and(U32.is_eq(namespace, 7), Bool.and((0 < id : U32), (id <= 16 : U32))), p)
def placement_snapshot_done(meta: Array<U32>, both: (Array<Maybe<Motion>> & String) & ((Array<Maybe<Health>> & String) & ((Motion & String) & ((Health & String) & (List<Motion> & String))))) -> Placement & String:
  match both:
    case ((main, mt), ((aux, at), ((incoming, it), ((incoming_aux, iat), (pending, pt))))): (Placement{main, aux, meta, incoming, incoming_aux, pending}, mt ++ "|" ++ at ++ "|" ++ it ++ "|" ++ iat ++ "|" ++ pt)
def placement_snapshot(p: Placement) -> Placement & String:
  match p:
    case Placement{main, aux, meta, incoming, incoming_aux, pending}: placement_snapshot_done(meta, (snapshot(~Motion, ~motion_observe, main), (snapshot(~Health, ~health_observe, aux), (motion_observe(incoming), (health_observe(incoming_aux), queue_snapshot(pending))))))
def lookup_state(live: U32, present: Bool) -> String:
  match live present:
    case 0 _: "MissingEntity"
    case _ False{}: "MissingComponent"
    case _ True{}: "Matched"
def metadata_join(both: (Array<U32> & String) & (Array<U32> & String)) -> Array<U32> & String:
  match both:
    case ((l, lt), (r, rt)): (ANode{l, r}, lt ++ "," ++ rt)
def metadata_observe(meta: Array<U32>) -> Array<U32> & String:
  match meta:
    case ALeaf{+v}: (ALeaf{v}, U32.show(v))
    case ANode{l, r}: metadata_join((metadata_observe(l), metadata_observe(r)))
def placement_meta_done(main: Array<Maybe<Motion>>, aux: Array<Maybe<Health>>, incoming: Motion, incoming_aux: Health, pending: List<Motion>, text: String, r: Array<U32> & String) -> Placement & String:
  match r:
    case (meta, mt): (Placement{main, aux, meta, incoming, incoming_aux, pending}, text ++ "|meta=" ++ mt)
def placement_meta(r: Placement & String) -> Placement & String:
  match r:
    case (Placement{main, aux, meta, incoming, incoming_aux, pending}, text): placement_meta_done(main, aux, incoming, incoming_aux, pending, text, metadata_observe(meta))
