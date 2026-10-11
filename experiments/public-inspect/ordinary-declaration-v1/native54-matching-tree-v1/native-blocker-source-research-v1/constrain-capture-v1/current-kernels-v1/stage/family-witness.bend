import Base
import core/inspector-query-projection.bend as Q
import core/inspector-query-families.bend as F
import core/inspector-query.bend as Queries
import core/inspector-query-world.bend as Traversal
import schema-families.bend as D
import core/inspector.bend as I
import core/check.bend as K
import core/component.bend as C
import core/world.bend as W
import core/compose.bend as P
import core/inspector-query.bend as Errors
def inspect_stock(~S:Data) -> Q.DeclaredSelection<I.Frame<S,D.Store<S>,Unit,U32>,S,C.Access<U32>>:
  F.inspect_slot(~S,~D.Store<S>,~Unit,~U32,~D.StockRest<S>,~D.Stock,~U32,~D.StockToken,~D.take_stock(~S),~D.put_stock(~S),~D.project_stock,~D.stock(~S),~F.Required{})
def inspect_title(~S:Data) -> Q.DeclaredSelection<I.Frame<S,D.Store<S>,Unit,U32>,S,C.Access<String>>:
  F.inspect_slot(~S,~D.Store<S>,~Unit,~U32,~D.TitleRest<S>,~D.Title,~String,~D.TitleToken,~D.take_title(~S),~D.put_title(~S),~D.project_title,~D.title(~S),~F.Required{})
def inspect_active(~S:Data) -> Q.DeclaredSelection<I.Frame<S,D.Store<S>,Unit,U32>,S,C.Access<Bool>>:
  F.inspect_slot(~S,~D.Store<S>,~Unit,~U32,~D.ActiveRest<S>,~D.Active,~Bool,~D.ActiveToken,~D.take_active(~S),~D.put_active(~S),~D.project_active,~D.active(~S),~F.Optional{})
def inspect_count(~S:Data) -> Q.DeclaredSelection<I.Frame<S,D.Store<S>,Unit,U32>,S,C.Access<List<&2,U32>>>:
  F.inspect_slot(~S,~D.Store<S>,~Unit,~U32,~D.CountRest<S>,~D.Count,~List<&2,U32>,~D.CountToken,~D.take_count(~S),~D.put_count(~S),~D.project_count,~D.count(~S),~F.Optional{})
def inspect_pair1(~S:Data) -> Q.DeclaredSelection<I.Frame<S,D.Store<S>,Unit,U32>,S,Q.Product<C.Access<U32>,C.Access<String>>>:
  Q.pair(~I.Frame<S,D.Store<S>,Unit,U32>,~S,~C.Access<U32>,~C.Access<String>,~inspect_stock(~S),~inspect_title(~S))
def inspect_pair2(~S:Data) -> Q.DeclaredSelection<I.Frame<S,D.Store<S>,Unit,U32>,S,Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>>:
  Q.pair(~I.Frame<S,D.Store<S>,Unit,U32>,~S,~Q.Product<C.Access<U32>,C.Access<String>>,~C.Access<Bool>,~inspect_pair1(~S),~inspect_active(~S))
def inspect_pair3(~S:Data) -> Q.DeclaredSelection<I.Frame<S,D.Store<S>,Unit,U32>,S,Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>>:
  Q.pair(~I.Frame<S,D.Store<S>,Unit,U32>,~S,~Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,~C.Access<List<&2,U32>>,~inspect_pair2(~S),~inspect_count(~S))
def inspect_project(~S:Data,frame:I.Frame<S,D.Store<S>,Unit,U32>,target:W.Handle<S>) -> I.Frame<S,D.Store<S>,Unit,U32> & Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>:
  Q.project_field(~I.Frame<S,D.Store<S>,Unit,U32>,~S,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,inspect_pair3(~S))(frame,target)
def inspect_workshop(frame:I.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32>,target:W.Handle<D.Workshop>) -> I.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32> & Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>:
  inspect_project(~D.Workshop,frame,target)
