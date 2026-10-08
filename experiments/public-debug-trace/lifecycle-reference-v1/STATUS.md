# Trace subscription reference development

Owning ticket: #57. This is an independently authored pinned TS development
consumer, not Bend, backend, full trace, performance or parity qualification.

The complete oracle is authored before execution. Each of six empty-schedule
frames retains both complete observer journals and the complete world dump.
Only finite nonnegative elapsed `ms` fields are normalized to zero.

Pinned `Debug.Handle` has observe/unsubscribe and no reset method. The fixture
distinguishes resetting an external collector from resetting runtime state.
Registering the same callback twice uses one Set member; either returned stop
removes that callback. These are source-derived hypotheses until this fixture
executes; subscription mutation during emission and listener exceptions are
separate unqualified boundaries, not new Bend contracts.

Success/skip/failure/barrier/relation/transition/restore traces, typed observer
ownership, ECS noninterference and disabled publication work remain under #57
and its #56/#50 prerequisites. This fixture never substitutes for those gates.
