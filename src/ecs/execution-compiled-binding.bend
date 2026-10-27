import Base
import ./execution-prepared.bend as Prep

# Compilation is affine construction inventory. Observations are cached Data;
# every refusal retains both without manufacturing Prepared authority.
type Binding<-Compilation:Type,-World:Type,-Owner:Type,-Evidence:Data,P:Data> is Type:
  Binding{compilation:Compilation,prepared:Prep.Prepared<World,Owner,P>,evidence:Evidence}
type Preparation<-Compilation:Type,-World:Type,-Owner:Type,-Evidence:Data,P:Data> is Type:
  CompiledPreparationReady{world:World,binding:Binding<Compilation,World,Owner,Evidence,P>}
  Refused{world:World,compilation:Compilation,inventory:Prep.Inventory<World,Owner,P>,evidence:Evidence}
def prepared(~Compilation:Type,~World:Type,~Owner:Type,~Evidence:Data,~P:Data,evidence:Evidence,result:Compilation & Prep.Preparation<World,Owner,P>) -> Preparation<Compilation,World,Owner,Evidence,P>:
  match result:
    case (compilation,Prep.PreparationReady{world,prepared}):CompiledPreparationReady{world,Binding{compilation,prepared,evidence}}
    case (compilation,Prep.PreparationRefused{world,inventory}):Refused{world,compilation,inventory,evidence}
type Invocation<-Compilation:Type,-H:Type,-World:Type,-Owner:Type,-Evidence:Data,P:Data,Status:Data> is Type:
  Invoked{scope:H,binding:Binding<Compilation,World,Owner,Evidence,P>,status:Status}
  InvocationRefused{scope:H,binding:Binding<Compilation,World,Owner,Evidence,P>,status:Status}
  InventoryRefused{scope:H,compilation:Compilation,inventory:Prep.Inventory<World,Owner,P>,evidence:Evidence,status:Status}
def invoked(~Compilation:Type,~H:Type,~World:Type,~Owner:Type,~Evidence:Data,~P:Data,~Status:Data,evidence:Evidence,result:Compilation & Prep.Invocation<H,World,Owner,P,Status>) -> Invocation<Compilation,H,World,Owner,Evidence,P,Status>:
  match result:
    case (compilation,Prep.Invoked{scope,prepared,status}):Invoked{scope,Binding{compilation,prepared,evidence},status}
    case (compilation,Prep.InvocationRefused{scope,prepared,status}):InvocationRefused{scope,Binding{compilation,prepared,evidence},status}
    case (compilation,Prep.InvocationInventoryRefused{scope,inventory,status}):InventoryRefused{scope,compilation,inventory,evidence,status}
