# Actual loader-path metadata v5

This archives the original executed plan `5e4ac887...` and all 52 output files, plus exact executed source/configuration: 70 lossless members. All ten metadata commands completed, 20 raw streams and 31 progressive guards verify. No tool binaries are duplicated. The historical `task_runner.py` bytes come from verified v4 archive member 065; subsequent root helper edits are not rebound to this execution.

`python3 verify.py` checks full archive membership, digests, exact command/result/raw joins and every guard. `python3 derive-loader.py` reproduces `LOADER-TARGETS.json` from these verified bytes without children.

Actual loader lists identify 25 unique loaded paths for the eight declared tool subjects. `ldconfig -p` records 425 advertised cache entries. Diagnostics establish glibc 2.36, `aarch64`, important HWCAP `0x100` present, no built-in glibc-hwcaps directories, and the four default directories matching v4. The source-backed eight legacy suffix combinations yield 56 candidate shallow directories; actual diagnostics do not independently prove their traversal order.

This remains **NOT_RESOLVER_ADMISSION**. The next bounded metadata stage must inspect ELF metadata of the 25 actual targets to learn transitive RPATH/RUNPATH/NEEDED; it must bind current execution helpers separately from the immutable historical plan. Cache targets, final search-directory membership/bytes/absence and alias chains are not yet closed. Compiler headers/GCC/linker scripts and a generated executable's runtime namespace remain separate stages. No recursive `/lib` scan, compiler or runtime workload was run here.
