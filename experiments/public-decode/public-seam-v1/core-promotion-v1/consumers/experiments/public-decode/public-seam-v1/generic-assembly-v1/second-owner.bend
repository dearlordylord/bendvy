import Base
import ../../../../../library/decode-requests.bend as Request
import /workspace/formal-proofs/bendvy/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy/src/ecs/bundle-component-install.bend as ComponentInstall
import /workspace/formal-proofs/bendvy/src/ecs/bundle-install.bend as Install
import ../../../../../dependencies/snapshot/decode-data.bend as D
import ../../complete-v1/controls.bend as First
import ../../../../../dependencies/snapshot/ordinary-declaration.bend as Identity

type Owner is Type:Owner{raw:D.Raw,words:Array<U32>,flags:Array<Bool>}
def project(owner:Owner) -> Owner & D.Raw:
  match owner:
    case Owner{+raw,words,flags}:(Owner{raw,words,flags},raw)
def identity() -> Identity.Declaration<Unit,Owner>:Identity.component(~Unit,~Owner,"second-owner")
def Store() -> Type:Col.Column<Unit,Owner>
def World() -> Type:W.World<Unit,Store(),First.Owner,Unit>
def take(column:Store()) -> Unit & Col.Column<Unit,Owner>:(Unit{},column)
def put(rest:Unit,column:Col.Column<Unit,Owner>) -> Store():column
def family() -> C.Family<Unit,Store(),Unit,Owner,D.Raw,Unit,take,put,project>:C.Family{Identity.key(~Unit,~Owner,identity())}
def empty(unit:Unit) -> Store():Col.empty(~Unit,~Owner)
def Recovery() -> Type:ComponentInstall.Recovery<Unit,Owner>
def repair(+original:D.Raw,+canonical:D.Raw,owner:Maybe<&1,Owner>) -> Request.Packet<Owner>:
  match owner:
    case None{}:Request.Packet{None{},original,canonical}
    case Some{Owner{_,words,flags}}:Request.Packet{Some{Owner{original,words,flags}},original,canonical}
def restored(+original:D.Raw,+canonical:D.Raw,result:Install.Restore<World(),ComponentInstall.Entry<Unit,Owner>,Recovery()>) -> Install.Restore<World(),Request.Packet<Owner>,Recovery()>:
  match result:
    case Install.Restored{world,ComponentInstall.Entry{_,owner}}:Install.Restored{world,repair(original,canonical,owner)}
    case Install.Pending{world,recovery,error}:Install.Pending{world,recovery,error}
def installed(+original:D.Raw,+canonical:D.Raw,result:Install.Attempt<World(),ComponentInstall.Entry<Unit,Owner>,Recovery()>) -> Install.Attempt<World(),Request.Packet<Owner>,Recovery()>:
  match result:
    case Install.Installed{world,inverse}:Install.Installed{world,world => restored(original,canonical,inverse(world))}
    case Install.Refused{world,ComponentInstall.Entry{_,owner},error}:Install.Refused{world,repair(original,canonical,owner),error}
    case Install.Quarantined{world,recovery,error}:Install.Quarantined{world,recovery,error}
def normalized(owner:Maybe<&1,Owner>,canonical:D.Raw) -> Maybe<&1,Owner>:
  match owner:
    case None{}:None{}
    case Some{Owner{_,words,flags}}:Some{Owner{canonical,words,flags}}
def install(world:World(),target:W.Handle<Unit>,packet:Request.Packet<Owner>) -> Install.Attempt<World(),Request.Packet<Owner>,Recovery()>:
  match packet:
    case Request.Packet{owner,+original,+canonical}:installed(original,canonical,ComponentInstall.install(~Unit,~Store(),~First.Owner,~Unit,~Unit,~Owner,~D.Raw,~Unit,~take,~put,~project,family(),world,ComponentInstall.Entry{target,normalized(owner,canonical)}))
