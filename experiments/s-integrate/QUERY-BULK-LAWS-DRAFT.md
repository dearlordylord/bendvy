# Query traversal obligations — draft

Before changing traversal, run the existing actual provider controls and the
new count-driven canary against the original source. This is a finite executable
contract, not approval of a universal proof.

For sorted unique issued rows with the configured width-four nominal payloads:
queries return ascending handles and complete declared observations, preserve
every actual Main/Aux owner, and leave allocator/pending/Ledger/mode/marks intact.
Required/Present/Absent/Optional retain their existing selection semantics.
An owner returned by one query must survive a second query and full world read.
Lookup must preserve the same owners and return its original Missing/Mismatch
classification. Traversal may use reversed affine accumulators internally but
must restore both owners and Data results in original order at the boundary.

The public 65,537-entity retention input must run on both compiled backends under
the existing five-second runtime cap. A JS stack failure is a failure, not a pass
or a reason to raise that cap. Compiling order/owner/observation mutants must be
detected. This does not accept a production storage layout or performance ratio.
