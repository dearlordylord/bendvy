import Base
import ./plain-transient-application.bend as Plain
import ./registered-application.bend as Registered
import ./system.bend as System
import ./app.bend as App

def misuse(app:App.Application<Plain.Schema,Plain.Plain,Unit,Unit,Unit & System.Owner<Plain.Schema,Registered.plain_registry()>>) -> App.Application<Plain.Schema,Plain.Plain,Unit,Unit,Unit & System.Owner<Plain.Schema,Registered.plain_registry()>> & App.Application<Plain.Schema,Plain.Plain,Unit,Unit,Unit & System.Owner<Plain.Schema,Registered.plain_registry()>>:
  (app,app)
