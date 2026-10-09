import Base

# Generic affine owner catalog, independent of machine or reader count.
type Entry<H: Type> is Type:
  Entry{key: U32,owner: H}
type Selected<H: Type> is Type:
  Selected{owner: Maybe<&1,H>,rest: List<&1,Entry<H>>}

def restore(~H: Type,key: U32,owner: Maybe<&1,H>,rest: List<&1,Entry<H>>) -> List<&1,Entry<H>>:
  match owner:
    case None{}: rest
    case Some{owner}: Entry{key,owner} <> rest
def choose(~H: Type,same: Bool,entry: Entry<H>,tail: Selected<H>) -> Selected<H>:
  match same entry tail:
    case True{}, Entry{key,owner}, Selected{other,rest}: Selected{Some{owner},restore(~H,key,other,rest)}
    case False{}, entry, Selected{owner,rest}: Selected{owner,entry <> rest}
def take(~H: Type,entries: List<&1,Entry<H>>,+key: U32) -> Selected<H>:
  match entries:
    case Nil{}: Selected{None{},[]}
    case Con{Entry{+actual,owner},rest}: choose(~H,U32.is_eq(actual,key),Entry{actual,owner},take(~H,rest,key))
