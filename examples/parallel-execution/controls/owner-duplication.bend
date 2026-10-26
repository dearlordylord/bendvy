import Base
import ../body.bend as Body

type Schema is Data:
  Schema{}
def duplicate(local:Body.Local<Schema>) -> Body.Local<Schema> & Body.Local<Schema>:
  (local,local)
