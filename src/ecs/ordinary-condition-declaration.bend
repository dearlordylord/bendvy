import Base
import ./world.bend as W
import ./schedule.bend as Sch
import ./schedule-provision.bend as SP
# Closed ordinary blueprint. Affine callable fields are freshly projected from
# the same closed declaration index; no captured owner or registered guard state.
# Closed named condition blueprint indexed by its World-threading predicate.
# Contains no captured affine guard owner or registered reader state. Predicate
# is trusted setup; its returned World survives regardless of Bool result.
type Declaration<-S:Data,-C:Type,-R:Type,-E:Data,-predicate:W.World<S,C,R,E> -> W.World<S,C,R,E> & Bool> is Data:Declaration{name:String}
# Owned condition-plan builder/evaluator plus ordered condition names.
# Ordinary constructors derive slots and descriptions from the same program.
# Raw construction remains trusted; this is not a registered stateful guard.
type Program<-S:Data,-C:Type,-R:Type,-E:Data,-Ids:Data> is Type:
  Program{width:Nat,build:Ids -> SP.Plan<S>,names:List<&2,String>,evaluate:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool}
# Materialized condition program: width, operational plan and ordered names.
# Metadata is detached; it does not grant runtime registration authority.
type Entries<S:Data> is Data:Entries{width:Nat,plan:SP.Plan<S>,names:List<&2,String>}
# Name a closed predicate for ordinary condition routing and descriptions.
# Does not evaluate it, register a system or allocate a reader/capture owner.
def named(~S:Data,~C:Type,~R:Type,~E:Data,~predicate:W.World<S,C,R,E> -> W.World<S,C,R,E> & Bool,name:String) -> Declaration<S,C,R,E,predicate>:Declaration{name}
# Return the condition's authored name, without evaluating its predicate.
def leaf_name(~S:Data,~C:Type,~R:Type,~E:Data,~predicate:W.World<S,C,R,E> -> W.World<S,C,R,E> & Bool,leaf:Declaration<S,C,R,E,predicate>) -> String:
  match leaf:
    case Declaration{name}:name
# Build one system placement and its condition slot from the same leaf.
# identify maps authored Ids to a registration ID; requirements are explicit
# plan metadata. Does not invoke predicate or system body during construction.
def system(~S:Data,~C:Type,~R:Type,~E:Data,~Ids:Data,~predicate:W.World<S,C,R,E> -> W.World<S,C,R,E> & Bool,~identify:Ids -> U32,requirements:List<&2,SP.Requirement<S>>,leaf:Declaration<S,C,R,E,predicate>) -> Program<S,C,R,E,Ids>:
  Program{1n,ids => SP.Entry{Sch.System{identify(ids),0},requirements},[leaf_name(~S,~C,~R,~E,~predicate,leaf)],world => slot => predicate(world)}
# Build a named phase placement with requirements and no condition slot.
# Phase metadata does not evaluate a guard or execute registered systems.
def phase(~S:Data,~C:Type,~R:Type,~E:Data,~Ids:Data,name:String,requirements:List<&2,SP.Requirement<S>>) -> Program<S,C,R,E,Ids>:
  Program{0n,ids => SP.Entry{Sch.Phase{name},requirements},[],world => slot => (world,False{})}
# Build an explicit structural barrier placement with requirements and no
# condition slot. Constructing the program does not apply pending commands.
def barrier(~S:Data,~C:Type,~R:Type,~E:Data,~Ids:Data,requirements:List<&2,SP.Requirement<S>>) -> Program<S,C,R,E,Ids>:
  Program{0n,ids => SP.Entry{Sch.Barrier{},requirements},[],world => slot => (world,False{})}
def shifted(~S:Data,plan:SP.Plan<S>,+offset:U32) -> SP.Plan<S>:
  match plan:
    case SP.Empty{}:SP.Empty{}
    case SP.Entry{Sch.System{id,slot},requirements}:SP.Entry{Sch.System{id,(slot + offset : U32)},requirements}
    case SP.Entry{Sch.Phase{name},requirements}:SP.Entry{Sch.Phase{name},requirements}
    case SP.Entry{Sch.Barrier{},requirements}:SP.Entry{Sch.Barrier{},requirements}
    case SP.Sequence{left,right}:SP.Sequence{shifted(~S,left,offset),shifted(~S,right,offset)}
def built_pair(~S:Data,~Ids:Data,first:Ids -> SP.Plan<S>,second:Ids -> SP.Plan<S>,offset:Nat,+ids:Ids) -> SP.Plan<S>:SP.Sequence{first(ids),shifted(~S,second(ids),U32.from_nat(offset))}
def selected(~S:Data,~C:Type,~R:Type,~E:Data,chosen:Bool,left:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,right:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,world:W.World<S,C,R,E>,slot:U32,offset:Nat) -> W.World<S,C,R,E> & Bool:
  match chosen:
    case True{}:left(world,slot)
    case False{}:right(world,(slot - U32.from_nat(offset) : U32))
