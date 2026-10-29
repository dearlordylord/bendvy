import Base
import ./execution-save-plan.bend as Plan
import ./execution-save-layout-field.bend as Field
import ./execution-save-data.bend as Saved
import ./execution-composer-layout.bend as Layout
import ./owner-product.bend as Product
import ./persistence-declaration.bend as Decl
import ./decode-data.bend as D
import ./execution-resource-policy.bend as Policy

def retained(-Q:Type,-Owner:Type,recipe:Q,result:Owner & Saved.Fields) -> Q & (Owner & Saved.Fields):(recipe,result)
def pair_returned(-LQ:Type,-RQ:Type,-LO:Type,-RO:Type,leftRecipe:LQ,leftOwner:LO,leftFields:Saved.Fields,result:RQ & (RO & Saved.Fields)) -> Product.Owner<LQ,RQ> & (Product.Owner<LO,RO> & Saved.Fields):
  match result:
    case (rightRecipe,(rightOwner,rightFields)):(Product.Owner{leftRecipe,rightRecipe},(Product.Owner{leftOwner,rightOwner},Saved.join(leftFields,rightFields)))
def pair_left(-LQ:Type,-RQ:Type,-LO:Type,-RO:Type,right:RQ -> RO -> RQ & (RO & Saved.Fields),rightRecipe:RQ,rightOwner:RO,result:LQ & (LO & Saved.Fields)) -> Product.Owner<LQ,RQ> & (Product.Owner<LO,RO> & Saved.Fields):
  match result:
    case (leftRecipe,(leftOwner,Saved.Fields{values,Some{error}})):(Product.Owner{leftRecipe,rightRecipe},(Product.Owner{leftOwner,rightOwner},Saved.Fields{values,Some{error}}))
    case (leftRecipe,(leftOwner,Saved.Fields{values,None{}})):pair_returned(LQ,RQ,LO,RO,leftRecipe,leftOwner,Saved.Fields{values,None{}},right(rightRecipe,rightOwner))
def pair(-LQ:Type,-RQ:Type,-LO:Type,-RO:Type,left:LQ -> LO -> LQ & (LO & Saved.Fields),right:RQ -> RO -> RQ & (RO & Saved.Fields),recipes:Product.Owner<LQ,RQ>,owners:Product.Owner<LO,RO>) -> Product.Owner<LQ,RQ> & (Product.Owner<LO,RO> & Saved.Fields):
  match recipes owners:
    case Product.Owner{lq,rq} Product.Owner{lo,ro}:pair_left(LQ,RQ,LO,RO,right,rq,ro,left(lq,lo))
def component_pair(-LQ:Type,-RQ:Type,-LO:Type,-RO:Type,left:LQ -> U32 -> LO -> LQ & (LO & Saved.Fields),right:RQ -> U32 -> RO -> RQ & (RO & Saved.Fields),recipes:Product.Owner<LQ,RQ>,+id:U32,owners:Product.Owner<LO,RO>) -> Product.Owner<LQ,RQ> & (Product.Owner<LO,RO> & Saved.Fields):
  pair(LQ,RQ,LO,RO,lq => lo => left(lq,id,lo),rq => ro => right(rq,id,ro),recipes,owners)
def component_constructed(~S:Data,-P:Type,-V:Data,-refresh:P -> P & V,+key:String,project:P -> P & D.Raw,access:Policy.Policy,declaration:Decl.Constructed<S,P,Plan.identity(~S,~P,key),project>,id:U32,owner:Layout.columns(~S,Plan.layout(Plan.Constructed{P,V,refresh,key,project,access}))) -> Decl.Constructed<S,P,Plan.identity(~S,~P,key),project> & (Layout.columns(~S,Plan.layout(Plan.Constructed{P,V,refresh,key,project,access})) & Saved.Fields):
  match declaration:
    case Decl.Constructed{+codec}:retained(Decl.Constructed<S,P,Plan.identity(~S,~P,key),project>,Layout.columns(~S,Plan.layout(Plan.Constructed{P,V,refresh,key,project,access})),Decl.Constructed{codec},Field.component(S,P,V,key,Plan.layout(Plan.Constructed{P,V,refresh,key,project,access}),Field.Constructed{codec},project,owner,id))
