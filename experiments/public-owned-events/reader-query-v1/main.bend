import Base
import ../families-v1/schema.bend as Families
import ../families-v1/fixture.bend as F
import ../../../src/ecs/column.bend as Col
import ./scenario.bend as Scenario
import ../../../src/ecs/world.bend as W
import ../../../src/ecs/world-io.bend as WI
type Workshop is Data:Workshop{}
type Garden is Data:Garden{}
def garden_foreign(first:String,world:W.World<Garden,Col.Column<Garden,U32>,Families.Resources(),Families.E()>,created:WI.Creation<Garden,Col.Column<Garden,U32>,Families.Resources(),Families.E()>) -> IO(Unit):
  match created:
    case WI.Created{other}:IO.print("Workshop\n" ++ first ++ "Garden\n" ++ Scenario.start(~Garden,world,other))
    case _:IO.die(Unit,1,"foreign creation failed")
def garden_first(first:String,created:WI.Creation<Garden,Col.Column<Garden,U32>,Families.Resources(),Families.E()>) -> IO(Unit):
  match created:
    case WI.Created{world}:IO.bind(WI.Creation<Garden,Col.Column<Garden,U32>,Families.Resources(),Families.E()>,Unit,WI.create(~Garden,~Col.Column<Garden,U32>,~Families.Resources(),~Families.E(),~F.empty(~Garden),Families.resources()),value => garden_foreign(first,world,value))
    case _:IO.die(Unit,1,"creation failed")
def workshop_foreign(world:W.World<Workshop,Col.Column<Workshop,U32>,Families.Resources(),Families.E()>,created:WI.Creation<Workshop,Col.Column<Workshop,U32>,Families.Resources(),Families.E()>) -> IO(Unit):
  match created:
    case WI.Created{other}:IO.bind(WI.Creation<Garden,Col.Column<Garden,U32>,Families.Resources(),Families.E()>,Unit,WI.create(~Garden,~Col.Column<Garden,U32>,~Families.Resources(),~Families.E(),~F.empty(~Garden),Families.resources()),value => garden_first(Scenario.start(~Workshop,world,other),value))
    case _:IO.die(Unit,1,"foreign creation failed")
def workshop_first(created:WI.Creation<Workshop,Col.Column<Workshop,U32>,Families.Resources(),Families.E()>) -> IO(Unit):
  match created:
    case WI.Created{world}:IO.bind(WI.Creation<Workshop,Col.Column<Workshop,U32>,Families.Resources(),Families.E()>,Unit,WI.create(~Workshop,~Col.Column<Workshop,U32>,~Families.Resources(),~Families.E(),~F.empty(~Workshop),Families.resources()),value => workshop_foreign(world,value))
    case _:IO.die(Unit,1,"creation failed")
def main() -> IO(Unit):IO.bind(WI.Creation<Workshop,Col.Column<Workshop,U32>,Families.Resources(),Families.E()>,Unit,WI.create(~Workshop,~Col.Column<Workshop,U32>,~Families.Resources(),~Families.E(),~F.empty(~Workshop),Families.resources()),workshop_first)
