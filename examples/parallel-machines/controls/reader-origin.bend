import Base
import ../../../src/ecs/execution-resource-policy.bend as Policy
import ../declarations.bend as D
import ../payloads.bend as P
import ../events.bend as Events
import ../../../src/ecs/execution-machine-stream.bend as Stream
import ../../../src/ecs/execution-composer-layout.bend as Layout

def unlike(~S:Data) -> Layout.Layout:Layout.LayoutPair{D.layout(~S),Layout.LayoutLeaf{P.PeerActor<S,D.Mode>,D.Mode,P.peer(~S,~D.Mode),"extra-affine-resource",Policy.Ordinary{}}}
def forbidden(~S:Data,reader:Events.Reader(~S)) -> Stream.Reader<S,D.Key,D.Mode,unlike(~S),Layout.InLeft{Layout.AtLeaf{}}>:reader
