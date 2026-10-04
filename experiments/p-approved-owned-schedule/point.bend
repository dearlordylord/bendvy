import Base
import ./arrays.bend as A

type SwapFrame<-source: Array<U32>, +n: U32, +index: U32, +value: U32, +branch: Bool> is Type:
  SwapFrame{owner: Array<U32>, old: U32, count: U32,
    exact: {(owner,old) == Array.swap.go(U32,source,n,index,value,branch) : Array<U32> & U32},
    before: {(source,count) == Array.size(U32,source) : Array<U32> & U32},
    after: {(owner,count) == Array.size(U32,owner) : Array<U32> & U32},
    point: {(owner,value) == Array.get.go(U32,owner,n,index,branch) : Array<U32> & U32}}

def node_size(-left: Array<U32>, -right: Array<U32>, +count: U32,
  e: {(left,count) == Array.size(U32,left) : Array<U32> & U32})
  -> {(ANode{left,right},U32.shl(count)) == Array.size(U32,ANode{left,right}) : Array<U32> & U32}:
  %e : {(ANode{left,right},U32.shl(count)) == Array.size.node(U32,right,_) : Array<U32> & U32}
  {==}

def low_exact(-left: Array<U32>, -right: Array<U32>, -owner: Array<U32>, +old: U32, +n: U32, +index: U32, +value: U32,
  e: {(owner,old) == Array.swap.go(U32,left,U32.shr(n),index,value,U32.is_lt(index,U32.shr(U32.shr(n)))) : Array<U32> & U32})
  -> {(ANode{owner,right},old) == Array.swap.go(U32,ANode{left,right},n,index,value,True{}) : Array<U32> & U32}:
  %e : {(ANode{owner,right},old) == Array.swap.lo(U32,right,_) : Array<U32> & U32}
  {==}

def low_point(-owner: Array<U32>, -right: Array<U32>, +n: U32, +index: U32, +value: U32,
  e: {(owner,value) == Array.get.go(U32,owner,U32.shr(n),index,U32.is_lt(index,U32.shr(U32.shr(n)))) : Array<U32> & U32})
  -> {(ANode{owner,right},value) == Array.get.go(U32,ANode{owner,right},n,index,True{}) : Array<U32> & U32}:
  %e : {(ANode{owner,right},value) == Array.swap.lo(U32,right,_) : Array<U32> & U32}
  {==}

def low(-left: Array<U32>, right: Array<U32>, +n: U32, +index: U32, +value: U32,
  frame: SwapFrame<left,U32.shr(n),index,value,U32.is_lt(index,U32.shr(U32.shr(n)))>)
  -> SwapFrame<ANode{left,right},n,index,value,True{}>:
  match frame:
    case SwapFrame{owner,+old,+count,exact,before,after,point}:
      er = low_exact(left,right,owner,old,n,index,value,exact)
      eb = node_size(left,right,count,before)
      ea = node_size(owner,right,count,after)
      ep = low_point(owner,right,n,index,value,point)
      SwapFrame{ANode{owner,right},old,U32.shl(count),er,eb,ea,ep}

def high_exact(-left: Array<U32>, -right: Array<U32>, -owner: Array<U32>, +old: U32, +n: U32, +index: U32, +value: U32,
  e: {(owner,old) == Array.swap.go(U32,right,U32.shr(n),U32.sub(index,U32.shr(n)),value,U32.is_lt(U32.sub(index,U32.shr(n)),U32.shr(U32.shr(n)))) : Array<U32> & U32})
  -> {(ANode{left,owner},old) == Array.swap.go(U32,ANode{left,right},n,index,value,False{}) : Array<U32> & U32}:
  %e : {(ANode{left,owner},old) == Array.swap.hi(U32,left,_) : Array<U32> & U32}
  {==}

def high_point(-left: Array<U32>, -owner: Array<U32>, +n: U32, +index: U32, +value: U32,
  e: {(owner,value) == Array.get.go(U32,owner,U32.shr(n),U32.sub(index,U32.shr(n)),U32.is_lt(U32.sub(index,U32.shr(n)),U32.shr(U32.shr(n)))) : Array<U32> & U32})
  -> {(ANode{left,owner},value) == Array.get.go(U32,ANode{left,owner},n,index,False{}) : Array<U32> & U32}:
  %e : {(ANode{left,owner},value) == Array.swap.hi(U32,left,_) : Array<U32> & U32}
  {==}

def original_size(-source: Array<U32>, -owner: Array<U32>, +count: U32,
  e: {(owner,count) == Array.size(U32,source) : Array<U32> & U32}, same: {owner == source : Array<U32>})
  -> {(source,count) == Array.size(U32,source) : Array<U32> & U32}:
  %same : {(_,count) == Array.size(U32,source) : Array<U32> & U32}
  e

def high_finish(-left: Array<U32>, -right: Array<U32>, +n: U32, +index: U32, +value: U32,
  lhs: A.SizeFrame<left>, rhs: SwapFrame<right,U32.shr(n),U32.sub(index,U32.shr(n)),value,U32.is_lt(U32.sub(index,U32.shr(n)),U32.shr(U32.shr(n)))>)
  -> SwapFrame<ANode{left,right},n,index,value,False{}>:
  match lhs rhs:
    case A.SizeFrame{kept,+count,+sized,+same} SwapFrame{owner,+old,_,exact,_,_,point}:
      source_size = original_size(left,kept,count,sized,same)
      kept_size = Equal.trans(Array<U32> & U32,(kept,count),Array.size(U32,left),Array.size(U32,kept),sized,
        Equal.cong(Array<U32>,Array<U32> & U32,x => Array.size(U32,x),left,kept,Equal.sym(Array<U32>,kept,left,same)))
      raw = high_exact(left,right,owner,old,n,index,value,exact)
      er = Equal.trans(Array<U32> & U32,(ANode{kept,owner},old),(ANode{left,owner},old),Array.swap.go(U32,ANode{left,right},n,index,value,False{}),
        Equal.cong(Array<U32>,Array<U32> & U32,x => (ANode{x,owner},old),kept,left,same),raw)
      eb = node_size(left,right,count,source_size)
      ea = node_size(kept,owner,count,kept_size)
      ep = high_point(kept,owner,n,index,value,point)
      SwapFrame{ANode{kept,owner},old,U32.shl(count),er,eb,ea,ep}

