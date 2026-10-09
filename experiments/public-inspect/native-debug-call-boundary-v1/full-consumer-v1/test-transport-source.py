"""Portable adapted transitive parser execution: cache poison never read."""
from pathlib import Path
import tempfile,hashlib,json,types,re,os,py_compile
HERE=Path(__file__).resolve().parent
with tempfile.TemporaryDirectory(prefix='bendvy56-full-source-') as td:
 root=Path(td);rows=[];pins={}
 for i,source in enumerate(['VALUE=2\n'+'#'*200,"import importlib.util\nfrom pathlib import Path\ns=importlib.util.spec_from_file_location('child',Path(__file__).parent/'origin0.py')\nm=importlib.util.module_from_spec(s);s.loader.exec_module(m)\nVALUE=m.VALUE\n"+'#'*200]):
  original=root/f'origin{i}.py';bad="raise RuntimeError('STALE_SOURCE_CACHE')\n";original.write_text(bad+'#'*(len(source)-len(bad)));os.utime(original,(1700000000,1700000000));py_compile.compile(str(original),doraise=True);original.write_text(source);os.utime(original,(1700000000,1700000000))
  adapted,n=re.subn(r'\b(\w+)\.loader\.exec_module\((\w+)\)',r'SOURCE_LOADER(\1.origin,\2)',source);name=f'adapted{i}.py';(root/name).write_text(adapted);rows.append(dict(original=str(original),adapted=name,replacements=n))
  for p in [original,root/name]:pins[str(p)]=hashlib.sha256(p.read_bytes()).hexdigest()
 (root/'PARSER-ADAPTERS.json').write_text(json.dumps(rows));transport=types.ModuleType('transport');transport.__file__=str(HERE/'transport.py');exec(compile((HERE/'transport.py').read_bytes(),transport.__file__,'exec'),transport.__dict__);transport.HERE=root
 assert transport.parser(pins).VALUE==2
 (root/'adapted0.py').write_text('VALUE=3\n')
 try:transport.parser(pins)
 except ValueError:pass
 else:raise AssertionError('transitive source drift accepted')
print('TRANSITIVE_COMPILED_PARSER_CACHE_AND_DRIFT_PASS; no compiler/backend child')
