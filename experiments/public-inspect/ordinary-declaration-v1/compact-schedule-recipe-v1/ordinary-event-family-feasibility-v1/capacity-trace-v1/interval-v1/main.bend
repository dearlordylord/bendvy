import Base
import ../trace.bend as T
import ../consumer.bend as C
import timing.bend as Clock
import render.bend as Render
# Effect continuation holds the real affine fixture between intervals.
# All source-defined snapshots remain outside each timed operation.
def finished(returned:C.Fixture & List<&2,T.Row>) -> IO(Unit):
  match returned:
    case (_,rows):IO.bind(Unit,Unit,Clock.capture(Render.rows(rows)),u => Clock.finish())
def next_rows(next:C.Fixture -> IO(C.Fixture & List<&2,T.Row>),returned:C.Fixture & List<&2,T.Row>) -> IO(C.Fixture & List<&2,T.Row>):
  match returned:
    case (fixture,rows):IO.bind(C.Fixture & List<&2,T.Row>,C.Fixture & List<&2,T.Row>,next(fixture),rest => IO.pure(C.Fixture & List<&2,T.Row>,T.appended(rows,rest)))
def after_end(next:C.Fixture -> IO(C.Fixture & List<&2,T.Row>),returned:C.Fixture & C.Observation) -> IO(C.Fixture & List<&2,T.Row>):
  match returned:
    case (fixture,completion):IO.bind(Unit,C.Fixture & List<&2,T.Row>,Clock.end(),u => next_rows(next,T.observe(Some{completion},fixture)))
def sequence(actions:List<&2,C.Action>,+index:U32,fixture:C.Fixture) -> IO(C.Fixture & List<&2,T.Row>):
  match actions:
    case []:IO.pure(C.Fixture & List<&2,T.Row>,(fixture,[]))
    case action <> rest:IO.bind(Unit,C.Fixture & List<&2,T.Row>,Clock.begin(index),u => after_end(fixture => sequence(rest,U32.add(index,1),fixture),T.ticked(action,fixture)))
def started(u:Unit) -> IO(Unit):
  IO.bind(C.Fixture & List<&2,T.Row>,Unit,next_rows(fixture => sequence(T.actions(),0,fixture),T.observe(None{},C.setup())),finished)
def main() -> IO(Unit):IO.bind(Unit,Unit,Clock.reset(),started)
