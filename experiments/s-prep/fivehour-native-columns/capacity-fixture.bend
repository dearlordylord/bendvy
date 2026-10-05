import Base
import ./storage.bend as S
type Owner is Type:
  Owner{cells:Array<U32>}
def value_done(+id:U32,m:Array<Maybe<Owner>>,a:Array<Maybe<Owner>>,f:Array<S.Metadata<U32>>,+c:U32,d:Nat,h:U32,result:Array<U32> & U32) -> S.Rows<Owner,Owner,U32> & String:
  match result:
    case (cells,value): (S.Rows{S.native_column_set(Maybe<Owner>,m,c,U32.sub(id,1),Some{Owner{cells}}),a,f,c,d,h},U32.show(value))
def probe_done(+id:U32,result:S.Rows<Owner,Owner,U32> & S.Taken<Owner>) -> S.Rows<Owner,Owner,U32> & String:
  match result:
    case (rows,S.NoEntity{}): (rows,"E")
    case (rows,S.NoMain{}): (rows,"N")
    case (S.Rows{m,a,f,+c,d,h},S.Taken{Owner{cells}}): value_done(id,m,a,f,c,d,h,Array.get(U32,cells,3))
def probe(rows:S.Rows<Owner,Owner,U32>,+id:U32) -> S.Rows<Owner,Owner,U32> & String:
  probe_done(id,S.native_take_rows(~Owner,~Owner,~U32,rows,id))
def sizes(+id:U32,capacity:U32,zero:String,beyond:String,last:String,result:(Array<Maybe<Owner>> & U32) & ((Array<Maybe<Owner>> & U32) & (Array<S.Metadata<U32>> & U32))) -> IO(Unit):
  match result:
    case ((_,ms),((_,auxsz),(_,fs))): IO.print(U32.show(id) ++ ":" ++ U32.show(capacity) ++ ":" ++ U32.show(ms) ++ ":" ++ U32.show(auxsz) ++ ":" ++ U32.show(fs) ++ ":" ++ zero ++ ":" ++ beyond ++ ":" ++ last)
def last_done(+id:U32,zero:String,beyond:String,result:S.Rows<Owner,Owner,U32> & String) -> IO(Unit):
  match result:
    case (S.Rows{m,a,f,capacity,_,_},last): sizes(id,capacity,zero,beyond,last,(Array.size(Maybe<Owner>,m),(Array.size(Maybe<Owner>,a),Array.size(S.Metadata<U32>,f))))
def beyond_done(+id:U32,zero:String,result:S.Rows<Owner,Owner,U32> & String) -> IO(Unit):
  match result:
    case (rows,beyond): last_done(id,zero,beyond,probe(rows,id))
def zero_done(+id:U32,result:S.Rows<Owner,Owner,U32> & String) -> IO(Unit):
  match result:
    case (rows,zero): beyond_done(id,zero,probe(rows,U32.add(id,1)))
def report(+id:U32,placement:S.Placement<Owner,Owner,U32>) -> IO(Unit):
  match placement:
    case S.Rejected{_,_}: IO.print("REJECTED")
    case S.Placed{rows}: zero_done(id,probe(rows,0))
def one(+id:U32) -> IO(Unit):
  report(id,S.rows_place(Owner,Owner,U32,S.rows_empty(Owner,Owner,U32),S.Row{id,Some{Owner{[37:U32^2n]}},Some{Owner{[91:U32^2n]}},None{},7,9}))
def cases(fuel:Nat,+id:U32) -> IO(Unit):
  match fuel:
    case 0n: one(65537)
    case 1n+n:
      do IO<Unit>:
        one(id)
        cases(n,U32.add(id,id))
def main() -> IO(Unit):
  cases(17n,1)