def inspect_garden(frame:I.Frame<D.Garden,D.Store<D.Garden>,Unit,U32>,target:W.Handle<D.Garden>) -> I.Frame<D.Garden,D.Store<D.Garden>,Unit,U32> & Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>:
  inspect_project(~D.Garden,frame,target)
def check_stock(~S:Data) -> Q.DeclaredSelection<K.Frame<S,D.Store<S>,Unit,U32>,S,C.Access<U32>>:
  F.check_slot(~S,~D.Store<S>,~Unit,~U32,~D.StockRest<S>,~D.Stock,~U32,~D.StockToken,~D.take_stock(~S),~D.put_stock(~S),~D.project_stock,~D.stock(~S),~F.Required{})
def check_title(~S:Data) -> Q.DeclaredSelection<K.Frame<S,D.Store<S>,Unit,U32>,S,C.Access<String>>:
  F.check_slot(~S,~D.Store<S>,~Unit,~U32,~D.TitleRest<S>,~D.Title,~String,~D.TitleToken,~D.take_title(~S),~D.put_title(~S),~D.project_title,~D.title(~S),~F.Required{})
def check_active(~S:Data) -> Q.DeclaredSelection<K.Frame<S,D.Store<S>,Unit,U32>,S,C.Access<Bool>>:
  F.check_slot(~S,~D.Store<S>,~Unit,~U32,~D.ActiveRest<S>,~D.Active,~Bool,~D.ActiveToken,~D.take_active(~S),~D.put_active(~S),~D.project_active,~D.active(~S),~F.Optional{})
def check_count(~S:Data) -> Q.DeclaredSelection<K.Frame<S,D.Store<S>,Unit,U32>,S,C.Access<List<&2,U32>>>:
  F.check_slot(~S,~D.Store<S>,~Unit,~U32,~D.CountRest<S>,~D.Count,~List<&2,U32>,~D.CountToken,~D.take_count(~S),~D.put_count(~S),~D.project_count,~D.count(~S),~F.Optional{})
def check_pair1(~S:Data) -> Q.DeclaredSelection<K.Frame<S,D.Store<S>,Unit,U32>,S,Q.Product<C.Access<U32>,C.Access<String>>>:
  Q.pair(~K.Frame<S,D.Store<S>,Unit,U32>,~S,~C.Access<U32>,~C.Access<String>,~check_stock(~S),~check_title(~S))
def check_pair2(~S:Data) -> Q.DeclaredSelection<K.Frame<S,D.Store<S>,Unit,U32>,S,Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>>:
  Q.pair(~K.Frame<S,D.Store<S>,Unit,U32>,~S,~Q.Product<C.Access<U32>,C.Access<String>>,~C.Access<Bool>,~check_pair1(~S),~check_active(~S))
def check_pair3(~S:Data) -> Q.DeclaredSelection<K.Frame<S,D.Store<S>,Unit,U32>,S,Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>>:
  Q.pair(~K.Frame<S,D.Store<S>,Unit,U32>,~S,~Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,~C.Access<List<&2,U32>>,~check_pair2(~S),~check_count(~S))
def check_project(~S:Data,frame:K.Frame<S,D.Store<S>,Unit,U32>,target:W.Handle<S>) -> K.Frame<S,D.Store<S>,Unit,U32> & Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>:
  Q.project_field(~K.Frame<S,D.Store<S>,Unit,U32>,~S,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,check_pair3(~S))(frame,target)
def check_workshop(frame:K.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32>,target:W.Handle<D.Workshop>) -> K.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32> & Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>:
  check_project(~D.Workshop,frame,target)
def check_garden(frame:K.Frame<D.Garden,D.Store<D.Garden>,Unit,U32>,target:W.Handle<D.Garden>) -> K.Frame<D.Garden,D.Store<D.Garden>,Unit,U32> & Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>:
  check_project(~D.Garden,frame,target)
def inspect_predicate_stock_with(~S:Data) -> Q.Predicate<I.Frame<S,D.Store<S>,Unit,U32>,S>:
  F.inspect_with(~S,~D.Store<S>,~Unit,~U32,~D.StockRest<S>,~D.Stock,~U32,~D.StockToken,~D.take_stock(~S),~D.put_stock(~S),~D.project_stock,~D.stock(~S))
