from pathlib import Path
import tempfile,unittest,types
h=Path(__file__).resolve().parent
source=(h/'check-source.py').read_text().split("if __name__!='__main__'")[0]
m=types.ModuleType('preservation');m.__file__=str(h/'check-source.py');exec(compile(source,m.__file__,'exec'),m.__dict__)
class Preservation(unittest.TestCase):
 def test_reached_repeat_refuses_before_overwrite(self):
  with tempfile.TemporaryDirectory()as temp:
   d=Path(temp);p=d/'input';p.write_bytes(b'first');out=d/'attempt';m.prepare_attempt(out,[p]);before={str(x.relative_to(out)):x.read_bytes()for x in out.rglob('*')if x.is_file()};p.write_bytes(b'changed')
   with self.assertRaises(FileExistsError):m.prepare_attempt(out,[p])
   self.assertEqual(before,{str(x.relative_to(out)):x.read_bytes()for x in out.rglob('*')if x.is_file()})
if __name__=='__main__':unittest.main()
