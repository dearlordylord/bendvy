# Native1024 tune — final numerical reconciliation

Independent read-only follow-up to native1024-window-report.md after the complete tune cohort; governing #21/#24 and SPEC. No benchmark, producer edit or acceptance decision was performed. The earlier report review remains frozen and its not-yet-measured tune classification remains correct for its earlier snapshot.

**Completed raw cohort reconciles; no global target acceptance follows.** I checked all20 authoritative outer receipts (exit0, no timeout), their exact observer argv, published receipt SHA256/schema/rotation/plan joins, five unique roles per rotation and fullWorldsPerRole65. Every executed command status is0. All21 summary receipt pins match actual bytes. Every recorded phaseMS equals its preserved rawMS entry; all ten samples per schema/role remain. I recomputed every median, and the stored medians and derived ratios agree.

| Schema | TS median ms | Default Native ms | Tune Native ms | Tune speedup over TS | Tune/default change |
|---|---:|---:|---:|---:|---:|
| Motion | 843.8047295 | 426.0 | 398.0 | 2.1201124x | -6.57277% |
| Health | 636.1532475000001 | 328.5 | 348.0 | 1.8280266x | +5.93607% |

Motion exceeds2x only as this unqualified ratio of medians. Health is1.8280266x and fails2x; therefore the required two-schema target remains unmet. Motion's6.57% lower tune median and Health's5.94% higher median support no single global scheduling improvement/adoption decision. Motion TS/default/tune clocks are all higher than the earlier LSE cohort; cross-cohort attribution is unsupported. Noise, resolution and qualification remain open.

The two JS roles execute exactly the same argv/program for each schema in every rotation. Their medians differ (Motion789/753ms, Health611/587ms); this is repeated-position/order noise evidence, not a JavaScript optimization. Every outlier is retained, including Motion TS953.745747ms, default Native627ms and tune Native541ms. This numerical review verifies status/receipt/raw-value reconciliation, not a rerun of the independent full65 semantic validator.

The source is unchanged concrete-v3; tune is a separate host-specific Clang flag diagnosis, not a source or portable product improvement. Feature-list/refined producer guard admission belongs to its separately recorded review. No full22, full5×3, workload occupancy, common timed physical forcing, canonical budget reset, qualified keep or production refinement gate is closed here.

Exact reviewed summary SHA256: `c352d3d372c430da6e71c755fb0c6f1702bb9d767f18df8e08a5e4eae442e18a`.
Exact20-row index SHA256: `d97f2d329f66084aa539f271d5082293dd35d0d2229eae83306e11ec8019d35d`.
Plan SHA256 from all joined receipts: `124ef20ca905f1c98cf588c842d24d5fa666fd3abee763e47d3d9c41193138bc`.
Raw prefix: `/tmp/bendvy-native-tune-observed-v2-r1`.
