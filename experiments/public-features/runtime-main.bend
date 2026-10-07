import Base
import runtime-app.bend as A
import runtime-other.bend as B
import runtime-context.bend as X
import runtime-context-other.bend as Y
import combat-feature.bend as Combat
import core-feature.bend as Core
import feature.bend as F
def main() -> IO(Unit):
  IO.print("A-selected=" ++ A.run(Combat.declaration(~X.Schema),Core.declaration(~X.Schema)) ++ "\nA-duplicate=" ++ A.run(Core.declaration(~X.Schema),Core.declaration(~X.Schema)) ++ "\nA-missing=" ++ A.run(Combat.declaration(~X.Schema),F.Definition{"Other",[],F.Empty{}}) ++ "\nA-priority=" ++ A.run(Combat.declaration(~X.Schema),Combat.declaration(~X.Schema)) ++ "\nA-foreign=" ++ A.foreign() ++ "\nA-sequence=" ++ A.sequence() ++ "\nA-marker=" ++ A.marker() ++ "\nB-selected=" ++ B.run(Combat.declaration(~Y.Schema),Core.declaration(~Y.Schema)) ++ "\nB-duplicate=" ++ B.run(Core.declaration(~Y.Schema),Core.declaration(~Y.Schema)) ++ "\nB-missing=" ++ B.run(Combat.declaration(~Y.Schema),F.Definition{"Other",[],F.Empty{}}) ++ "\nB-priority=" ++ B.run(Combat.declaration(~Y.Schema),Combat.declaration(~Y.Schema)) ++ "\nB-foreign=" ++ B.foreign() ++ "\nB-sequence=" ++ B.sequence() ++ "\nB-marker=" ++ B.marker())
