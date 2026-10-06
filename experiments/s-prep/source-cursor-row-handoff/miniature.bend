import Base

type OwnedPayload is Type:
  OwnedPayload{cells:Array<U32>,frame:U32}
type DetachedRow<-Schema:Data,-M:Type> is Type:
  DetachedRow{id:U32,owner:M}
type DetachedBatch<-Schema:Data,-M:Type> is Type:
  DetachedBatch{namespace:U32,columns:Array<Maybe<M>>,rows:List<&1,DetachedRow<Schema,M>>}
type MiniSchema is Data:
  MiniSchema{}

def restore_done(-Schema:Data,-M:Type,namespace:U32,columns:Array<Maybe<M>>) -> DetachedBatch<Schema,M>:
  DetachedBatch{namespace,columns,[]}
def restore_rows(-Schema:Data,-M:Type,namespace:U32,rows:List<&1,DetachedRow<Schema,M>>,columns:Array<Maybe<M>>) -> DetachedBatch<Schema,M>:
  match rows:
    case Nil{}: restore_done(Schema,M,namespace,columns)
    case Con{DetachedRow{id,owner},rest}: restore_rows(Schema,M,namespace,rest,Array.set(Maybe<M>,columns,U32.sub(id,1),Some{owner}))
def seal_taken(-Schema:Data,-M:Type,+id:U32,namespace:U32,rows:List<&1,DetachedRow<Schema,M>>,result:Array<Maybe<M>> & Maybe<M>) -> DetachedBatch<Schema,M>:
  match result:
    case (columns,None{}): DetachedBatch{namespace,columns,rows}
    case (columns,Some{owner}): DetachedBatch{namespace,columns,Con{DetachedRow{id,owner},rows}}
def take_one(-Schema:Data,-M:Type,+id:U32,batch:DetachedBatch<Schema,M>) -> DetachedBatch<Schema,M>:
  match batch:
    case DetachedBatch{namespace,columns,rows}: seal_taken(Schema,M,id,namespace,rows,Array.swap(Maybe<M>,columns,U32.sub(id,1),None{}))
def recover(-Schema:Data,-M:Type,batch:DetachedBatch<Schema,M>) -> DetachedBatch<Schema,M>:
  match batch:
    case DetachedBatch{namespace,columns,rows}: restore_rows(Schema,M,namespace,rows,columns)
def render_cells(cells:List<&1,U32>) -> String:
  match cells:
    case Nil{}: ""
    case Con{value,rest}: U32.show(value) ++ "," ++ render_cells(rest)
def next_text(result:Array<Maybe<OwnedPayload>> & Maybe<OwnedPayload>) -> String:
  match result:
    case (columns,None{}): "missing"
    case (columns,Some{OwnedPayload{cells,frame}}): U32.show(frame) ++ ":" ++ render_cells(Array.to_list(~U32,cells))
def first_text(result:Array<Maybe<OwnedPayload>> & Maybe<OwnedPayload>) -> String:
  match result:
    case (columns,None{}): "missing"
    case (columns,Some{OwnedPayload{cells,frame}}): U32.show(frame) ++ ":" ++ render_cells(Array.to_list(~U32,cells)) ++ "|" ++ next_text(Array.swap(Maybe<OwnedPayload>,columns,1,None{}))
def restored_text(batch:DetachedBatch<MiniSchema,OwnedPayload>) -> String:
  match batch:
    case DetachedBatch{namespace,columns,rows}: U32.show(namespace) ++ ":" ++ first_text(Array.swap(Maybe<OwnedPayload>,columns,0,None{}))
def render_taken_rows(-Schema:Data,-M:Type,rows:List<&1,DetachedRow<Schema,M>>,columns:Array<Maybe<M>>,order:String) -> String:
  match rows:
    case Nil{}: order
    case Con{DetachedRow{+id,owner},rest}: render_taken_rows(Schema,M,rest,Array.set(Maybe<M>,columns,U32.sub(id,1),Some{owner}),order ++ U32.show(id) ++ ",")
def order_text(batch:DetachedBatch<MiniSchema,OwnedPayload>) -> String:
  match batch:
    case DetachedBatch{namespace,columns,rows}: render_taken_rows(MiniSchema,OwnedPayload,rows,columns,"")
def one() -> DetachedBatch<MiniSchema,OwnedPayload>:
  DetachedBatch{7,ALeaf{Some{OwnedPayload{[31:U32^2n],88}}},[]}
def two() -> DetachedBatch<MiniSchema,OwnedPayload>:
  DetachedBatch{7,ANode{ALeaf{Some{OwnedPayload{Array.set(U32,[31:U32^1n],1,32),88}}},ALeaf{Some{OwnedPayload{Array.set(U32,[41:U32^1n],1,42),99}}}},[]}
def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(restored_text(recover(MiniSchema,OwnedPayload,take_one(MiniSchema,OwnedPayload,1,one()))))
    IO.print(order_text(take_one(MiniSchema,OwnedPayload,1,take_one(MiniSchema,OwnedPayload,2,two()))))
    IO.print(restored_text(recover(MiniSchema,OwnedPayload,take_one(MiniSchema,OwnedPayload,1,take_one(MiniSchema,OwnedPayload,2,two())))))
    return Unit{}
