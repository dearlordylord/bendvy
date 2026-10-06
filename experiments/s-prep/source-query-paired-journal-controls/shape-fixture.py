#!/usr/bin/env python3
"""Authored literal complete owned arrays/world state at five outer/payload depths."""
import pathlib
H=pathlib.Path(__file__).resolve().parent
text='''import Base
import ./storage.bend as S
import ./query.bend as Q

type Schema is Data:
  Schema{}
type Other is Data:
  Other{}
type Owned is Type:
  Owned{items:Array<U32>,scalar:U32}
def words_leaf(+value:U32) -> Array<U32> & String: (ALeaf{value},U32.show(value))
def words_join(result:(Array<U32> & String) & (Array<U32> & String)) -> Array<U32> & String:
  match result:
    case ((left,lt),(right,rt)): (ANode{left,right},"(" ++ lt ++ "," ++ rt ++ ")")
def words(array:Array<U32>) -> Array<U32> & String:
  match array:
    case ALeaf{value}: words_leaf(value)
    case ANode{left,right}: words_join((words(left),words(right)))
def owned_words(+scalar:U32,result:Array<U32> & String) -> Owned & String:
  match result:
    case (items,text): (Owned{items,scalar},text ++ "@" ++ U32.show(scalar))
def owned(owner:Owned) -> Owned & String:
  match owner:
    case Owned{items,scalar}: owned_words(scalar,words(items))
def maybe_owned(result:Owned & String) -> Array<Maybe<Owned>> & String:
  match result:
    case (owner,text): (ALeaf{Some{owner}},text)
def owners_join(result:(Array<Maybe<Owned>> & String) & (Array<Maybe<Owned>> & String)) -> Array<Maybe<Owned>> & String:
  match result:
    case ((left,lt),(right,rt)): (ANode{left,right},"(" ++ lt ++ "," ++ rt ++ ")")
def owners(array:Array<Maybe<Owned>>) -> Array<Maybe<Owned>> & String:
  match array:
    case ALeaf{None{}}: (ALeaf{None{}},"none")
    case ALeaf{Some{owner}}: maybe_owned(owned(owner))
    case ANode{left,right}: owners_join((owners(left),owners(right)))
def handles(values:List<&2,S.Handle<Schema>>) -> String:
  match values:
    case Nil{}: "end"
    case Con{S.Handle{ns,id},tail}: U32.show(ns) ++ ":" ++ U32.show(id) ++ ";" ++ handles(tail)
def flags(values:Array<Maybe<&2,Unit>>) -> String:
  match values:
    case ALeaf{None{}}: "0"
    case ALeaf{Some{_}}: "1"
    case ANode{left,right}: "(" ++ flags(left) ++ "," ++ flags(right) ++ ")"
def bools(values:Array<Bool>) -> String:
  match values:
    case ALeaf{False{}}: "0"
    case ALeaf{True{}}: "1"
    case ANode{left,right}: "(" ++ bools(left) ++ "," ++ bools(right) ++ ")"
def snapshot_fields(+ns:U32,next:U32,capacity:U32,depth:Nat,high:U32,live:Array<Bool>,flag:Array<Maybe<&2,Unit>>,added:Array<U32>,changed:Array<U32>,mode:U32,values:List<&2,S.Handle<Schema>>,parts:(Array<Maybe<Owned>> & String) & ((Array<Maybe<Owned>> & String) & (Owned & String))) -> String:
  match parts:
    case ((main,mt),((aux,at),(ledger,lt))): U32.show(ns) ++ ":" ++ U32.show(next) ++ "|" ++ U32.show(capacity) ++ ":" ++ Nat.show(depth) ++ ":" ++ U32.show(high) ++ "|" ++ mt ++ "|" ++ at ++ "|" ++ bools(live) ++ "|" ++ flags(flag) ++ "|" ++ words_text(words(added)) ++ "|" ++ words_text(words(changed)) ++ "|" ++ lt ++ "|" ++ U32.show(mode) ++ "|" ++ handles(values)
def words_text(result:Array<U32> & String) -> String:
  match result:
    case (_,text): text
def snapshot_rows(ns:U32,next:U32,ledger:Owned,mode:U32,values:List<&2,S.Handle<Schema>>,rows:S.Rows<Owned,Owned,Unit>) -> String:
  match rows:
    case S.Rows{main,aux,S.MetadataColumns{live,flag,added,changed},capacity,depth,high}: snapshot_fields(ns,next,capacity,depth,high,live,flag,added,changed,mode,values,(owners(main),(owners(aux),owned(ledger))))
def snapshot(result:S.World<Schema,Owned,Owned,Unit,Owned,U32> & List<&2,S.Handle<Schema>>) -> String:
  match result:
    case (S.World{ns,next,rows,Nil{},Some{ledger},mode},values): snapshot_rows(ns,next,ledger,mode,values,rows)
    case _: "unexpected-context"
'''
# words_text must precede its caller.
a=text.index('def words_text');b=text.index('def snapshot_rows');chunk=text[a:b];text=text[:a]+text[b:];at=text.index('def snapshot_fields');text=text[:at]+chunk+text[at:]
def tree(xs):
 if len(xs)==1:return 'ALeaf{'+xs[0]+'}'
 half=len(xs)//2;return 'ANode{'+tree(xs[:half])+','+tree(xs[half:])+'}'
