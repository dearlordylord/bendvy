import Base
import ../../scenario-systems.bend as Systems
import ../../scenario-driver.bend as Driver
import ../dispatch.bend as Dispatch

# Concrete affine application carriers; public ECS declarations are unchanged.
type Plain is Type:
  Plain{main:Systems.plain_main_owner(),added:Systems.plain_added_owner(),changed:Systems.plain_changed_owner(),without:Systems.plain_without_owner(),withHealth:Systems.plain_with_owner(),trace:Dispatch.Trace}
def plain_pack(value:Dispatch.plain_owners()) -> Plain:
  match value:
    case ((((((Unit{},main),added),changed),without),withHealth),trace):Plain{main,added,changed,without,withHealth,trace}
def plain_unpack(value:Plain) -> Dispatch.plain_owners():
  match value:
    case Plain{main,added,changed,without,withHealth,trace}:((((((Unit{},main),added),changed),without),withHealth),trace)
def plain_roundtrip(value:Dispatch.plain_owners()) -> Dispatch.plain_owners():
  plain_unpack(plain_pack(value))

type Transient is Type:
  Transient{main:Systems.transient_main_owner(),added:Systems.transient_added_owner(),changed:Systems.transient_changed_owner(),without:Systems.transient_without_owner(),withHealth:Systems.transient_with_owner(),trace:Dispatch.Trace}
def transient_pack(value:Dispatch.transient_owners()) -> Transient:
  match value:
    case ((((((Unit{},main),added),changed),without),withHealth),trace):Transient{main,added,changed,without,withHealth,trace}
def transient_unpack(value:Transient) -> Dispatch.transient_owners():
  match value:
    case Transient{main,added,changed,without,withHealth,trace}:((((((Unit{},main),added),changed),without),withHealth),trace)
def transient_roundtrip(value:Dispatch.transient_owners()) -> Dispatch.transient_owners():
  transient_unpack(transient_pack(value))

type Constructed is Type:
  Constructed{main:Systems.constructed_main_owner(),added:Systems.constructed_added_owner(),changed:Systems.constructed_changed_owner(),without:Systems.constructed_without_owner(),withHealth:Systems.constructed_with_owner(),trace:Dispatch.Trace}
def constructed_pack(value:Dispatch.constructed_owners()) -> Constructed:
  match value:
    case ((((((Unit{},main),added),changed),without),withHealth),trace):Constructed{main,added,changed,without,withHealth,trace}
def constructed_unpack(value:Constructed) -> Dispatch.constructed_owners():
  match value:
    case Constructed{main,added,changed,without,withHealth,trace}:((((((Unit{},main),added),changed),without),withHealth),trace)
def constructed_roundtrip(value:Dispatch.constructed_owners()) -> Dispatch.constructed_owners():
  constructed_unpack(constructed_pack(value))
