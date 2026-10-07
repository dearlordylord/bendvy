import Base
import ../runtime-app.bend as A
import ../runtime-other.bend as B
import growth-app.bend as GA
import growth-other.bend as GB
import ../runtime-context.bend as X
import ../runtime-context-other.bend as Y
import ../combat-feature.bend as C
import ../core-feature.bend as K
import ../../../src/ecs/feature.bend as F
# Derived by selecting unchanged complete application case expressions.
def render_small() -> String:
  "A-small-selected=" ++ A.run(C.declaration(~X.Schema),K.declaration(~X.Schema)) ++ "\nA-small-duplicate=" ++ A.run(K.declaration(~X.Schema),K.declaration(~X.Schema)) ++ "\nA-small-missing=" ++ A.run(C.declaration(~X.Schema),F.Definition{"Other",[],F.Empty{}}) ++ "\nA-small-priority=" ++ A.run(C.declaration(~X.Schema),C.declaration(~X.Schema)) ++ "\nB-small-selected=" ++ B.run(C.declaration(~Y.Schema),K.declaration(~Y.Schema)) ++ "\nB-small-duplicate=" ++ B.run(K.declaration(~Y.Schema),K.declaration(~Y.Schema)) ++ "\nB-small-missing=" ++ B.run(C.declaration(~Y.Schema),F.Definition{"Other",[],F.Empty{}}) ++ "\nB-small-priority=" ++ B.run(C.declaration(~Y.Schema),C.declaration(~Y.Schema))
def render_grown() -> String:
  "A-grown-selected=" ++ GA.run(C.declaration(~X.Schema),K.declaration(~X.Schema)) ++ "\nA-grown-duplicate=" ++ GA.run(K.declaration(~X.Schema),K.declaration(~X.Schema)) ++ "\nA-grown-missing=" ++ GA.run(C.declaration(~X.Schema),F.Definition{"Other",[],F.Empty{}}) ++ "\nA-grown-priority=" ++ GA.run(C.declaration(~X.Schema),C.declaration(~X.Schema)) ++ "\nB-grown-selected=" ++ GB.run(C.declaration(~Y.Schema),K.declaration(~Y.Schema)) ++ "\nB-grown-duplicate=" ++ GB.run(K.declaration(~Y.Schema),K.declaration(~Y.Schema)) ++ "\nB-grown-missing=" ++ GB.run(C.declaration(~Y.Schema),F.Definition{"Other",[],F.Empty{}}) ++ "\nB-grown-priority=" ++ GB.run(C.declaration(~Y.Schema),C.declaration(~Y.Schema))
