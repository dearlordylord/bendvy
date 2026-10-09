import Base

# K is the closed declaration's finite token type. S prevents cross-schema reuse.
type Requirements<S: Data,K: Data> is Data:
  Requirements{tokens: List<&2,K>}

def contains_step(~K: Data,found: Bool,tail: Bool) -> Bool:
  Bool.or(found,tail)
def contains(~K: Data,~same: K -> K -> Bool,+key: K,items: List<&2,K>) -> Bool:
  match items:
    case Nil{}: False{}
    case Con{head,rest}: contains_step(~K,same(key,head),contains(~K,~same,key,rest))
def add_checked(~K: Data,exists: Bool,key: K,items: List<&2,K>) -> List<&2,K>:
  match exists:
    case True{}: items
    case False{}: List.append(&2,K,items,[key])
def merge(~K: Data,~same: K -> K -> Bool,remaining: List<&2,K>,+items: List<&2,K>) -> List<&2,K>:
  match remaining:
    case Nil{}: items
    case Con{+key,rest}: merge(~K,~same,rest,add_checked(~K,contains(~K,~same,key,items),key,items))
def union(~S: Data,~K: Data,~same: K -> K -> Bool,left: Requirements<S,K>,right: Requirements<S,K>) -> Requirements<S,K>:
  match left right:
    case Requirements{left},Requirements{right}: Requirements{merge(~K,~same,right,merge(~K,~same,left,[]))}

def absent_checked(~K: Data,present: Bool,key: K,tail: List<&2,K>) -> List<&2,K>:
  match present:
    case True{}: tail
    case False{}: key <> tail
def absent(~K: Data,~Env: Data,~present: K -> Env -> Bool,tokens: List<&2,K>,+env: Env) -> List<&2,K>:
  match tokens:
    case Nil{}: []
    case Con{+key,rest}: absent_checked(~K,present(key,env),key,absent(~K,~Env,~present,rest,env))

type Checked<S: Data,K: Data,H: Type,W: Type> is Type:
  Ready{owners: H,world: W}
  Missing{owners: H,world: W,tokens: List<&2,K>}
def checked(~S: Data,~K: Data,~H: Type,~W: Type,owners: H,world: W,missing: List<&2,K>) -> Checked<S,K,H,W>:
  match missing:
    case Nil{}: Ready{owners,world}
    case missing: Missing{owners,world,missing}
def inspected(~S: Data,~K: Data,~Env: Data,~H: Type,~W: Type,
  ~present: K -> Env -> Bool,owners: H,needs: Requirements<S,K>,pair: W & Env) -> Checked<S,K,H,W>:
  match needs pair:
    case Requirements{tokens},(world,env): checked(~S,~K,~H,~W,owners,world,absent(~K,~Env,~present,tokens,env))
def preflight(~S: Data,~K: Data,~Env: Data,~H: Type,~W: Type,
  ~inspect: W -> W & Env,~present: K -> Env -> Bool,
  needs: Requirements<S,K>,owners: H,world: W) -> Checked<S,K,H,W>:
  inspected(~S,~K,~Env,~H,~W,~present,owners,needs,inspect(world))
