import Base
import ./types.bend as T
import ./storage.bend as S
import ./observations.bend as O
import ./dispatcher.bend as D

type TraceEvent<-Schema:Data,-V:Data,-AV:Data,-F:Data,-LV:Data,-Mode:Data,-P:Data> is Data:
  Reserved{step:String,worldName:String,label:String,handle:S.Handle<Schema>,components:O.BundleView<V,AV,F>} 
  Read{step:String,system:String,count:U32,boundary:T.ReadBoundary,
    query:List<&2,O.QueryRow<Schema,V,AV,F>>,added:List<&2,O.QueryRow<Schema,V,AV,F>>,changed:List<&2,O.QueryRow<Schema,V,AV,F>>,
    removed:List<&2,S.Handle<Schema>>,despawned:List<&2,S.Handle<Schema>>,messages:List<&2,P>,messageLag:Bool,removedLag:Bool,despawnedLag:Bool}
  Snapshot{step:String,worldName:String,prior:D.DispatchOutcome,world:O.WorldView<V,AV,F,LV,Mode>,query:List<&2,O.QueryRow<Schema,V,AV,F>>,
    plus:List<&2,O.QueryRow<Schema,V,AV,F>>,minus:List<&2,O.QueryRow<Schema,V,AV,F>>,optional:List<&2,O.QueryRow<Schema,V,AV,F>>,
    lookups:List<&2,Lookup<Schema,V,AV,F>>}
  Dispatch{step:String,worldName:String,tracked:Bool,outcome:D.DispatchOutcome,clockTick:U32,frame:U32,counts:List<&2,Count>}
  ReadDone{step:String,system:String,frame:U32,tick:U32,outcome:T.Outcome,messageLag:Bool,removedLag:Bool,despawnedLag:Bool}
  OwnWrites{step:String,system:String,views:List<&2,OwnView>}
type Lookup<-Schema:Data,-V:Data,-AV:Data,-F:Data> is Data:
  Lookup{label:String,handle:S.Handle<Schema>,result:T.Access<O.QueryRow<Schema,V,AV,F>>}
type Count is Data:
  Count{system:String,value:T.Four}
type OwnView is Data:
  Main{value:T.Access<T.MainView>}
  Ledger{value:Maybe<&2,T.LedgerView>}
  ReservedLookup{value:T.Access<T.MainView>}
type Binding<-Schema:Data> is Data:
  Binding{label:String,handle:S.Handle<Schema>}
