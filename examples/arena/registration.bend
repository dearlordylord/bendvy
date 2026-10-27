import Base
import ./schema.bend as D
import ./system.bend as Decay
import ./spawn.bend as Spawn
import ./root.bend as Root
import ./gameplay.bend as G
import ../../src/ecs/execution-system.bend as Sys
import ../../src/ecs/execution-parallel-system.bend as System
import ../../src/ecs/execution-parallel-scope.bend as Scope
import ../../src/ecs/execution-generalized-command-leaf.bend as Author
import ../../src/ecs/execution-command-system.bend as Cmd

def peer(left:Root.Binding(),result:Root.PeerCompilation() & Sys.Defined<D.World(),Root.Peer(),Cmd.Captures(~D.Schema,~D.components(),~D.resources(),~Decay.route(),~Decay.User)>) -> Maybe<Root.Application()>:
  match result:
    case (compilation,Sys.Defined{world,owner}):Some{Root.build(world,left,Scope.CompiledBinding{compilation,owner})}
    case _:None{}
def author(result:Root.Compilation() & Sys.Defined<D.World(),Root.Owner(),Cmd.Captures(~D.Schema,~D.components(),~D.resources(),~Spawn.route(),~Spawn.User)>) -> Maybe<Root.Application()>:
  match result:
    case (compilation,Sys.Defined{world,owner}):peer(Scope.CompiledBinding{compilation,owner},Author.define_with_compilation(~D.Schema,~D.components(),~D.resources(),~Unit,~Decay.route(),~Decay.Ops,~Decay.User,~String,~Unit,~Decay.declaration,~Decay.body,~{==},Decay.compilation(),world,"Arena body update",Decay.User{False{},G.Args{400.0,250.0,5,0,False{},[]},[]}))
    case _:None{}
def attach(world:D.World(),seeds:List<&2,G.Body>) -> Maybe<Root.Application()>:
  author(Author.define_with_compilation(~D.Schema,~D.components(),~D.resources(),~Unit,~Spawn.route(),~Spawn.Ops,~Spawn.User,~String,~Unit,~Spawn.declaration,~Spawn.body,~{==},Spawn.compilation(),world,"Arena spawns",Spawn.User{seeds,[],[]}))
