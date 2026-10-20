import Base
import ./snapshot-schema.bend as Schema
import ./ordinary-schema.bend as Ordinary
import ./owner-product.bend as Product
import ./decode-data.bend as D

def resources_join(~User:Type,~Logs:Type,logs:Logs,observed:User & List<&2,D.Field>) -> Product.Owner<User,Logs> & List<&2,D.Field>:
  match observed:
    case (user,fields):(Product.Owner{user,logs},fields)
# Advanced save projection for Product.Owner<User,Logs>: project only User and
# return both actual owners. Logs are retained unchanged, not serialized as fields.
def resources(~User:Type,~Logs:Type,~project:User -> User & List<&2,D.Field>,owner:Product.Owner<User,Logs>) -> Product.Owner<User,Logs> & List<&2,D.Field>:
  match owner:
    case Product.Owner{user,logs}:resources_join(~User,~Logs,logs,project(user))
# Affine event logs are runtime state, never ordinary persisted resource entries.
# Lift a save-eligible user-resource schema over its affine event-log owner.
# Keep the same declaration inventory/component projection and serialize only user
# resources; logs remain runtime state and are returned intact by the projection.
# This does not save readers, retained batches or a replayable event checkpoint.
# See docs/parity/restore-basic.md for the separate runtime restore boundary.
def with_events(~S:Data,~C:Type,~User:Type,~Logs:Type,~components:U32 -> C -> C & List<&2,D.Field>,~user:User -> User & List<&2,D.Field>,schema:Schema.Schema<S,C,User,True{},components,user>) -> Schema.Schema<S,C,Product.Owner<User,Logs>,True{},components,resources(~User,~Logs,~user)>:
  match schema:
    case Schema.Schema{Ordinary.Schema{entries}}:Schema.Schema{Ordinary.Schema{entries}}
