import Base

type Key is Data:
  EntityKey{index:U32,generation:U32}

def index(key:Key) -> U32:
  match key:
    case EntityKey{index,_}:index

def generation(key:Key) -> U32:
  match key:
    case EntityKey{_,generation}:generation

def equal(left:Key,right:Key) -> Bool:
  match left right:
    case EntityKey{li,lg} EntityKey{ri,rg}:U32.is_eq(li,ri)
