import Base
import ./typed-api-fixture.bend as F

# Must be rejected by affine ownership: one registered Provider cannot be copied.
def bad_duplicate_provider(provider:F.core_provider_type()) -> F.core_provider_type() & F.core_provider_type():
  (provider,provider)
