import Base
import ../../../../../../../../src/ecs/transaction.bend as Tx
import ./ordinary-combined-consumer.bend as Core
import ../../../../../../../../src/ecs/ordinary-reader-system.bend as Ordinary
import ../../../../../../../../src/ecs/world.bend as W
import ../../../../../../../../src/ecs/event-notice-runtime.bend as Mixed
import ../../../../../../../../src/ecs/relation-commands.bend as Notice

def dispose(provider:Core.provider_type(),context:Core.context_type()) -> Ordinary.ProviderDisposal<Core.context_type(),Core.provider_type(),Unit>:
  Ordinary.dispose_provider(~Core.Schema,~Core.store_type(),~Unit,~Core.event_type(),~Core.context_type(),~Core.metadata_type(),~Core.all_owner(),~Core.all_view(),~Core.all_delta(),~Bool,~Unit,~U32,~Core.all_view(),~Core.validate_all,~Core.prepare_all,~Core.commit_all,~Core.release_all,~Mixed.split(~Core.Schema,~Core.store_type(),~Unit,~Core.Publication,~Core.family_type(),~Unit),~Mixed.join(~Core.Schema,~Core.store_type(),~Unit,~Core.Publication,~Core.family_type(),~Unit),~Ordinary.shared_runner(~Core.Schema,~Core.store_type(),~Unit,~Core.Publication,~Core.family_type(),~Unit,~Core.all_owner(),~Core.all_view(),~Core.all_delta(),~Bool,~Unit,~U32,~Core.all_view(),~Core.validate_all,~Core.prepare_all,~Core.commit_all,~Core.release_all,~Core.no_caps,~Core.callback,~Core.no_grant(~Tx.Tx<Core.world_type(),Core.event_type()>),~Core.sync_events,~Core.classify),provider,context)
def publish_parts(parts:Core.world_type() & Core.metadata_type()) -> Core.context_type():
  match parts:
    case (world,metadata):Mixed.join(~Core.Schema,~Core.store_type(),~Unit,~Core.Publication,~Core.family_type(),~Unit,W.event_publish(~Core.Schema,~Core.store_type(),~Unit,~Core.event_type(),world,[Notice.Original{Core.Value{99}}]),metadata)
def published(context:Core.context_type()) -> Core.context_type():
  publish_parts(Mixed.split(~Core.Schema,~Core.store_type(),~Unit,~Core.Publication,~Core.family_type(),~Unit,context))
def c_ran(first:String,result:Core.run_type()) -> String:
  match result:
    case Ordinary.RunCompleted{_,_,view}:"["++first++","++Core.view_json(view)++"]"
    case _:"unexpected-C-run"
def c_defined(first:String,result:Core.definition_type()) -> String:
  match result:
    case Ordinary.DefinitionRegistered{context,provider}:c_ran(first,Core.run_all(provider,context,False{}))
    case _:"unexpected-C-definition"
def b_disposed(first:String,result:Ordinary.ProviderDisposal<Core.context_type(),Core.provider_type(),Unit>) -> String:
  match result:
    case Ordinary.ProviderDisposed{context,_}:c_defined(first,Core.define_all(published(context),"C"))
    case _:"unexpected-B-disposal"
def b_ran(result:Core.run_type()) -> String:
  match result:
    case Ordinary.RunCompleted{context,provider,view}:b_disposed(Core.view_json(view),dispose(provider,context))
    case _:"unexpected-B-run"
def a_disposed(second:Core.provider_type(),result:Ordinary.ProviderDisposal<Core.context_type(),Core.provider_type(),Unit>) -> String:
  match result:
    case Ordinary.ProviderDisposed{context,_}:b_ran(Core.run_all(second,context,False{}))
    case _:"unexpected-A-disposal"
def a_ran(second:Core.provider_type(),result:Core.run_type()) -> String:
  match result:
    case Ordinary.RunCompleted{context,provider,_}:a_disposed(second,dispose(provider,context))
    case _:"unexpected-A-run"
def b_defined(first:Core.provider_type(),result:Core.definition_type()) -> String:
  match result:
    case Ordinary.DefinitionRegistered{context,second}:a_ran(second,Core.run_all(first,context,False{}))
    case _:"unexpected-B-definition"
def a_defined(result:Core.definition_type()) -> String:
  match result:
    case Ordinary.DefinitionRegistered{context,first}:b_defined(first,Core.define_all(context,"B"))
    case _:"unexpected-A-definition"
def started(setup:Core.Setup) -> String:
  match setup:
    case Core.Ready{context,_}:a_defined(Core.define_all(context,"A"))
    case Core.SetupFailed{}:"unexpected-setup"
def main() -> IO(Unit):
  IO.print(started(Core.setup()))
