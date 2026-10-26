# Composed application observation model

The oracle models the declared four-system graph, independently of generated
JavaScript or C and without reading implementation output. It was frozen before
the first full consumer output capture. The earlier smoke output covered only
missing-service events and local counters.

Each fresh scenario creates namespace 1, live entity keys 1:0 and 2:0, four body
owners and two guards. Nested edges are 1>2, 3>4, 1>3 and 3>2; stable serial order
is 1,3,2,4. A required-service guard error continues unrelated work and suppresses
its affected body. Missing service therefore advances only body1, guard5, body2
and guard6, ending at tick4. Position/count become12/2; label bodies remain0.

Provisioning moves HOST-901 from the actual provision receipt into the declared
resource. It does not execute a system or advance the execution clock. A second
provision retains HOST-902 in the refusal receipt. The next run ends at tick10,
position/count14/4, label token suffix!! and host calls2. The repeated run ends at
tick16, position/count16/6, suffix!!!! and calls4. Both labels bodies report an
error after their second host call; actual writes and returned owners remain.

Each final observation includes all column positions and lifecycle metadata,
actual payloads and cached Data views, allocator slots and order, registrations,
execution clock, system and guard locals/cursors, handler history, actual
provisions and refused host owners, derived schema entries, plan and bindings.
The invalid local edge1>3 at scope[0] refuses before execution, retaining the
complete initial application. The ordinary wrapper still retains the globally
well-formed plan; the local nesting error is an explicit composition refusal.

The model is finite. It does not establish universal owner preservation,
concurrency, host rollback, finalization or validation of arbitrary trusted seeds.

The eight-case successor adds an ordinary optional-resource read to each guard.
It changes the guard access metadata to [host,optional], with no additional tick
or owner mutation. A fresh optional-none scenario has the missing-case transition
with actual optional resource/cache `none`; the absent optional owner is not a
missing required service. Constructed validation accepts seed and rejects bad at
path$ with expectedliteral, returning VALID-906 and REJECT-907 actual owners.
Schema collision refuses duplicate component keyduplicate with factory1;
namespace exhaustion retains factory4294967295. Both preserve the exact incoming
resource owners and deliberately STALE caches, including REFUSAL-HOST-904 calls9.
These expected lines were derived before capturing the eight-case output.
