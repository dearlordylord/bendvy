import Base
import ./typed-api-fixture.bend as F

# Must be rejected by affine ownership: a per-reader owner has one owner path.
def bad_duplicate_reader_owner(owner:F.core_reader_owner_type()) -> F.core_reader_owner_type() & F.core_reader_owner_type():
  (owner,owner)
