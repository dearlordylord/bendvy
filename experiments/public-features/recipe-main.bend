import Base
import recipe-app.bend as A
import recipe-other.bend as B
import core-feature.bend as Core
import combat-feature.bend as Combat
import feature.bend as F
def main() -> IO(Unit):
  IO.print("A-selected=" ++ A.run(Combat.declaration(~A.Schema),Core.declaration(~A.Schema)) ++ "\nA-duplicate=" ++ A.run(Core.declaration(~A.Schema),Core.declaration(~A.Schema)) ++ "\nA-missing=" ++ A.run(Combat.declaration(~A.Schema),F.Definition{"Other",[],F.Empty{}}) ++ "\nA-priority=" ++ A.run(Combat.declaration(~A.Schema),Combat.declaration(~A.Schema)) ++ "\nB-selected=" ++ B.run(Combat.declaration(~B.Schema),Core.declaration(~B.Schema)) ++ "\nB-duplicate=" ++ B.run(Core.declaration(~B.Schema),Core.declaration(~B.Schema)) ++ "\nB-missing=" ++ B.run(Combat.declaration(~B.Schema),F.Definition{"Other",[],F.Empty{}}) ++ "\nB-priority=" ++ B.run(Combat.declaration(~B.Schema),Combat.declaration(~B.Schema)))
