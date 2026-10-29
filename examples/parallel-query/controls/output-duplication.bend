import Base
# The command owner remains abstract in an ordinary command body.
def duplicate(~O:Type,+output:O) -> O & O:(output,output)
