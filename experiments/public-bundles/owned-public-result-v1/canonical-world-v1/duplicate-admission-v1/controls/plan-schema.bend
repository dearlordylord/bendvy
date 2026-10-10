import Base
import ../ordinary-bundle.bend as Front
import ../bundle.bend as B
import ../runtime.bend as R
import ../../complete-families-v1/canonical.bend as K
def bad(plan:Front.Plan<K.SchemaB,B.Raw(),B.Cooked()>,owner:B.Owner(R.Mail),input:B.Input()) -> B.Owner(R.Mail) & B.Output():Front.request(~K.SchemaA,~B.Store,~R.Mail,~U32,~B.Packet,~K.Context<K.SchemaA>,~B.Raw(),~B.Cooked(),~B.ConstructorError(),~K.stage(~K.SchemaA),~B.pack,~B.unpack,plan,owner,input)
