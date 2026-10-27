import Base
import ./execution-builder.bend as Build
import ./execution-declaration.bend as D
import ./execution-query-interpreter.bend as Query
import ./execution-resource-interpreter.bend as Resource

# The ordinary framework selects genuine interpreters for the same closed Program.
# No caller-supplied permission catalog or dynamic invocation inventory enters caps.
# Actual World admission and resource/component cuts remain later retained owners.
def compile(~S:Data,~WC:Type,~C:Type,~R:Type,~Ops:Data -> Type -> Type,~program:Build.Program(~S,~WC,~C,~R,~Ops)) -> D.Compilation<S,WC,C,R,Ops>:
  Build.compile_with_interpreters(~S,~WC,~C,~R,~Query.provider_dictionary(~S,~WC,~C,~R),~Resource.read_dictionary(~S,~C,~R),~Resource.write_dictionary(~S,~C,~R),~Ops,~program)
