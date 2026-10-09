"""No-child resolver declaration controls; no host discovery."""
import importlib.util
from pathlib import Path
import unittest
spec=importlib.util.spec_from_file_location('resolver_plan',Path(__file__).with_name('resolver-plan.py'))
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
class Declaration(unittest.TestCase):
    def base(self):return {'status':'UNADMITTED_CANDIDATE_NOT_CLOSED','fullByteInventoryExecuted':False,'loaderSearchDirectories':['/lib','/lib/tls/missing'],'resolverInputs':['/etc/ld.so.preload'],'remaining':['candidate']}
    def build(self,c):return m.declaration(c,{'bend':'/preserved/bend'},['/link/input'],{'PATH':'/usr/bin'},['/base'])
    def test_absence_preserved_without_scan(self):
        d=self.build(self.base());self.assertIn('/lib/tls/missing',d['loader_search_directories']);self.assertIn('/etc/ld.so.preload',d['resolver_inputs']);self.assertFalse(d['qualifiesClosedResolver']);self.assertIn('/preserved/bend',d['resolver_inputs']);self.assertIn('/link/input',d['resolver_inputs'])
    def test_broad_recursive_root_refused(self):
        c=self.base();c['resolverInputs'].append('/lib')
        with self.assertRaises(ValueError):self.build(c)
    def test_fake_closed_status_refused(self):
        c=self.base();c['status']='CLOSED'
        with self.assertRaises(ValueError):self.build(c)
    def test_duplicates_refused(self):
        c=self.base();c['loaderSearchDirectories'].append('/lib')
        with self.assertRaises(ValueError):self.build(c)
class Includes(unittest.TestCase):
    def test_recursive_config_includes_and_absent_glob(self):
        import tempfile
        spec=importlib.util.spec_from_file_location('metadata',Path(__file__).with_name('prepare-metadata.py'))
        metadata=importlib.util.module_from_spec(spec);spec.loader.exec_module(metadata)
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);(root/'first.conf').write_text('include second.conf\ninclude missing*.conf\n')
            (root/'second.conf').write_text('include first.conf\n/local/lib\n')
            files,patterns=metadata.configurations(root/'first.conf')
            self.assertEqual(len(files),2);self.assertEqual(patterns[str(root/'missing*.conf')],[])
if __name__=='__main__':unittest.main()
