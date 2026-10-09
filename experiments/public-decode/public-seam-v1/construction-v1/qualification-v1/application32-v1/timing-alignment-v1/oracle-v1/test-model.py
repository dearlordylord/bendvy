"""No-child checks of independently derived full lifecycle expectations."""
import copy
import unittest
from pathlib import Path

scope={'__name__':'model','__file__':str(Path(__file__).with_name('expected.py'))}
exec(compile(Path(scope['__file__']).read_bytes(),scope['__file__'],'exec'),scope)

class Model(unittest.TestCase):
    def setUp(self): self.models=scope['expected']()
    def test_full_order_and_independently_equal_public_views(self):
        self.assertEqual([len(v) for v in self.models.values()],[32,32,32])
        for common,native,ts in zip(*self.models.values()):
            self.assertEqual(common['value'],native['value']['public'])
            self.assertEqual(common['value'],ts['value']['public'])
        self.assertEqual([(r['$'],r['operation']) for r in self.models['common'][::8]],
                         [('Workshop','insert'),('Workshop','spawn'),('Workshop','resource'),('Garden','insert')])
    def test_actual_physical_queue_difference_preserved(self):
        native=self.models['native'][8]['value']['native']
        ts=self.models['ts'][8]['value']['ts']
        self.assertEqual(native['committed']['pending'],3)
        self.assertEqual(len(ts['after']['pendingCommands']),2)
        self.assertEqual(native['committed']['store']['receipts'][1]['payload']['owner']['words'],[111,222])
        self.assertEqual(native['barrier']['pending'],0)
        self.assertEqual(ts['flushed']['pendingCommands'],[])
    def test_world_indices_registration_and_stamps(self):
        item=self.models['native'][8]['value']
        self.assertEqual([e['id'] for e in item['public']['before']['entities']],[1])
        self.assertEqual([e['id'] for e in item['public']['barrier']['entities']],[1,2])
        self.assertEqual([r['id'] for r in item['native']['before']['meta']['registrations']],[3,2,1])
        self.assertEqual(item['native']['instance']['id'],3)
        self.assertEqual(item['native']['barrier']['meta']['clock'],3)
        self.assertEqual(item['native']['barrier']['store']['values']['stamps'][0]['id'],2)
    def test_failure_owners_and_last_fields(self):
        for index in (3,7,11,15,19,23,27,31):
            report=self.models['native'][index]['value']['native']
            self.assertEqual(report['before'],report['committed'])
            refused=self.models['common'][index]['value']['checked']
            self.assertEqual(refused['$'],'Refused')
            self.assertEqual(refused['input']['value']['words'],[111,222])
            self.assertEqual(refused['input']['value']['flags'],[True,False])
        final=self.models['native'][-1]['value']['native']
        self.assertEqual(final['barrier']['store']['receipts'],[])
        self.assertEqual(final['instance']['recoveries'],[])
        self.assertEqual(final['instance']['pending'],[])
    def test_source_model_delta_is_limited(self):
        for row in self.models['native']:
            old=scope['namespace']['report'](row['name'],row['operation'])
            new=copy.deepcopy(row['value']['native'])
            for phase in ('before','committed','barrier'):
                new[phase]['meta']['registrations']=old[phase]['meta']['registrations']
                new[phase]['meta']['nextSystemId']=old[phase]['meta']['nextSystemId']
                del new[phase]['store']['receipts']
            new['instance']['id']=1
            self.assertEqual(new,old)

if __name__=='__main__': unittest.main()
