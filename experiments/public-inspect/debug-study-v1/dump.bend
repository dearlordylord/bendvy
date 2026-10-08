import Base
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Cap
import skeleton.bend as F

# Trusted setup supplies a closed nominal Token equality and Check read grants.
# Rows are Data projections; this module owns neither columns nor ECS storage.
type Row<S:Data,Token:Data,V:Data> is Data:
  Row{entity:W.Handle<S>,present:List<&2,Token>,value:V}
type Observed<S:Data,Token:Data,V:Data,RV:Data> is Data:
  Observed{liveCount:Nat,rows:List<&2,Row<S,Token,V>>,resource:RV}
type Entry<S:Data,V:Data> is Data:
  Entry{entity:W.Handle<S>,value:V}
type Dump<S:Data,V:Data,RV:Data> is Data:
  Dump{liveCount:Nat,rows:List<&2,Entry<S,V>>,resource:RV}

def contains_id(+id:U32,values:List<&2,U32>) -> Bool:
  match values:
    case []:False{}
    case head <> rest:Bool.or(U32.is_eq(id,head),contains_id(id,rest))
def includes(~S:Data,entities:Maybe<&2,List<&2,U32>>,entity:W.Handle<S>) -> Bool:
  match entities entity:
    case None{} _:True{}
    case Some{ids} W.Handle{_,id}:contains_id(id,ids)
def contains_token(~Token:Data,~equal:Token -> Token -> Bool,+token:Token,values:List<&2,Token>) -> Bool:
  match values:
    case []:False{}
    case head <> rest:Bool.or(equal(token,head),contains_token(~Token,~equal,token,rest))
def requirements(~Token:Data,~equal:Token -> Token -> Bool,required:List<&2,Token>,+present:List<&2,Token>) -> Bool:
  match required:
    case []:True{}
    case token <> rest:Bool.and(contains_token(~Token,~equal,token,present),requirements(~Token,~equal,rest,present))
def accepted(~S:Data,~Token:Data,~V:Data,~equal:Token -> Token -> Bool,entities:Maybe<&2,List<&2,U32>>,required:List<&2,Token>,row:Row<S,Token,V>) -> Bool:
  match row:
    case Row{entity,present,_}:Bool.and(includes(~S,entities,entity),requirements(~Token,~equal,required,present))
# Canonical little-endian decimal digits: [] is zero; nonzero highest digit
# is 1..9 and every digit is 0..9. Trusted normalizer/setup owns validity.
def decrement_digits(digits:List<&2,U32>) -> List<&2,U32>:
  match digits:
    case []:[]
    case 0 <> tail:9 <> decrement_digits(tail)
    case 1 <> []:[]
    case digit <> tail:(digit - 1 : U32) <> tail
def decrement(limit:F.Limit) -> F.Limit:
  match limit:
    case F.Unbounded{}:F.Unbounded{}
    case F.BoundedDecimal{digits}:F.BoundedDecimal{decrement_digits(digits)}
def row_value(~S:Data,~Token:Data,~V:Data,row:Row<S,Token,V>) -> Entry<S,V>:
  match row:
    case Row{entity,_,value}:Entry{entity,value}
def select_choice(~S:Data,~Token:Data,~V:Data,row:Row<S,Token,V>,limit:F.Limit,rest:F.Limit -> List<&2,Entry<S,V>>,include:Bool) -> List<&2,Entry<S,V>>:
  match include:
    case True{}:row_value(~S,~Token,~V,row) <> rest(decrement(limit))
    case False{}:rest(limit)
def select(~S:Data,~Token:Data,~V:Data,~equal:Token -> Token -> Bool,+entities:Maybe<&2,List<&2,U32>>,+required:List<&2,Token>,rows:List<&2,Row<S,Token,V>>,+limit:F.Limit) -> List<&2,Entry<S,V>>:
  match rows limit:
    case _, F.BoundedDecimal{[]}:[]
    case [], _:[]
    case +row <> tail, limit:select_choice(~S,~Token,~V,row,limit,next => select(~S,~Token,~V,~equal,entities,required,tail,next),accepted(~S,~Token,~V,~equal,entities,required,row))
def project(~S:Data,~Token:Data,~V:Data,~RV:Data,~equal:Token -> Token -> Bool,filter:F.Filter<S,Token>,observed:Observed<S,Token,V,RV>) -> Dump<S,V,RV>:
  match filter observed:
    case F.Filter{entities,required,limit} Observed{count,rows,resource}:Dump{count,select(~S,~Token,~V,~equal,entities,required,rows,limit),resource}
def joined(~H:Type,~S:Data,~Token:Data,~V:Data,~RV:Data,~equal:Token -> Token -> Bool,filter:F.Filter<S,Token>,result:H & Observed<S,Token,V,RV>) -> H & F.Output<Dump<S,V,RV>>:
  (owner,observed)=result
  (owner,F.Enabled{project(~S,~Token,~V,~RV,~equal,filter,observed)})
def dump(~H:Type,~S:Data,~Token:Data,~V:Data,~RV:Data,~equal:Token -> Token -> Bool,~read:Cap.ValueRead<H,Observed<S,Token,V,RV>>,active:Bool,filter:F.Filter<S,Token>,owner:H) -> H & F.Output<Dump<S,V,RV>>:
  match active:
    case False{}:(owner,F.Disabled{})
    case True{}:joined(~H,~S,~Token,~V,~RV,~equal,filter,Cap.value_read(~H,~Observed<S,Token,V,RV>,~read,owner))