def inspect_predicate_title_with(~S:Data) -> Q.Predicate<I.Frame<S,D.Store<S>,Unit,U32>,S>:
  F.inspect_with(~S,~D.Store<S>,~Unit,~U32,~D.TitleRest<S>,~D.Title,~String,~D.TitleToken,~D.take_title(~S),~D.put_title(~S),~D.project_title,~D.title(~S))
def inspect_predicate_count_without(~S:Data) -> Q.Predicate<I.Frame<S,D.Store<S>,Unit,U32>,S>:
  F.inspect_without(~S,~D.Store<S>,~Unit,~U32,~D.CountRest<S>,~D.Count,~List<&2,U32>,~D.CountToken,~D.take_count(~S),~D.put_count(~S),~D.project_count,~D.count(~S))
def inspect_predicate_stock_added(~S:Data) -> Q.Predicate<I.Frame<S,D.Store<S>,Unit,U32>,S>:
  F.inspect_filter(~S,~D.Store<S>,~Unit,~U32,~D.StockRest<S>,~D.Stock,~U32,~D.StockToken,~D.take_stock(~S),~D.put_stock(~S),~D.project_stock,~D.stock(~S),~P.Added{})
def inspect_predicate_title_changed(~S:Data) -> Q.Predicate<I.Frame<S,D.Store<S>,Unit,U32>,S>:
  F.inspect_filter(~S,~D.Store<S>,~Unit,~U32,~D.TitleRest<S>,~D.Title,~String,~D.TitleToken,~D.take_title(~S),~D.put_title(~S),~D.project_title,~D.title(~S),~P.Changed{})
def inspect_conjunction1(~S:Data) -> Q.Predicate<I.Frame<S,D.Store<S>,Unit,U32>,S>:
  Q.both(~I.Frame<S,D.Store<S>,Unit,U32>,~S,~inspect_predicate_stock_with(~S),~inspect_predicate_title_with(~S))
def inspect_conjunction2(~S:Data) -> Q.Predicate<I.Frame<S,D.Store<S>,Unit,U32>,S>:
  Q.both(~I.Frame<S,D.Store<S>,Unit,U32>,~S,~inspect_conjunction1(~S),~inspect_predicate_count_without(~S))
def inspect_conjunction3(~S:Data) -> Q.Predicate<I.Frame<S,D.Store<S>,Unit,U32>,S>:
  Q.both(~I.Frame<S,D.Store<S>,Unit,U32>,~S,~inspect_conjunction2(~S),~inspect_predicate_stock_added(~S))
def inspect_conjunction4(~S:Data) -> Q.Predicate<I.Frame<S,D.Store<S>,Unit,U32>,S>:
  Q.both(~I.Frame<S,D.Store<S>,Unit,U32>,~S,~inspect_conjunction3(~S),~inspect_predicate_title_changed(~S))
def inspect_match_workshop(frame:I.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32>,target:W.Handle<D.Workshop>) -> I.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32> & Bool:
  Q.predicate_field(~I.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32>,~D.Workshop,inspect_conjunction4(~D.Workshop))(frame,target)
def inspect_match_garden(frame:I.Frame<D.Garden,D.Store<D.Garden>,Unit,U32>,target:W.Handle<D.Garden>) -> I.Frame<D.Garden,D.Store<D.Garden>,Unit,U32> & Bool:
  Q.predicate_field(~I.Frame<D.Garden,D.Store<D.Garden>,Unit,U32>,~D.Garden,inspect_conjunction4(~D.Garden))(frame,target)
def check_predicate_stock_with(~S:Data) -> Q.Predicate<K.Frame<S,D.Store<S>,Unit,U32>,S>:
  F.check_with(~S,~D.Store<S>,~Unit,~U32,~D.StockRest<S>,~D.Stock,~U32,~D.StockToken,~D.take_stock(~S),~D.put_stock(~S),~D.project_stock,~D.stock(~S))
