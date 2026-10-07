# Evidence retention

Keep all raw evidence directories locally until integrator review. Git selection retains verified `evidence/*.tar.gz` archives, `archive-index.json`, aggregate index and compact receipts; raw staged/generated directories are ignored. No history or failure is deleted.

For each terminal evidence directory, archive every file with its path relative to `evidence/`, record decoded SHA256 hashes and archive SHA256, reopen the archive, assert exact member membership and verify every decoded hash. Include the receipt status in the index. Skip any live/incomplete directory. Execution inputs and receipts remain unchanged; compression is packaging only.

The aggregate index must identify all six fresh receipts and compare their exact input pin dictionaries with the admitted prospective common freeze. Individual historical receipts retain their original source versions and cannot replace missing current gates. An independently rooted Factory collision remains a failed authority discovery even when its expected counterexample is detected by the foreign diagnostic runner.
