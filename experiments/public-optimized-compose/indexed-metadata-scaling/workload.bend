import Base
import ../../../src/ecs/lifecycle.bend as L

# Shared operation algorithm; providers differ only in owned metadata representation.
type Observation is Data:
  Observation{phase:U32,id:U32,added:U32,changed:U32}
type Trace<-M:Type> is Type:
  Trace{metadata:M,observations:List<&2,Observation>}

def record(~M:Type,+phase:U32,+id:U32,points:List<&2,Observation>,observed:M & L.Stamp) -> Trace<M>:
  match observed:
    case (metadata,L.Stamp{a,c}): Trace{metadata,Observation{phase,id,a,c} <> points}

def read(~M:Type,~get:M -> U32 -> M & L.Stamp,phase:U32,+id:U32,trace:Trace<M>) -> Trace<M>:
  match trace:
    case Trace{metadata,points}: record(~M,phase,id,points,get(metadata,id))

def seed(~M:Type,~set:M -> U32 -> L.Stamp -> M,fuel:Nat,+id:U32,metadata:M) -> M:
  match fuel:
    case 0n: metadata
    case 1n+more: seed(~M,~set,more,U32.add(id,1),set(metadata,id,L.Stamp{id,U32.add(id,1)}))

def all_read(~M:Type,~get:M -> U32 -> M & L.Stamp,fuel:Nat,+id:U32,+phase:U32,trace:Trace<M>) -> Trace<M>:
  match fuel:
    case 0n: trace
    case 1n+more: all_read(~M,~get,more,U32.add(id,1),phase,read(~M,~get,phase,id,trace))

def restore_then_read(~M:Type,~get:M -> U32 -> M & L.Stamp,~set:M -> U32 -> L.Stamp -> M,+id:U32,saved:L.Stamp,trace:Trace<M>) -> Trace<M>:
  match trace:
    case Trace{metadata,points}: read(~M,~get,6,id,Trace{set(metadata,id,saved),points})

def cleared_then_restore(~M:Type,~get:M -> U32 -> M & L.Stamp,~set:M -> U32 -> L.Stamp -> M,~clear:M -> U32 -> M,+id:U32,saved:L.Stamp,trace:Trace<M>) -> Trace<M>:
  match trace:
    case Trace{metadata,points}: restore_then_read(~M,~get,~set,id,saved,read(~M,~get,5,id,Trace{clear(metadata,id),points}))

def second_write(~M:Type,~get:M -> U32 -> M & L.Stamp,~set:M -> U32 -> L.Stamp -> M,~clear:M -> U32 -> M,+id:U32,+saved:L.Stamp,trace:Trace<M>) -> Trace<M>:
  match saved trace:
    case L.Stamp{+a,c} Trace{metadata,points}: cleared_then_restore(~M,~get,~set,~clear,id,saved,read(~M,~get,4,id,Trace{set(metadata,id,L.Stamp{a,U32.add(c,2000)}),points}))

def first_write(~M:Type,~get:M -> U32 -> M & L.Stamp,~set:M -> U32 -> L.Stamp -> M,~clear:M -> U32 -> M,+id:U32,+saved:L.Stamp,metadata:M,points:List<&2,Observation>) -> Trace<M>:
  match saved:
    case L.Stamp{+a,c}: second_write(~M,~get,~set,~clear,id,saved,read(~M,~get,3,id,Trace{set(metadata,id,L.Stamp{a,U32.add(c,1000)}),points}))

def saved_write(~M:Type,~get:M -> U32 -> M & L.Stamp,~set:M -> U32 -> L.Stamp -> M,~clear:M -> U32 -> M,+id:U32,points:List<&2,Observation>,observed:M & L.Stamp) -> Trace<M>:
  match observed:
    case (metadata,L.Stamp{+a,+c}): first_write(~M,~get,~set,~clear,id,L.Stamp{a,c},metadata,Observation{1,id,a,c} <> points)

def one_update(~M:Type,~get:M -> U32 -> M & L.Stamp,~set:M -> U32 -> L.Stamp -> M,~clear:M -> U32 -> M,+id:U32,trace:Trace<M>) -> Trace<M>:
  match trace:
    case Trace{metadata,points}: saved_write(~M,~get,~set,~clear,id,points,get(metadata,id))

