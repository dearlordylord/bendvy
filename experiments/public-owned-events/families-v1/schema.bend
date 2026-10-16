import Base
import ../../../src/ecs/owner-product.bend as Product
import ../../../src/ecs/owned-event-log.bend as Log
import ../../../src/ecs/owned-event-key-route.bend as Route
import ../../../src/ecs/event-publication.bend as Publication
import ../../../src/ecs/ordinary-owned-event.bend as Pub
import ../../../src/ecs/ordinary-owned-event-binding.bend as Binding

def User() -> Type:Array<U32>
def P() -> Type:Array<U32>
def Q() -> Type:Array<Array<U32>>
def Logs() -> Type:Product.Owner<Log.Log<P()>,Product.Owner<Log.Log<P()>,Log.Log<Q()>>>
def Resources() -> Type:Product.Owner<User(),Logs()>
def E() -> Data:Publication.Publication<Nat,Publication.Publication<Nat,Nat>>
def a_domain(~S:Data) -> Pub.Domain<S,P()>:Pub.domain(~S,~P(),"Cargo")
def b_domain(~S:Data) -> Pub.Domain<S,P()>:Pub.domain(~S,~P(),"Alerts")
def c_domain(~S:Data) -> Pub.Domain<S,Q()>:Pub.domain(~S,~Q(),"Crates")
def a_path() -> Product.Lens<Resources(),Log.Log<P()>,(User() & (Product.Owner<Log.Log<P()>,Log.Log<Q()>> & Unit))>:
  Binding.right_path(~User(),~Logs(),~P(),~((Product.Owner<Log.Log<P()>,Log.Log<Q()>> & Unit)),~Binding.left_path(~Log.Log<P()>,~Product.Owner<Log.Log<P()>,Log.Log<Q()>>,~P(),~(Unit),~Binding.identity_lens(~Log.Log<P()>)))
def a_inject() -> Nat -> E():Route.inject_left(~Nat,~Publication.Publication<Nat,Nat>,~Route.inject_leaf)
def a_select() -> List<&2,E()> -> List<&2,Nat>:Route.select_left(~Nat,~Publication.Publication<Nat,Nat>,~Route.select_leaf)
def a_binding(~S:Data) -> Binding.Binding<S,Resources(),P(),(User() & (Product.Owner<Log.Log<P()>,Log.Log<Q()>> & Unit)),E(),a_path(),a_inject(),a_select(),a_domain(~S)>:
  Binding.under_resource(~S,~User(),~Logs(),~P(),~((Product.Owner<Log.Log<P()>,Log.Log<Q()>> & Unit)),~E(),~Binding.left_path(~Log.Log<P()>,~Product.Owner<Log.Log<P()>,Log.Log<Q()>>,~P(),~(Unit),~Binding.identity_lens(~Log.Log<P()>)),~Route.inject_left(~Nat,~Publication.Publication<Nat,Nat>,~Route.inject_leaf),~Route.select_left(~Nat,~Publication.Publication<Nat,Nat>,~Route.select_leaf),~a_domain(~S),Binding.left(~S,~Log.Log<P()>,~Product.Owner<Log.Log<P()>,Log.Log<Q()>>,~P(),~(Unit),~Nat,~Publication.Publication<Nat,Nat>,~Binding.identity_lens(~Log.Log<P()>),~Route.inject_leaf,~Route.select_leaf,~a_domain(~S),Binding.leaf(~S,~P(),~a_domain(~S))))
def b_path() -> Product.Lens<Resources(),Log.Log<P()>,(User() & (Log.Log<P()> & (Log.Log<Q()> & Unit)))>:
  Binding.right_path(~User(),~Logs(),~P(),~((Log.Log<P()> & (Log.Log<Q()> & Unit))),~Binding.right_path(~Log.Log<P()>,~Product.Owner<Log.Log<P()>,Log.Log<Q()>>,~P(),~((Log.Log<Q()> & Unit)),~Binding.left_path(~Log.Log<P()>,~Log.Log<Q()>,~P(),~(Unit),~Binding.identity_lens(~Log.Log<P()>))))
