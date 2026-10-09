import Base
import ./owners.bend as Owners
import ../dispatch.bend as Dispatch
# Source-consuming arbitrary-owner adapters; no owner can be erased or copied.
def plain(value:Dispatch.plain_owners()) -> Dispatch.plain_owners():
  Owners.plain_roundtrip(value)
def transient(value:Dispatch.transient_owners()) -> Dispatch.transient_owners():
  Owners.transient_roundtrip(value)
def constructed(value:Dispatch.constructed_owners()) -> Dispatch.constructed_owners():
  Owners.constructed_roundtrip(value)
def main() -> Unit:
  Unit{}
