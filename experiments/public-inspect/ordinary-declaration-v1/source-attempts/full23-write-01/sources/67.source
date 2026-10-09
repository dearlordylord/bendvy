import Base
import ../../ordinary-binding.bend as Binding
import ../../../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../../../src/ecs/world.bend as W
import ../../../../../src/ecs/component.bend as C
import ../../../../../src/ecs/column.bend as Col

type Workshop is Data:
  Workshop{}
type Garden is Data:
  Garden{}
type Stock is Type:
  Stock{cells:Array<U32>}
type StockToken is Data:
  StockToken{}
type Title is Type:
  Title{cells:Array<U32>}
type TitleToken is Data:
  TitleToken{}
type Active is Type:
  Active{cells:Array<U32>}
type ActiveToken is Data:
  ActiveToken{}
type Count is Type:
  Count{cells:Array<U32>}
type CountToken is Data:
  CountToken{}
type Store<S:Data> is Type:
  Store{stock:Col.Column<S,Stock>,title:Col.Column<S,Title>,active:Col.Column<S,Active>,count:Col.Column<S,Count>}
type StockRest<S:Data> is Type:
  StockRest{title:Col.Column<S,Title>,active:Col.Column<S,Active>,count:Col.Column<S,Count>}
def take_stock(~S:Data,store:Store<S>) -> StockRest<S> & Col.Column<S,Stock>:
  match store:
    case Store{stock,title,active,count}:(StockRest{title,active,count},stock)
def put_stock(~S:Data,rest:StockRest<S>,stock:Col.Column<S,Stock>) -> Store<S>:
  match rest:
    case StockRest{title,active,count}:Store{stock,title,active,count}
def stock_done(observed:Array<U32> & U32) -> Stock & U32:
  (cells,value)=observed
  (Stock{cells},value)
def project_stock(value:Stock) -> Stock & U32:
  match value:
    case Stock{cells}:stock_done(Array.get(U32,cells,0))
def stock_binding(~S:Data) -> Binding.Binding<S,Store<S>,StockRest<S>,Stock,U32,StockToken,take_stock(~S),put_stock(~S),project_stock>:
  Binding.bind(~S,~Store<S>,~StockRest<S>,~Stock,~U32,~StockToken,~take_stock(~S),~put_stock(~S),~project_stock,Identity.component(~S,~Stock,"stock"))
def stock(~S:Data) -> C.Family<S,Store<S>,StockRest<S>,Stock,U32,StockToken,take_stock(~S),put_stock(~S),project_stock>:
  Binding.family(~S,~Store<S>,~StockRest<S>,~Stock,~U32,~StockToken,~take_stock(~S),~put_stock(~S),~project_stock,stock_binding(~S))
type TitleRest<S:Data> is Type:
  TitleRest{stock:Col.Column<S,Stock>,active:Col.Column<S,Active>,count:Col.Column<S,Count>}
def take_title(~S:Data,store:Store<S>) -> TitleRest<S> & Col.Column<S,Title>:
  match store:
    case Store{stock,title,active,count}:(TitleRest{stock,active,count},title)
def put_title(~S:Data,rest:TitleRest<S>,title:Col.Column<S,Title>) -> Store<S>:
  match rest:
    case TitleRest{stock,active,count}:Store{stock,title,active,count}
def title_done(observed:Array<U32> & U32) -> Title & String:
  (cells,value)=observed
  (Title{cells},U32.show(value))
def project_title(value:Title) -> Title & String:
  match value:
    case Title{cells}:title_done(Array.get(U32,cells,0))
def title_binding(~S:Data) -> Binding.Binding<S,Store<S>,TitleRest<S>,Title,String,TitleToken,take_title(~S),put_title(~S),project_title>:
  Binding.bind(~S,~Store<S>,~TitleRest<S>,~Title,~String,~TitleToken,~take_title(~S),~put_title(~S),~project_title,Identity.component(~S,~Title,"title"))
def title(~S:Data) -> C.Family<S,Store<S>,TitleRest<S>,Title,String,TitleToken,take_title(~S),put_title(~S),project_title>:
  Binding.family(~S,~Store<S>,~TitleRest<S>,~Title,~String,~TitleToken,~take_title(~S),~put_title(~S),~project_title,title_binding(~S))
type ActiveRest<S:Data> is Type:
  ActiveRest{stock:Col.Column<S,Stock>,title:Col.Column<S,Title>,count:Col.Column<S,Count>}
def take_active(~S:Data,store:Store<S>) -> ActiveRest<S> & Col.Column<S,Active>:
  match store:
    case Store{stock,title,active,count}:(ActiveRest{stock,title,count},active)
def put_active(~S:Data,rest:ActiveRest<S>,active:Col.Column<S,Active>) -> Store<S>:
  match rest:
    case ActiveRest{stock,title,count}:Store{stock,title,active,count}
def active_done(observed:Array<U32> & U32) -> Active & Bool:
  (cells,value)=observed
  (Active{cells},U32.is_eq(value,1))
def project_active(value:Active) -> Active & Bool:
  match value:
    case Active{cells}:active_done(Array.get(U32,cells,0))
def active_binding(~S:Data) -> Binding.Binding<S,Store<S>,ActiveRest<S>,Active,Bool,ActiveToken,take_active(~S),put_active(~S),project_active>:
  Binding.bind(~S,~Store<S>,~ActiveRest<S>,~Active,~Bool,~ActiveToken,~take_active(~S),~put_active(~S),~project_active,Identity.component(~S,~Active,"active"))
def active(~S:Data) -> C.Family<S,Store<S>,ActiveRest<S>,Active,Bool,ActiveToken,take_active(~S),put_active(~S),project_active>:
  Binding.family(~S,~Store<S>,~ActiveRest<S>,~Active,~Bool,~ActiveToken,~take_active(~S),~put_active(~S),~project_active,active_binding(~S))
type CountRest<S:Data> is Type:
  CountRest{stock:Col.Column<S,Stock>,title:Col.Column<S,Title>,active:Col.Column<S,Active>}
def take_count(~S:Data,store:Store<S>) -> CountRest<S> & Col.Column<S,Count>:
  match store:
    case Store{stock,title,active,count}:(CountRest{stock,title,active},count)
def put_count(~S:Data,rest:CountRest<S>,count:Col.Column<S,Count>) -> Store<S>:
  match rest:
    case CountRest{stock,title,active}:Store{stock,title,active,count}
def count_done(observed:Array<U32> & U32) -> Count & List<&2,U32>:
  (cells,value)=observed
  (Count{cells},[value])
def project_count(value:Count) -> Count & List<&2,U32>:
  match value:
    case Count{cells}:count_done(Array.get(U32,cells,0))
def count_binding(~S:Data) -> Binding.Binding<S,Store<S>,CountRest<S>,Count,List<&2,U32>,CountToken,take_count(~S),put_count(~S),project_count>:
  Binding.bind(~S,~Store<S>,~CountRest<S>,~Count,~List<&2,U32>,~CountToken,~take_count(~S),~put_count(~S),~project_count,Identity.component(~S,~Count,"count"))
def count(~S:Data) -> C.Family<S,Store<S>,CountRest<S>,Count,List<&2,U32>,CountToken,take_count(~S),put_count(~S),project_count>:
  Binding.family(~S,~Store<S>,~CountRest<S>,~Count,~List<&2,U32>,~CountToken,~take_count(~S),~put_count(~S),~project_count,count_binding(~S))
