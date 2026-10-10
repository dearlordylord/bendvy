import Base
import ../runtime-registration-records-v1/records.bend as Stored
type Record<S:Data,Token:Type> is Type:
  Record{token:Token,fields:Stored.Fields<S>}
def observed(~S:Data,~Token:Type,record:Record<S,Token>) -> Record<S,Token> & List<&2,Stored.Fields<S>>:
  match record:
    case Record{token,+fields}:(Record{token,fields},[fields])
def second(~S:Data,~Left:Type,~Right:Type,left:Left,before:List<&2,Stored.Fields<S>>,result:Right & List<&2,Stored.Fields<S>>) -> (Left & Right) & List<&2,Stored.Fields<S>>:
  match result:
    case (right,after):((left,right),List.append(&2,Stored.Fields<S>,before,after))
def first(~S:Data,~Left:Type,~Right:Type,rightFold:Right -> Right & List<&2,Stored.Fields<S>>,right:Right,result:Left & List<&2,Stored.Fields<S>>) -> (Left & Right) & List<&2,Stored.Fields<S>>:
  match result:
    case (left,before):second(~S,~Left,~Right,left,before,rightFold(right))
def pair(~S:Data,~Left:Type,~Right:Type,leftFold:Left -> Left & List<&2,Stored.Fields<S>>,rightFold:Right -> Right & List<&2,Stored.Fields<S>>,owners:Left & Right) -> (Left & Right) & List<&2,Stored.Fields<S>>:
  match owners:
    case (left,right):first(~S,~Left,~Right,rightFold,right,leftFold(left))
def empty(~S:Data,unit:Unit) -> Unit & List<&2,Stored.Fields<S>>:
  (unit,[])
