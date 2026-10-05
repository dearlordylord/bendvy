import Base

type Owner is Type:
  Owner{values:Array<U32>}
type Token is Data:
  Token{}
type Providers is Data:
  Providers{get:Owner -> Token -> Owner & U32,set:Owner -> Token -> U32 -> Owner}
def get_done(result:Array<U32> & U32) -> Owner & U32:
  match result:
    case (values,value): (Owner{values},value)
def get(owner:Owner,token:Token) -> Owner & U32:
  match owner token:
    case Owner{values} Token{}: get_done(Array.get(U32,values,0))
def set_done(result:Array<U32> & U32) -> Owner:
  match result:
    case (values,_): Owner{values}
def set(owner:Owner,token:Token,value:U32) -> Owner:
  match owner token:
    case Owner{values} Token{}: set_done(Array.swap(U32,values,0,value))
def applied(setter:Owner -> Token -> U32 -> Owner,result:Owner & U32) -> Owner:
  match result:
    case (owner,value): setter(owner,Token{},U32.add(value,1))
def finish(-O:Type,setter:O -> Token -> U32 -> O,result:O & U32) -> O:
  match result:
    case (owner,value): setter(owner,Token{},U32.add(value,1))
def apply(-O:Type,getter:O -> Token -> O & U32,setter:O -> Token -> U32 -> O,owner:O) -> O:
  finish(O,setter,getter(owner,Token{}))
def loop(fuel:Nat,+providers:Providers,owner:Owner) -> Owner:
  match fuel providers:
    case 0n _: owner
    case 1n+rest Providers{+getter,+setter}: loop(rest,Providers{getter,setter},apply(Owner,getter,setter,owner))
def main() -> IO(Unit):
  IO.pure(Unit,Unit{})
