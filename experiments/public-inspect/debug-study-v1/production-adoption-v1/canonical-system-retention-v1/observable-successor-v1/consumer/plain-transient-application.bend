import Base
import ../../../../../../../src/ecs/ordinary-query-declaration.bend as Query
import ../../../../../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../../../../../src/ecs/persistence-declaration.bend as Recipe
import ../../../../../../../src/ecs/snapshot-leaf.bend as Leaf
import ../../../../../../../src/ecs/column.bend as Col
import ../../../../../../../src/ecs/compose.bend as Q
import ../../../../../../../src/ecs/component.bend as Cmp
import ../../../../../../../src/ecs/capabilities.bend as Cap

type Schema is Data:
  Schema{}
type Payload is Type:
  Payload{values:Array<U32>}
def viewed(observed:Array<U32> & U32) -> Payload & U32:
  match observed:
    case (values,value):(Payload{values},value)
def view(owner:Payload) -> Payload & U32:
  match owner:
    case Payload{values}:viewed(Array.get(U32,values,0))
def plain_identity() -> Identity.Declaration<Schema,Payload>:
  Identity.component(~Schema,~Payload,"Plain")
def transient_identity() -> Identity.Declaration<Schema,Payload>:
  Identity.component(~Schema,~Payload,"Transient")
type Plain is Type:
  Plain{column:Col.Column<Schema,Payload>,declaration:Recipe.Plain<Schema,Payload,plain_identity()>}
def plain_take(owner:Plain) -> Recipe.Plain<Schema,Payload,plain_identity()> & Col.Column<Schema,Payload>:
  match owner:
    case Plain{column,declaration}:(declaration,column)
def plain_put(declaration:Recipe.Plain<Schema,Payload,plain_identity()>,column:Col.Column<Schema,Payload>) -> Plain:
  Plain{column,declaration}
def Transient() -> Type:
  Leaf.TransientComponent<Schema,Payload,transient_identity()>
def transient_take(owner:Transient()) -> Recipe.Transient<Schema,Payload,transient_identity()> & Col.Column<Schema,Payload>:
  match owner:
    case Leaf.TransientComponent{column,declaration}:(declaration,column)
def transient_put(declaration:Recipe.Transient<Schema,Payload,transient_identity()>,column:Col.Column<Schema,Payload>) -> Transient():
  Leaf.TransientComponent{column,declaration}

def plain_read() -> Query.Declaration<Schema,Q.Frame<Schema,Plain,Unit,Unit>,Cap.Read<Q.Frame<Schema,Plain,Unit,Unit>,U32>>:
  Query.read(~Schema,~Payload,~Plain,~Unit,~Unit,~Recipe.Plain<Schema,Payload,plain_identity()>,~U32,~Schema,~plain_identity(),~view,~plain_take,~plain_put)

def plain_write() -> Query.Declaration<Schema,Q.Frame<Schema,Plain,Unit,Unit>,Cap.Write<Q.Frame<Schema,Plain,Unit,Unit>,Payload,U32>>:
  Query.write(~Schema,~Payload,~Plain,~Unit,~Unit,~Recipe.Plain<Schema,Payload,plain_identity()>,~U32,~Schema,~plain_identity(),~view,~plain_take,~plain_put)

def plain_optional() -> Query.Declaration<Schema,Q.Frame<Schema,Plain,Unit,Unit>,Cap.Read<Q.Frame<Schema,Plain,Unit,Unit>,U32>>:
  Query.optional(~Schema,~Payload,~Plain,~Unit,~Unit,~Recipe.Plain<Schema,Payload,plain_identity()>,~U32,~Schema,~plain_identity(),~view,~plain_take,~plain_put)

def plain_with_component() -> Query.Declaration<Schema,Q.Frame<Schema,Plain,Unit,Unit>,Unit>:
  Query.with_component(~Schema,~Payload,~Plain,~Unit,~Unit,~Recipe.Plain<Schema,Payload,plain_identity()>,~U32,~Schema,~plain_identity(),~view,~plain_take,~plain_put)

def plain_without_component() -> Query.Declaration<Schema,Q.Frame<Schema,Plain,Unit,Unit>,Unit>:
  Query.without_component(~Schema,~Payload,~Plain,~Unit,~Unit,~Recipe.Plain<Schema,Payload,plain_identity()>,~U32,~Schema,~plain_identity(),~view,~plain_take,~plain_put)

def plain_added() -> Query.Declaration<Schema,Q.Frame<Schema,Plain,Unit,Unit>,Unit>:
  Query.added(~Schema,~Payload,~Plain,~Unit,~Unit,~Recipe.Plain<Schema,Payload,plain_identity()>,~U32,~Schema,~plain_identity(),~view,~plain_take,~plain_put)