def check_predicate_title_with(~S:Data) -> Q.Predicate<K.Frame<S,D.Store<S>,Unit,U32>,S>:
  F.check_with(~S,~D.Store<S>,~Unit,~U32,~D.TitleRest<S>,~D.Title,~String,~D.TitleToken,~D.take_title(~S),~D.put_title(~S),~D.project_title,~D.title(~S))
def check_predicate_count_without(~S:Data) -> Q.Predicate<K.Frame<S,D.Store<S>,Unit,U32>,S>:
  F.check_without(~S,~D.Store<S>,~Unit,~U32,~D.CountRest<S>,~D.Count,~List<&2,U32>,~D.CountToken,~D.take_count(~S),~D.put_count(~S),~D.project_count,~D.count(~S))
def check_conjunction1(~S:Data) -> Q.Predicate<K.Frame<S,D.Store<S>,Unit,U32>,S>:
  Q.both(~K.Frame<S,D.Store<S>,Unit,U32>,~S,~check_predicate_stock_with(~S),~check_predicate_title_with(~S))
def check_conjunction2(~S:Data) -> Q.Predicate<K.Frame<S,D.Store<S>,Unit,U32>,S>:
  Q.both(~K.Frame<S,D.Store<S>,Unit,U32>,~S,~check_conjunction1(~S),~check_predicate_count_without(~S))
def check_match_workshop(frame:K.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32>,target:W.Handle<D.Workshop>) -> K.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32> & Bool:
  Q.predicate_field(~K.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32>,~D.Workshop,check_conjunction2(~D.Workshop))(frame,target)
def check_match_garden(frame:K.Frame<D.Garden,D.Store<D.Garden>,Unit,U32>,target:W.Handle<D.Garden>) -> K.Frame<D.Garden,D.Store<D.Garden>,Unit,U32> & Bool:
  Q.predicate_field(~K.Frame<D.Garden,D.Store<D.Garden>,Unit,U32>,~D.Garden,check_conjunction2(~D.Garden))(frame,target)
def inspect_declaration(~S:Data) -> Q.DeclaredSelection<I.Frame<S,D.Store<S>,Unit,U32>,S,Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>>:
  Q.constrain(~I.Frame<S,D.Store<S>,Unit,U32>,~S,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~inspect_pair3(~S),~inspect_conjunction4(~S))
def inspect_each_workshop(frame:I.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32>) -> I.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32> & List<&2,Queries.ProjectedRow<D.Workshop,Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>>>:
  Queries.each_composed(~I.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32>,~D.Workshop,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~Queries.grant_composed(~I.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32>,~D.Workshop,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~inspect_declaration(~D.Workshop),~Traversal.inspect_world(~D.Workshop,~D.Store<D.Workshop>,~Unit,~U32)),frame)
def inspect_each_garden(frame:I.Frame<D.Garden,D.Store<D.Garden>,Unit,U32>) -> I.Frame<D.Garden,D.Store<D.Garden>,Unit,U32> & List<&2,Queries.ProjectedRow<D.Garden,Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>>>:
  Queries.each_composed(~I.Frame<D.Garden,D.Store<D.Garden>,Unit,U32>,~D.Garden,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~Queries.grant_composed(~I.Frame<D.Garden,D.Store<D.Garden>,Unit,U32>,~D.Garden,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~inspect_declaration(~D.Garden),~Traversal.inspect_world(~D.Garden,~D.Store<D.Garden>,~Unit,~U32)),frame)
def check_declaration(~S:Data) -> Q.DeclaredSelection<K.Frame<S,D.Store<S>,Unit,U32>,S,Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>>:
  Q.constrain(~K.Frame<S,D.Store<S>,Unit,U32>,~S,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~check_pair3(~S),~check_conjunction2(~S))
def check_each_workshop(frame:K.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32>) -> K.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32> & List<&2,Queries.ProjectedRow<D.Workshop,Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>>>:
  Queries.each_composed(~K.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32>,~D.Workshop,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~Queries.grant_composed(~K.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32>,~D.Workshop,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~check_declaration(~D.Workshop),~Traversal.check_world(~D.Workshop,~D.Store<D.Workshop>,~Unit,~U32)),frame)
