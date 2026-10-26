import Base
import ../ordinary/schema.bend as Schema
import ../ordinary/bodies.bend as Body
import ../ordinary/admission-controls.bend as Control
import ../../../src/ecs/dependency-application.bend as App
import ../../../src/ecs/dependency-registration.bend as Reg
import ../../../src/ecs/dependency-registry-program.bend as Prog
def rejected(~S:Data,world:Schema.World(~S),reader:Control.Reader(~S),guard:Control.Guard(~S)) -> App.Application<Schema.World(~S),Control.Reader(~S),Control.Guard(~S),Schema.Handler,String,U32,Control.ReaderDispatch(~S),Control.GuardDispatch(~S),Body.handle>:
  App.build(~Schema.World(~S),~Control.Reader(~S),~Control.Guard(~S),~Schema.Handler,~String,~U32,~Control.ReaderDispatch(~S),~Control.GuardDispatch(~S),~Prog.leaf(~S,~Unit,~Schema.Resources(~S),~Unit,~Schema.Read(),~Schema.Local,~String,~U32,~Schema.read(~S),~Body.reader),~Prog.leaf(~S,~Unit,~Schema.Resources(~S),~Unit,~Schema.Write(),~Schema.Local,~String,~Bool,~Schema.write(~S),~Control.writable),~Body.handle,~Schema.available,world,reader,Reg.ConditionRegistry{Reg.leaf(~S,~Unit,~Schema.Resources(~S),~Unit,~Schema.Write(),~Schema.Local,~String,~Bool,~Schema.write(~S),~Control.writable,guard),None{}},Schema.Handler{ALeaf{701},[]},[],[App.Binding{1,2}])
