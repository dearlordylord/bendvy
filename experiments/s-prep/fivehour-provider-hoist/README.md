# Closed provider hoisting: rejected Data-record proposal

The old generated Dense row loop creates curried `run_clo` provider wrappers at each row. This source observation is not allocation/timing attribution or an established bottleneck.

A proposed reusable `Providers is Data` record containing function fields is invalid: Bend function arrows inhabit Type, not Data. The intended checker rejection is `expected : Data / observed : Type` at Providers. This does not justify making component owners Data or duplicating affine functions/owners.

Closed frozen operation templates are a separate possible compiler specialization; they do not themselves prove that passing functions to the unchanged rank2 callback avoids wrapper creation. Actual generated-source and semantic checks are required before claiming that path works. No application callback, compiler, dependency, law or timing protocol is changed here.
