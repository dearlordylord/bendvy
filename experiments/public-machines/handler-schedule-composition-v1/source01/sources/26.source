import Base

# Atom is the caller's schema-bound heterogeneous condition shape. Env is only
# captured machine metadata; the world and its component owners remain Type.
type Tree<Atom: Data> is Data:
  Leaf{atom: Atom}
  Constant{value: Bool}
  Negate{inner: Tree<Atom>}
  Both{left: Tree<Atom>,right: Tree<Atom>}
  Either{left: Tree<Atom>,right: Tree<Atom>}

def all(~Atom: Data,items: List<&2,Tree<Atom>>) -> Tree<Atom>:
  match items:
    case Nil{}: Constant{True{}}
    case Con{head,tail}: Both{head,all(~Atom,tail)}
def any(~Atom: Data,items: List<&2,Tree<Atom>>) -> Tree<Atom>:
  match items:
    case Nil{}: Constant{False{}}
    case Con{head,tail}: Either{head,any(~Atom,tail)}

def both_next(~Env: Data,first: Bool,env: Env,next: Env -> Bool) -> Bool:
  match first:
    case False{}: False{}
    case True{}: next(env)
def either_next(~Env: Data,first: Bool,env: Env,next: Env -> Bool) -> Bool:
  match first:
    case False{}: next(env)
    case True{}: True{}

def evaluate(~Atom: Data,~Env: Data,~leaf: Atom -> Env -> Bool,tree: Tree<Atom>,+env: Env) -> Bool:
  match tree:
    case Leaf{atom}: leaf(atom,env)
    case Constant{value}: value
    case Negate{inner}: Bool.not(evaluate(~Atom,~Env,~leaf,inner,env))
    case Both{left,right}: both_next(~Env,evaluate(~Atom,~Env,~leaf,left,env),env,env => evaluate(~Atom,~Env,~leaf,right,env))
    case Either{left,right}: either_next(~Env,evaluate(~Atom,~Env,~leaf,left,env),env,env => evaluate(~Atom,~Env,~leaf,right,env))
