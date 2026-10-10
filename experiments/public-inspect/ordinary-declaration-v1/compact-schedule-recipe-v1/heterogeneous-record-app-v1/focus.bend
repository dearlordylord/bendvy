import Base
# Generated structural focus/reinsertion: no id-based cast or detached field cache.
def last(~Left:Type,~Right:Type,owners:Left & Right) -> Left & Right:
  owners
def put_last(~Left:Type,~Right:Type,left:Left,right:Right) -> Left & Right:
  (left,right)
def taken_left(~Previous:Type,~Leaf:Type,~Right:Type,right:Right,result:Previous & Leaf) -> (Previous & Right) & Leaf:
  match result:
    case (previous,leaf):((previous,right),leaf)
def take_left(~Left:Type,~Previous:Type,~Leaf:Type,~Right:Type,take:Left -> Previous & Leaf,owners:Left & Right) -> (Previous & Right) & Leaf:
  match owners:
    case (left,right):taken_left(~Previous,~Leaf,~Right,right,take(left))
def put_left(~Left:Type,~Previous:Type,~Leaf:Type,~Right:Type,put:Previous -> Leaf -> Left,others:Previous & Right,leaf:Leaf) -> Left & Right:
  match others:
    case (previous,right):(put(previous,leaf),right)
