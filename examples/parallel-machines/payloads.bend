import Base

type Actor<-S:Data,-Mode:Data> is Type:
  Actor{identity:Array<U32>,mode:Mode,history:Array<String>}
type PeerActor<-S:Data,-Mode:Data> is Type:
  PeerActor{labels:Array<String>,mode:Mode}
def actor(~S:Data,~Mode:Data,value:Actor<S,Mode>) -> Actor<S,Mode> & Mode:
  match value:
    case Actor{identity,+mode,history}:(Actor{identity,mode,history},mode)
def peer(~S:Data,~Mode:Data,value:PeerActor<S,Mode>) -> PeerActor<S,Mode> & Mode:
  match value:
    case PeerActor{labels,+mode}:(PeerActor{labels,mode},mode)
