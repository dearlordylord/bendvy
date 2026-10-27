import Base
import ./world.bend as W
import ./execution-command-buffer.bend as Buffer
import ./execution-composer-layout.bend as Layout
import ./execution-relation-operation.bend as Operation
import ./execution-relation-store.bend as Relation
import ./execution-reservation-bundle.bend as Bundle

# Detached queue metadata never contains an affine incoming/displaced payload.
# The snapshot returns every actual Entry and Receipt owner in its original list.
type Pending<S:Data> is Data:
  Component{handle:W.Handle<S>,incoming:Bool}
  Despawn{handle:W.Handle<S>}
  Spawn{handle:W.Handle<S>}
  Relation{route:Layout.Route,operation:Operation.Operation<S>}
type Receipt<S:Data> is Data:
  Applied{handle:W.Handle<S>,previous:Bool}
  Refused{handle:W.Handle<S>,incoming:Bool}
  Despawned{handle:W.Handle<S>}
  DespawnRefused{handle:W.Handle<S>}
  Spawned{handle:W.Handle<S>}
  SpawnRefused{handle:W.Handle<S>,reason:Bundle.Refusal}
  RelationPublished{route:Layout.Route,receipt:Relation.Receipt<S>}
  RelationUndeclared{route:Layout.Route,operation:Operation.Operation<S>}
type Snapshot<S:Data> is Data:
  Snapshot{pending:List<&2,Pending<S>>,receipts:List<&2,Receipt<S>>}
def inserted(-S:Data,-P:Type,-D:Type,+handle:W.Handle<S>,incoming:Maybe<&1,P>) -> Buffer.Entry<S,P,D> & Pending<S>:
  match incoming:
    case None{}:(Buffer.Entry{handle,None{}},Component{handle,False{}})
    case Some{value}:(Buffer.Entry{handle,Some{value}},Component{handle,True{}})
def entry(-S:Data,-P:Type,-D:Type,value:Buffer.Entry<S,P,D>) -> Buffer.Entry<S,P,D> & Pending<S>:
  match value:
    case Buffer.Entry{handle,incoming}:inserted(S,P,D,handle,incoming)
    case Buffer.Despawn{+handle}:(Buffer.Despawn{handle},Despawn{handle})
    case Buffer.Spawn{+handle,bundle}:(Buffer.Spawn{handle,bundle},Spawn{handle})
    case Buffer.Relation{+route,+operation}:(Buffer.Relation{route,operation},Relation{route,operation})
def entries_join(-S:Data,-P:Type,-D:Type,head:Buffer.Entry<S,P,D> & Pending<S>,tail:List<Buffer.Entry<S,P,D>> & List<&2,Pending<S>>) -> List<Buffer.Entry<S,P,D>> & List<&2,Pending<S>>:
  match head tail:
    case (head,value), (tail,values):(head <> tail,value <> values)
def entries(-S:Data,-P:Type,-D:Type,values:List<Buffer.Entry<S,P,D>>) -> List<Buffer.Entry<S,P,D>> & List<&2,Pending<S>>:
  match values:
    case []:([],[])
    case head <> tail:entries_join(S,P,D,entry(S,P,D,head),entries(S,P,D,tail))
def applied(-S:Data,-P:Type,-D:Type,+handle:W.Handle<S>,previous:Maybe<&1,P>) -> Buffer.Receipt<S,P,D> & Receipt<S>:
  match previous:
    case None{}:(Buffer.Applied{handle,None{}},Applied{handle,False{}})
    case Some{value}:(Buffer.Applied{handle,Some{value}},Applied{handle,True{}})
def refused(-S:Data,-P:Type,-D:Type,+handle:W.Handle<S>,incoming:Maybe<&1,P>) -> Buffer.Receipt<S,P,D> & Receipt<S>:
  match incoming:
    case None{}:(Buffer.Refused{handle,None{}},Refused{handle,False{}})
    case Some{value}:(Buffer.Refused{handle,Some{value}},Refused{handle,True{}})
def receipt(-S:Data,-P:Type,-D:Type,value:Buffer.Receipt<S,P,D>) -> Buffer.Receipt<S,P,D> & Receipt<S>:
  match value:
    case Buffer.Applied{handle,previous}:applied(S,P,D,handle,previous)
    case Buffer.Refused{handle,incoming}:refused(S,P,D,handle,incoming)
    case Buffer.Despawned{+handle,removed}:(Buffer.Despawned{handle,removed},Despawned{handle})
    case Buffer.DespawnRefused{+handle}:(Buffer.DespawnRefused{handle},DespawnRefused{handle})
    case Buffer.Spawned{+handle,previous}:(Buffer.Spawned{handle,previous},Spawned{handle})
    case Buffer.SpawnRefused{+handle,bundle,+reason}:(Buffer.SpawnRefused{handle,bundle,reason},SpawnRefused{handle,reason})
    case Buffer.RelationPublished{+route,+receipt}:(Buffer.RelationPublished{route,receipt},RelationPublished{route,receipt})
    case Buffer.RelationUndeclared{+route,+operation}:(Buffer.RelationUndeclared{route,operation},RelationUndeclared{route,operation})
def receipts_join(-S:Data,-P:Type,-D:Type,head:Buffer.Receipt<S,P,D> & Receipt<S>,tail:List<Buffer.Receipt<S,P,D>> & List<&2,Receipt<S>>) -> List<Buffer.Receipt<S,P,D>> & List<&2,Receipt<S>>:
  match head tail:
    case (head,value), (tail,values):(head <> tail,value <> values)
def receipts(-S:Data,-P:Type,-D:Type,values:List<Buffer.Receipt<S,P,D>>) -> List<Buffer.Receipt<S,P,D>> & List<&2,Receipt<S>>:
  match values:
    case []:([],[])
    case head <> tail:receipts_join(S,P,D,receipt(S,P,D,head),receipts(S,P,D,tail))
def returned(-S:Data,-P:Type,-D:Type,pending:List<Buffer.Entry<S,P,D>> & List<&2,Pending<S>>,receipts:List<Buffer.Receipt<S,P,D>> & List<&2,Receipt<S>>) -> Buffer.Buffer<S,P,D> & Snapshot<S>:
  match pending receipts:
    case (pending,pendingView), (receipts,receiptView):(Buffer.Buffer{pending,receipts},Snapshot{List.reverse(&2,Pending<S>,pendingView),List.reverse(&2,Receipt<S>,receiptView)})
def snapshot(-S:Data,-P:Type,-D:Type,buffer:Buffer.Buffer<S,P,D>) -> Buffer.Buffer<S,P,D> & Snapshot<S>:
  match buffer:
    case Buffer.Buffer{pending,results}:returned(S,P,D,entries(S,P,D,pending),receipts(S,P,D,results))
