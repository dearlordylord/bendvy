"""No-child diagnostic shape/type controls, not actual profile evidence."""
import runpy,unittest
from pathlib import Path
V=runpy.run_path(str(Path(__file__).with_name('validate-profile.py')))
class Profile(unittest.TestCase):
    def test_cpu_and_allocation_shapes(self):
        V['validate_shape']('CPU',{'nodes':[{'id':1}],'samples':[1],'timeDeltas':[2]})
        V['validate_shape']('allocation',{'head':{},'samples':[]})
        for role,value in [('CPU',{}),('CPU',{'nodes':[]}),('CPU',{'nodes':[1],'samples':[1],'timeDeltas':[]}),('allocation',{'head':[],'samples':[]}),('allocation',{'head':{},'samples':True}),('unknown',{})]:
            with self.assertRaises(ValueError):V['validate_shape'](role,value)
if __name__=='__main__':unittest.main()
