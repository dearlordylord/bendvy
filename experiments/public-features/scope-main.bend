import Base
import scope-control.bend as A
import scope-other.bend as B
import core-feature.bend as Core
import combat-feature.bend as Combat
import recipe-app.bend as X
import recipe-other.bend as Y
import feature.bend as F
import provider.bend as P
import ../../src/ecs/schema-fragments.bend as SF
import ../../src/ecs/component.bend as C
def main() -> IO(Unit):
  IO.print("A-dependency=" ++ A.run(Combat.declaration(~X.Schema),[SF.Entry{SF.Component{},"core","core"}]) ++ "\nA-undeclared=" ++ A.run(Core.declaration(~X.Schema),[SF.Entry{SF.Component{},"combat","combat"}]) ++ "\nA-transitive=" ++ A.run(F.Definition{"Addon",[SF.Entry{SF.Component{},"addon","addon"}],Combat.definition(~X.Schema)},[SF.Entry{SF.Component{},"core","core"}]) ++ "\nA-repeated=" ++ A.run(F.Definition{"Combat",[SF.Entry{SF.Component{},"combat","combat"}],F.Sequence{Core.definition(~X.Schema),Core.definition(~X.Schema)}},[SF.Entry{SF.Component{},"core","core"}]) ++ "\nA-conflict=" ++ A.run(F.Definition{"Combat",[SF.Entry{SF.Component{},"combat","combat"}],F.Sequence{Core.definition(~X.Schema),F.Feature{"Core",[SF.Entry{SF.Component{},"core","different"}],F.Empty{}}}},[SF.Entry{SF.Component{},"core","core"}]) ++ "\nA-retry=" ++ A.retry(P.bind_feature(~X.Schema,~Array<U32>,~(Array<U32> & C.Access<U32>),~A.build,Core.declaration(~X.Schema),[SF.Entry{SF.Component{},"combat","combat"}],ANode{ALeaf{11},ALeaf{12}})) ++ "\nB-dependency=" ++ B.run(Combat.declaration(~Y.Schema),[SF.Entry{SF.Component{},"core","core"}]) ++ "\nB-undeclared=" ++ B.run(Core.declaration(~Y.Schema),[SF.Entry{SF.Component{},"combat","combat"}]) ++ "\nB-transitive=" ++ B.run(F.Definition{"Addon",[SF.Entry{SF.Component{},"addon","addon"}],Combat.definition(~Y.Schema)},[SF.Entry{SF.Component{},"core","core"}]) ++ "\nB-repeated=" ++ B.run(F.Definition{"Combat",[SF.Entry{SF.Component{},"combat","combat"}],F.Sequence{Core.definition(~Y.Schema),Core.definition(~Y.Schema)}},[SF.Entry{SF.Component{},"core","core"}]) ++ "\nB-conflict=" ++ B.run(F.Definition{"Combat",[SF.Entry{SF.Component{},"combat","combat"}],F.Sequence{Core.definition(~Y.Schema),F.Feature{"Core",[SF.Entry{SF.Component{},"core","different"}],F.Empty{}}}},[SF.Entry{SF.Component{},"core","core"}]) ++ "\nB-retry=" ++ B.retry(P.bind_feature(~Y.Schema,~Array<U32>,~(Array<U32> & C.Access<U32>),~B.build,Core.declaration(~Y.Schema),[SF.Entry{SF.Component{},"combat","combat"}],ANode{ALeaf{11},ALeaf{12}})))
