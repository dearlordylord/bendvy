import Base
import ./schema.bend as Schema
import /workspace/formal-proofs/bendvy/experiments/public-decode/typed.bend as D
import /workspace/formal-proofs/bendvy-worktrees/parity-61-audit/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-product.bend as Product
import /workspace/formal-proofs/bendvy-worktrees/parity-61-audit/experiments/public-inspect/debug-study-v1/production-adoption-v1/public-api-v1/docs/ordinary-v1/canonical-schema-product.bend as Ordinary
def joined_components(~LC:Type,~RC:Type,left:LC,fields:List<&2,D.Field>,observed:RC & List<&2,D.Field>) -> Product.Owner<LC,RC> & List<&2,D.Field>:
  match observed:
    case (right,more):(Product.Owner{left,right},List.append(&2,D.Field,fields,more))
def right_components(~LC:Type,~RC:Type,~right:U32 -> RC -> RC & List<&2,D.Field>,id:U32,owner:RC,observed:LC & List<&2,D.Field>) -> Product.Owner<LC,RC> & List<&2,D.Field>:
  match observed:
    case (left,fields):joined_components(~LC,~RC,left,fields,right(id,owner))
def product_components_owned(~LC:Type,~RC:Type,~left:U32 -> LC -> LC & List<&2,D.Field>,~right:U32 -> RC -> RC & List<&2,D.Field>,+id:U32,owner:Product.Owner<LC,RC>) -> Product.Owner<LC,RC> & List<&2,D.Field>:
  match owner:
    case Product.Owner{a,b}:right_components(~LC,~RC,~right,id,b,left(id,a))
def product_components(~LC:Type,~RC:Type,~left:U32 -> LC -> LC & List<&2,D.Field>,~right:U32 -> RC -> RC & List<&2,D.Field>,id:U32,owner:Product.Owner<LC,RC>) -> Product.Owner<LC,RC> & List<&2,D.Field>:
  product_components_owned(~LC,~RC,~left,~right,id,owner)
def right_resources(~LR:Type,~RR:Type,~right:RR -> RR & List<&2,D.Field>,owner:RR,observed:LR & List<&2,D.Field>) -> Product.Owner<LR,RR> & List<&2,D.Field>:
  match observed:
    case (left,fields):joined_components(~LR,~RR,left,fields,right(owner))
def product_resources(~LR:Type,~RR:Type,~left:LR -> LR & List<&2,D.Field>,~right:RR -> RR & List<&2,D.Field>,owner:Product.Owner<LR,RR>) -> Product.Owner<LR,RR> & List<&2,D.Field>:
  match owner:
    case Product.Owner{a,b}:right_resources(~LR,~RR,~right,b,left(a))
def product(~S:Data,~LC:Type,~LR:Type,~RC:Type,~RR:Type,~leftEligible:Bool,~rightEligible:Bool,~leftComponents:U32 -> LC -> LC & List<&2,D.Field>,~leftResources:LR -> LR & List<&2,D.Field>,~rightComponents:U32 -> RC -> RC & List<&2,D.Field>,~rightResources:RR -> RR & List<&2,D.Field>,left:Schema.Schema<S,LC,LR,leftEligible,leftComponents,leftResources>,right:Schema.Schema<S,RC,RR,rightEligible,rightComponents,rightResources>) -> Schema.Schema<S,Product.Owner<LC,RC>,Product.Owner<LR,RR>,Bool.and(leftEligible,rightEligible),product_components(~LC,~RC,~leftComponents,~rightComponents),product_resources(~LR,~RR,~leftResources,~rightResources)>:
  Schema.Schema{Ordinary.product(~S,~LC,~LR,~RC,~RR,Schema.inventory(~S,~LC,~LR,~leftEligible,~leftComponents,~leftResources,left),Schema.inventory(~S,~RC,~RR,~rightEligible,~rightComponents,~rightResources,right))}
