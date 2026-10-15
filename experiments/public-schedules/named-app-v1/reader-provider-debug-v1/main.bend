import Base
import ../../../../src/ecs/inspector-query.bend as IQ
import ../../../../src/ecs/internal/relation-failures/readings.bend as KRead
import ../../../../src/ecs/world.bend as W
import ../../../../src/ecs/system.bend as Sys
import ../../../../src/ecs/transaction.bend as Tx
import ../../../../src/ecs/reader-parameter.bend as RP
import ../../../../src/ecs/ordinary-reader-system.bend as Ordinary
import ../../../../src/ecs/column.bend as Col
import ../../../../src/ecs/compose.bend as Compose
import ../../../../src/ecs/inspector.bend as Inspector
import ../../../../src/ecs/ordinary-declaration.bend as Identity
import ../../../../src/ecs/ordinary-component-binding.bend as Binding
import ../../../../src/ecs/ordinary-query-observable.bend as Observable
import ../../../../src/ecs/ordinary-reader-query-parameter.bend as QParam
import ../../../../src/ecs/ordinary-reader-stream-parameter.bend as Stream
import ../../../../src/ecs/ordinary-event-declaration.bend as Event
import ../../../../src/ecs/event-runtime.bend as Ev
import ../../../../src/ecs/event-stream.bend as Leaf
import ../../../../src/ecs/event-notice-runtime.bend as Mixed
import ../../../../src/ecs/event-family-routing.bend as Route
import ../../../../src/ecs/relation-commands.bend as Notice
import ../../../../src/ecs/removals.bend as Rm
import ../../../../src/ecs/ordinary-removal-provision.bend as Provision
import ../../../../src/ecs/relation-types.bend as Relations
import ../../../../src/ecs/relation-failure-reader.bend as KDecl
import ../../../../src/ecs/internal/relation-failures/domains.bend as KD
import ./fixture.bend as F
import ./declarations.bend as D
import ./observer.bend as O
import ../../../../src/ecs/ordinary-app-reader-parameter.bend as Parameter
import ../../../../src/ecs/ordinary-app-reader-fields.bend as RF
import ../../../../src/ecs/ordinary-app-registration-fields.bend as Fields
import ../../../../src/ecs/ordinary-app-composer.bend as App
import ../../../../src/ecs/ordinary-app-records.bend as Pair
import ../../../../src/ecs/ordinary-app-recipe.bend as Recipe
import ../../../../src/ecs/ordinary-app-observation-data.bend as DTO
import ../../../../src/ecs/ordinary-app-access.bend as Access