def b_inject() -> Nat -> E():Route.inject_right(~Nat,~Publication.Publication<Nat,Nat>,~Route.inject_left(~Nat,~Nat,~Route.inject_leaf))
def b_select() -> List<&2,E()> -> List<&2,Nat>:Route.select_right(~Nat,~Publication.Publication<Nat,Nat>,~Route.select_left(~Nat,~Nat,~Route.select_leaf))
def b_binding(~S:Data) -> Binding.Binding<S,Resources(),P(),(User() & (Log.Log<P()> & (Log.Log<Q()> & Unit))),E(),b_path(),b_inject(),b_select(),b_domain(~S)>:
  Binding.under_resource(~S,~User(),~Logs(),~P(),~((Log.Log<P()> & (Log.Log<Q()> & Unit))),~E(),~Binding.right_path(~Log.Log<P()>,~Product.Owner<Log.Log<P()>,Log.Log<Q()>>,~P(),~((Log.Log<Q()> & Unit)),~Binding.left_path(~Log.Log<P()>,~Log.Log<Q()>,~P(),~(Unit),~Binding.identity_lens(~Log.Log<P()>))),~Route.inject_right(~Nat,~Publication.Publication<Nat,Nat>,~Route.inject_left(~Nat,~Nat,~Route.inject_leaf)),~Route.select_right(~Nat,~Publication.Publication<Nat,Nat>,~Route.select_left(~Nat,~Nat,~Route.select_leaf)),~b_domain(~S),Binding.right(~S,~Log.Log<P()>,~Product.Owner<Log.Log<P()>,Log.Log<Q()>>,~P(),~((Log.Log<Q()> & Unit)),~Nat,~Publication.Publication<Nat,Nat>,~Binding.left_path(~Log.Log<P()>,~Log.Log<Q()>,~P(),~(Unit),~Binding.identity_lens(~Log.Log<P()>)),~Route.inject_left(~Nat,~Nat,~Route.inject_leaf),~Route.select_left(~Nat,~Nat,~Route.select_leaf),~b_domain(~S),Binding.left(~S,~Log.Log<P()>,~Log.Log<Q()>,~P(),~(Unit),~Nat,~Nat,~Binding.identity_lens(~Log.Log<P()>),~Route.inject_leaf,~Route.select_leaf,~b_domain(~S),Binding.leaf(~S,~P(),~b_domain(~S)))))
def c_path() -> Product.Lens<Resources(),Log.Log<Q()>,(User() & (Log.Log<P()> & (Log.Log<P()> & Unit)))>:
  Binding.right_path(~User(),~Logs(),~Q(),~((Log.Log<P()> & (Log.Log<P()> & Unit))),~Binding.right_path(~Log.Log<P()>,~Product.Owner<Log.Log<P()>,Log.Log<Q()>>,~Q(),~((Log.Log<P()> & Unit)),~Binding.right_path(~Log.Log<P()>,~Log.Log<Q()>,~Q(),~(Unit),~Binding.identity_lens(~Log.Log<Q()>))))
def c_inject() -> Nat -> E():Route.inject_right(~Nat,~Publication.Publication<Nat,Nat>,~Route.inject_right(~Nat,~Nat,~Route.inject_leaf))
def c_select() -> List<&2,E()> -> List<&2,Nat>:Route.select_right(~Nat,~Publication.Publication<Nat,Nat>,~Route.select_right(~Nat,~Nat,~Route.select_leaf))
def c_binding(~S:Data) -> Binding.Binding<S,Resources(),Q(),(User() & (Log.Log<P()> & (Log.Log<P()> & Unit))),E(),c_path(),c_inject(),c_select(),c_domain(~S)>:
  Binding.under_resource(~S,~User(),~Logs(),~Q(),~((Log.Log<P()> & (Log.Log<P()> & Unit))),~E(),~Binding.right_path(~Log.Log<P()>,~Product.Owner<Log.Log<P()>,Log.Log<Q()>>,~Q(),~((Log.Log<P()> & Unit)),~Binding.right_path(~Log.Log<P()>,~Log.Log<Q()>,~Q(),~(Unit),~Binding.identity_lens(~Log.Log<Q()>))),~Route.inject_right(~Nat,~Publication.Publication<Nat,Nat>,~Route.inject_right(~Nat,~Nat,~Route.inject_leaf)),~Route.select_right(~Nat,~Publication.Publication<Nat,Nat>,~Route.select_right(~Nat,~Nat,~Route.select_leaf)),~c_domain(~S),Binding.right(~S,~Log.Log<P()>,~Product.Owner<Log.Log<P()>,Log.Log<Q()>>,~Q(),~((Log.Log<P()> & Unit)),~Nat,~Publication.Publication<Nat,Nat>,~Binding.right_path(~Log.Log<P()>,~Log.Log<Q()>,~Q(),~(Unit),~Binding.identity_lens(~Log.Log<Q()>)),~Route.inject_right(~Nat,~Nat,~Route.inject_leaf),~Route.select_right(~Nat,~Nat,~Route.select_leaf),~c_domain(~S),Binding.right(~S,~Log.Log<P()>,~Log.Log<Q()>,~Q(),~(Unit),~Nat,~Nat,~Binding.identity_lens(~Log.Log<Q()>),~Route.inject_leaf,~Route.select_leaf,~c_domain(~S),Binding.leaf(~S,~Q(),~c_domain(~S)))))
def resources() -> Resources():Product.Owner{ANode{ALeaf{100},ALeaf{101}},Product.Owner{Log.empty(~P()),Product.Owner{Log.empty(~P()),Log.empty(~Q())}}}
