"""No-child controls reach the exact collector output gate."""
import json,types,unittest
from pathlib import Path
HERE=Path(__file__).resolve().parent

def module(path):
 m=types.ModuleType(path.stem);m.__file__=str(path);exec(compile(path.read_bytes(),str(path),'exec'),m.__dict__);return m
class Complete(unittest.TestCase):
 def test_full_models_and_corruptions(self):
  parser=module(HERE/'transport-v1/transport.py')
  for collector in ['development-js.py','development-native.py']:
   m=module(HERE/collector)
   for case,selected in json.loads((HERE/'ORACLE-SELECTION.json').read_text()).items():
    plan={'entrypoint':str(HERE.parent/(case+'.bend')),'oracle':selected['json'],'expectedSHA256':selected['expectedSHA256'],'stdoutOracle':selected['stdout'],'stdoutOracleSHA256':selected['stdoutSHA256'],'baselineJSON':selected.get('baselineJSON'),'baselineSHA256':selected.get('baselineSHA256'),'baselineStdout':selected.get('baselineStdout'),'baselineStdoutSHA256':selected.get('baselineStdoutSHA256')}
    raw=Path(selected['stdout']).read_bytes();record={}
    m.validate_output(plan,parser,raw,record)
    self.assertEqual(record['wholeOracleSHA256'],selected['expectedSHA256'])
    if case=='main-mutant':self.assertEqual(record['normalBaselineRejectedSHA256'],selected['baselineSHA256'])
    wire=module(Path(selected['directory'])/'wire.py')
    logical=parser.decode_string(raw.decode());lines=logical.splitlines(keepends=True)
    parts=lines[1].split(';');reordered=list(lines);reordered[1]=';'.join(parts[:1]+parts[2:3]+parts[1:2]+parts[3:])
    altered=logical[:-1]+('9' if logical[-1]!='9' else '8')
    controls=[raw[:-1],raw+b'EXTRA\n',raw.replace(b'\n',b'\r\n'),wire.pure_string(''.join(reordered)),wire.pure_string(''.join(lines[:-1])),wire.pure_string(''.join(lines[:2]+lines[3:])),wire.pure_string(altered),wire.pure_string(logical+'\n')]
    for number,bad in enumerate(controls):
     with self.subTest(collector=collector,case=case,control=number):
      with self.assertRaises(ValueError):m.validate_output(plan,parser,bad,{})
    if case=='main-mutant':
     with self.assertRaises(ValueError):m.validate_output(plan,parser,Path(selected['baselineStdout']).read_bytes(),{})
 def test_printed_string_root_and_escapes(self):
  parser=module(HERE/'transport-v1/transport.py')
  self.assertEqual(parser.decode_string('"a\\n\\t\\r\\0\\\\\\"\\u{1}"\n'),'a\n\t\r\0\\"\x01')
  for bad in ['plain\n','"a"','"a"\n\n','"a"suffix\n','"a\nb"\n','"\\q"\n','"\\u{a}"\n','"\\u{01}"\n']:
   with self.subTest(bad=bad),self.assertRaises(ValueError):parser.decode_string(bad)
if __name__=='__main__':unittest.main()
