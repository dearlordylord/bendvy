import Base
import ../../../src/ecs/execution-composer-layout.bend as Layout

def public_layout() -> Layout.Layout:Layout.LayoutLeaf{Array<U32>,"public"}
def secret_layout() -> Layout.Layout:Layout.LayoutLeaf{Array<U32>,"secret"}
def relabel(owner:Layout.resources(~Unit,public_layout())) -> Layout.resources(~Unit,secret_layout()):
  Layout.checked_owner(Layout.resources(~Unit,public_layout()),Layout.resources(~Unit,secret_layout()),{==},owner)
