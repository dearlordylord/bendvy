import Base
import ../consumer/frontend.bend as Auto
type AuthoritySchema is Data:
  AuthoritySchema{}
def duplicate(app:Auto.RegisteredApplication(~AuthoritySchema)) -> Auto.RegisteredApplication(~AuthoritySchema) & Auto.RegisteredApplication(~AuthoritySchema):
  (app,app)
