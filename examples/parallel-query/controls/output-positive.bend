import Base
import ../payloads.bend as P
import ../declarations.bend as D
import ../output-declaration.bend as Decl
import ../../../src/ecs/execution-builder.bend as Build
import ../../../src/ecs/execution-command-local.bend as Local
import ../../../src/ecs/execution-command-buffer.bend as Buffer
import ../../../src/ecs/execution-command-permission.bend as Permission
import ../../../src/ecs/execution-query.bend as Query

type Schema is Data:
  Schema{}
def Ops(Permit:Data,H:Type) -> Type:Query.TaskOutputEach<Schema,Permit,H,Buffer.Buffer<Schema,P.Output,Unit>,String>
def declaration(~Permit:Data,~H:Type,~entity:Permission.EntityCommands<Buffer.Buffer<Schema,P.Output,Unit>,Schema,D.layout(),Permit>,~B:Type,~builder:Build.Builder(~Schema,~D.Store(~Schema),~D.Store(~Schema),~D.Resources(~Schema),~Permit,~H,~B),book:B) -> B & Ops(Permit,H):
  Decl.declaration(~Schema,~D.Store(~Schema),~Query.Parallel{},~Permit,~H,~Buffer.Buffer<Schema,P.Output,Unit>,~Local.canonical(~Schema,~P.Output,~Unit),~Permission.despawn_field(~Buffer.Buffer<Schema,P.Output,Unit>,~Schema,~D.layout(),~Permit,entity),~B,~builder,book)