def swap_go(array: Array<U32>, +n: U32, +index: U32, +value: U32, +branch: Bool) -> SwapFrame<array,n,index,value,branch>:
  match array branch:
    case ALeaf{+old} _: SwapFrame{ALeaf{value},old,1,{==},{==},{==},{==}}
    case ANode{left,right} True{}:
      low(left,right,n,index,value,swap_go(left,U32.shr(n),index,value,U32.is_lt(index,U32.shr(U32.shr(n)))))
    case ANode{left,right} False{}:
      high_finish(left,right,n,index,value,A.size(left),
        swap_go(right,U32.shr(n),U32.sub(index,U32.shr(n)),value,U32.is_lt(U32.sub(index,U32.shr(n)),U32.shr(U32.shr(n)))))

type SetFrame<-source: Array<U32>, +index: U32, +value: U32> is Type:
  SetFrame{owner: Array<U32>,
    exact: {owner == Array.set(U32,source,index,value) : Array<U32>},
    point: {(owner,value) == Array.get(U32,owner,index) : Array<U32> & U32}}

def count(result: Array<U32> & U32) -> U32:
  match result:
    case (_,value): value

def same_count(-array: Array<U32>, +left: U32, +right: U32,
  first: {(array,left) == Array.size(U32,array) : Array<U32> & U32},
  second: {(array,right) == Array.size(U32,array) : Array<U32> & U32}) -> {left == right : U32}:
  Equal.cong(Array<U32> & U32,U32,r => count(r),(array,left),(array,right),
    Equal.trans(Array<U32> & U32,(array,left),Array.size(U32,array),(array,right),first,
      Equal.sym(Array<U32> & U32,(array,right),Array.size(U32,array),second)))

def set_exact(-source: Array<U32>, -sized: Array<U32>, -owner: Array<U32>, +old: U32, +n: U32, +index: U32, +value: U32,
  size: {(sized,n) == Array.size(U32,source) : Array<U32> & U32},
  swap: {(owner,old) == Array.swap.go(U32,sized,n,U32.and(index,U32.sub(n,1)),value,U32.is_lt(U32.and(index,U32.sub(n,1)),U32.shr(n))) : Array<U32> & U32})
  -> {owner == Array.set(U32,source,index,value) : Array<U32>}:
  %size : {owner == Array.set.fin(U32,Array.swap.at(U32,index,value,_)) : Array<U32>}
  %swap : {owner == Array.set.fin(U32,_) : Array<U32>}
  {==}

def set_point(-owner: Array<U32>, +count: U32, +n: U32, +index: U32, +value: U32,
  size: {(owner,count) == Array.size(U32,owner) : Array<U32> & U32}, same: {count == n : U32},
  path: {(owner,value) == Array.get.go(U32,owner,n,U32.and(index,U32.sub(n,1)),U32.is_lt(U32.and(index,U32.sub(n,1)),U32.shr(n))) : Array<U32> & U32})
  -> {(owner,value) == Array.get(U32,owner,index) : Array<U32> & U32}:
  %size : {(owner,value) == Array.get.at(U32,index,_) : Array<U32> & U32}
  %Equal.sym(U32,count,n,same) : {(owner,value) == Array.get.at(U32,index,(owner,_)) : Array<U32> & U32}
  path

def set_finish(-source: Array<U32>, -sized: Array<U32>, +n: U32, +index: U32, +value: U32,
  +size: {(sized,n) == Array.size(U32,source) : Array<U32> & U32}, same: {sized == source : Array<U32>},
  frame: SwapFrame<sized,n,U32.and(index,U32.sub(n,1)),value,U32.is_lt(U32.and(index,U32.sub(n,1)),U32.shr(n))>)
  -> SetFrame<source,index,value>:
  match frame:
    case SwapFrame{owner,+old,+count,exact,before,after,point}:
      sized_count = Equal.trans(Array<U32> & U32,(sized,n),Array.size(U32,source),Array.size(U32,sized),size,
        Equal.cong(Array<U32>,Array<U32> & U32,x => Array.size(U32,x),source,sized,Equal.sym(Array<U32>,sized,source,same)))
      ec = same_count(sized,count,n,before,sized_count)
      er = set_exact(source,sized,owner,old,n,index,value,size,exact)
      ep = set_point(owner,count,n,index,value,after,ec,point)
      SetFrame{owner,er,ep}

def set_sized(-source: Array<U32>, +index: U32, +value: U32, frame: A.SizeFrame<source>) -> SetFrame<source,index,value>:
  match frame:
    case A.SizeFrame{sized,+n,exact,same}:
      set_finish(source,sized,n,index,value,exact,same,
        swap_go(sized,n,U32.and(index,U32.sub(n,1)),value,U32.is_lt(U32.and(index,U32.sub(n,1)),U32.shr(n))))

def set(array: Array<U32>, +index: U32, +value: U32) -> SetFrame<array,index,value>:
  set_sized(array,index,value,A.size(array))
