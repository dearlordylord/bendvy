# Paired query ownership and short circuit

This finite consumer invokes the public `Declaration.pair` with two Array-bearing `Type` grants and an Array-bearing owner. It retains both grants and the actual returned owner until final observation. Three cases cover left refusal (right is not invoked), right refusal after left success, and both selectors succeeding. Full grant and owner cells, outcome flags, ordered modes and duplicate clauses are compared with the literal `expected.stdout`.

The trailing owner cells must remain333 and444; left increments the first cell once, and right increments the second only when reached. This complements the ordinary Dense256 full-output consumer. It is finite executable coverage, not a universal proof or performance qualification.
