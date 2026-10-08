import Base
import types.bend as T
import application.bend as App
# Nominal app owners cannot be passed to a different schema's marker.
def denied(app:App.Application<T.SchemaA>) -> App.Application<T.SchemaB>:
  App.marker(~T.SchemaB,app)
