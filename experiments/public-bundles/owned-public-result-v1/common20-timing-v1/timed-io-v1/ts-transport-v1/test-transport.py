import json,types,unittest
from pathlib import Path
HERE=Path(__file__).resolve().parent
m=types.ModuleType('transport');m.__file__=str(HERE/'transport.py');exec(compile((HERE/'transport.py').read_bytes(),m.__file__,'exec'),m.__dict__)
class Protocol(unittest.TestCase):
 def test_whole_and_digest(self):
  raw='first\nlast\n'.encode();meta={'elapsedNs':'123','bytes':len(raw),'digest':m.digest(raw)}
  result={'stdout':raw,'stderr':json.dumps(meta).encode()+b'\n','exit':0,'failure':None}
  self.assertTrue(m.validate_result(result,raw.decode(),False)['wholeOutputEqual'])
  for change in [{'stdout':raw[:-1]},{'stderr':result['stderr']+b'noise\n'},{'stderr':json.dumps(dict(meta,bytes=True)).encode()+b'\n'},{'stdout':b'cached\n'},{'exit':1}]:
   with self.subTest(change=change),self.assertRaises(ValueError):m.validate_result(dict(result,**change),raw.decode(),False)
 def test_reached_late_capture(self):
  full=''.join(str(i)+'\n' for i in range(10));raw=''.join(str(i)+'\n' for i in range(9)).encode();meta={'elapsedNs':'123','bytes':len(raw),'digest':m.digest(raw)}
  for tail in [b'Error: capture outside feature timer\n',b'feature timer protocol failure\n']:
   result={'stdout':raw,'stderr':json.dumps(meta).encode()+b'\n'+tail,'exit':1,'failure':None}
   self.assertTrue(m.validate_result(result,full,True)['wholePositiveRejected'])
   for change in [{'exit':0},{'stdout':full.encode()},{'stderr':json.dumps(meta).encode()+b'\n'},{'failure':'deadline'}]:
    with self.subTest(change=change),self.assertRaises(ValueError):m.validate_result(dict(result,**change),full,True)
if __name__=='__main__':unittest.main()
