import Base
import ./owned.bend as A

type Store is Type:
  Store{cells: List<A.Cell<A.Motion>>}
def initial() -> Store:
  Store{[A.Cell{A.Payload{[10 : U32^2n]}, []}, A.Cell{A.Payload{[20 : U32^2n]}, []}]}
def restored(success: Bool, tail: List<A.Cell<A.Motion>>, result: A.Cell<A.Motion> & String) -> Store & String:
  match result:
    case (cell, text): (Store{A.finish_cell(~A.Motion, success, cell) <> tail}, text)
def writable(~callback: @-P: Type -> (P -> A.Motion -> P & U32) -> (P -> A.Motion -> U32 -> P) -> (P -> A.Motion -> U32 -> P) -> (P -> A.Motion -> P & U32) -> P -> P & String, success: Bool, s: Store) -> Store & String:
  match s:
    case Store{Nil{}}: (Store{[]}, "MissingEntity")
    case Store{Con{cell, tail}}: restored(success, tail, callback(A.Cell<A.Motion>, A.get(~A.Motion), A.set(~A.Motion), A.set(~A.Motion), A.get(~A.Motion), cell))
def commit_second(first: A.Cell<A.Motion>, tail: List<A.Cell<A.Motion>>, result: A.Cell<A.Motion> & String) -> Store:
  match result:
    case (second, _): Store{first <> A.finish_cell(~A.Motion, True{}, second) <> tail}
def prepare(~callback: @-P: Type -> (P -> A.Motion -> P & U32) -> (P -> A.Motion -> U32 -> P) -> (P -> A.Motion -> U32 -> P) -> (P -> A.Motion -> P & U32) -> P -> P & String, s: Store) -> Store:
  match s:
    case Store{Con{first, Con{second, tail}}}: commit_second(first, tail, callback(A.Cell<A.Motion>, A.get(~A.Motion), A.set(~A.Motion), A.set(~A.Motion), A.get(~A.Motion), second))
    case s: s
