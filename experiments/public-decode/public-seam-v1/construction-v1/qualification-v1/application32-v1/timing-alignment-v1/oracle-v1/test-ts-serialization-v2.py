"""Full source-model delta/presence controls; no subject output consulted."""
import copy
import json
import unittest
from pathlib import Path

HERE=Path(__file__).resolve().parent
scope={'__name__':'correction_model','__file__':str(HERE/'ts-serialization-v2.py')}
exec(compile((HERE/'ts-serialization-v2.py').read_bytes(),str(HERE/'ts-serialization-v2.py'),'exec'),scope)

class Serialization(unittest.TestCase):
    def test_only_two_target_key_omissions(self):
        old=scope['model']['expected']()['ts'];new=scope['expected']()
        restored=copy.deepcopy(new)
        for index in (11,15):
            self.assertNotIn('target',new[index]['value']['ts'])
            restored[index]['value']['ts']['target']={'undefined':True}
        self.assertEqual(restored,old)
        self.assertEqual(len(new),32)
    def test_full_public_and_nested_markers_preserved(self):
        models=scope['model']['expected']();new=scope['expected']()
        for old,row,common in zip(models['ts'],new,models['common']):
            self.assertEqual(row['value']['public'],old['value']['public'])
            self.assertEqual(row['value']['public'],common['value'])
        self.assertEqual(new[15]['value']['ts']['checked']['error']['actual'],{'undefined':True})
        self.assertEqual(new[8]['value']['ts']['target'],2)
        self.assertIsNone(new[16]['value']['ts']['target'])
        self.assertEqual(new[0]['value']['ts']['target'],1)
    def test_wire_byte_delta_is_source_derived(self):
        old=scope['model']['expected']()['ts'];new=scope['expected']()
        wire=lambda value:(json.dumps(value,separators=(',',':'),ensure_ascii=False)+'\n').encode()
        self.assertEqual(len(wire(old))-len(wire(new)),2*len(',"target":{"undefined":true}'))
        self.assertEqual(json.loads(wire(new)),new)

if __name__=='__main__':unittest.main()
