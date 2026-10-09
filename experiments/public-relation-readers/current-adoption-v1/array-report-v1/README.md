# Physical Array report candidate

Each `held` computes one complete schema report into `ALeaf`, returning an actual Array. Main holds one array while the second helper computes its array. `completed` takes two arrays and directly pattern-extracts their leaves before constructing unchanged Output, with no Array.get or application calls during final extraction.

Pinned compiler comp.ts:943 gives Array one-box layout, arr_op:1741 returns physical allocation and arr_leaf:1763 emits inline cell read/free. Unlike the prior known recursive carrier, this uses actual array storage. Direct final extraction has no intervening225-word return continuation; its two input arrays occupy two words. Source evidence supports a new diagnostic hypothesis, not a guarantee about optimizer output.

Only internally constructed single leaves reach this path. Exhaustive node branches recursively select the left Data report array; these are private transport, not a public malformed-container or ECS ownership policy. All eight applications and complete original DTO remain unchanged. Source5 and full12ac typed source roundtrip pass. No Native/backend replay: new copied-reference diagnostic is unexecuted and awaits independent admission.
