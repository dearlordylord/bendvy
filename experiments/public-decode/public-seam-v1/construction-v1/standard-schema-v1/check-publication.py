"""Actual additive host route, mocked execution only; no subprocess children."""
import hashlib,json,sys,tempfile,types
from pathlib import Path
W=Path('/workspace/formal-proofs/bendvy-worktrees/parity-46-public-seam')
P=W/'experiments/public-decode/complete-v1/oracle-v1/run-reference.py'
m=types.ModuleType('host');m.__file__=str(P);exec(compile(P.read_bytes(),str(P),'exec'),m.__dict__)
for a,b in [(True,1),(False,0),({'ok':True},{'ok':1})]:
    try:m.strict_equal(a,b)
    except AssertionError:pass
    else:raise AssertionError('Bool/integer confusion')
old=sys.argv
try:
 with tempfile.TemporaryDirectory() as folder:
    root=Path(folder);(root/'scripts').mkdir();m.ROOT=root
    base=(Path('/workspace/formal-proofs/bendvy/scripts/task_runner.py')).read_text()
    logs=(Path('/workspace/formal-proofs/bendvy/scripts/receipt-logs.py')).read_text()
    for name in ('success','existing-raw','symlink-raw','existing-receipt','symlink-receipt','publication-failure'):
        out=root/name;out.mkdir();marker=out/'mock-executed';helper=root/'scripts/task_runner.py';lp=root/'scripts/receipt-logs.py'
        helper.write_text(base+'\ndef execute_result(*args,**kwargs):\n    from pathlib import Path\n    Path('+repr(str(marker))+').write_text("mock only")\n    return '+repr({'stdout':b'{"ok":true}\n','stderr':b'', 'exit':0,'failure':None})+'\n')
        extra=''
        if name=='publication-failure':
            extra='\ndef fail_record(self,label,stdout,stderr):\n    import hashlib\n    path=self.directory/(label+".stdout")\n    with path.open("xb") as stream:stream.write(stdout)\n    self.hashes[path.name]=hashlib.sha256(stdout).hexdigest()\n    raise OSError("forced partial publication")\nCommandLogs.record=fail_record\n'
        lp.write_text(logs+extra)
        if name=='existing-receipt':(out/'receipt.json').write_bytes(b'original receipt')
        if name=='symlink-receipt':(out/'receipt.json').symlink_to(root/'missing-receipt')
        if name=='existing-raw':(out/'raw').mkdir();(out/'raw/host.stdout').write_bytes(b'original')
        if name=='symlink-raw':(out/'raw').symlink_to(root/'missing-target')
        expected=out/'expected.json';expected.write_text('{"ok":true}')
        plan={'python':str(Path(sys.executable).resolve()),'inputs':{str(f):hashlib.sha256(f.read_bytes()).hexdigest() for f in (helper,lp,expected)},'referenceDirectory':str(root/'reference'),'referenceMembership':{},'scope':'mock control','argv':['notexecuted'],'environment':{},'cwd':str(root),'expected':str(expected)}
        pf=out/'plan.json';pf.write_text(json.dumps(plan));digest=hashlib.sha256(pf.read_bytes()).hexdigest();sys.argv=[str(P),'--standard-schema-host','--execute','--output',str(out),'--plan-sha256',digest]
        try:m.host_main()
        except (OSError,AssertionError):assert name!='success'
        else:assert name=='success'
        if name in ('existing-receipt','symlink-receipt'):
            assert not marker.exists()
            if name=='existing-receipt':assert (out/'receipt.json').read_bytes()==b'original receipt'
            else:assert (out/'receipt.json').is_symlink()
            continue
        receipt=json.loads((out/'receipt.json').read_bytes())
        if name in ('existing-raw','symlink-raw'):
            assert not marker.exists() and receipt['status']=='INCOMPLETE'
            if name=='existing-raw':assert (out/'raw/host.stdout').read_bytes()==b'original'
            else:assert (out/'raw').is_symlink()
        elif name=='publication-failure':
            assert receipt['result']['exit']==0 and receipt['result']['failure'] is None
            assert bytes.fromhex(receipt['failedCaptureRaw']['stdout'])==b'{"ok":true}\n'
            assert receipt['logs']=={'host.stdout':hashlib.sha256(b'{"ok":true}\n').hexdigest()}
            assert 'forced partial publication' in receipt['captureError']
        else:assert receipt['status']=='DEVELOPMENT_HOST_PASS'
finally:sys.argv=old
print('PASS strict types, fresh/existing/symlink raw and actual Runner partial publication')