def plain_changed() -> Query.Declaration<Schema,Q.Frame<Schema,Plain,Unit,Unit>,Unit>:
  Query.changed(~Schema,~Payload,~Plain,~Unit,~Unit,~Recipe.Plain<Schema,Payload,plain_identity()>,~U32,~Schema,~plain_identity(),~view,~plain_take,~plain_put)

def plain_consume(frame:Q.Frame<Schema,Plain,Unit,Unit>) -> Q.Frame<Schema,Plain,Unit,Unit> & Cmp.Access<U32>:
  Query.execute_read(~Schema,~Q.Frame<Schema,Plain,Unit,Unit>,~U32,~plain_read(),frame)

def plain_replace(frame:Q.Frame<Schema,Plain,Unit,Unit>,incoming:Payload) -> Q.Frame<Schema,Plain,Unit,Unit>:
  Cap.set(~Q.Frame<Schema,Plain,Unit,Unit>,~Payload,~U32,~Query.grant(~Schema,~Q.Frame<Schema,Plain,Unit,Unit>,~Cap.Write<Q.Frame<Schema,Plain,Unit,Unit>,Payload,U32>,plain_write()),frame,incoming)

def transient_read() -> Query.Declaration<Schema,Q.Frame<Schema,Transient(),Unit,Unit>,Cap.Read<Q.Frame<Schema,Transient(),Unit,Unit>,U32>>:
  Query.read(~Schema,~Payload,~Transient(),~Unit,~Unit,~Recipe.Transient<Schema,Payload,transient_identity()>,~U32,~Schema,~transient_identity(),~view,~transient_take,~transient_put)

def transient_write() -> Query.Declaration<Schema,Q.Frame<Schema,Transient(),Unit,Unit>,Cap.Write<Q.Frame<Schema,Transient(),Unit,Unit>,Payload,U32>>:
  Query.write(~Schema,~Payload,~Transient(),~Unit,~Unit,~Recipe.Transient<Schema,Payload,transient_identity()>,~U32,~Schema,~transient_identity(),~view,~transient_take,~transient_put)

def transient_optional() -> Query.Declaration<Schema,Q.Frame<Schema,Transient(),Unit,Unit>,Cap.Read<Q.Frame<Schema,Transient(),Unit,Unit>,U32>>:
  Query.optional(~Schema,~Payload,~Transient(),~Unit,~Unit,~Recipe.Transient<Schema,Payload,transient_identity()>,~U32,~Schema,~transient_identity(),~view,~transient_take,~transient_put)

def transient_with_component() -> Query.Declaration<Schema,Q.Frame<Schema,Transient(),Unit,Unit>,Unit>:
  Query.with_component(~Schema,~Payload,~Transient(),~Unit,~Unit,~Recipe.Transient<Schema,Payload,transient_identity()>,~U32,~Schema,~transient_identity(),~view,~transient_take,~transient_put)

def transient_without_component() -> Query.Declaration<Schema,Q.Frame<Schema,Transient(),Unit,Unit>,Unit>:
  Query.without_component(~Schema,~Payload,~Transient(),~Unit,~Unit,~Recipe.Transient<Schema,Payload,transient_identity()>,~U32,~Schema,~transient_identity(),~view,~transient_take,~transient_put)

def transient_added() -> Query.Declaration<Schema,Q.Frame<Schema,Transient(),Unit,Unit>,Unit>:
  Query.added(~Schema,~Payload,~Transient(),~Unit,~Unit,~Recipe.Transient<Schema,Payload,transient_identity()>,~U32,~Schema,~transient_identity(),~view,~transient_take,~transient_put)

def transient_changed() -> Query.Declaration<Schema,Q.Frame<Schema,Transient(),Unit,Unit>,Unit>:
  Query.changed(~Schema,~Payload,~Transient(),~Unit,~Unit,~Recipe.Transient<Schema,Payload,transient_identity()>,~U32,~Schema,~transient_identity(),~view,~transient_take,~transient_put)

def transient_consume(frame:Q.Frame<Schema,Transient(),Unit,Unit>) -> Q.Frame<Schema,Transient(),Unit,Unit> & Cmp.Access<U32>:
  Query.execute_read(~Schema,~Q.Frame<Schema,Transient(),Unit,Unit>,~U32,~transient_read(),frame)

def transient_replace(frame:Q.Frame<Schema,Transient(),Unit,Unit>,incoming:Payload) -> Q.Frame<Schema,Transient(),Unit,Unit>:
  Cap.set(~Q.Frame<Schema,Transient(),Unit,Unit>,~Payload,~U32,~Query.grant(~Schema,~Q.Frame<Schema,Transient(),Unit,Unit>,~Cap.Write<Q.Frame<Schema,Transient(),Unit,Unit>,Payload,U32>,transient_write()),frame,incoming)