def raw_pair_all(left:F.q_parameter_type(),right:F.eemr_parameter_type()) -> D.all_parameter_type():
  RP.pair(~F.context_type(),~F.q_owner(),~F.q_view(),~F.q_delta(),~QParam.validate_context(~F.Schema,~F.store_type(),~Unit,~F.Publication,~F.family_type(),~Unit,~Unit,~Unit,~F.query_declaration()),~QParam.prepare_context(~F.Schema,~F.store_type(),~Unit,~F.Publication,~F.family_type(),~Unit,~Unit,~Unit,~F.query_declaration()),~QParam.commit_context(~F.context_type()),~QParam.release_context(~F.context_type()),~F.eemr_owner(),~F.eemr_view(),~F.eemr_delta(),~RP.pair_validate_fn(~F.context_type(),~F.e_owner(),~F.emr_owner(),~Stream.validate_event(~F.Schema,~F.store_type(),~Unit,~F.Publication,~F.event_type(),~F.family_type(),~Unit,~F.take_events,~F.put_events,~F.event_declaration()),~RP.pair_validate_fn(~F.context_type(),~F.e_owner(),~F.mr_owner(),~Stream.validate_event(~F.Schema,~F.store_type(),~Unit,~F.Publication,~F.event_type(),~F.family_type(),~Unit,~F.take_events,~F.put_events,~F.event_declaration()),~RP.pair_validate_fn(~F.context_type(),~F.m_owner(),~F.r_owner(),~Stream.validate_removal(~F.Schema,~F.store_type(),~Unit,~F.Publication,~U32,~F.family_type(),~Unit,~F.inject_removal,~F.select_removal,~F.removal_selection()),~Stream.validate_relation(~F.Schema,~F.store_type(),~Unit,~F.Publication,~F.family_type(),~Unit,~F.relation_declarations())))),~RP.pair_prepare_fn(~F.context_type(),~F.e_owner(),~F.emr_owner(),~F.e_view(),~F.emr_view(),~F.e_delta(),~F.emr_delta(),~Stream.prepare_event(~F.Schema,~F.store_type(),~Unit,~F.Publication,~F.event_type(),~F.family_type(),~Unit,~F.take_events,~F.put_events,~F.event_declaration()),~RP.pair_prepare_fn(~F.context_type(),~F.e_owner(),~F.mr_owner(),~F.e_view(),~F.mr_view(),~F.e_delta(),~F.mr_delta(),~Stream.prepare_event(~F.Schema,~F.store_type(),~Unit,~F.Publication,~F.event_type(),~F.family_type(),~Unit,~F.take_events,~F.put_events,~F.event_declaration()),~RP.pair_prepare_fn(~F.context_type(),~F.m_owner(),~F.r_owner(),~F.m_view(),~F.r_view(),~F.m_delta(),~F.r_delta(),~Stream.prepare_removal(~F.Schema,~F.store_type(),~Unit,~F.Publication,~U32,~F.family_type(),~Unit,~F.select_removal),~Stream.prepare_relation(~F.Schema,~F.store_type(),~Unit,~F.Publication,~F.family_type(),~Unit,~F.relation_declarations())))),~RP.pair_commit_fn(~F.context_type(),~F.e_owner(),~F.emr_owner(),~F.e_delta(),~F.emr_delta(),~Stream.commit_event(~F.Schema,~F.store_type(),~Unit,~F.Publication,~F.event_type(),~F.family_type(),~Unit,~F.take_events,~F.put_events),~RP.pair_commit_fn(~F.context_type(),~F.e_owner(),~F.mr_owner(),~F.e_delta(),~F.mr_delta(),~Stream.commit_event(~F.Schema,~F.store_type(),~Unit,~F.Publication,~F.event_type(),~F.family_type(),~Unit,~F.take_events,~F.put_events),~RP.pair_commit_fn(~F.context_type(),~F.m_owner(),~F.r_owner(),~F.m_delta(),~F.r_delta(),~Stream.commit_removal(~F.Schema,~F.store_type(),~Unit,~F.Publication,~U32,~F.family_type(),~Unit,~F.select_removal),~Stream.commit_relation(~F.Schema,~F.store_type(),~Unit,~F.Publication,~F.family_type(),~Unit)))),~RP.pair_release_fn(~F.context_type(),~F.e_owner(),~F.emr_owner(),~Stream.release_event(~F.Schema,~F.store_type(),~Unit,~F.Publication,~F.event_type(),~F.family_type(),~Unit,~F.take_events,~F.put_events),~RP.pair_release_fn(~F.context_type(),~F.e_owner(),~F.mr_owner(),~Stream.release_event(~F.Schema,~F.store_type(),~Unit,~F.Publication,~F.event_type(),~F.family_type(),~Unit,~F.take_events,~F.put_events),~RP.pair_release_fn(~F.context_type(),~F.m_owner(),~F.r_owner(),~Stream.release_removal(~F.Schema,~F.store_type(),~Unit,~F.Publication,~U32,~F.family_type(),~Unit,~F.select_removal),~Stream.release_relation(~F.Schema,~F.store_type(),~Unit,~F.Publication,~F.family_type(),~Unit)))),left,right)
