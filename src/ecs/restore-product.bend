import Base
import ./change-tick.bend as Tick
import ./world.bend as W
import ./restore-data.bend as R
import ./decode-data.bend as D
import ./owner-product.bend as Product

def staged_right(~L:Type,~Right:Type,~Custom:Data,left:L,observed:Right & R.Dispatch<Custom>) -> Product.Owner<L,Right> & R.Dispatch<Custom>:
  match observed:
    case (right,result):(Product.Owner{left,right},result)
def staged_left(~L:Type,~Right:Type,~Custom:Data,~stageRight:Right -> R.Position -> D.Field -> Right & R.Dispatch<Custom>,right:Right,position:R.Position,field:D.Field,observed:L & R.Dispatch<Custom>) -> Product.Owner<L,Right> & R.Dispatch<Custom>:
  match observed:
    case (left,R.Unhandled{}):staged_right(~L,~Right,~Custom,left,stageRight(right,position,field))
    case (left,result):(Product.Owner{left,right},result)
def stage(~L:Type,~Right:Type,~Custom:Data,~stageLeft:L -> R.Position -> D.Field -> L & R.Dispatch<Custom>,~stageRight:Right -> R.Position -> D.Field -> Right & R.Dispatch<Custom>,state:Product.Owner<L,Right>,+position:R.Position,+field:D.Field) -> Product.Owner<L,Right> & R.Dispatch<Custom>:
  match state:
    case Product.Owner{left,right}:staged_left(~L,~Right,~Custom,~stageRight,right,position,field,stageLeft(left,position,field))
def release(~L:Type,~Right:Type,~releaseLeft:L -> L,~releaseRight:Right -> Right,state:Product.Owner<L,Right>) -> Product.Owner<L,Right>:
  match state:
    case Product.Owner{left,right}:Product.Owner{releaseLeft(left),releaseRight(right)}

def insert_join(~LC:Type,~LR:Type,~RC:Type,~RR:Type,~L:Type,~Right:Type,left:LC,leftResource:LR,state:L,observed:(RC & RR) & Right) -> (Product.Owner<LC,RC> & Product.Owner<LR,RR>) & Product.Owner<L,Right>:
  match observed:
    case ((right,rightResource),stateRight):((Product.Owner{left,right},Product.Owner{leftResource,rightResource}),Product.Owner{state,stateRight})
def insert_next(~S:Data,~LC:Type,~LR:Type,~RC:Type,~RR:Type,~L:Type,~Right:Type,~insertRight:RC -> RR -> Right -> List<&2,R.Binding<S>> -> Tick.Tick -> (RC & RR) & Right,right:RC,rightResource:RR,stateRight:Right,bindings:List<&2,R.Binding<S>>,tick:Tick.Tick,observed:(LC & LR) & L) -> (Product.Owner<LC,RC> & Product.Owner<LR,RR>) & Product.Owner<L,Right>:
  match observed:
    case ((left,leftResource),state):insert_join(~LC,~LR,~RC,~RR,~L,~Right,left,leftResource,state,insertRight(right,rightResource,stateRight,bindings,tick))
def insert(~S:Data,~LC:Type,~LR:Type,~RC:Type,~RR:Type,~L:Type,~Right:Type,~insertLeft:LC -> LR -> L -> List<&2,R.Binding<S>> -> Tick.Tick -> (LC & LR) & L,~insertRight:RC -> RR -> Right -> List<&2,R.Binding<S>> -> Tick.Tick -> (RC & RR) & Right,owner:Product.Owner<LC,RC>,resource:Product.Owner<LR,RR>,state:Product.Owner<L,Right>,+bindings:List<&2,R.Binding<S>>,+tick:Tick.Tick) -> (Product.Owner<LC,RC> & Product.Owner<LR,RR>) & Product.Owner<L,Right>:
  match owner resource state:
    case Product.Owner{left,right} Product.Owner{leftResource,rightResource} Product.Owner{stateLeft,stateRight}:insert_next(~S,~LC,~LR,~RC,~RR,~L,~Right,~insertRight,right,rightResource,stateRight,bindings,tick,insertLeft(left,leftResource,stateLeft,bindings,tick))
def recovery_join(~L:Type,~Right:Type,~LR:Type,~RR:Type,left:L,recovery:LR,observed:Right & RR) -> Product.Owner<L,Right> & Product.Owner<LR,RR>:
  match observed:
    case (right,more):(Product.Owner{left,right},Product.Owner{recovery,more})
def recovery_left(~L:Type,~Right:Type,~LR:Type,~RR:Type,~takeRight:Right -> Right & RR,right:Right,observed:L & LR) -> Product.Owner<L,Right> & Product.Owner<LR,RR>:
  match observed:
    case (left,recovery):recovery_join(~L,~Right,~LR,~RR,left,recovery,takeRight(right))
def take_recovery(~L:Type,~Right:Type,~LR:Type,~RR:Type,~takeLeft:L -> L & LR,~takeRight:Right -> Right & RR,state:Product.Owner<L,Right>) -> Product.Owner<L,Right> & Product.Owner<LR,RR>:
  match state:
    case Product.Owner{left,right}:recovery_left(~L,~Right,~LR,~RR,~takeRight,right,takeLeft(left))
