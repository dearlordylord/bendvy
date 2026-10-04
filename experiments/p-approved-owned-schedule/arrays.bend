import Base

type SizeFrame<-source: Array<U32>> is Type:
  SizeFrame{owner: Array<U32>, size: U32,
    exact: {(owner,size) == Array.size(U32,source) : Array<U32> & U32},
    same: {owner == source : Array<U32>}}

def size_node_exact(-left: Array<U32>, -right: Array<U32>, -owner: Array<U32>, +size: U32,
  e: {(owner,size) == Array.size(U32,left) : Array<U32> & U32})
  -> {(ANode{owner,right},U32.shl(size)) == Array.size(U32,ANode{left,right}) : Array<U32> & U32}:
  %e : {(ANode{owner,right},U32.shl(size)) == Array.size.node(U32,right,_) : Array<U32> & U32}
  {==}

def size_node_same(-left: Array<U32>, -right: Array<U32>, -owner: Array<U32>, e: {owner == left : Array<U32>})
  -> {ANode{owner,right} == ANode{left,right} : Array<U32>}:
  %e : {ANode{owner,right} == ANode{_,right} : Array<U32>}
  {==}

def size_node(-left: Array<U32>, right: Array<U32>, frame: SizeFrame<left>) -> SizeFrame<ANode{left,right}>:
  match frame:
    case SizeFrame{owner,+size,e,same}:
      er = size_node_exact(left,right,owner,size,e)
      es = size_node_same(left,right,owner,same)
      SizeFrame{ANode{owner,right},U32.shl(size),er,es}

def size(array: Array<U32>) -> SizeFrame<array>:
  match array:
    case ALeaf{+value}: SizeFrame{ALeaf{value},1,{==},{==}}
    case ANode{left,right}: size_node(left,right,size(left))

type GetFrame<-source: Array<U32>, +n: U32, +index: U32, +branch: Bool> is Type:
  GetFrame{owner: Array<U32>, value: U32,
    exact: {(owner,value) == Array.get.go(U32,source,n,index,branch) : Array<U32> & U32},
    same: {owner == source : Array<U32>}}

def get_low_exact(-left: Array<U32>, -right: Array<U32>, -owner: Array<U32>, +value: U32, +n: U32, +index: U32,
  e: {(owner,value) == Array.get.go(U32,left,U32.shr(n),index,U32.is_lt(index,U32.shr(U32.shr(n)))) : Array<U32> & U32})
  -> {(ANode{owner,right},value) == Array.get.go(U32,ANode{left,right},n,index,True{}) : Array<U32> & U32}:
  %e : {(ANode{owner,right},value) == Array.swap.lo(U32,right,_) : Array<U32> & U32}
  {==}

def get_high_exact(-left: Array<U32>, -right: Array<U32>, -owner: Array<U32>, +value: U32, +n: U32, +index: U32,
  e: {(owner,value) == Array.get.go(U32,right,U32.shr(n),U32.sub(index,U32.shr(n)),U32.is_lt(U32.sub(index,U32.shr(n)),U32.shr(U32.shr(n)))) : Array<U32> & U32})
  -> {(ANode{left,owner},value) == Array.get.go(U32,ANode{left,right},n,index,False{}) : Array<U32> & U32}:
  %e : {(ANode{left,owner},value) == Array.swap.hi(U32,left,_) : Array<U32> & U32}
  {==}

def get_low(-left: Array<U32>, right: Array<U32>, +n: U32, +index: U32,
  frame: GetFrame<left,U32.shr(n),index,U32.is_lt(index,U32.shr(U32.shr(n)))>)
  -> GetFrame<ANode{left,right},n,index,True{}>:
  match frame:
    case GetFrame{owner,+value,exact,same}:
      er = get_low_exact(left,right,owner,value,n,index,exact)
      es = size_node_same(left,right,owner,same)
      GetFrame{ANode{owner,right},value,er,es}

def high_same(-left: Array<U32>, -right: Array<U32>, -owner: Array<U32>, e: {owner == right : Array<U32>})
  -> {ANode{left,owner} == ANode{left,right} : Array<U32>}:
  %e : {ANode{left,owner} == ANode{left,_} : Array<U32>}
  {==}

def get_high(left: Array<U32>, -right: Array<U32>, +n: U32, +index: U32,
  frame: GetFrame<right,U32.shr(n),U32.sub(index,U32.shr(n)),U32.is_lt(U32.sub(index,U32.shr(n)),U32.shr(U32.shr(n)))>)
  -> GetFrame<ANode{left,right},n,index,False{}>:
  match frame:
    case GetFrame{owner,+value,exact,same}:
      er = get_high_exact(left,right,owner,value,n,index,exact)
      es = high_same(left,right,owner,same)
      GetFrame{ANode{left,owner},value,er,es}

def get_go(array: Array<U32>, +n: U32, +index: U32, +branch: Bool) -> GetFrame<array,n,index,branch>:
  match array branch:
    case ALeaf{+value} _: GetFrame{ALeaf{value},value,{==},{==}}
    case ANode{left,right} True{}:
      get_low(left,right,n,index,get_go(left,U32.shr(n),index,U32.is_lt(index,U32.shr(U32.shr(n)))))
    case ANode{left,right} False{}:
      get_high(left,right,n,index,get_go(right,U32.shr(n),U32.sub(index,U32.shr(n)),U32.is_lt(U32.sub(index,U32.shr(n)),U32.shr(U32.shr(n)))))

type ReadFrame<-source: Array<U32>, +index: U32> is Type:
  ReadFrame{owner: Array<U32>, value: U32,
    exact: {(owner,value) == Array.get(U32,source,index) : Array<U32> & U32},
    same: {owner == source : Array<U32>}}

def read_exact(-source: Array<U32>, -sized: Array<U32>, +n: U32, +index: U32,
  -owner: Array<U32>, +value: U32,
  size: {(sized,n) == Array.size(U32,source) : Array<U32> & U32},
  get: {(owner,value) == Array.get.go(U32,sized,n,U32.and(index,U32.sub(n,1)),U32.is_lt(U32.and(index,U32.sub(n,1)),U32.shr(n))) : Array<U32> & U32})
  -> {(owner,value) == Array.get(U32,source,index) : Array<U32> & U32}:
  %size : {(owner,value) == Array.get.at(U32,index,_) : Array<U32> & U32}
  get

def read_finish(-source: Array<U32>, -sized: Array<U32>, +n: U32, +index: U32,
  size: {(sized,n) == Array.size(U32,source) : Array<U32> & U32}, same: {sized == source : Array<U32>},
  frame: GetFrame<sized,n,U32.and(index,U32.sub(n,1)),U32.is_lt(U32.and(index,U32.sub(n,1)),U32.shr(n))>)
  -> ReadFrame<source,index>:
  match frame:
    case GetFrame{owner,+value,exact,preserved}:
      er = read_exact(source,sized,n,index,owner,value,size,exact)
      es = Equal.trans(Array<U32>,owner,sized,source,preserved,same)
      ReadFrame{owner,value,er,es}

def read_sized(-source: Array<U32>, +index: U32, frame: SizeFrame<source>) -> ReadFrame<source,index>:
  match frame:
    case SizeFrame{sized,+n,exact,same}:
      read_finish(source,sized,n,index,exact,same,
        get_go(sized,n,U32.and(index,U32.sub(n,1)),U32.is_lt(U32.and(index,U32.sub(n,1)),U32.shr(n))))

def read(array: Array<U32>, +index: U32) -> ReadFrame<array,index>:
  read_sized(array,index,size(array))
