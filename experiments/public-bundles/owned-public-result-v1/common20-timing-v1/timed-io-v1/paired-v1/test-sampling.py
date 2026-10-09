"""Portable no-child grouped lifecycle schedule/summary controls."""
import json,runpy,unittest
from pathlib import Path
S=runpy.run_path(str(Path(__file__).with_name('sampling-io.py')))
CONTRACT={'pairs':20,'warmups':2,'seed':20261007}
class Sampling(unittest.TestCase):
    def test_full_balanced_schedule(self):
        rows=S['schedule'](CONTRACT);self.assertEqual(len(rows),602);self.assertEqual(rows,S['schedule'](CONTRACT));self.assertEqual(len({r['label']for r in rows}),602)
        for scale in [1,2,4]:
            for backend in ['JS','Native']:
                selected=[r for r in rows if r['lifecycles']==scale and r['backend']==backend]
                pairs={r['pair']:r['order']for r in selected};self.assertEqual(len(pairs),20);self.assertEqual(sum(order[0]=='TS'for order in pairs.values()),10)
                self.assertEqual(len(selected),40*scale)
    def test_staged_scale1_retains_all_pairs(self):
        rows=S['schedule'](CONTRACT,[1]);self.assertEqual(len(rows),86);self.assertEqual({r['lifecycles']for r in rows},{1})
        commands=[{'label':r['label'],'stderr':{'rawHex':json.dumps({'elapsedNs':'10'}).encode().hex()}}for r in rows]
        self.assertEqual(len(S['summarize'](rows,commands)['summary']),2)
    def test_complete_sums_and_missing_lifecycle_refusal(self):
        rows=S['schedule'](CONTRACT)
        commands=[{'label':r['label'],'stderr':{'rawHex':json.dumps({'elapsedNs':'10'if r['role']=='TS'else'20'}).encode().hex()}}for r in rows]
        value=S['summarize'](rows,commands);self.assertEqual(len(value['summary']),6)
        for entry in value['summary']:self.assertEqual(entry['medianPairedRatio'],2);self.assertEqual(len(entry['allPairs']),20)
        with self.assertRaises(ValueError):S['summarize'](rows,commands[:-1])
if __name__=='__main__':unittest.main()
