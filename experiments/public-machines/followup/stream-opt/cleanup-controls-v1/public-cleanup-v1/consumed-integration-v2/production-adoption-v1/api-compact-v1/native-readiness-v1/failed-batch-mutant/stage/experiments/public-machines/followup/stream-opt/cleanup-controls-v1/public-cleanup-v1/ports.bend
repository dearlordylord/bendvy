import Base
import /workspace/formal-proofs/bendvy/src/ecs/machine-stream.bend as St

# Schema-authored heterogeneous products, outside the generic kernel.
type Two<S: Data,A: Data,B: Data> is Type:
  Two{a: St.Reader<S,A>,b: St.Reader<S,B>}
type Three<S: Data,A: Data,B: Data,C: Data> is Type:
  Three{a: St.Reader<S,A>,b: St.Reader<S,B>,c: St.Reader<S,C>}

def validate_two(~S: Data,~A: Data,~B: Data,ports: Two<S,A,B>,+namespace: U32,+id: U32) -> Two<S,A,B> & Bool:
  match ports:
    case Two{St.Reader{+a,+ai},St.Reader{+b,+bi}}:
      (Two{St.Reader{a,ai},St.Reader{b,bi}},Bool.and(Bool.and(U32.is_eq(a,namespace),U32.is_eq(ai,id)),Bool.and(U32.is_eq(b,namespace),U32.is_eq(bi,id))))

def validate_three(~S: Data,~A: Data,~B: Data,~C: Data,ports: Three<S,A,B,C>,+namespace: U32,+id: U32) -> Three<S,A,B,C> & Bool:
  match ports:
    case Three{St.Reader{+a,+ai},St.Reader{+b,+bi},St.Reader{+c,+ci}}:
      (Three{St.Reader{a,ai},St.Reader{b,bi},St.Reader{c,ci}},Bool.and(Bool.and(U32.is_eq(a,namespace),U32.is_eq(ai,id)),Bool.and(Bool.and(U32.is_eq(b,namespace),U32.is_eq(bi,id)),Bool.and(U32.is_eq(c,namespace),U32.is_eq(ci,id)))))

def remove_two(~World: Type,~S: Data,~A: Data,~B: Data,~removeA: World -> St.Reader<S,A> -> World,~removeB: World -> St.Reader<S,B> -> World,world: World,ports: Two<S,A,B>) -> World:
  match ports:
    case Two{a,b}: removeB(removeA(world,a),b)

def remove_three(~World: Type,~S: Data,~A: Data,~B: Data,~C: Data,~removeA: World -> St.Reader<S,A> -> World,~removeB: World -> St.Reader<S,B> -> World,~removeC: World -> St.Reader<S,C> -> World,world: World,ports: Three<S,A,B,C>) -> World:
  match ports:
    case Three{a,b,c}: removeC(removeB(removeA(world,a),b),c)
