# Independent marker phase oracle

Complete source-derived String output for three checkpoints: initial, marker1 and marker2. No runtime output was available or consulted. All captured A-source01 pins are verified against current files. Root independently sanity-checks this packet before execution.

Initial World clock17 and one pending clock callback are retained. The marker's existing structural flush runs that callback once, producing clock18. Capture takes and resets both machines' initial pending cohort before applying either. Marker1 therefore applies Flow Boot10→Play20 and Level Boot90→Pause30 before any exit/transition/enter hook. Each phase uses real typed capabilities and tracked registry callbacks. Their six emitted read observations see both applied values. Exit queues LevelBoot40, transition queues FlowPause50, and enter replaces Level pending with Play60. Those pending values remain for the next marker.

Marker2 captures/applies Pause50 and Play60. No pending structural callback remains, so clock stays18. All successful tracked registry calls end with cursor18. The captured cohorts, slot previous/changed/pending fields, entire raw event history, registration metadata, status and all three nested component/resource/owner Arrays remain in the complete output. The formatter uses actual L/N tree syntax and List.show comma-space separators. Entry returns String, so installed compiler JSON quoting retains each checkpoint newline inside the result.

This finite witness models sequencing and the existing callback behavior. It introduces no preparation, commit, failure, initialization, disposal or marker policy. It does not claim general #48 closure, new laws, performance or runtime evidence before actual execution.