def updates(~M:Type,~get:M -> U32 -> M & L.Stamp,~set:M -> U32 -> L.Stamp -> M,~clear:M -> U32 -> M,fuel:Nat,+id:U32,trace:Trace<M>) -> Trace<M>:
  match fuel:
    case 0n: trace
    case 1n+more: updates(~M,~get,~set,~clear,more,U32.add(id,1),one_update(~M,~get,~set,~clear,id,trace))

def special_clear(~M:Type,~get:M -> U32 -> M & L.Stamp,~clear:M -> U32 -> M,+id:U32,trace:Trace<M>) -> Trace<M>:
  match trace:
    case Trace{metadata,points}: read(~M,~get,10,id,Trace{clear(metadata,id),points})

def special_written(~M:Type,~get:M -> U32 -> M & L.Stamp,~set:M -> U32 -> L.Stamp -> M,~clear:M -> U32 -> M,+id:U32,trace:Trace<M>) -> Trace<M>:
  match trace:
    case Trace{metadata,points}: special_clear(~M,~get,~clear,id,read(~M,~get,9,id,Trace{set(metadata,id,L.Stamp{0,77}),points}))

def special(~M:Type,~get:M -> U32 -> M & L.Stamp,~set:M -> U32 -> L.Stamp -> M,~clear:M -> U32 -> M,+id:U32,trace:Trace<M>) -> Trace<M>:
  special_written(~M,~get,~set,~clear,id,read(~M,~get,8,id,trace))

def specials(~M:Type,~get:M -> U32 -> M & L.Stamp,~set:M -> U32 -> L.Stamp -> M,~clear:M -> U32 -> M,ids:List<&2,U32>,trace:Trace<M>) -> Trace<M>:
  match ids:
    case []: trace
    case id <> more: specials(~M,~get,~set,~clear,more,special(~M,~get,~set,~clear,id,trace))

def finish_sparse(~M:Type,~get:M -> U32 -> M & L.Stamp,~set:M -> U32 -> L.Stamp -> M,~clear:M -> U32 -> M,+size:U32,trace:Trace<M>) -> Trace<M>:
  all_read(~M,~get,U32.to_nat(size),1,11,specials(~M,~get,~set,~clear,[0,U32.add(size,1),65536,131072,131073,4294967295],trace))

def run(~M:Type,~get:M -> U32 -> M & L.Stamp,~set:M -> U32 -> L.Stamp -> M,~clear:M -> U32 -> M,+size:U32,metadata:M) -> Trace<M>:
  finish_sparse(~M,~get,~set,~clear,size,all_read(~M,~get,U32.to_nat(size),1,7,updates(~M,~get,~set,~clear,U32.to_nat(size),1,all_read(~M,~get,U32.to_nat(size),1,2,Trace{seed(~M,~set,U32.to_nat(size),1,metadata),[]}))))

def run_dense(~M:Type,~get:M -> U32 -> M & L.Stamp,~set:M -> U32 -> L.Stamp -> M,~clear:M -> U32 -> M,+size:U32,metadata:M) -> Trace<M>:
  all_read(~M,~get,U32.to_nat(size),1,11,all_read(~M,~get,U32.to_nat(size),1,7,updates(~M,~get,~set,~clear,U32.to_nat(size),1,all_read(~M,~get,U32.to_nat(size),1,2,Trace{seed(~M,~set,U32.to_nat(size),1,metadata),[]}))))

def observation_show(point:Observation) -> String:
  match point:
    case Observation{p,id,a,c}: "[" ++ U32.show(p) ++ "," ++ U32.show(id) ++ "," ++ U32.show(a) ++ "," ++ U32.show(c) ++ "]"

def render_fragment(point:Observation,first:Bool,suffix:String) -> String:
  match first:
    case True{}: observation_show(point) ++ suffix
    case False{}: observation_show(point) ++ ", " ++ suffix

# Points are stored newest first. Prepend each bounded row to the suffix;
# append never receives the growing output as its left operand.
def render_reverse(points:List<&2,Observation>,first:Bool,suffix:String) -> String:
  match points:
    case []: "[" ++ suffix
    case point <> more: render_reverse(more,False{},render_fragment(point,first,suffix))

def render(~M:Type,trace:Trace<M>) -> String:
  match trace:
    case Trace{_,points}: render_reverse(points,True{},"]")