def tree_text(xs):
 if len(xs)==1:return xs[0]
 h=len(xs)//2;return '('+tree_text(xs[:h])+','+tree_text(xs[h:])+')'
expected=[]
for d in range(5):
 n=2**d;pd=d;payload=2**pd
 def own(i):return 'Owned{'+tree([str(1000*i+j) for j in range(payload)])+','+str(i)+'}'
 def owntext(i):return tree_text([str(1000*i+j) for j in range(payload)])+'@'+str(i)
 main=['None{}' if i==2 else 'Some{'+own(i)+'}' for i in range(1,n+1)];aux=['Some{'+own(100+i)+'}' for i in range(1,n+1)];live=['False{}' if i==3 else 'True{}' for i in range(1,n+1)];flags0=['Some{Unit{}}' if i%2 else 'None{}' for i in range(1,n+1)];hi=max(1,n-1)
 world='S.World{7,999,S.Rows{'+tree(main)+','+tree(aux)+',S.MetadataColumns{'+tree(live)+','+tree(flags0)+','+tree([str(100+i) for i in range(n)])+','+tree([str(200+i) for i in range(n)])+'},'+str(n)+','+str(d)+'n,'+str(hi)+'},[],'+'Some{'+own(999)+'},123}'
 text+='def world'+str(d)+'() -> S.World<Schema,Owned,Owned,Unit,Owned,U32>:\n  '+world+'\n'
 for selection in ['Required','Present','Absent','Optional']:
  ids=[i for i in range(1,hi+1) if i not in [2,3] and (selection not in ['Present','Absent'] or (i%2==1)==(selection=='Present'))]
  fields='7:999|'+str(n)+':'+str(d)+':'+str(hi)+'|'+tree_text(['none' if i==2 else owntext(i) for i in range(1,n+1)])+'|'+tree_text([owntext(100+i) for i in range(1,n+1)])+'|'+tree_text(['0' if i==3 else '1' for i in range(1,n+1)])+'|'+tree_text(['1' if i%2 else '0' for i in range(1,n+1)])+'|'+tree_text([str(100+i) for i in range(n)])+'|'+tree_text([str(200+i) for i in range(n)])+'|'+owntext(999)+'|123|'+''.join('7:'+str(i)+';' for i in ids)+'end'
  expected.append(f'd{d}-{selection}:'+fields)
text+='def main() -> IO(Unit):\n  do IO<Unit>:\n'
for d in range(5):
 for selection in ['Required','Present','Absent','Optional']:text+='    IO.print("d'+str(d)+'-'+selection+':" ++ snapshot(Q.prototype_identity_each(Schema,Owned,Owned,Unit,Owned,U32,Q.'+selection+'{},world'+str(d)+'())))\n'
text+='    return Unit{}\n'
(H/'full-shape.bend').write_text(text);(H/'full-shape-expected.txt').write_text('\n'.join(expected)+'\n')
