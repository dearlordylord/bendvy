import Base
import ./api.bend as A
import ./schemas.bend as S
import ./mutant-system.bend as C

def print_query(prefix: String, result: A.World<S.MotionToken, S.TagCell> & String) -> IO(A.World<S.MotionToken, S.TagCell>):
  match result:
    case (w, text):
      do IO<A.World<S.MotionToken, S.TagCell>>:
        IO.print(prefix ++ text)
        return w
def lookup_text(result: A.LookupResult) -> String:
  match result:
    case A.QueryMismatch{}: "QueryMismatch"
    case A.MissingEntity{}: "MissingEntity"
    case A.Matched{text}: "match:" ++ text
def print_lookup(prefix: String, result: A.World<S.MotionToken, S.TagCell> & A.LookupResult) -> IO(A.World<S.MotionToken, S.TagCell>):
  match result:
    case (w, result):
      do IO<A.World<S.MotionToken, S.TagCell>>:
        IO.print(prefix ++ lookup_text(result))
        return w
def observe(+checkpoint: String, w: A.World<S.MotionToken, S.TagCell>) -> IO(A.World<S.MotionToken, S.TagCell>):
  do IO<A.World<S.MotionToken, S.TagCell>>:
    w : A.World<S.MotionToken, S.TagCell> <- print_query("motion:" ++ checkpoint ++ ":Required:", A.query(~S.MotionToken, ~S.TagCell, ~Maybe<&2, S.Tag>, ~C.motion_read, ~S.tag_get, ~S.tag_has, A.Required{}, w))
    w : A.World<S.MotionToken, S.TagCell> <- print_query("motion:" ++ checkpoint ++ ":Present:", A.query(~S.MotionToken, ~S.TagCell, ~Maybe<&2, S.Tag>, ~C.motion_read, ~S.tag_get, ~S.tag_has, A.Present{}, w))
    w : A.World<S.MotionToken, S.TagCell> <- print_query("motion:" ++ checkpoint ++ ":Absent:", A.query(~S.MotionToken, ~S.TagCell, ~Maybe<&2, S.Tag>, ~C.motion_read, ~S.tag_get, ~S.tag_has, A.Absent{}, w))
    w : A.World<S.MotionToken, S.TagCell> <- print_query("motion:" ++ checkpoint ++ ":Optional:", A.query(~S.MotionToken, ~S.TagCell, ~Maybe<&2, S.Tag>, ~C.motion_read, ~S.tag_get, ~S.tag_has, A.Optional{}, w))
    w : A.World<S.MotionToken, S.TagCell> <- print_lookup("motion:" ++ checkpoint ++ ":lookup-b-Required:", A.lookup(~S.MotionToken, ~S.TagCell, ~Maybe<&2, S.Tag>, ~C.motion_read, ~S.tag_get, ~S.tag_has, A.Required{}, "b", w))
    w : A.World<S.MotionToken, S.TagCell> <- print_lookup("motion:" ++ checkpoint ++ ":lookup-b-Present:", A.lookup(~S.MotionToken, ~S.TagCell, ~Maybe<&2, S.Tag>, ~C.motion_read, ~S.tag_get, ~S.tag_has, A.Present{}, "b", w))
    w : A.World<S.MotionToken, S.TagCell> <- print_lookup("motion:" ++ checkpoint ++ ":lookup-b-Optional:", A.lookup(~S.MotionToken, ~S.TagCell, ~Maybe<&2, S.Tag>, ~C.motion_read, ~S.tag_get, ~S.tag_has, A.Optional{}, "b", w))
    return w
def tick(+checkpoint: String, w: A.World<S.MotionToken, S.TagCell>) -> IO(A.World<S.MotionToken, S.TagCell>):
  do IO<A.World<S.MotionToken, S.TagCell>>:
    w : A.World<S.MotionToken, S.TagCell> <- print_query("motion:" ++ checkpoint ++ ":own:", A.writable(~S.MotionToken, ~S.TagCell, ~Maybe<&2, S.Tag>, ~C.motion_step, ~S.tag_get, w))
    w : A.World<S.MotionToken, S.TagCell> <- observe(checkpoint, w)
    return w
def run() -> IO(Unit):
  do IO<Unit>:
    w : A.World<S.MotionToken, S.TagCell> <- observe("setup", S.motion())
    w : A.World<S.MotionToken, S.TagCell> <- tick("step1", w)
    w : A.World<S.MotionToken, S.TagCell> <- tick("step2", w)
    w : A.World<S.MotionToken, S.TagCell> <- tick("step3", w)
    return Unit{}
def main() -> IO(Unit):
  run()
