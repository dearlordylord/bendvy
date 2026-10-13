import Base
import /workspace/formal-proofs/bendvy/src/ecs/string-equality.bend as Equality
type Count is Data:
  One{}
  Two{}
  Four{}
def valid_one(one:Bool) -> Maybe<&2,Count>:
  match one:
    case True{}:Some{One{}}
    case False{}:None{}
def valid_four(+text:String,four:Bool) -> Maybe<&2,Count>:
  match four:
    case True{}:Some{Four{}}
    case False{}:valid_one(Equality.equal(text,"1"))
def valid_two(+text:String,two:Bool) -> Maybe<&2,Count>:
  match two:
    case True{}:Some{Two{}}
    case False{}:valid_four(text,Equality.equal(text,"4"))
def choose(+text:String) -> Maybe<&2,Count>:valid_two(text,Equality.equal(text,"2"))
def argument_tail(+text:String,rest:List<String>) -> Maybe<&2,Count>:
  match rest:
    case []:choose(text)
    case _ <> _:None{}
def argument(values:List<String>) -> Maybe<&2,Count>:
  match values:
    case []:None{}
    case text <> rest:argument_tail(text,rest)
def invoked(values:List<String>) -> Maybe<&2,Count>:
  match values:
    case []:None{}
    case _ <> rest:argument(rest)
