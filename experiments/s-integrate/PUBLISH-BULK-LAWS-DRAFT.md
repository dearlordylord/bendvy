# Publication ordering — draft for discussion

This is a proposed finite contract, not an approved universal law/proof.

Given an actual issued command batch in reverse chronological order and an
existing reverse-chronological pending queue, publication retains every affine
command owner and yields `staged ++ pending`. Publication does not apply commands,
change the allocator or modify live rows/resources/mode. Applying later reverses
the combined queue once, so existing commands execute before the newer batch.

Controls split a single actual reservation queue into newer commands and one
existing command. Full-field getter canaries return the actual Main/Aux/Ledger
owners. Application checks every issued handle, ordered lifecycle pair and all
payload cells/metadata, then actual removal/despawn checks retained owners again.
These are finite controls, with uniform payload fields; they do not prove arbitrary
batch refinement, factory authority or production performance.
