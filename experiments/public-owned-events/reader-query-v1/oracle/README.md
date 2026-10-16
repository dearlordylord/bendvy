# Independently derived reader/query oracle

Source freeze `edc8fb566`, including observer `78c51e120`/`f1ff5a71d`.
SOURCE-FREEZE SHA-256:
`299e8b64089cde1c102e4f9a8341940cf50716cfe41696767efb37759645c33a`.
`bindings.json` verifies all 93 Bend sources and two CNI sidecars against frozen
committed blobs, and binds the selected contract and primary Base semantics.
Only this oracle directory is owned/committed by this independent agent.

No backend execution/output, generated backend source or other author's oracle
was consulted. Source checking is not proof. `derive.py` models the finite
scenario independently, including both schema invocations and every observed
World/resource/log/stream/journal/reader/registry/Args/Observation field.
`python3 derive.py` regenerates raw output, deterministic gzip and states.json;
`python3 selftest.py` checks separately stated state matrices and wire facts.

Four actual IO World creations allocate namespace 1/2 for Workshop and 3/4 for
Garden. Each primary World reserves three live entities, of which IDs 1 and 2
have Value; the absent Value on ID 3 skips gameplay. Population stamps are
(1,1)/(2,2), clock 2. Ordinary registration gives publisher ID 1 and query reader
ID 2, with access names [Cargo:read, Value, Counter]. The foreign Worlds stay
empty, with independent namespace, no registrations and clock zero.

Empty reading first activates position (1,1,0) and advances registry cursor to 2.
Each publication emits Cargo 900/901, Alert 1000 and nested Crates 900/902,
all carrying delta 7, in global FIFO order. The first query read enters two
matching rows for each Cargo: values 10,20,11,21 become committed 12,22; user
Array becomes [104,105], stamps (1,5)/(2,6), clock and registry cursor 6.

After the second publication, old value 23 fails on the fourth entered row.
One transaction covers both unread events, so ALL four component/resource
writes restore prior committed values, stamps and user Array. World.clock
remains 10. Actual Args.scratch becomes [9,2], and both affine Observation
entered Arrays become [2,100]. Those owners survive the abort. Stream cursor
stays 3 and registry cursor stays 6. Retry reads the same Cargo IDs 3/4 and
commits 14,24, user [108,109], stamps (1,13)/(2,14), clock/cursor 14.

The nochange call has empty unread input: no projection or row body enters;
Args/observations/World stay intact, stream cursor advances to tick 7 and
registry cursor remains 14. Foreign invocation rejects by actual namespace
without ticking either runtime or entering gameplay. Args and all accumulated
Observation owners return unchanged. The host swaps runtimes back afterward.
No frames run: batches and shared journal retain every published ID despite
capacity 2, because capacity trimming is performed by frame maintenance.

List.show uses brackets and comma-space; affine item lists use semicolon plus
literal [] terminators; Bool.show emits True/False. Snapshot has NO terminal LF,
so the following operation result is concatenated directly. The final returned
observation report ends in LF, and the one IO.print adds another LF.

Full 18-snapshot raw output: 48,711 bytes, SHA-256
`d0d879bb551c40a4d1d71c9a0e6b368aa85b91b01d9f341c2c7d4325a968c07f`.
Deterministic gzip: 1,536 bytes, SHA-256
`6c5bb5dcf884c06692b5a784ddea7b931419754ab3a556f2133a8b5ef3c5bf84`.
