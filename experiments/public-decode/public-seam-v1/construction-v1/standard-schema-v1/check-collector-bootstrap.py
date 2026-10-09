"""No-child controls: actual host branch must refuse before helper execution."""
import hashlib
import json
from pathlib import Path
import sys
import tempfile
import types

RUNNER=Path('/workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam/experiments/public-decode/complete-v1/oracle-v1/run-reference.py')
module=types.ModuleType('subject');module.__file__=str(RUNNER)
exec(compile(RUNNER.read_bytes(),str(RUNNER),'exec'),module.__dict__)
old_argv=sys.argv
try:
    with tempfile.TemporaryDirectory() as folder:
        root=Path(folder);(root/'scripts').mkdir();helper=root/'scripts/task_runner.py'
        sentinel=root/'helper-executed'
        helper.write_text('from pathlib import Path\nPath('+repr(str(sentinel))+').write_text("UNAUTHORIZED")\nraise RuntimeError("helper executed")\n')
        module.ROOT=root
        for name in ('wrong-python','pin-drift'):
            out=root/name;out.mkdir();plan={'python':str(Path(sys.executable).resolve()) if name=='pin-drift' else '/wrong/python',
                'inputs':{str(helper):'0'*64},'referenceDirectory':str(root/'reference'),'referenceMembership':{}}
            file=out/'plan.json';file.write_text(json.dumps(plan));digest=hashlib.sha256(file.read_bytes()).hexdigest()
            sys.argv=[str(RUNNER),'--standard-schema-host','--execute','--output',str(out),'--plan-sha256',digest]
            try:module.host_main()
            except AssertionError as error:
                assert ('Python mismatch' if name=='wrong-python' else 'input drift') in str(error)
            else:raise AssertionError('guard accepted invalid input')
            assert not sentinel.exists(),'helper executed before admission guard'
            assert not (out/'receipt.json').exists(),'business child boundary reached'
finally:sys.argv=old_argv
print('PASS actual host bootstrap wrong-Python/pin-drift refuses before helper')
