import Base
import ../../../src/ecs/execution-resource-policy.bend as Policy
import ../../../src/ecs/execution-composer-layout.bend as Layout

def project(owner:Array<U32>) -> Array<U32> & U32:Array.get(U32,owner,0)
def public_layout() -> Layout.Layout:Layout.LayoutLeaf{Array<U32>,U32,project,"public",Policy.Ordinary{}}
def secret_layout() -> Layout.Layout:Layout.LayoutLeaf{Array<U32>,U32,project,"secret",Policy.Ordinary{}}
def relabel(owner:Layout.resources(~Unit,public_layout())) -> Layout.resources(~Unit,secret_layout()):
  Layout.checked_owner(Layout.resources(~Unit,public_layout()),Layout.resources(~Unit,secret_layout()),{==},owner)
