import Base
import ./enum-lookup.bend as E
import ../t11-replacement/types.bend as T
import ../t11-replacement/spec.bend as S

# Unsorted, duplicate physical keys and keys outside the requested interval.
def raw_rows() -> List<&2,T.Row>:
  [T.Row{3n,30n,True{}},T.Row{1n,10n,False{}},T.Row{3n,99n,False{}},T.Row{5n,50n,True{}},T.Row{0n,5n,False{}}]

def inside_duplicate_first() -> {Some{T.Row{3n,30n,True{}}} == S.at(S.enumerate_rows(3n,2n,raw_rows(),T.Any{}),3n) : Maybe<&2,T.Row>}:
  E.lookup_inside(3n,2n,raw_rows(),3n,{==},{==})

def below_start() -> {None{} == S.at(S.enumerate_rows(3n,2n,raw_rows(),T.Any{}),1n) : Maybe<&2,T.Row>}:
  E.lookup_below(3n,2n,raw_rows(),1n,{==})

def at_upper_boundary() -> {None{} == S.at(S.enumerate_rows(3n,2n,raw_rows(),T.Any{}),5n) : Maybe<&2,T.Row>}:
  E.lookup_above(3n,2n,raw_rows(),5n,{==})

def beyond_upper_boundary() -> {None{} == S.at(S.enumerate_rows(3n,2n,raw_rows(),T.Any{}),9n) : Maybe<&2,T.Row>}:
  E.lookup_above(3n,2n,raw_rows(),9n,{==})

def zero_interval() -> {None{} == S.at(S.enumerate_rows(0n,2n,raw_rows(),T.Any{}),0n) : Maybe<&2,T.Row>}:
  {==}

def all_selections(+selection: T.Selection)
  -> {S.enumerate_rows(3n,2n,raw_rows(),selection)
    == S.enumerate_rows(3n,2n,S.enumerate_rows(3n,2n,raw_rows(),T.Any{}),selection) : List<&2,T.Row>}:
  E.enumeration_stable(3n,2n,raw_rows(),selection)

def same_observation()
  -> {S.observe(T.World{7n,5n,raw_rows(),[T.Target{1n,T.Remove{}}]})
    == S.observe(T.World{7n,5n,S.enumerate_rows(5n,0n,raw_rows(),T.Any{}),[T.Target{1n,T.Remove{}}]}) : T.Observation}:
  E.observation_stable(7n,5n,raw_rows(),[T.Target{1n,T.Remove{}}])
