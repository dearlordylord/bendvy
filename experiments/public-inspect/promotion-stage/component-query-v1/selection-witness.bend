import Base
import selection.bend as Q
import core-v1/src/ecs/world.bend as W
type Schema is Data:
  Schema{}
type Owner is Type:
  Owner{left:Array<U32>,right:Array<U32>}
def number_done(right:Array<U32>,observed:Array<U32> & U32) -> Owner & U32:
  (left,value)=observed
  (Owner{left,right},value)
def number(owner:Owner,target:W.Handle<Schema>) -> Owner & U32:
  match owner:
    case Owner{left,right}:number_done(right,Array.get(U32,left,0))
def text(owner:Owner,target:W.Handle<Schema>) -> Owner & String:
  (owner,"named")
def leaf_number() -> Q.Selection<Owner,Schema,U32>:
  Q.Selection{Q.yes(~Owner,~Schema),number}
def leaf_text() -> Q.Selection<Owner,Schema,String>:
  Q.Selection{Q.yes(~Owner,~Schema),text}
def first() -> Q.Selection<Owner,Schema,Q.Product<U32,String>>:
  Q.pair(~Owner,~Schema,~U32,~String,~leaf_number(),~leaf_text())
def second() -> Q.Selection<Owner,Schema,Q.Product<Q.Product<U32,String>,Unit>>:
  Q.pair(~Owner,~Schema,~Q.Product<U32,String>,~Unit,~first(),~Q.empty(~Owner,~Schema))
def third() -> Q.Selection<Owner,Schema,Q.Product<Q.Product<Q.Product<U32,String>,Unit>,U32>>:
  Q.pair(~Owner,~Schema,~Q.Product<Q.Product<U32,String>,Unit>,~U32,~second(),~leaf_number())
def fourth() -> Q.Selection<Owner,Schema,Q.Product<Q.Product<Q.Product<Q.Product<U32,String>,Unit>,U32>,String>>:
  Q.pair(~Owner,~Schema,~Q.Product<Q.Product<Q.Product<U32,String>,Unit>,U32>,~String,~third(),~leaf_text())
type Fields is Data:
  Fields{first:U32,label:String,empty:Unit,second:U32,other:String}
def named(value:Q.Product<Q.Product<Q.Product<Q.Product<U32,String>,Unit>,U32>,String>) -> Fields:
  match value:
    case Q.Product{Q.Product{Q.Product{Q.Product{first,label},empty},second},other}:Fields{first,label,empty,second,other}
def declaration() -> Q.Selection<Owner,Schema,Fields>:
  Q.map(~Owner,~Schema,~Q.Product<Q.Product<Q.Product<Q.Product<U32,String>,Unit>,U32>,String>,~Fields,~fourth(),~named)
def body(~H:Type,~cap:Q.Read<H,Schema,Fields>,target:W.Handle<Schema>,owner:H) -> H & Fields:
  Q.read(~H,~Schema,~Fields,~cap,owner,target)
def witness(owner:Owner,target:W.Handle<Schema>) -> Owner & Fields:
  Q.invoke(~Owner,~Schema,~Fields,~declaration(),~body,target,owner)
def main() -> Unit:
  Unit{}
