import Base
import schema.bend as F
import events.bend as Event
import locals.bend as Locals
import catalog.bend as Catalog
import ../../../src/ecs/restore-runtime.bend as Restore
import ../../../src/ecs/restore-public.bend as Public
import ../../../src/ecs/snapshot-data.bend as Snapshot
def Restored(~S:Data) -> Type:Event.Runtime(~S) & (F.Owned(~S) & (Public.Outcome<S,String> & (F.FullRecovery(~S) & Maybe<&1,Catalog.DrainReceipt()>)))
def restore(~S:Data,owner:F.Owned(~S),runtime:Event.Runtime(~S),input:Snapshot.Snapshot) -> Restored(~S):Restore.run(~S,~F.FullStore(~S),~F.UserResources(~S),~F.Logs(),~F.Events(~S),~Event.FamilyOwner(~S),~Array<U32>,~Catalog.DrainReceipt(),~F.FullState(~S),~String,~F.Full_stage(~S),~F.Full_release(~S),~F.Full_clear(~S),~F.Full_insert(~S),~Catalog.emit(~S),~Catalog.catalog_retain(~S),~Catalog.catalog_drain(),~Catalog.catalog_clear(~S),~Catalog.catalog(~S),~Event.sync(~S),~F.FullRecovery(~S),~F.Full_commit(~S),~F.Full_take(~S),owner,runtime,input)
