# Bounded runner cleanup retained execution evidence

These are exact original raw outputs from the normal 29-test suite, final configured commit hooks, and reached unbounded-join mutant control. ARCHIVE.json records tool-observed exits retrospectively; it is not a newly executed receipt. The mutant/test sources are gzip-compressed exact bytes. Applying the stated single-line inverse restores committed runner 775a63b5ef exactly; the mutant test is byte-identical to that commit's test source.

The normal suite and final hook each pass all 29 runner controls, including real descendant, inherited-pipe, cancellation, and unrelated-sibling behavior. All final configured checks pass. The mutation restores only the unbounded post-SIGKILL join; the control reaches that call and rejects its missing timeout. This supports the explicit wait-bound change, not attribution of the earlier 40.514-second failure or a universal OS shutdown guarantee. Earlier failed preparation logs remain at their original /tmp paths and are not relabeled as passing evidence.

The standalone suite preceded assertion-only test refinements, and its exact test source was not independently captured. The archived test hash applies to the final configured hook and mutant02; the final hook supplies the 29-control qualification for committed source 775a63b5ef. Raw outputs remain unchanged.
