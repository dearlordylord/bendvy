import Base
import core-v1/src/ecs/column.bend as Col
import core-v1/src/ecs/component.bend as C
import core-v1/src/ecs/relation-types.bend as G
import core-v1/src/ecs/relation-commands.bend as A

type Workshop is Data:
  Workshop{}
type Garden is Data:
  Garden{}
type Stock is Type:
  Stock{cells:Array<U32>}
type Title is Type:
  Title{cells:Array<U32>}
type StockToken is Data:
  StockToken{}
type TitleToken is Data:
  TitleToken{}
type Components<S:Data> is Type:
  Components{stock:Col.Column<S,Stock>,title:Col.Column<S,Title>}
type Resources is Type:
  Resources{first:Array<U32>,second:Array<U32>}
type FixtureEvent is Data:
  FixtureEvent{}
type StockRest<S:Data> is Type:
  StockRest{title:Col.Column<S,Title>,graph:G.Graph<S>}
type TitleRest<S:Data> is Type:
  TitleRest{stock:Col.Column<S,Stock>,graph:G.Graph<S>}
def take_stock(~S:Data,store:A.Store<S,Components<S>>) -> StockRest<S> & Col.Column<S,Stock>:
  match store:
    case A.Store{Components{stock,title},graph}:(StockRest{title,graph},stock)
def put_stock(~S:Data,rest:StockRest<S>,stock:Col.Column<S,Stock>) -> A.Store<S,Components<S>>:
  match rest:
    case StockRest{title,graph}:A.Store{Components{stock,title},graph}
def stock_done(observed:Array<U32> & U32) -> Stock & U32:
  (cells,value)=observed
  (Stock{cells},value)
def project_stock(value:Stock) -> Stock & U32:
  match value:
    case Stock{cells}:stock_done(Array.get(U32,cells,0))
def stock(~S:Data) -> C.Family<S,A.Store<S,Components<S>>,StockRest<S>,Stock,U32,StockToken,take_stock(~S),put_stock(~S),project_stock>:
  C.Family{"stock"}
def take_title(~S:Data,store:A.Store<S,Components<S>>) -> TitleRest<S> & Col.Column<S,Title>:
  match store:
    case A.Store{Components{stock,title},graph}:(TitleRest{stock,graph},title)
def put_title(~S:Data,rest:TitleRest<S>,title:Col.Column<S,Title>) -> A.Store<S,Components<S>>:
  match rest:
    case TitleRest{stock,graph}:A.Store{Components{stock,title},graph}
def title_done(observed:Array<U32> & U32) -> Title & String:
  (cells,value)=observed
  (Title{cells},U32.show(value))
def project_title(value:Title) -> Title & String:
  match value:
    case Title{cells}:title_done(Array.get(U32,cells,0))
def title(~S:Data) -> C.Family<S,A.Store<S,Components<S>>,TitleRest<S>,Title,String,TitleToken,take_title(~S),put_title(~S),project_title>:
  C.Family{"title"}
def empty(~S:Data,unit:Unit) -> A.Store<S,Components<S>>:
  A.empty(~S,~Components<S>,Components{Col.empty(~S,~Stock),Col.empty(~S,~Title)})
def link(~S:Data) -> G.Descriptor<S>:
  G.Descriptor{1,"Link","LinkedBy",G.Ordinary{}}
