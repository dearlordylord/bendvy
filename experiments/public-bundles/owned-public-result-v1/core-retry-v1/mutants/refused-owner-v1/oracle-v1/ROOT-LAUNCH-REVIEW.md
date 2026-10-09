# Exact mutant launch admission

PASS: JS plan `919a45f0a8964954c3e2803af0f027f7b9ed2c88dcdb8c9856547a504c625839`; Native plan `d4763de48d70b6ce56c6b82203397175b19a205847c3c03603a5058f7d33fe61`. Root independently verified all47/50 current pins and complete Native resource inventories/membership under the heavy lock; outputs absent, fixed CPU5 and30/5 or30/120/5 caps unchanged. Full counteroracle/baseline byte hashes match and are unequal.

Compared both collectors to the independently reviewed positive recipe: changes are path relocation, frozen oracle/baseline bindings and mandatory whole positive-baseline rejection after exact counteroracle equality. Original partial-publication/failure/guard handling remains. Source/oracle review is separate in ROOT-SOURCE-REVIEW.md. Admit one JS sequence, then conditional Native sequence if successful, under the shared lock. No source substitution, new policy, closed resolver or performance claim.
