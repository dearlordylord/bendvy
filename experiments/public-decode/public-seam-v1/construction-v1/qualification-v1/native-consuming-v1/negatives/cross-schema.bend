import Base
import ../../canonical-v1/source/fixture.bend as Input
import /workspace/formal-proofs/bendvy/src/ecs/decode-construction.bend as Constructor
import /workspace/formal-proofs/bendvy/src/ecs/persistence-declaration.bend as Decl
import /workspace/formal-proofs/bendvy/src/ecs/decode-data.bend as D
# The nominal schema/index is retained in the actual constructor declaration.
def invalid() -> Constructor.Factory<Input.Second,Input.Input,Input.Owner,Input.identity(~Input.Second),Input.project,Input.incoming,Input.build>:
  Constructor.factory(~Input.First,~Input.Input,~Input.Owner,~Input.identity(~Input.First),~Input.project,~Input.incoming,~Input.build,Decl.constructed(~Input.First,~Input.Owner,~Input.identity(~Input.First),~Input.project,D.Integer{}))
