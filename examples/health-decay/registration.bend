import Base
import ./schema.bend as D
import ./system.bend as Decay
import ./spawn.bend as Spawn
import ./root.bend as Root
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-system.bend as System
import ../../src/ecs/execution-parallel-scope.bend as Scope
import ../../src/ecs/execution-generalized-command-leaf.bend as Author
import ../../src/ecs/execution-command-system.bend as Cmd

def peer(left:Root.Binding(),result:Root.PeerCompilation() & Sys.Defined<D.World(),Root.Peer(),Unit>) -> Maybe<Root.Application()>:
  match result:
    case (compilation,Sys.Defined{world,owner}):Some{Root.build(world,left,Scope.CompiledBinding{compilation,owner})}
    case _:None{}
def author(result:Root.Compilation() & Sys.Defined<D.World(),Root.Owner(),Cmd.Captures(~D.Schema,~D.components(),~D.resources(),~Spawn.route(),~Spawn.User)>) -> Maybe<Root.Application()>:
  match result:
    case (compilation,Sys.Defined{world,owner}):peer(Scope.CompiledBinding{compilation,owner},System.define_with_compilation(~D.Schema,~D.Columns(),~Decay.C(),~Decay.R(),~Unit,~Decay.Ops,~Unit,~String,~Unit,~Decay.kernel,~Decay.body,~D.Resources(),Decay.compiled(),world,"Health decay",Unit{}))
    case _:None{}
def attach(world:D.World()) -> Maybe<Root.Application()>:
  author(Author.define_with_compilation(~D.Schema,~D.components(),~D.resources(),~Unit,~Spawn.route(),~Spawn.Ops,~Spawn.User,~String,~Unit,~Spawn.declaration,~Spawn.body,~{==},Spawn.compilation(),world,"Deferred seeds",Spawn.initial()))
