import Base
import ../consumer.bend as Consumer
type AuthoritySchema is Data:
  AuthoritySchema{}
def duplicate(app:Consumer.Application(~AuthoritySchema)) -> Consumer.Application(~AuthoritySchema) & Consumer.Application(~AuthoritySchema):
  (app,app)
