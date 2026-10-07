import Base
import state.bend as V
import ../public-decode/typed.bend as D

# Caller-authored finite scalar decoders. These do not execute D.Codec.
def phase_decoded(+raw: String,decoded: Maybe<&2,V.Phase>) -> Result<&2,&1,D.Error,V.Phase>:
  match decoded:
    case Some{value}: Done{value}
    case None{}: Fail{D.Invalid{"$","\"ready\" | \"windup\" | \"active\"",D.Text{raw}}}
def phase(raw: String) -> Result<&2,&1,D.Error,V.Phase>:
  match raw:
    case +raw: phase_decoded(raw,V.phase_raw(raw))
def mode_decoded(+raw: U32,decoded: Maybe<&2,V.Mode>) -> Result<&2,&1,D.Error,V.Mode>:
  match decoded:
    case Some{value}: Done{value}
    case None{}: Fail{D.Invalid{"$","0 | 1 | 2",D.Number{raw}}}
def mode(raw: U32) -> Result<&2,&1,D.Error,V.Mode>:
  match raw:
    case +raw: mode_decoded(raw,V.mode_decode(raw))
