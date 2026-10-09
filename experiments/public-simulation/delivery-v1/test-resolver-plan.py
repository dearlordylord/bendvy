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
class Aliases(unittest.TestCase):
    def module(self):
        import types
        source=Path(__file__).with_name('prepare-metadata.py')
        module=types.ModuleType('alias_metadata');module.__file__=str(source)
        exec(compile(source.read_bytes(),str(source),'exec'),module.__dict__)
        return module
    def test_repeated_directory_alias_and_absent_final_file(self):
        import tempfile
        module=self.module()
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);actual=root/'usr'/'lib';actual.mkdir(parents=True)
            alias=root/'lib';alias.symlink_to('usr/lib',target_is_directory=True)
            payload=actual/'libthing.so.1';payload.write_bytes(b'payload')
            candidate=actual/'libthing.so';candidate.symlink_to(alias/'libthing.so.1')
            result=module.aliases(alias/'libthing.so')
            self.assertEqual(result['resolved'],str(payload));self.assertTrue(result['present'])
            self.assertEqual([row['path'] for row in result['links']],
                             [str(alias),str(candidate),str(alias)])
            payload.unlink();result=module.aliases(alias/'libthing.so')
            self.assertFalse(result['present']);self.assertEqual(len(result['links']),3)
    def test_real_and_expanding_alias_cycles_refuse(self):
        import tempfile
        module=self.module()
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);first=root/'first';second=root/'second'
            first.symlink_to(second);second.symlink_to(first)
            with self.assertRaises(ValueError):module.aliases(first)
            first.unlink();second.unlink();first.symlink_to(first/'tail')
            with self.assertRaises(ValueError):module.aliases(first)
if __name__=='__main__':unittest.main()
