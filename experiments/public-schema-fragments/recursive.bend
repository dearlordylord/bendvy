import Base
import ../../src/ecs/schema-fragments.bend as F
import merges.bend as M

def final(owners: (M.Owned & M.Owned) & U32) -> String:
  ((left,right),third) = owners
  M.show(left) ++ ":" ++ M.show(right) ++ ":" ++ U32.show(third)
def third(~S: Data,result: F.Merge<S,M.Owned & M.Owned,U32>) -> String:
  match result:
    case F.Merged{F.Fragment{_,owners}}: final(owners)
    case F.Rejected{_,_,_}: "unexpected-third-rejection"
def second(~S: Data,result: F.Merge<S,M.Owned,M.Owned>) -> String:
  match result:
    case F.Merged{fragment}: third(~S,F.merge(~S,~M.Owned & M.Owned,~U32,fragment,F.fragment(~S,~U32,[F.Entry{F.Resource{},"third","Third"}],7)))
    case F.Rejected{_,_,_}: "unexpected-second-rejection"
def run(~S: Data) -> String:
  second(~S,F.merge(~S,~M.Owned,~M.Owned,F.fragment(~S,~M.Owned,[F.Entry{F.Component{},"left","Left"}],M.owner(10)),F.fragment(~S,~M.Owned,[F.Entry{F.Component{},"right","Right"}],M.owner(20))))
def main() -> IO(Unit):
  IO.print(run(~M.Schema) ++ "\n" ++ run(~M.Other))
