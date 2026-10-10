import Base
# Fixture-only action transport. The runtime list contains the complete declared
# scenario, not a lifetime or snapshot budget of the observation API.
def joined(~App:Type,next:App -> String -> String,prefix:String,result:App & String) -> String:
  match result:
    case (app,text):next(app,prefix ++ text ++ "\n")
def sequence(~App:Type,actions:List<App -> App & String>,prefix:String,app:App) -> String:
  match actions:
    case []:prefix
    case action <> rest:joined(~App,sequence(~App,rest),prefix,action(app))
def entered(~App:Type,actions:List<App -> App & String>,app:App) -> String:
  sequence(~App,actions,"",app)
