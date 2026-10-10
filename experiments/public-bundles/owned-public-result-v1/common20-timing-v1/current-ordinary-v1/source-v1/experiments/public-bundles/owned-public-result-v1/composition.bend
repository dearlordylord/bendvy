import Base
import /workspace/formal-proofs/bendvy/src/ecs/capabilities.bend as Owned
import /workspace/formal-proofs/bendvy/src/ecs/bundle-provider.bend as Public
import /workspace/formal-proofs/bendvy/src/ecs/bundle-requests.bend as Cmd
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W

# Gameplay composes two calls through the same closed capability and opaque H.
# If spawn refuses, both the returned initial Raw and unsubmitted replacement
# remain owned in the result. A successful spawn supplies the actual handle.
type Input<Raw:Type> is Type:
  Input{initial:Raw,replacement:Raw}
type Composed<S:Data,Raw:Type,Error:Data> is Type:
  Composed{first:Cmd.Output<S,Raw,Error>,second:Maybe<&1,Cmd.Output<S,Raw,Error>>,unsubmitted:Maybe<&1,Raw>}
def inserted(~S:Data,~Raw:Type,~Error:Data,~H:Type,target:W.Handle<S>,spawned:Bool,result:H & Cmd.Output<S,Raw,Error>) -> H & Composed<S,Raw,Error>:
  match result:
    case (ctx,second): (ctx,Composed{Cmd.Accepted{target,spawned},Some{second},None{}})
def spawned(~S:Data,~Raw:Type,~Error:Data,~H:Type,~cap:Owned.OwnedRequest<H,Cmd.Input<S,Raw>,Cmd.Output<S,Raw,Error>>,replacement:Raw,result:H & Cmd.Output<S,Raw,Error>) -> H & Composed<S,Raw,Error>:
  match result:
    case (ctx,Cmd.Refused{raw,error}): (ctx,Composed{Cmd.Refused{raw,error},None{},Some{replacement}})
    case (ctx,Cmd.Accepted{+target,spawned}): inserted(~S,~Raw,~Error,~H,target,spawned,Owned.owned_request(~H,~Cmd.Input<S,Raw>,~Cmd.Output<S,Raw,Error>,~cap,ctx,Cmd.Input{Cmd.Insert{target},replacement}))
def run(~S:Data,~Raw:Type,~Error:Data,~H:Type,~cap:Owned.OwnedRequest<H,Cmd.Input<S,Raw>,Cmd.Output<S,Raw,Error>>,input:Input<Raw>,ctx:H) -> H & Composed<S,Raw,Error>:
  match input:
    case Input{initial,replacement}: spawned(~S,~Raw,~Error,~H,~cap,replacement,Owned.owned_request(~H,~Cmd.Input<S,Raw>,~Cmd.Output<S,Raw,Error>,~cap,ctx,Cmd.Input{Cmd.Spawn{},initial}))
