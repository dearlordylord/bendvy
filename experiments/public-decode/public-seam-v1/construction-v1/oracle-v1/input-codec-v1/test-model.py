"""Source/model owner and branch controls; no runtime output or children."""
import copy
import hashlib
import json
import unittest
from pathlib import Path
import expected as E

class Model(unittest.TestCase):
    def test_source_basis(self):
        basis=json.loads(Path(__file__).with_name('source-basis.json').read_text())
        for path,digest in basis['sources'].items():
            self.assertEqual(hashlib.sha256(Path(path).read_bytes()).hexdigest(),digest)
        self.assertEqual(len(basis['sources']),53)

    def test_full_models_and_schema_independence(self):
        value=E.expected()
        self.assertEqual(value,json.loads(Path(__file__).with_name('expected.json').read_text()))
        self.assertEqual(value['first'],value['second'])
        self.assertIsNot(value['first'],value['second'])
        self.assertEqual(set(value['first']),{'$','success','parseRefusal','wrongKind','downstreamRefusal','failure','skip'})
        for schema in ('first','second'):
            for name,report in value[schema].items():
                if name=='$':continue
                self.assertEqual(set(report),{'$','before','committed','barrier','instance','result'})
                self.assertEqual(report['before']['column']['slots'][0]['value']['y'],99)
                self.assertEqual(report['barrier']['mail']['value']['y'],100)

    def test_distinct_admission_errors_and_exact_input(self):
        v=E.expected()['first']
        p=v['parseRefusal']['result']['output']
        self.assertEqual(p['error'],E.c('Construction',error=E.c('Constructor',error=E.c('ParseError',raw=E.text('7;q')))))
        k=v['wrongKind']['result']['output']
        self.assertEqual(k['error']['error']['error'],E.invalid(E.number(7),'$','string'))
        d=v['downstreamRefusal']['result']['output']
        self.assertEqual(d['error'],E.c('Operation',error=E.c('Validation',error=E.invalid(E.number(9),'$.x','literal'))))
        self.assertEqual(d['owner'],E.some(E.incoming(E.text('9,8'))))
        for name in ('parseRefusal','wrongKind','downstreamRefusal','skip'):
            self.assertEqual(v[name]['before'],v[name]['committed'])
            self.assertEqual(v[name]['before'],v[name]['barrier'])

    def test_real_deferred_storage_and_failed_packet(self):
        v=E.expected()['first'];s=v['success'];f=v['failure']
        self.assertEqual(s['committed']['pending'],2)
        self.assertEqual(s['committed']['live'],[False,True,False,False])
        self.assertEqual(s['barrier']['live'],[False,True,True,False])
        self.assertEqual(s['barrier']['column']['slots'][1],E.some(E.owner(7,8,E.text('7,8'),True)))
        self.assertEqual(s['barrier']['meta']['clock'],2)
        self.assertEqual(f['committed']['meta']['nextId'],3)
        self.assertEqual(f['barrier']['meta']['capacity'],4)
        self.assertEqual(f['barrier']['meta']['clock'],1)
        self.assertEqual(f['barrier']['column'],f['before']['column'])
        packet=f['instance']['recoveries'][0]['packets'][0]
        self.assertEqual(packet['original'],E.saved(7,8))
        self.assertEqual(packet['owner']['value']['original'],E.text('7,8'))
        self.assertEqual(packet['owner']['value']['words'],[71,72])
        self.assertEqual(packet['owner']['value']['flags'],[True,False])
        altered=copy.deepcopy(E.expected());altered['second']['failure']['instance']['recoveries'][0]['packets']=[]
        self.assertNotEqual(altered,E.expected())

if __name__=='__main__':unittest.main()
