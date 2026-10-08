import Base
import ./plain-transient-application.bend as Plain
import ./registered-application.bend as Registered
import ./system.bend as System
import ./app.bend as App

def misuse(owner:System.Owner<Plain.Schema,Registered.plain_registry()>) -> System.Owner<Plain.Schema,Registered.plain_registry()> & System.Owner<Plain.Schema,Registered.plain_registry()>:
  (owner,owner)
