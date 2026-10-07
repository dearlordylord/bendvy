import Base
import ../../../../../src/ecs/string-equality.bend as SE

type Family is Data:
  Population{}
  Fanout{}
  Depth{}
type Input is Data:
  Input{family:Family,population:U32,span:U32,seed:U32}
type Parsed is Data:
  Valid{input:Input}
  Invalid{}
def family_depth(same:Bool) -> Maybe<&2,Family>:
  match same:
    case True{}:Some{Depth{}}
    case False{}:None{}
def family_fanout(same:Bool,name:String) -> Maybe<&2,Family>:
  match same:
    case True{}:Some{Fanout{}}
    case False{}:family_depth(SE.equal(name,"depth"))
def family_population(same:Bool,+name:String) -> Maybe<&2,Family>:
  match same:
    case True{}:Some{Population{}}
    case False{}:family_fanout(SE.equal(name,"fanout"),name)
def parse_family(+name:String) -> Maybe<&2,Family>:
  family_population(SE.equal(name,"population"),name)
def valid_span(+span:U32) -> Bool:
  U32.is_eq(span,1) || U32.is_eq(span,16) || U32.is_eq(span,128)
def valid_case(family:Family,+population:U32,span:U32) -> Bool:
  match family:
    case Population{}:(U32.is_eq(population,64) || U32.is_eq(population,256) || U32.is_eq(population,1024)) && U32.is_zero(span)
    case Fanout{}:U32.is_eq(population,256) && valid_span(span)
    case Depth{}:U32.is_eq(population,256) && valid_span(span)
def validated(allowed:Bool,input:Input) -> Parsed:
  match allowed:
    case True{}:Valid{input}
    case False{}:Invalid{}
def decoded(family:Maybe<&2,Family>,population:Maybe<&2,U32>,span:Maybe<&2,U32>,seed:Maybe<&2,U32>) -> Parsed:
  match family population span seed:
    case Some{+family} Some{+population} Some{+span} Some{seed}:validated(valid_case(family,population,span),Input{family,population,span,seed})
    case _ _ _ _:Invalid{}
def digit_continued(ok:Bool,next:Unit -> Bool) -> Bool:
  match ok:
    case True{}:next(Unit{})
    case False{}:False{}
def digits(text:String) -> Bool:
  match text:
    case SNil{}:True{}
    case SCon{Chr{+code},rest}:digit_continued(U32.is_le(48,code) && U32.is_le(code,57),_ => digits(rest))
def numeric_allowed(ok:Bool,text:String) -> Maybe<&2,U32>:
  match ok:
    case True{}:U32.read(text)
    case False{}:None{}
def numeric(+text:String) -> Maybe<&2,U32>:
  numeric_allowed(digits(text),text)
def parse(args:List<&1,String>) -> Parsed:
  match args:
    case _ <> family <> population <> span <> seed <> []:decoded(parse_family(family),numeric(population),numeric(span),numeric(seed))
    case _:Invalid{}
def family_name(family:Family) -> String:
  match family:
    case Population{}:"population"
    case Fanout{}:"fanout"
    case Depth{}:"depth"
# Fixture shape bound, not a core limit or performance threshold. Max accepted N=1024.
# 30 complete records; <=11 query row sets +retained set and 3 complete graph columns.
# Every relation has at most one outgoing edge/entity, so inverse member totals are linear.
# The 2048-per-entity margin covers full payload/cell/key/container nodes and notices;
# 4096-per-record also covers fixed input/setup metadata. Exhaustion still refuses explicitly.
def walk_budget(+population:U32) -> Nat:
  U32.to_nat(U32.mul(30,U32.add(U32.mul(2048,U32.add(population,1)),4096)))
def serialize_budget(+population:U32) -> Nat:
  U32.to_nat(U32.add(U32.mul(4,U32.mul(30,U32.add(U32.mul(2048,U32.add(population,1)),4096))),64))
