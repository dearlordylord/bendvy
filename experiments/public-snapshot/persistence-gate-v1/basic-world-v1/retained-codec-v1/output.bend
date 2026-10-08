import Base
import ../fixture.bend as F
import ./driver.bend as Driver
import ./format.bend as Format
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W

def garden(workshop:String,result:Driver.Finished<F.Garden>) -> String:
  match result:
    case Driver.Finished{_,report}:"{\"Workshop\":" ++ workshop ++ ",\"Garden\":" ++ Format.report(~F.Garden,report) ++ "}"
    case Driver.SetupRefused{_,_}:"{\"refused\":\"GardenSetup\"}"
    case Driver.CreationRefused{_,_}:"{\"refused\":\"GardenCreation\"}"
def workshop(result:Driver.Finished<F.Workshop>) -> String:
  match result:
    case Driver.Finished{factory,report}:garden(Format.report(~F.Workshop,report),Driver.run(~F.Garden,factory))
    case Driver.SetupRefused{_,_}:"{\"refused\":\"WorkshopSetup\"}"
    case Driver.CreationRefused{_,_}:"{\"refused\":\"WorkshopCreation\"}"
def output() -> String:
  workshop(Driver.run(~F.Workshop,W.factory()))