def check_each_garden(frame:K.Frame<D.Garden,D.Store<D.Garden>,Unit,U32>) -> K.Frame<D.Garden,D.Store<D.Garden>,Unit,U32> & List<&2,Queries.ProjectedRow<D.Garden,Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>>>:
  Queries.each_composed(~K.Frame<D.Garden,D.Store<D.Garden>,Unit,U32>,~D.Garden,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~Queries.grant_composed(~K.Frame<D.Garden,D.Store<D.Garden>,Unit,U32>,~D.Garden,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~check_declaration(~D.Garden),~Traversal.check_world(~D.Garden,~D.Store<D.Garden>,~Unit,~U32)),frame)
def inspect_get_workshop(frame:I.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32>,target:W.Handle<D.Workshop>) -> I.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32> & Result<&2,&2,Errors.LookupError,Queries.ProjectedRow<D.Workshop,Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>>>:
  Queries.get_composed(~I.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32>,~D.Workshop,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~Queries.grant_composed(~I.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32>,~D.Workshop,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~inspect_declaration(~D.Workshop),~Traversal.inspect_world(~D.Workshop,~D.Store<D.Workshop>,~Unit,~U32)),frame,target)
def inspect_single_workshop(frame:I.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32>) -> I.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32> & Result<&2,&2,Errors.SingleError,Queries.ProjectedRow<D.Workshop,Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>>>:
  Queries.single_composed(~I.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32>,~D.Workshop,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~Queries.grant_composed(~I.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32>,~D.Workshop,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~inspect_declaration(~D.Workshop),~Traversal.inspect_world(~D.Workshop,~D.Store<D.Workshop>,~Unit,~U32)),frame)
def inspect_single_optional_workshop(frame:I.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32>) -> I.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32> & Result<&2,&2,Errors.SingleError,Maybe<&2,Queries.ProjectedRow<D.Workshop,Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>>>>:
  Queries.single_optional_composed(~I.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32>,~D.Workshop,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~Queries.grant_composed(~I.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32>,~D.Workshop,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~inspect_declaration(~D.Workshop),~Traversal.inspect_world(~D.Workshop,~D.Store<D.Workshop>,~Unit,~U32)),frame)
def inspect_get_garden(frame:I.Frame<D.Garden,D.Store<D.Garden>,Unit,U32>,target:W.Handle<D.Garden>) -> I.Frame<D.Garden,D.Store<D.Garden>,Unit,U32> & Result<&2,&2,Errors.LookupError,Queries.ProjectedRow<D.Garden,Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>>>:
  Queries.get_composed(~I.Frame<D.Garden,D.Store<D.Garden>,Unit,U32>,~D.Garden,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~Queries.grant_composed(~I.Frame<D.Garden,D.Store<D.Garden>,Unit,U32>,~D.Garden,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~inspect_declaration(~D.Garden),~Traversal.inspect_world(~D.Garden,~D.Store<D.Garden>,~Unit,~U32)),frame,target)
def inspect_single_garden(frame:I.Frame<D.Garden,D.Store<D.Garden>,Unit,U32>) -> I.Frame<D.Garden,D.Store<D.Garden>,Unit,U32> & Result<&2,&2,Errors.SingleError,Queries.ProjectedRow<D.Garden,Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>>>:
  Queries.single_composed(~I.Frame<D.Garden,D.Store<D.Garden>,Unit,U32>,~D.Garden,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~Queries.grant_composed(~I.Frame<D.Garden,D.Store<D.Garden>,Unit,U32>,~D.Garden,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~inspect_declaration(~D.Garden),~Traversal.inspect_world(~D.Garden,~D.Store<D.Garden>,~Unit,~U32)),frame)
def inspect_single_optional_garden(frame:I.Frame<D.Garden,D.Store<D.Garden>,Unit,U32>) -> I.Frame<D.Garden,D.Store<D.Garden>,Unit,U32> & Result<&2,&2,Errors.SingleError,Maybe<&2,Queries.ProjectedRow<D.Garden,Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>>>>:
  Queries.single_optional_composed(~I.Frame<D.Garden,D.Store<D.Garden>,Unit,U32>,~D.Garden,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~Queries.grant_composed(~I.Frame<D.Garden,D.Store<D.Garden>,Unit,U32>,~D.Garden,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~inspect_declaration(~D.Garden),~Traversal.inspect_world(~D.Garden,~D.Store<D.Garden>,~Unit,~U32)),frame)
