import Base
import ./fixture-raw-boundary.bend as Boundary
import ./second-owner.bend as Other
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/decode-requests.bend as Request
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/world.bend as W
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/column.bend as Col
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/component.bend as C
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/bundle-component-install.bend as ComponentInstall
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/bundle-install.bend as Install
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/decode-data.bend as D
import ../../complete-v1/controls.bend as First
import /workspace/formal-proofs/bendvy-worktrees/ordinary-snapshot-integration/src/ecs/ordinary-declaration.bend as Identity

def project(owner:First.Owner) -> First.Owner & D.Raw:
  match owner:
    case First.Owner{+raw,sentinel}:(First.Owner{raw,sentinel},Boundary.to_new(raw))
type Schema is Data:Schema{}

def identity() -> Identity.Declaration<Schema,First.Owner>:Identity.component(~Schema,~First.Owner,"first-owner")
def Store() -> Type:Col.Column<Schema,First.Owner>
def World() -> Type:W.World<Schema,Store(),Other.Owner,Unit>
def take(column:Store()) -> Unit & Col.Column<Schema,First.Owner>:(Unit{},column)
def put(rest:Unit,column:Col.Column<Schema,First.Owner>) -> Store():column
def family() -> C.Family<Schema,Store(),Unit,First.Owner,D.Raw,Unit,take,put,project>:C.Family{Identity.key(~Schema,~First.Owner,identity())}
def empty(unit:Unit) -> Store():Col.empty(~Schema,~First.Owner)
def Recovery() -> Type:ComponentInstall.Recovery<Schema,First.Owner>
def repair(+original:D.Raw,+canonical:D.Raw,owner:Maybe<&1,First.Owner>) -> Request.Packet<First.Owner>:
  match owner:
    case None{}:Request.Packet{None{},original,canonical}
    case Some{First.Owner{_,sentinel}}:Request.Packet{Some{First.Owner{Boundary.to_old(original),sentinel}},original,canonical}
def restored(+original:D.Raw,+canonical:D.Raw,result:Install.Restore<World(),ComponentInstall.Entry<Schema,First.Owner>,Recovery()>) -> Install.Restore<World(),Request.Packet<First.Owner>,Recovery()>:
  match result:
    case Install.Restored{world,ComponentInstall.Entry{_,owner}}:Install.Restored{world,repair(original,canonical,owner)}
    case Install.Pending{world,recovery,error}:Install.Pending{world,recovery,error}
def installed(+original:D.Raw,+canonical:D.Raw,result:Install.Attempt<World(),ComponentInstall.Entry<Schema,First.Owner>,Recovery()>) -> Install.Attempt<World(),Request.Packet<First.Owner>,Recovery()>:
  match result:
    case Install.Installed{world,inverse}:Install.Installed{world,world => restored(original,canonical,inverse(world))}
    case Install.Refused{world,ComponentInstall.Entry{_,owner},error}:Install.Refused{world,repair(original,canonical,owner),error}
    case Install.Quarantined{world,recovery,error}:Install.Quarantined{world,recovery,error}
def normalized(owner:Maybe<&1,First.Owner>,canonical:D.Raw) -> Maybe<&1,First.Owner>:
  match owner:
    case None{}:None{}
    case Some{First.Owner{_,sentinel}}:Some{First.Owner{Boundary.to_old(canonical),sentinel}}
def install(world:World(),target:W.Handle<Schema>,packet:Request.Packet<First.Owner>) -> Install.Attempt<World(),Request.Packet<First.Owner>,Recovery()>:
  match packet:
    case Request.Packet{owner,+original,+canonical}:installed(original,canonical,ComponentInstall.install(~Schema,~Store(),~Other.Owner,~Unit,~Unit,~First.Owner,~D.Raw,~Unit,~take,~put,~project,family(),world,ComponentInstall.Entry{target,normalized(owner,canonical)}))
