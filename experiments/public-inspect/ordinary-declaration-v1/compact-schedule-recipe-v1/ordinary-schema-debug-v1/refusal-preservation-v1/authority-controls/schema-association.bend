import Base
import ../frontend.bend as Front
import ../../setup.bend as Setup
import ../../application.bend as Application
import /workspace/formal-proofs/bendvy/src/ecs/ordinary-schema.bend as Schema
type AuthoritySchema is Data:
  AuthoritySchema{}
type OtherSchema is Data:
  OtherSchema{}
def attach(schema:Schema.Schema<OtherSchema,Setup.store(~OtherSchema,~Array<U32>),Setup.resources(~Array<U32>)>,app:Front.RegisteredApp(~AuthoritySchema)) -> Application.Application<AuthoritySchema,Setup.store(~AuthoritySchema,~Array<U32>),Setup.resources(~Array<U32>),U32,Front.owners(~AuthoritySchema),Front.rows(~AuthoritySchema),Front.observe(~AuthoritySchema),Front.fold(~AuthoritySchema)>:
  Application.attached(~AuthoritySchema,~Setup.store(~AuthoritySchema,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Front.owners(~AuthoritySchema),~Front.rows(~AuthoritySchema),~Front.observe(~AuthoritySchema),~Front.fold(~AuthoritySchema),schema,app)