def check_get_workshop(frame:K.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32>,target:W.Handle<D.Workshop>) -> K.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32> & Result<&2,&2,Errors.LookupError,Queries.ProjectedRow<D.Workshop,Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>>>:
  Queries.get_composed(~K.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32>,~D.Workshop,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~Queries.grant_composed(~K.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32>,~D.Workshop,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~check_declaration(~D.Workshop),~Traversal.check_world(~D.Workshop,~D.Store<D.Workshop>,~Unit,~U32)),frame,target)
def check_single_workshop(frame:K.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32>) -> K.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32> & Result<&2,&2,Errors.SingleError,Queries.ProjectedRow<D.Workshop,Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>>>:
  Queries.single_composed(~K.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32>,~D.Workshop,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~Queries.grant_composed(~K.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32>,~D.Workshop,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~check_declaration(~D.Workshop),~Traversal.check_world(~D.Workshop,~D.Store<D.Workshop>,~Unit,~U32)),frame)
def check_single_optional_workshop(frame:K.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32>) -> K.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32> & Result<&2,&2,Errors.SingleError,Maybe<&2,Queries.ProjectedRow<D.Workshop,Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>>>>:
  Queries.single_optional_composed(~K.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32>,~D.Workshop,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~Queries.grant_composed(~K.Frame<D.Workshop,D.Store<D.Workshop>,Unit,U32>,~D.Workshop,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~check_declaration(~D.Workshop),~Traversal.check_world(~D.Workshop,~D.Store<D.Workshop>,~Unit,~U32)),frame)
def check_get_garden(frame:K.Frame<D.Garden,D.Store<D.Garden>,Unit,U32>,target:W.Handle<D.Garden>) -> K.Frame<D.Garden,D.Store<D.Garden>,Unit,U32> & Result<&2,&2,Errors.LookupError,Queries.ProjectedRow<D.Garden,Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>>>:
  Queries.get_composed(~K.Frame<D.Garden,D.Store<D.Garden>,Unit,U32>,~D.Garden,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~Queries.grant_composed(~K.Frame<D.Garden,D.Store<D.Garden>,Unit,U32>,~D.Garden,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~check_declaration(~D.Garden),~Traversal.check_world(~D.Garden,~D.Store<D.Garden>,~Unit,~U32)),frame,target)
def check_single_garden(frame:K.Frame<D.Garden,D.Store<D.Garden>,Unit,U32>) -> K.Frame<D.Garden,D.Store<D.Garden>,Unit,U32> & Result<&2,&2,Errors.SingleError,Queries.ProjectedRow<D.Garden,Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>>>:
  Queries.single_composed(~K.Frame<D.Garden,D.Store<D.Garden>,Unit,U32>,~D.Garden,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~Queries.grant_composed(~K.Frame<D.Garden,D.Store<D.Garden>,Unit,U32>,~D.Garden,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~check_declaration(~D.Garden),~Traversal.check_world(~D.Garden,~D.Store<D.Garden>,~Unit,~U32)),frame)
def check_single_optional_garden(frame:K.Frame<D.Garden,D.Store<D.Garden>,Unit,U32>) -> K.Frame<D.Garden,D.Store<D.Garden>,Unit,U32> & Result<&2,&2,Errors.SingleError,Maybe<&2,Queries.ProjectedRow<D.Garden,Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>>>>:
  Queries.single_optional_composed(~K.Frame<D.Garden,D.Store<D.Garden>,Unit,U32>,~D.Garden,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~Queries.grant_composed(~K.Frame<D.Garden,D.Store<D.Garden>,Unit,U32>,~D.Garden,~Q.Product<Q.Product<Q.Product<C.Access<U32>,C.Access<String>>,C.Access<Bool>>,C.Access<List<&2,U32>>>,~check_declaration(~D.Garden),~Traversal.check_world(~D.Garden,~D.Store<D.Garden>,~Unit,~U32)),frame)
def main() -> Unit:
  Unit{}
