import Base
import ../payloads.bend as P
import ../declarations.bend as D
import ../output-declaration.bend as Decl
import ../../../src/ecs/execution-builder.bend as Build
import ../../../src/ecs/execution-command-local.bend as Local
import ../../../src/ecs/execution-command-buffer.bend as Buffer
import ../../../src/ecs/execution-state.bend as State
import ../../../src/ecs/execution-declaration.bend as Grant
import ../../../src/ecs/execution-query.bend as Query

type Schema is Data:
  Schema{}
def Ops(H:Type) -> Type:Query.OutputEach<Schema,H,Buffer.Buffer<Schema,P.Output,Unit>,String>
def declaration(~H:Type,~B:Type,~builder:Build.Builder(~Schema,~D.Store(~Schema),~D.Store(~Schema),~D.Resources(~Schema),~H,~B),book:B) -> B & Ops(H):
  Decl.declaration(~Schema,~D.Store(~Schema),~Query.Parallel{},~H,~Buffer.Buffer<Schema,P.Output,Unit>,~Local.Commands{Buffer.insert(~Schema,~P.Output,~Unit),Buffer.remove(~Schema,~P.Output,~Unit),Buffer.split(~Schema,~P.Output,~Unit),Buffer.merge(~Schema,~P.Output,~Unit)},~B,~builder,book)
def invoke(scope:State.Scope<Schema,D.Store(~Schema),D.Resources(~Schema)>,output:Buffer.Buffer<Schema,P.Output,Unit>) -> State.Scope<Schema,D.Store(~Schema),D.Resources(~Schema)> & (Buffer.Buffer<Schema,P.Output,Unit> & Query.Report<String>):
  Query.each_output(~Schema,~State.Scope<Schema,D.Store(~Schema),D.Resources(~Schema)>,~Buffer.Buffer<Schema,P.Output,Unit>,~String,Grant.grants(~Schema,~D.Store(~Schema),~D.Resources(~Schema),~Ops,Build.compile(~Schema,~D.Store(~Schema),~D.Store(~Schema),~D.Resources(~Schema),~Ops,~declaration)))(scope,output)
