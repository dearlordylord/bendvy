import Base
import ../../src/ecs/schema-fragments.bend as F

type Schema is Data:
  Schema{}
type Other is Data:
  Other{}
type Owned is Type:
  Owned{cells: Array<U32>}
def owner(first: U32) -> Owned:
  Owned{ANode{ALeaf{first},ALeaf{99}}}
def error(error: F.Error) -> String:
  match error:
    case F.DuplicateKey{_,key}: "key:" ++ key
    case F.DuplicateName{_,name}: "name:" ++ name
    case F.UndeclaredDescriptor{_,key,_}: "undeclared:" ++ key
def owner_last(value: Array<U32> & U32,first: U32) -> String:
  (_,last) = value
  U32.show(first) ++ "," ++ U32.show(last)
def owner_first(value: Array<U32> & U32) -> String:
  (array,first) = value
  owner_last(Array.get(U32,array,1),first)
def show(owner: Owned) -> String:
  match owner:
    case Owned{array}: owner_first(Array.get(U32,array,0))
def successful(owners: Owned & Owned) -> String:
  (left,right) = owners
  "ok:" ++ show(left) ++ ":" ++ show(right)
def result(~S: Data,merged: F.Merge<S,Owned,Owned>) -> String:
  match merged:
    case F.Rejected{e,F.Fragment{_,left},F.Fragment{_,right}}: error(e) ++ ":" ++ show(left) ++ ":" ++ show(right)
    case F.Merged{F.Fragment{_,owners}}: successful(owners)
def case_run(~S: Data,left: List<&2,F.Entry<S>>,right: List<&2,F.Entry<S>>) -> String:
  result(~S,F.merge(~S,~Owned,~Owned,F.fragment(~S,~Owned,left,owner(10)),F.fragment(~S,~Owned,right,owner(20))))
def cases(~S: Data) -> String:
  case_run(~S,[],[]) ++ "\n" ++ case_run(~S,[F.Entry{F.Component{},"a","A"}],[F.Entry{F.Component{},"b","B"}]) ++ "\n" ++ case_run(~S,[F.Entry{F.Component{},"a","A"}],[F.Entry{F.Component{},"a","B"}]) ++ "\n" ++ case_run(~S,[F.Entry{F.Component{},"a","A"}],[F.Entry{F.Component{},"b","A"}]) ++ "\n" ++ case_run(~S,[],[F.Entry{F.Component{},"a","A"},F.Entry{F.Component{},"b","A"}]) ++ "\n" ++ case_run(~S,[F.Entry{F.Component{},"a","A"}],[F.Entry{F.Component{},"a","A"}]) ++ "\n" ++ case_run(~S,[F.Entry{F.Component{},"a","A"}],[F.Entry{F.Resource{},"a","A"}]) ++ "\n" ++ case_run(~S,[F.Entry{F.Component{},"k","A"},F.Entry{F.Event{},"e1","E"},F.Entry{F.Event{},"e2","E"}],[F.Entry{F.Component{},"k","B"}]) ++ "\n" ++ case_run(~S,[F.Entry{F.Component{},"k","A"}],[F.Entry{F.Component{},"k","B"},F.Entry{F.Event{},"e1","E"},F.Entry{F.Event{},"e2","E"}])
def main() -> IO(Unit):
  IO.print(cases(~Schema) ++ "\n" ++ cases(~Other))
