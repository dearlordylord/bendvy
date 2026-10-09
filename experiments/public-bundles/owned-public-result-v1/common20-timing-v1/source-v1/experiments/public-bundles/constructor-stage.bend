import Base
import /workspace/formal-proofs/bendvy-worktrees/parity-41-public-readiness/src/ecs/bundle-pack.bend as BPack

# Experimental reversible constructor RESULT receipts, not a universal Raw->C
# inverse or production Decode policy. Only the trusted author supplies undo.
type Construction<Raw:Type,Cooked:Type,Error:Data> is Type:
  Constructed{cooked:Cooked,undo:Cooked -> Raw}
  Invalid{raw:Raw,error:Error}
type Staged<Context:Type,Raw:Type,Cooked:Type,Error:Data> is Type:
  Valid{context:Context,cooked:Cooked,undo:Cooked -> Raw,positions:List<&2,Maybe<&2,Error>>}
  Failed{context:Context,raw:Raw,positions:List<&2,Maybe<&2,Error>>}
def undo_pack(~HR:Type,~HC:Type,~TR:Type,~TC:Type,headUndo:HC -> HR,tailUndo:TC -> TR,cooked:BPack.Pack<HC,TC>) -> BPack.Pack<HR,TR>:
  match cooked:
    case BPack.Pack{head,tail}: BPack.Pack{headUndo(head),tailUndo(tail)}
def constructed_tail(~Ctx:Type,~HR:Type,~HC:Type,~TR:Type,~TC:Type,~Error:Data,head:HC,headUndo:HC -> HR,tail:Staged<Ctx,TR,TC,Error>) -> Staged<Ctx,BPack.Pack<HR,TR>,BPack.Pack<HC,TC>,Error>:
  match tail:
    case Valid{ctx,cooked,undo,positions}: Valid{ctx,BPack.Pack{head,cooked},p => undo_pack(~HR,~HC,~TR,~TC,headUndo,undo,p),None{} <> positions}
    case Failed{ctx,raw,positions}: Failed{ctx,BPack.Pack{headUndo(head),raw},None{} <> positions}
def invalid_tail(~Ctx:Type,~HR:Type,~HC:Type,~TR:Type,~TC:Type,~Error:Data,head:HR,error:Error,tail:Staged<Ctx,TR,TC,Error>) -> Staged<Ctx,BPack.Pack<HR,TR>,BPack.Pack<HC,TC>,Error>:
  match tail:
    case Valid{ctx,cooked,undo,positions}: Failed{ctx,BPack.Pack{head,undo(cooked)},Some{error} <> positions}
    case Failed{ctx,raw,positions}: Failed{ctx,BPack.Pack{head,raw},Some{error} <> positions}
def constructed_head(~Ctx:Type,~HR:Type,~HC:Type,~TR:Type,~TC:Type,~Error:Data,~stageTail:Ctx -> TR -> Staged<Ctx,TR,TC,Error>,tail:TR,observed:Ctx & Construction<HR,HC,Error>) -> Staged<Ctx,BPack.Pack<HR,TR>,BPack.Pack<HC,TC>,Error>:
  match observed:
    case (ctx,Constructed{head,undo}): constructed_tail(~Ctx,~HR,~HC,~TR,~TC,~Error,head,undo,stageTail(ctx,tail))
    case (ctx,Invalid{head,error}): invalid_tail(~Ctx,~HR,~HC,~TR,~TC,~Error,head,error,stageTail(ctx,tail))
def stage(~Ctx:Type,~HR:Type,~HC:Type,~TR:Type,~TC:Type,~Error:Data,~constructHead:Ctx -> HR -> Ctx & Construction<HR,HC,Error>,~stageTail:Ctx -> TR -> Staged<Ctx,TR,TC,Error>,ctx:Ctx,raw:BPack.Pack<HR,TR>) -> Staged<Ctx,BPack.Pack<HR,TR>,BPack.Pack<HC,TC>,Error>:
  match raw:
    case BPack.Pack{head,tail}: constructed_head(~Ctx,~HR,~HC,~TR,~TC,~Error,~stageTail,tail,constructHead(ctx,head))
def terminal(~Ctx:Type,~Error:Data,ctx:Ctx,raw:Unit) -> Staged<Ctx,Unit,Unit,Error>:
  Valid{ctx,Unit{},u => u,[]}
