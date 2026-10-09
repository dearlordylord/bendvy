"""Reuse exact existing source-derived Data term transport for complete Report."""
from pathlib import Path
import json,sys,types,hashlib,stat
sys.dont_write_bytecode=True
def source_load(path,name):
 path=Path(path)
 if path.is_symlink() or not path.is_file():raise ValueError('regular source required')
 with path.open('rb') as stream:
  if not stat.S_ISREG(__import__('os').fstat(stream.fileno()).st_mode):raise ValueError('regular source descriptor required')
  raw=stream.read()
 pins=globals().get('PINNED_FILES')
 if pins is not None and hashlib.sha256(raw).hexdigest()!=pins[str(path)]:raise ValueError('transitive source drift')
 m=types.ModuleType(name);m.__file__=str(path);m.__dict__.update({'PINNED_FILES':pins,'SOURCE_LOADER':source_load})
 exec(compile(raw,str(path),'exec'),m.__dict__);return m
m=source_load(Path(__file__).resolve().parent/'transport-source.py','existing_transport')
def check(entry,raw,expected):
 t=m.Transport(entry);observed=t.convert(m.TERM.parse_term(Path(raw).read_text()),t.resolve('Report',t.entry,{}));m.TERM.strict_equal(observed,json.loads(Path(expected).read_text()));return t.inventory()
if __name__=='__main__':
 check(*sys.argv[1:]);print('WHOLE_REPORT_PASS')
