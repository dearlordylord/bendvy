import Base
import ./inspector-event-value.bend as Getter
import ./ordinary-event-family.bend as Provision
import ./ordinary-event-declaration.bend as Event
import ./event-family-routing.bend as Route
import ./event-stream.bend as Leaf
import ./capabilities.bend as Cap
import ./event-notice-runtime.bend as Mixed
# Bind existing generated selection and the same ordinary declaration once.
def bind(~S:Data,~C:Type,~R:Type,~P:Data,~E:Data,~F:Type,~take:F -> F & Leaf.Stream<S,E>,~put:F -> Leaf.Stream<S,E> -> F,declaration:Event.Declaration<S,E>,_:Provision.Selection<S,E,F,take,put>) -> Cap.ValueRead<Route.Runtime<S,C,R,P,F>,Maybe<&2,List<&2,E>>>:
  Getter.read(~S,~C,~R,~P,~E,~F,~take,~put,declaration)

# Lift an already generated typed selection through the retained notice owner wrapper.
def lift_notice(~S:Data,~E:Data,~P:Data,~F:Type,~H:Type,~take:F -> F & Leaf.Stream<S,E>,~put:F -> Leaf.Stream<S,E> -> F,_:Provision.Selection<S,E,F,take,put>) -> Provision.Selection<S,E,Mixed.State<S,P,F,H>,Mixed.take(~S,~E,~P,~F,~H,~take),Mixed.put(~S,~E,~P,~F,~H,~put)>:Provision.Selection{}
