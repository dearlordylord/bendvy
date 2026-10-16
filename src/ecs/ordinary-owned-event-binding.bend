import Base
import ./owner-product.bend as Product
import ./owned-event-log.bend as Log
import ./owned-event-key-route.bend as Route
import ./event-publication.bend as Publication
import ./ordinary-owned-event.bend as Pub

# Trusted engine family boundary. Ordinary constructors derive all paths/routes
# from child bindings; gameplay never supplies a live lens or key-routing closure.
# The raw constructor is trusted provisioning, not a module-privacy guarantee.
type Binding<S:Data,R:Type,P:Type,Rest:Type,E:Data,-path:Product.Lens<R,Log.Log<P>,Rest>,-inject:Nat -> E,-select:List<&2,E> -> List<&2,Nat>,-identity:Pub.Domain<S,P>> is Data:
  Binding{}
def identity_take(~T:Type,owner:T) -> Unit & T:(Unit{},owner)
def identity_put(~T:Type,unit:Unit,owner:T) -> T:owner
def identity_lens(~T:Type) -> Product.Lens<T,T,Unit>:
  Product.Lens{identity_take(~T),identity_put(~T)}
def leaf(~S:Data,~P:Type,~identity:Pub.Domain<S,P>) -> Binding<S,Log.Log<P>,P,Unit,Nat,identity_lens(~Log.Log<P>),Route.inject_leaf,Route.select_leaf,identity>:
  Binding{}
def left_path(~A:Type,~B:Type,~P:Type,~Rest:Type,~path:Product.Lens<A,Log.Log<P>,Rest>) -> Product.Lens<Product.Owner<A,B>,Log.Log<P>,B & Rest>:
  Product.compose(~Product.Owner<A,B>,~A,~B,~Log.Log<P>,~Rest,~Product.lens(~A,~B,~Product.Left{}),~path)
def right_path(~A:Type,~B:Type,~P:Type,~Rest:Type,~path:Product.Lens<B,Log.Log<P>,Rest>) -> Product.Lens<Product.Owner<A,B>,Log.Log<P>,A & Rest>:
  Product.compose(~Product.Owner<A,B>,~B,~A,~Log.Log<P>,~Rest,~Product.lens(~A,~B,~Product.Right{}),~path)
def left(~S:Data,~A:Type,~B:Type,~P:Type,~Rest:Type,~EA:Data,~EB:Data,~path:Product.Lens<A,Log.Log<P>,Rest>,~inject:Nat -> EA,~select:List<&2,EA> -> List<&2,Nat>,~identity:Pub.Domain<S,P>,binding:Binding<S,A,P,Rest,EA,path,inject,select,identity>) -> Binding<S,Product.Owner<A,B>,P,B & Rest,Publication.Publication<EA,EB>,left_path(~A,~B,~P,~Rest,~path),Route.inject_left(~EA,~EB,~inject),Route.select_left(~EA,~EB,~select),identity>:
  Binding{}
def right(~S:Data,~A:Type,~B:Type,~P:Type,~Rest:Type,~EA:Data,~EB:Data,~path:Product.Lens<B,Log.Log<P>,Rest>,~inject:Nat -> EB,~select:List<&2,EB> -> List<&2,Nat>,~identity:Pub.Domain<S,P>,binding:Binding<S,B,P,Rest,EB,path,inject,select,identity>) -> Binding<S,Product.Owner<A,B>,P,A & Rest,Publication.Publication<EA,EB>,right_path(~A,~B,~P,~Rest,~path),Route.inject_right(~EA,~EB,~inject),Route.select_right(~EA,~EB,~select),identity>:
  Binding{}
def under_resource(~S:Data,~User:Type,~R:Type,~P:Type,~Rest:Type,~E:Data,~path:Product.Lens<R,Log.Log<P>,Rest>,~inject:Nat -> E,~select:List<&2,E> -> List<&2,Nat>,~identity:Pub.Domain<S,P>,binding:Binding<S,R,P,Rest,E,path,inject,select,identity>) -> Binding<S,Product.Owner<User,R>,P,User & Rest,E,right_path(~User,~R,~P,~Rest,~path),inject,select,identity>:
  Binding{}