def initialize_all(context:F.context_type(),facts:RP.RegistrationFacts) -> F.context_type() & (F.all_owner() & D.all_parameter_type()):
  RP.initialize_pair(~F.context_type(),~RP.RegistrationFacts,~F.q_owner(),~F.q_parameter_type(),~F.eemr_owner(),~F.eemr_parameter_type(),~D.all_parameter_type(),~F.q_initialize,~F.eemr_initialize,~raw_pair_all,context,facts)
def metadata_type() -> Type:
  Mixed.State<F.Schema,F.Publication,F.family_type(),Unit> & Nat
def declaration_type() -> Data:
  List<&2,Fields.DeclaredUse>
def invocation_type() -> Type:
  Ordinary.Invocation<metadata_type(),F.all_owner(),D.all_parameter_type(),declaration_type(),Bool>
def envelope_type() -> Type:
  Ordinary.Envelope<metadata_type(),F.all_owner(),D.all_parameter_type(),declaration_type(),U32,F.all_view()>
def runner_fn() -> F.world_type() -> invocation_type() -> Sys.Outcome<F.world_type(),Empty,envelope_type()>:
  Ordinary.shared_runner(~F.Schema,~F.store_type(),~Unit,~F.Publication,~F.family_type(),~Unit,~F.all_owner(),~F.all_view(),~F.all_delta(),~Bool,~declaration_type(),~U32,~F.all_view(),~D.validate_fn(),~D.prepare_fn(),~D.commit_fn(),~D.release_fn(),~F.no_caps,~F.callback,~F.no_grant(~Tx.Tx<F.world_type(),F.event_type()>),~F.sync_events,~F.classify)
def registry_type() -> Type:
  Sys.Registry<F.Schema,F.store_type(),Unit,F.event_type(),invocation_type(),Empty,envelope_type(),runner_fn()>
def provider_type() -> Type:
  Ordinary.Provider<registry_type(),F.all_owner(),D.all_parameter_type(),declaration_type()>
def definition_type() -> Type:
  Ordinary.Definition<F.context_type(),provider_type(),D.all_parameter_type(),declaration_type()>
def define_all(context:F.context_type(),name:String) -> definition_type():
  RF.define_mixed(~F.Schema,~F.store_type(),~Unit,~F.Publication,~F.family_type(),~Unit,~F.all_owner(),~F.all_view(),~F.all_delta(),~Bool,~U32,~F.all_view(),~D.validate_fn(),~D.prepare_fn(),~D.commit_fn(),~D.release_fn(),~F.no_caps,~F.callback,~F.no_grant(~Tx.Tx<F.world_type(),F.event_type()>),~F.sync_events,~F.classify,~initialize_all,D.all_parameter(),context,name)
def run_type() -> Type:
  Ordinary.RunResult<F.context_type(),provider_type(),Bool,U32,F.all_view()>
def run_all(provider:provider_type(),context:F.context_type(),fail:Bool) -> run_type():
  Ordinary.run_mixed(~F.Schema,~F.store_type(),~Unit,~F.Publication,~F.family_type(),~Unit,~F.all_owner(),~F.all_view(),~F.all_delta(),~Bool,~declaration_type(),~U32,~F.all_view(),~D.validate_fn(),~D.prepare_fn(),~D.commit_fn(),~D.release_fn(),~F.no_caps,~F.callback,~F.no_grant(~Tx.Tx<F.world_type(),F.event_type()>),~F.sync_events,~F.classify,provider,context,fail)
def fold_fn() -> (Unit & provider_type()) -> (Unit & provider_type()) & List<&2,Fields.Fields<F.Schema>>:
  Pair.fold_pair(~F.Schema,~Unit,~provider_type(),~Pair.empty(~F.Schema),~RF.fold(~F.Schema,~F.store_type(),~Unit,~F.event_type(),~invocation_type(),~Empty,~envelope_type(),~runner_fn(),~F.all_owner(),~D.all_parameter_type()))
def app_type() -> Type:
  App.Registered<F.Schema,F.context_type(),Unit & provider_type(),String,O.observe,fold_fn()>
