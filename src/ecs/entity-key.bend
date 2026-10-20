import Base

# Detached entity slot index and generation. This key has no world namespace
# or liveness proof; use a World.Handle and checked operations for authority.
# Generation wrap follows the allocator contract, not eternal key uniqueness.
type Key is Data:
  EntityKey{index:U32,generation:U32}

# Return only the slot index, discarding generation for this observation.
# Equal indices do not establish equal entity identities or valid handles.
def index(key:Key) -> U32:
  match key:
    case EntityKey{index,_}:index

# Return the stored generation without validating a live entity or world.
def generation(key:Key) -> U32:
  match key:
    case EntityKey{_,generation}:generation

# Compare both slot index and generation. Does not compare world namespaces
# or establish liveness; World handle validation remains required.
def equal(left:Key,right:Key) -> Bool:
  match left right:
    case EntityKey{li,lg} EntityKey{ri,rg}:Bool.and(U32.is_eq(li,ri),U32.is_eq(lg,rg))
