import Base

type Main is Type:
  Main{cells: Array<U32>, tag: U32}
type SlotResult is Type:
  SlotResult{array: Array<Maybe<Main>>, old: Maybe<Main>, accepted: Bool}
def main_owner(value: U32) -> Main:
  Main{ANode{ANode{ALeaf{value},ALeaf{2}},ANode{ALeaf{3},ALeaf{4}}},7}
def seed() -> Array<Maybe<Main>>:
  ANode{ANode{ALeaf{Some{main_owner(10)}},ALeaf{None{}}},ANode{ALeaf{Some{main_owner(30)}},ALeaf{Some{main_owner(40)}}}}
def done(result: Array<Maybe<Main>> & Maybe<Main>) -> SlotResult:
  match result:
    case (array,old): SlotResult{array,old,True{}}
def checked(~swapper: Array<Maybe<Main>> -> @+capacity:U32 -> @+index:U32 -> Maybe<Main> -> Array<Maybe<Main>> & Maybe<Main>,array: Array<Maybe<Main>>,value: Main,valid: Bool,+capacity: U32,id: U32) -> SlotResult:
  match valid:
    case False{}: SlotResult{array,Some{value},False{}}
    case True{}: done(swapper(array,capacity,U32.sub(id,1),Some{value}))
def guarded(~swapper: Array<Maybe<Main>> -> @+capacity:U32 -> @+index:U32 -> Maybe<Main> -> Array<Maybe<Main>> & Maybe<Main>,array: Array<Maybe<Main>>,value: Main,+capacity: U32,+id: U32,foreign: U32) -> SlotResult:
  checked(~swapper,array,value,Bool.and(U32.is_eq(foreign,1),Bool.and((0 < id : U32),Bool.and((id <= capacity : U32),Bool.and((0 < capacity : U32),U32.is_eq(U32.and(capacity,U32.sub(capacity,1)),0))))),capacity,id)
def show_main(value: Main) -> String:
  match value:
    case Main{cells,tag}: List.show(&1,U32,U32.show,Array.to_list(U32,cells)) ++ ":" ++ U32.show(tag)
def show_optional(value: Maybe<Main>) -> String:
  match value:
    case None{}: "none"
    case Some{value}: show_main(value)
def show_result(result: SlotResult) -> String:
  match result:
    case SlotResult{array,old,accepted}: List.show(&1,Maybe<Main>,show_optional,Array.to_list(Maybe<Main>,array)) ++ ":old=" ++ show_optional(old) ++ ":" ++ Bool.show(accepted)
def data_done(result: Array<U32> & U32) -> String:
  match result:
    case (array,value): List.show(&1,U32,U32.show,Array.to_list(U32,array)) ++ ":" ++ U32.show(value)
def data_set(~getter: Array<U32> -> @+capacity:U32 -> @+index:U32 -> Array<U32> & U32,~setter: Array<U32> -> @+capacity:U32 -> @+index:U32 -> U32 -> Array<U32>,array: Array<U32>) -> String:
  data_done(getter(setter(array,4,2,99),4,2))
def run(~swapper: Array<Maybe<Main>> -> @+capacity:U32 -> @+index:U32 -> Maybe<Main> -> Array<Maybe<Main>> & Maybe<Main>,~getter: Array<U32> -> @+capacity:U32 -> @+index:U32 -> Array<U32> & U32,~setter: Array<U32> -> @+capacity:U32 -> @+index:U32 -> U32 -> Array<U32>) -> IO(Unit):
  do IO<Unit>:
    IO.print(show_result(guarded(~swapper,seed(),main_owner(90),4,1,1)))
    IO.print(show_result(guarded(~swapper,seed(),main_owner(20),4,2,1)))
    IO.print(show_result(guarded(~swapper,seed(),main_owner(90),4,0,1)))
    IO.print(show_result(guarded(~swapper,seed(),main_owner(90),4,5,1)))
    IO.print(show_result(guarded(~swapper,seed(),main_owner(90),4,1,2)))
    IO.print(data_set(~getter,~setter,ANode{ANode{ALeaf{1},ALeaf{2}},ANode{ALeaf{3},ALeaf{4}}}))
