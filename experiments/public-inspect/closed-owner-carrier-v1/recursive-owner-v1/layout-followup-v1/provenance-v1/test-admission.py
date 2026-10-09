import hashlib,json,tempfile,types,sys,os,py_compile,importlib.util
from pathlib import Path
HERE=Path(__file__).resolve().parent
RUNNER=HERE.parent.parent/'cpu-profile-v1/diagnostic-run.py'
m=types.ModuleType('test_admission');m.__file__=str(RUNNER);exec(compile(RUNNER.read_bytes(),str(RUNNER),'exec'),m.__dict__)
with tempfile.TemporaryDirectory() as d:
 p=Path(d)/'plan.json';p.write_text('{}')
 try:m.run(p,'0'*64)
 except ValueError as e:assert str(e)=='plan admission mismatch'
 else:raise AssertionError('wrong digest accepted')
 python=Path(sys.executable).resolve();p.write_text(json.dumps({'pins':{str(python):m.sha(python)},'pythonInterpreter':'/wrong/python'}))
 try:m.run(p,m.sha(p))
 except ValueError as e:assert str(e)=='actual interpreter differs before helpers'
 else:raise AssertionError('wrong interpreter accepted')
 helper=Path(d)/'helper.py';helper.write_text('value="stale"\n');stamp=helper.stat();py_compile.compile(str(helper));helper.write_text('value="fresh"\n');os.utime(helper,ns=(stamp.st_atime_ns,stamp.st_mtime_ns))
 spec=importlib.util.spec_from_file_location('ordinary_cached',helper);cached=importlib.util.module_from_spec(spec);spec.loader.exec_module(cached);assert cached.value=='stale'
 m.VERIFIED_SOURCES={str(helper):b'value="captured"\n'}
 assert m.load('sentinel',helper).value=='captured'
print('PASS wrong digest/interpreter before helpers and captured-source selection; no child')
