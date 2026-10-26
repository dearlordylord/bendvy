import Base
# A worker cannot turn its abstract output owner into an unrelated affine owner.
def escape(~O:Type,output:O) -> Array<U32>:output
