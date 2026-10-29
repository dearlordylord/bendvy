import Base

# Framework physical offsets, never public entity keys or gameplay authority.
# Dynamic lists deliberately replace fixed-width masks and template row sets.
type Domain is Data:
  Domain{offsets:List<&2,U32>}
type Validation is Data:
  Valid{}
  Duplicate{offset:U32}
  OutOfBounds{offset:U32,capacity:U32}
type Access is Data:
  Access{reads:Domain,writes:Domain}

def contains_list(+offset:U32,offsets:List<&2,U32>) -> Bool:
  match offsets:
    case []:False{}
    case +head <> tail:Bool.or(U32.is_eq(offset,head),contains_list(offset,tail))
def contains(domain:Domain,offset:U32) -> Bool:
  match domain:
    case Domain{offsets}:contains_list(offset,offsets)
def validate_tail(+capacity:U32,+offset:U32,next:Validation,duplicate:Bool,inRange:Bool) -> Validation:
  match duplicate inRange:
    case True{} _:Duplicate{offset}
    case False{} False{}:OutOfBounds{offset,capacity}
    case False{} True{}:next
def validate_list(+capacity:U32,offsets:List<&2,U32>) -> Validation:
  match offsets:
    case []:Valid{}
    case +head <> +tail:validate_tail(capacity,head,validate_list(capacity,tail),contains_list(head,tail),U32.is_lt(head,capacity))
def validate(capacity:U32,domain:Domain) -> Validation:
  match domain:
    case Domain{offsets}:validate_list(capacity,offsets)
def intersects_list(+right:Domain,offsets:List<&2,U32>) -> Bool:
  match offsets:
    case []:False{}
    case head <> rest:Bool.or(contains(right,head),intersects_list(right,rest))
def intersects(left:Domain,right:Domain) -> Bool:
  match left:
    case Domain{offsets}:intersects_list(right,offsets)
def insert(+domain:Domain,+offset:U32,present:Bool) -> Domain:
  match domain present:
    case domain True{}:domain
    case Domain{offsets} False{}:Domain{offset <> offsets}
def union_list(offsets:List<&2,U32>,+result:Domain) -> Domain:
  match offsets:
    case []:result
    case +offset <> rest:union_list(rest,insert(result,offset,contains(result,offset)))
def union(left:Domain,right:Domain) -> Domain:
  match left:
    case Domain{offsets}:union_list(offsets,right)
def conflicts(left:Access,right:Access) -> Bool:
  match left right:
    case Access{+lr,+lw} Access{+rr,+rw}:Bool.or(intersects(lw,rw),Bool.or(intersects(lw,rr),intersects(rw,lr)))
