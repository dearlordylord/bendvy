Independent source-only complete quarantine recovery oracle.

Bound to producer 5f467e8ad and all 40 current IO imports. No producer or runtime stdout was read. The ten checkpoints preserve complete registry, physical World, pending work, context, raw owners, lifecycle stamps and the nested retained recovery receipt. Repeated inactive resume preserves that receipt and adds a second MissingEntity; reactivation executes the retained tail/head/raw inverse chain before final cleanup. IO printing is raw UTF-8 plus LF.

This models the finite plain-column case and explicit caller reactivation, without adopting a retry/disposal policy or proving general nonplain recovery.