def resource_constructed(~S:Data,-P:Type,-V:Data,-refresh:P -> P & V,+key:String,project:P -> P & D.Raw,access:Policy.Policy,declaration:Decl.Constructed<S,P,Plan.identity(~S,~P,key),project>,owner:Layout.resources(~S,Plan.layout(Plan.Constructed{P,V,refresh,key,project,access}))) -> Decl.Constructed<S,P,Plan.identity(~S,~P,key),project> & (Layout.resources(~S,Plan.layout(Plan.Constructed{P,V,refresh,key,project,access})) & Saved.Fields):
  match declaration:
    case Decl.Constructed{+codec}:retained(Decl.Constructed<S,P,Plan.identity(~S,~P,key),project>,Layout.resources(~S,Plan.layout(Plan.Constructed{P,V,refresh,key,project,access})),Decl.Constructed{codec},Field.resource(S,P,V,key,Plan.layout(Plan.Constructed{P,V,refresh,key,project,access}),Field.Constructed{codec},project,owner))
def components(~S:Data,plan:Plan.Plan) -> Plan.Recipes(~S,plan) -> U32 -> Layout.columns(~S,Plan.layout(plan)) -> Plan.Recipes(~S,plan) & (Layout.columns(~S,Plan.layout(plan)) & Saved.Fields):
  match plan:
    case Plan.Empty{}:recipe => id => owner => (recipe,(owner,Saved.empty()))
    case Plan.Plain{P,V,refresh,key,_}:declaration => id => owner => retained(Plan.Recipes(~S,plan),Layout.columns(~S,Plan.layout(plan)),declaration,Field.component(S,P,V,key,Plan.layout(plan),Field.Plain{},owner => (owner,D.Missing{}),owner,id))
    case Plan.Transient{P,V,refresh,key,_}:declaration => id => owner => retained(Plan.Recipes(~S,plan),Layout.columns(~S,Plan.layout(plan)),declaration,Field.component(S,P,V,key,Plan.layout(plan),Field.Transient{},owner => (owner,D.Missing{}),owner,id))
    case Plan.Constructed{P,V,refresh,key,project,access}:declaration => id => owner => component_constructed(~S,P,V,refresh,key,project,access,declaration,id,owner)
    case Plan.Pair{left,right}:recipe => id => owner => component_pair(Plan.Recipes(~S,left),Plan.Recipes(~S,right),Layout.columns(~S,Plan.layout(left)),Layout.columns(~S,Plan.layout(right)),components(~S,left),components(~S,right),recipe,id,owner)
def resources(~S:Data,plan:Plan.Plan) -> Plan.Recipes(~S,plan) -> Layout.resources(~S,Plan.layout(plan)) -> Plan.Recipes(~S,plan) & (Layout.resources(~S,Plan.layout(plan)) & Saved.Fields):
  match plan:
    case Plan.Empty{}:recipe => owner => (recipe,(owner,Saved.empty()))
    case Plan.Plain{P,V,refresh,key,_}:declaration => owner => retained(Plan.Recipes(~S,plan),Layout.resources(~S,Plan.layout(plan)),declaration,Field.resource(S,P,V,key,Plan.layout(plan),Field.Plain{},owner => (owner,D.Missing{}),owner))
    case Plan.Transient{P,V,refresh,key,_}:declaration => owner => retained(Plan.Recipes(~S,plan),Layout.resources(~S,Plan.layout(plan)),declaration,Field.resource(S,P,V,key,Plan.layout(plan),Field.Transient{},owner => (owner,D.Missing{}),owner))
    case Plan.Constructed{P,V,refresh,key,project,access}:declaration => owner => resource_constructed(~S,P,V,refresh,key,project,access,declaration,owner)
    case Plan.Pair{left,right}:recipe => owner => pair(Plan.Recipes(~S,left),Plan.Recipes(~S,right),Layout.resources(~S,Plan.layout(left)),Layout.resources(~S,Plan.layout(right)),resources(~S,left),resources(~S,right),recipe,owner)