def attached(context:F.context_type(),provider:provider_type()) -> app_type():
  RF.attach_context(~F.Schema,~F.store_type(),~Unit,~F.event_type(),~invocation_type(),~Empty,~envelope_type(),~runner_fn(),~F.all_owner(),~D.all_parameter_type(),~F.context_type(),~Unit,~String,~O.observe,~Pair.empty(~F.Schema),context,Unit{},provider,Recipe.Recipe{},True{})
def returned(debug:Bool,result:run_type()) -> app_type() & String:
  match result:
    case Ordinary.RunCompleted{context,provider,output}:(App.Registered{context,(Unit{},provider),Recipe.Recipe{},debug},"completed:"++F.view_json(output))
    case Ordinary.RunFailed{context,provider,error,output}:(App.Registered{context,(Unit{},provider),Recipe.Recipe{},debug},"failed:"++U32.show(error)++":"++F.view_json(output))
    case Ordinary.RunInvalidReader{context,provider}:(App.Registered{context,(Unit{},provider),Recipe.Recipe{},debug},"invalid-reader")
    case Ordinary.RunRegistrationRejected{context,provider,args}:(App.Registered{context,(Unit{},provider),Recipe.Recipe{},debug},"registration-rejected:"++F.boolean(args))
    case Ordinary.RunSkipped{context,provider}:(App.Registered{context,(Unit{},provider),Recipe.Recipe{},debug},"skipped")
def run(app:app_type(),fail:Bool) -> app_type() & String:
  match app:
    case App.Registered{context,(Unit{},provider),_,debug}:returned(debug,run_all(provider,context,fail))

type ProviderHeader is Data:
  ProviderHeader{namespace:U32,id:U32,name:String,access:List<&2,String>,cursor:U32,parameterAccess:List<&2,String>,uses:List<&2,Fields.DeclaredUse>}
def provider_restored(value:ProviderHeader & (F.all_owner() & String)) -> provider_type() & String:
  match value:
    case (ProviderHeader{+namespace,+id,+name,+access,+cursor,+parameterAccess,+uses},(reader,text)):(Ordinary.Provider{Sys.Registry{namespace,id,name,access,cursor},reader,RP.Param{parameterAccess},uses},"provider("++U32.show(namespace)++","++U32.show(id)++","++F.quoted(name)++","++O.strings(access)++","++U32.show(cursor)++","++O.strings(parameterAccess)++","++F.list_json(~Fields.DeclaredUse,~O.use,uses)++","++text++")")
def provider_observed(provider:provider_type()) -> provider_type() & String:
  match provider:
    case Ordinary.Provider{Sys.Registry{namespace,id,name,access,cursor},reader,RP.Param{parameterAccess},uses}:provider_restored((ProviderHeader{namespace,id,name,access,cursor,parameterAccess,uses},O.owners(reader)))
def physical_context(provider:provider_type(),debug:Bool,providerText:String,result:F.context_type() & String) -> app_type() & String:
  match result:
    case (context,text):(App.Registered{context,(Unit{},provider),Recipe.Recipe{},debug},providerText++"|"++text)
def physical_provider(context:F.context_type(),debug:Bool,result:provider_type() & String) -> app_type() & String:
  match result:
    case (provider,text):physical_context(provider,debug,text,O.context(context))
def physical(app:app_type()) -> app_type() & String:
  match app:
    case App.Registered{context,(Unit{},provider),_,debug}:physical_provider(context,debug,provider_observed(provider))
def record_physical(label:String,description:String,index:String,result:app_type() & String) -> app_type() & String:
  match result:
    case (app,text):(app,"record("++label++"|description="++description++"|index="++index++"|physical="++text++")\n")
def record_index(label:String,description:String,result:app_type() & Maybe<&2,List<&2,Access.Entry>>) -> app_type() & String:
  match result:
    case (app,index):record_physical(label,description,O.index(index),physical(app))
