import Base
import trace-value.bend as J
# Shared canonical whole-tree walk. Keys count as Text nodes; every leaf is consumed.
# Count and sums are harness controls, never substitutes for the complete trace oracle.
type Summary is Data:
  Summary{nodes:U32,characters:U32,sum:U32}
def force_text(text:String,nodes:U32,characters:U32,sum:U32) -> Summary:
  match text:
    case SNil{}:Summary{nodes,characters,sum}
    case SCon{head,tail}:force_text(tail,nodes,U32.add(characters,1),U32.add(sum,Char.to_u32(head)))
def fields(values:List<&2,J.Field>) -> List<&2,J.Value>:
  match values:
    case []:[]
    case J.Field{key,value} <> rest:J.Text{key} <> value <> fields(rest)
def continue(summary:Summary,pending:List<&2,J.Value>,next:List<&2,J.Value> -> Summary -> Summary) -> Summary:
  next(pending,summary)
def visit(value:J.Value,rest:List<&2,J.Value>,nodes:U32,characters:U32,sum:U32,next:List<&2,J.Value> -> Summary -> Summary) -> Summary:
  match value:
    case J.Null{}:next(rest,Summary{nodes,characters,U32.add(sum,1)})
    case J.Number{n}:next(rest,Summary{nodes,characters,U32.add(U32.add(sum,2),n)})
    case J.Text{s}:continue(force_text(s,nodes,characters,U32.add(sum,3)),rest,next)
    case J.Truth{True{}}:next(rest,Summary{nodes,characters,U32.add(sum,5)})
    case J.Truth{False{}}:next(rest,Summary{nodes,characters,U32.add(sum,4)})
    case J.Items{items}:next(List.append(&2,J.Value,items,rest),Summary{nodes,characters,U32.add(sum,6)})
    case J.Object{values}:next(List.append(&2,J.Value,fields(values),rest),Summary{nodes,characters,U32.add(sum,7)})
def step(pending:List<&2,J.Value>,summary:Summary,next:List<&2,J.Value> -> Summary -> Summary) -> Summary:
  match pending summary:
    case [] result:result
    case value <> rest Summary{nodes,characters,sum}:
      visit(value,rest,U32.add(nodes,1),characters,sum,next)
def walk(fuel:Nat,pending:List<&2,J.Value>,summary:Summary) -> Summary:
  match fuel:
    case 0n:Summary{0,0,0}
    case 1n+rest:step(pending,summary,pending => summary => walk(rest,pending,summary))
def force(value:J.Value) -> Summary:
  walk(U32.to_nat(100000),[value],Summary{0,0,0})
def value(summary:Summary) -> J.Value:
  match summary:
    case Summary{nodes,characters,sum}:J.Object{[J.Field{"nodes",J.Number{nodes}},J.Field{"characters",J.Number{characters}},J.Field{"sum",J.Number{sum}}]}
