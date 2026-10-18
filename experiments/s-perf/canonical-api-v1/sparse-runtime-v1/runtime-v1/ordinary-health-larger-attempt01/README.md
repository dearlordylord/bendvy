# Sparse ordinary Health larger consumers

All four consumer-only cases pass complete independent wire oracles. Runtime stderr is empty.

| Size | Backends | Bytes per output | SHA-256 |
| --- | --- | ---: | --- |
| 256 | JS, Native | 1701031 | `e83229491f2225f5756eaa3070cec55c7038d8e0b9d12a1f5a858fac8d11a46a` |
| 1024 | JS, Native | 6832144 | `41b7af0a005d73d4a30e8c9f6912e83db1cc497f595f6fb6102d77612a99d80a` |

These cases reuse exactly the first qualified Health64 artifacts, sources and tools. Health source `ec15951bb` is integrated on main `d5fdcbb2c`; no implementation changes occur here. Original callback, transaction finish, payloads, full row outputs, three fresh postcommit Main/optional Aux/Flag queries, optional postfilters, weights1/3/5, cumulative audit, world creation and String observation construction remain unchanged. Frozen consumer caps are 180 seconds for both backends.

`RETENTION.json` retains complete source/plan/receipt/guard/artifact/output/oracle joins, including producer evidence. One author portable verification passes 1007 members, 681 objects, 16 guards and four current PASS cases. Run `python3 verify.py PATH_TO_THIS_PACKET` without the original temporary files.

Together with the preceding first-pair and six-case packets, this completes ordinary Sparse correctness for Motion and Health at 64/256/1024 on JS and Native. Independent final review/integration and combined #28 applicability remain coordinator gates. No comparative timing or full #21 acceptance claim.
