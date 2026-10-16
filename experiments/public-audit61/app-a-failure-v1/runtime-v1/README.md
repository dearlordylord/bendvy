# AppA later resource failure — complete actual pair

Source e2a0017a3 and plans e2c7ce6a7 execute the existing public application
with a successful scalar transaction followed by a failing Counter transaction.
Stock JS and Native both match all 5,281 bytes of independently derived oracle
58c352eda, SHA `2ef926dd7fc931df61c36f3135562f88345d79a60174416a8032af1022ba9a82`.
Five commands exited zero, runtime stderr is empty, and all seventeen guards
are unchanged. Native uses the original -O3 build120; emit30/runtime5 and the
existing collector/internal lock are unchanged. No backend retry was needed.

The report retains Scalar15 with added2/changed3, Array[7,9], restored
Counter[10,11], untouched Sibling[100,101], World clock3, component cursor3 and
resource cursor0, complete original World/owner/receipt views and repeated
selected observations. Schedule observations are Entered, Ran1, Applied, Ran2;
the second barrier does not execute. Actual ResourceFailed is retained rather
than discarded. This demonstrates earlier committed work surviving the later
failure and rollback of the approved field replacement, not an arbitrary-Type
inverse or new capture/disposal contract.

`actual-attempt01/manifest.json` uses the existing AppA path/hash/gzip-object
format: 469 bindings, 433 distinct retained objects and 22 explicit installed
ELF identities. It retains complete raw outputs, plans, argv/caps, source/tool
configuration/resources, progressive guards and generated JS/C/native artifacts,
the independent oracle and its original model dependency. All compressed/raw
hashes and lengths were checked; the model reproduced byte-exact in an isolated
sibling directory layout. The original-model hash is bound by the pinned
SOURCE-BASIS and is retained at both source and imported paths; it is not claimed
as a directly executed backend input. The backend compares frozen full oracle
bytes. Historical AppA/AppB normal, authority and reached controls remain
unchanged and keep their original scope.

This is a bounded #61 failure-path delivery, not full parity or whole-core audit
acceptance. It changes no shared ECS source; existing protected regression
qualification is coordinator-owned, and no fresh timing/speed claim is made.
Generic inverse execution, unresolved captures/owned events/restore and the
remaining #61 capability/independent-composition gates remain outside this pair.
Independent final review and root integration/CI/report are separate.
