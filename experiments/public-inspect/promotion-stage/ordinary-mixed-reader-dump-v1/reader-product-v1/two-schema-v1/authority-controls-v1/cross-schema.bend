import Base
import ../../../../../../public-schedules/named-app-v1/reader-provider-debug-v1/main.bend as P
import ../../../../../../public-schedules/named-app-v1/reader-provider-debug-v1/fixture.bend as F
import ../../../../../../public-schedules/named-app-v1/reader-provider-debug-v1/declarations.bend as D
import ../../../../../../public-schedules/named-app-v1/reader-provider-debug-v1/observer.bend as O
import ../beta/declarations.bend as BetaD
import ../../../../../../../src/ecs/ordinary-app-reader-fields.bend as RF
import ../../../../../../../src/ecs/transaction.bend as Tx
import ../../../../../../../src/ecs/ordinary-app-records.bend as Pair
import ../../../../../../../src/ecs/ordinary-app-recipe.bend as Recipe
def define(context:F.context_type(),name:String) -> P.definition_type():
  RF.define_mixed(~F.Schema,~F.store_type(),~Unit,~F.Publication,~F.family_type(),~Unit,~F.all_owner(),~F.all_view(),~F.all_delta(),~Bool,~U32,~F.all_view(),~D.validate_fn(),~D.prepare_fn(),~D.commit_fn(),~D.release_fn(),~F.no_caps,~F.callback,~F.no_grant(~Tx.Tx<F.world_type(),F.event_type()>),~F.sync_events,~F.classify,~P.initialize_all,BetaD.all_parameter(),context,name)
