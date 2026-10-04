import Base
import ./LAWS.bend as Laws
import ./complete.bend as C
import ../t11-replacement/types.bend as T
import ../t11-replacement/spec.bend as S

# Own endpoint section: query_any_complete_ordered
def Laws.query_any_complete_ordered(limit,world):
  match world:
    case T.World{+id,+next,+rows,+pending}:
      C.guarded(S.admissible(limit,T.World{id,next,rows,pending}),limit,id,next,rows,pending,T.Any{},{==})

# Own endpoint section: query_present_complete_ordered
def Laws.query_present_complete_ordered(limit,world):
  match world:
    case T.World{+id,+next,+rows,+pending}:
      C.guarded(S.admissible(limit,T.World{id,next,rows,pending}),limit,id,next,rows,pending,T.Present{},{==})

# Own endpoint section: query_absent_complete_ordered
def Laws.query_absent_complete_ordered(limit,world):
  match world:
    case T.World{+id,+next,+rows,+pending}:
      C.guarded(S.admissible(limit,T.World{id,next,rows,pending}),limit,id,next,rows,pending,T.Absent{},{==})

