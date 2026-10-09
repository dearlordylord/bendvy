"""Frozen original0cc5ff97 main AST; no historical default execution."""
import ast,hashlib
from pathlib import Path
P=Path('/workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/complete-v1/oracle-v1/run-reference.py')
b=next(n for n in ast.parse(P.read_text()).body if isinstance(n,ast.FunctionDef) and n.name=='main')
assert isinstance(b.body[0],ast.Import) and b.body[0].names[0].name=='task_runner'
b.body=b.body[1:]
assert hashlib.sha256(ast.dump(b,include_attributes=False).encode()).hexdigest()=='961d5e7a3577d0fe8fb65174a06162a80c8c91f6b0c08fbe91b4849ee473c3eb', 'historical default semantic/source AST drift'
print('PASS historical default main exact AST except deferred import')
