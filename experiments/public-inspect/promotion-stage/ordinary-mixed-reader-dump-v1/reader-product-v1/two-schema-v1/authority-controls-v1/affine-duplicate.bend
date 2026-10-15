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
def duplicate(first:F.context_type(),second:F.context_type(),provider:P.provider_type()) -> P.app_type() & P.app_type():
  (RF.attach_context(~F.Schema,~F.store_type(),~Unit,~F.event_type(),~P.invocation_type(),~Empty,~P.envelope_type(),~P.runner_fn(),~F.all_owner(),~D.all_parameter_type(),~F.context_type(),~Unit,~String,~O.observe,~Pair.empty(~F.Schema),first,Unit{},provider,Recipe.Recipe{},True{}),RF.attach_context(~F.Schema,~F.store_type(),~Unit,~F.event_type(),~P.invocation_type(),~Empty,~P.envelope_type(),~P.runner_fn(),~F.all_owner(),~D.all_parameter_type(),~F.context_type(),~Unit,~String,~O.observe,~Pair.empty(~F.Schema),second,Unit{},provider,Recipe.Recipe{},True{}))
