# Canonical Native artifact-only admission

Admit exactly the two plans in author commit `8d3c9ccd`, once:

- generic15: `6be3578feb06579850b4bf83d1a8bb5ef8ba5961fc889b9100caf75f628c3c25`;
- deferred8: `0d8d716cd97c32aa36eca6b4a01fb5ce46f66842edf1c25ad76956d338581b38`.

Coordinator independently checked both plan/binding hashes, all current 159/144 input entries including complete recursive resource membership and bytes, successful canonical C artifact/receipt/plan hashes, exact commands and absent binary outputs under the shared heavy lock. Both C receipts record DEVELOPMENT_C_EMIT_PASS. Source and whole independent models remain the admitted canonical cohort; no source transformation or re-emission occurs.

The Native-from-C collector is unchanged since reviewed `bc85305e`; bootstrap, output guards, unconditional receipts and full nominal transport are retained. Commands use approved Clang19, O3/pthread/lm, CPU5, build120/run5, one thread and GPU off. This admits artifact-only build/runtime stages under the existing workflow recipe; it establishes no runtime result, delivery/performance acceptance or full #46 completion.
