import Base

type Buffer is Data:
  Buffer{chunks:List<&2,String>,pieces:List<&2,String>,remaining:Nat}
def empty() -> Buffer:Buffer{[],[],4096n}
def join_rev(values:List<&2,String>,acc:String) -> String:
  match values:
    case []:acc
    case head <> rest:join_rev(rest,String.append(head,acc))
def added(chunks:List<&2,String>,pieces:List<&2,String>,value:String,remaining:Nat) -> Buffer:
  match remaining:
    case 0n:Buffer{join_rev(value <> pieces,SNil{}) <> chunks,[],4096n}
    case 1n+rest:Buffer{chunks,value <> pieces,1n+rest}
def piece(value:String,count:Nat,buffer:Buffer) -> Buffer:
  match buffer:
    case Buffer{chunks,pieces,remaining}:added(chunks,pieces,value,Nat.sub(remaining,count))
def allowance_checked(remaining:Nat,fits:Bool) -> Nat:
  match fits:
    case True{}:remaining
    case False{}:64n
def allowance(+remaining:Nat) -> Nat:allowance_checked(remaining,Nat.is_le(remaining,64n))
def room(buffer:Buffer) -> Buffer & Nat:
  match buffer:
    case Buffer{chunks,pieces,+remaining}:(Buffer{chunks,pieces,remaining},remaining)
def done(origin:String,used:Nat,buffer:Buffer) -> Buffer:
  match used:
    case 0n:buffer
    case 1n+rest:piece(origin,1n+rest,buffer)
def normalize_remaining(value:Nat) -> Nat:
  match value:
    case 0n:4096n
    case 1n+rest:1n+rest
def text_go(value:String,origin:String,+used:Nat,left:Nat,remaining:Nat,buffer:Buffer) -> Buffer:
  match value:
    case SNil{}:done(origin,used,buffer)
    case SCon{_,+rest}:
      match left:
        case 0n:buffer
        case 1n+more:
          match more:
            case 0n:
              +nextRemaining=normalize_remaining(Nat.sub(remaining,1n+used))
              text_go(rest,rest,0n,allowance(nextRemaining),nextRemaining,piece(String.take(origin,1n+used),1n+used,buffer))
            case 1n+tail:text_go(rest,origin,1n+used,1n+tail,remaining,buffer)
def text_next(+value:String,observed:Buffer & Nat) -> Buffer:
  match observed:
    case (buffer,+count):text_go(value,value,0n,allowance(count),count,buffer)
def text(value:String,buffer:Buffer) -> Buffer:text_next(value,room(buffer))
# Trusted private count is the exact actual Char count supplied by Doc smart constructors.
def known_fields(value:String,+count:Nat,chunks:List<&2,String>,pieces:List<&2,String>,+remaining:Nat,fits:Bool) -> Buffer:
  match fits:
    case True{}:added(chunks,pieces,value,Nat.sub(remaining,count))
    case False{}:text(value,Buffer{chunks,pieces,remaining})
def known(value:String,count:Nat,buffer:Buffer) -> Buffer:
  match count buffer:
    case 0n,buffer:buffer
    case 1n++rest,Buffer{chunks,pieces,+remaining}:known_fields(value,1n+rest,chunks,pieces,remaining,Nat.is_le(1n+rest,remaining))
def write_chunks(chunks:List<&2,String>,last:String) -> IO(Unit):
  match chunks:
    case []:IO.write(last)
    case head <> rest:IO.bind(Unit,Unit,IO.write(head),_=>write_chunks(rest,last))
def write(value:Buffer) -> IO(Unit):
  match value:
    case Buffer{chunks,pieces,_}:write_chunks(List.reverse(&2,String,chunks),join_rev(pieces,SNil{}))