def record_description(label:String,result:app_type() & Maybe<&2,DTO.Product<List<&2,DTO.Binding<F.Schema>>,DTO.Observation<String>>>) -> app_type() & String:
  match result:
    case (app,description):record_index(label,O.description(description),Access.index(~F.Schema,~F.context_type(),~(Unit & provider_type()),~String,~O.observe,~fold_fn(),app))
def record(label:String,app:app_type()) -> app_type() & String:
  record_description(label,App.snapshot(~F.Schema,~F.context_type(),~(Unit & provider_type()),~String,~O.observe,~fold_fn(),app))
def enabled(app:app_type(),flag:Bool) -> app_type():
  App.enabled(~F.Schema,~F.context_type(),~(Unit & provider_type()),~String,~O.observe,~fold_fn(),app,flag)
def finished(rows:String,result:app_type() & String) -> String:
  match result:
    case (_,text):rows++text
# Both description and access-index calls repeat without invoking a reader.
def final_record(rows:String,result:app_type() & String) -> String:
  match result:
    case (app,text):finished(rows++text,record("enabled-repeat-after-success",app))
def succeeded(rows:String,result:app_type() & String) -> String:
  match result:
    case (app,view):final_record(rows++"callback("++view++")\n",record("enabled-after-success",app))
def after_failure_record(rows:String,result:app_type() & String) -> String:
  match result:
    case (app,text):succeeded(rows++text,run(app,False{}))
def failed_record(rows:String,result:app_type() & String) -> String:
  match result:
    case (app,text):after_failure_record(rows++text,record("enabled-after-failure",enabled(app,True{})))
def failed(rows:String,result:app_type() & String) -> String:
  match result:
    case (app,view):failed_record(rows++"callback("++view++")\n",record("disabled-after-failure",app))
def disabled_record(rows:String,result:app_type() & String) -> String:
  match result:
    case (app,text):failed(rows++text,run(app,True{}))
def repeated(rows:String,result:app_type() & String) -> String:
  match result:
    case (app,text):disabled_record(rows++text,record("disabled-before",enabled(app,False{})))
def first(result:app_type() & String) -> String:
  match result:
    case (app,text):repeated(text,record("enabled-repeat-before",app))
def rejected_context(value:Parameter.Declared<F.Schema,D.all_parameter_type()> & (F.context_type() & String)) -> String:
  match value:
    case (Parameter.Declared{RP.Param{access},uses},(_,text)):"definition-rejected("++O.strings(access)++","++F.list_json(~Fields.DeclaredUse,~O.use,uses)++","++text++")"
def disposal_context(parameterAccess:List<&2,String>,uses:List<&2,Fields.DeclaredUse>,providerText:String,result:F.context_type() & String) -> String:
  match result:
    case (_,text):"definition-disposal-rejected("++O.strings(parameterAccess)++","++F.list_json(~Fields.DeclaredUse,~O.use,uses)++","++providerText++","++text++")"
def disposal_provider(context:F.context_type(),value:Parameter.Declared<F.Schema,D.all_parameter_type()> & (provider_type() & String)) -> String:
  match value:
    case (Parameter.Declared{RP.Param{access},uses},(_,text)):disposal_context(access,uses,text,O.context(context))
def recovered(result:RF.Recovered<F.Schema,F.context_type(),provider_type(),D.all_parameter_type()>) -> String:
  match result:
    case RF.Registered{context,provider}:first(record("enabled-before",attached(context,provider)))
    case RF.Rejected{context,descriptor}:rejected_context((descriptor,O.context(context)))
    case RF.DisposalRejected{context,provider,descriptor}:disposal_provider(context,(descriptor,provider_observed(provider)))
def defined(result:definition_type()) -> String:
  recovered(RF.recover(~F.Schema,~F.context_type(),~registry_type(),~F.all_owner(),~D.all_parameter_type(),result))
def started(setup:F.Setup) -> String:
  match setup:
    case F.Ready{context,_}:defined(define_all(context,"mixed-reader"))
    case F.SetupFailed{}:"setup-failed"
def main() -> IO(Unit):
  IO.print(started(F.setup()))