def evaluated_pair(~S:Data,~C:Type,~R:Type,~E:Data,left:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,right:W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool,+offset:Nat,world:W.World<S,C,R,E>,+slot:U32) -> W.World<S,C,R,E> & Bool:selected(~S,~C,~R,~E,Nat.is_lt(U32.to_nat(slot),offset),left,right,world,slot,offset)
# Compose programs in authored order, shifting right-side system condition
# slots by left width. Preserves names/requirements and World-threading routing;
# does not evaluate predicates or reorder systems by dependency.
def sequence(~S:Data,~C:Type,~R:Type,~E:Data,~Ids:Data,first:Program<S,C,R,E,Ids>,second:Program<S,C,R,E,Ids>) -> Program<S,C,R,E,Ids>:
  match first second:
    case Program{+leftWidth,leftBuild,leftNames,leftEval} Program{rightWidth,rightBuild,rightNames,rightEval}:Program{Nat.add(leftWidth,rightWidth),ids => built_pair(~S,~Ids,leftBuild,rightBuild,leftWidth,ids),List.append(&2,String,leftNames,rightNames),world => slot => evaluated_pair(~S,~C,~R,~E,leftEval,rightEval,leftWidth,world,slot)}
# Consume a program to obtain its slot-indexed World-threading evaluator.
# Use slots from the matching materialized/validated program; arbitrary callback
# mutations or host effects are not transactionally isolated by this adapter.
def evaluator(~S:Data,~C:Type,~R:Type,~E:Data,~Ids:Data,program:Program<S,C,R,E,Ids>) -> W.World<S,C,R,E> -> U32 -> W.World<S,C,R,E> & Bool:
  match program:
    case Program{_,_,_,evaluate}:evaluate
def built(~S:Data,~Ids:Data,width:Nat,names:List<&2,String>,result:SP.Plan<S>) -> Entries<S>:Entries{width,result,names}
# Build detached Entries from authored Ids, retaining plan order/names.
# Does not validate registration liveness or run guards; valid checks structural
# slot bounds before ordinary schedule attachment checks actual registration IDs.
def materialize(~S:Data,~C:Type,~R:Type,~E:Data,~Ids:Data,declaration:Program<S,C,R,E,Ids>,ids:Ids) -> Entries<S>:
  match declaration:
    case Program{width,build,names,_}:built(~S,~Ids,width,names,build(ids))
# Advanced structural check that each system's condition slot is below width.
# Does not check World association, live registrations or predicate provenance.
def slots(~S:Data,plan:SP.Plan<S>,+width:Nat) -> Bool:
  match plan:
    case SP.Empty{}:True{}
    case SP.Entry{Sch.System{_,slot},_}:Nat.is_lt(U32.to_nat(slot),width)
    case SP.Entry{Sch.Phase{_},_}:True{}
    case SP.Entry{Sch.Barrier{},_}:True{}
    case SP.Sequence{left,right}:Bool.and(slots(~S,left,width),slots(~S,right,width))
# Structural validation only. Trusted closed constructors establish provenance.
# Check width/name length agreement, representable slot range and slot bounds.
# Structural validation only: trusted constructors establish correspondence
# between predicates, names and plan; this is not runtime authority validation.
def valid(~S:Data,entries:Entries<S>) -> Bool:
  match entries:
    case Entries{+width,plan,names}:Bool.and(Nat.is_eq(width,List.length(&2,String,names)),Bool.and(Nat.is_le(width,1n+U32.to_nat(4294967295)),slots(~S,plan,width)))
# Consume Entries and return its operational plan without evaluating guards.
def plan(~S:Data,entries:Entries<S>) -> SP.Plan<S>:
  match entries:
    case Entries{_,plan,_}:plan
# Detached name lookup by Nat position, returning None outside the list.
# Names are descriptive; finding one supplies no execution authority.
def lookup(names:List<&2,String>,index:Nat) -> Maybe<&2,String>:
  match names index:
    case [] _:None{}
    case first <> _ 0n:Some{first}
    case _ <> rest 1n+prior:lookup(rest,prior)
# Return the optional authored name for a materialized condition slot.
# Does not validate a registration or execute the corresponding predicate.
def condition_name(~S:Data,entries:Entries<S>,slot:U32) -> Maybe<&2,String>:
  match entries:
    case Entries{_,_,names}:lookup(names,U32.to_nat(slot))
