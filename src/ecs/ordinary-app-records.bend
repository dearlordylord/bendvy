import Base
import ./ordinary-app-registration-fields.bend as Stored
# Advanced application carrier pairing actual affine registration Token
# with its detached Fields. Fields alone do not replace registration authority;
# keep token and metadata from the same registration together.
type Record<S:Data,Token:Type> is Type:
  Record{token:Token,fields:Stored.Fields<S>}
# Return the record owner together with its one detached Fields entry.
# Does not invoke the registration, advance its cursor or read payloads.
def observed(~S:Data,~Token:Type,record:Record<S,Token>) -> Record<S,Token> & List<&2,Stored.Fields<S>>:
  match record:
    case Record{token,+fields}:(Record{token,fields},[fields])
def second(~S:Data,~Left:Type,~Right:Type,left:Left,before:List<&2,Stored.Fields<S>>,result:Right & List<&2,Stored.Fields<S>>) -> (Left & Right) & List<&2,Stored.Fields<S>>:
  match result:
    case (right,after):((left,right),List.append(&2,Stored.Fields<S>,before,after))
def first(~S:Data,~Left:Type,~Right:Type,rightFold:Right -> Right & List<&2,Stored.Fields<S>>,right:Right,result:Left & List<&2,Stored.Fields<S>>) -> (Left & Right) & List<&2,Stored.Fields<S>>:
  match result:
    case (left,before):second(~S,~Left,~Right,left,before,rightFold(right))
# Advanced metadata fold over heterogeneous owners in left/right order.
# Returns both owners and appended detached fields; supplied folds must
# preserve their owned registrations rather than fabricate authority.
def pair(~S:Data,~Left:Type,~Right:Type,leftFold:Left -> Left & List<&2,Stored.Fields<S>>,rightFold:Right -> Right & List<&2,Stored.Fields<S>>,owners:Left & Right) -> (Left & Right) & List<&2,Stored.Fields<S>>:
  match owners:
    case (left,right):first(~S,~Left,~Right,rightFold,right,leftFold(left))
# Unit-owner base metadata fold, returning the same Unit and no fields.
# Does not register a system or infer metadata from arbitrary owners.
def empty(~S:Data,unit:Unit) -> Unit & List<&2,Stored.Fields<S>>:
  (unit,[])
# Closed advanced adapter composing two metadata folds with the same
# owner-threading and left/right order as pair; does not execute systems.
def fold_pair(~S:Data,~Left:Type,~Right:Type,~left:Left -> Left & List<&2,Stored.Fields<S>>,~right:Right -> Right & List<&2,Stored.Fields<S>>,owners:Left & Right) -> (Left & Right) & List<&2,Stored.Fields<S>>:
  pair(~S,~Left,~Right,left,right,owners)
