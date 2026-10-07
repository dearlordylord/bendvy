"""Shared reviewed source/stage/tool/artifact/log guards and owned supervision."""
import gzip, importlib.util, json, os, pathlib, shutil
import preflight
from stage import inventory

from pathlib import Path as _runner_Path
import sys as _runner_sys
_runner_root = next(p for p in _runner_Path(__file__).resolve().parents if (p/'scripts/task_runner.py').is_file())
_runner_sys.path.insert(0, str(_runner_root/'scripts'))
import task_runner

HERE = pathlib.Path(__file__).resolve().parent

class Harness:
    def __init__(self, stage_path, output):
        assert not output.exists(), 'Output must be fresh'
        self.stage_path, self.output = stage_path, output
        self.staged = json.loads((stage_path/'stage.json').read_text())
        self.stage = stage_path/'stage'
        output.mkdir(parents=True)
        self.tools = {name:pathlib.Path(shutil.which(name)).resolve() for name in ['bend','node','python3','taskset']}
        self.tools['clang'] = pathlib.Path('/tmp/bendvy-clang19-diagnostic/clang19').resolve()
        spec = importlib.util.spec_from_file_location('feature_tools',HERE/'tool-pins.py')
        self.pins = importlib.util.module_from_spec(spec); spec.loader.exec_module(self.pins)
        self.installed = self.pins.snapshot()
        self.receipt = {'status':'INCOMPLETE','stageReceiptSHA':preflight.digest(stage_path/'stage.json'),'installedTools':self.installed,'childEnvironmentFixed':{'BEND_NO_TELEMETRY':'1'},'noticeCacheObserved':preflight.notice_cache(),'commands':[],'artifacts':{},'logs':{}}
        self.guard()
    def save(self):
        (self.output/'receipt.json').write_text(json.dumps(self.receipt,indent=2)+'\n')
    def guard(self):
        assert preflight.digest(self.stage_path/'stage.json')==self.receipt['stageReceiptSHA'],'Stage receipt drift'
        assert inventory(self.stage)==self.staged['stageInventory'],'Staged source drift'
        assert preflight.snapshot()==self.staged['sources'],'Live source drift'
        assert preflight.external()==self.staged['external'],'External source drift'
        self.pins.verify(self.installed)
        for group in ['artifacts','logs']:
            assert all(preflight.digest(self.output/p)==h for p,h in self.receipt[group].items()),group+' drift'
    def pin(self,path):
        self.receipt['artifacts'][str(path.relative_to(self.output))]=preflight.digest(path)
    def run(self,label,command,cap,good=True):
        self.guard()
        try:
            result=task_runner.execute_completed(list(map(str,command)),cap,dict(os.environ,BEND_NO_TELEMETRY='1',BENDVY_CLANG19_ROOT='/tmp/bendvy-clang19-diagnostic/root'))
        except Exception as error:
            self.receipt['commands'].append({'label':label,'command':list(map(str,command)),'cap':cap,'error':repr(error)})
            self.save();raise
        gzip.open(self.output/(label+'.stdout.gz'),'wb').write(result.stdout)
        (self.output/(label+'.stderr')).write_bytes(result.stderr)
        for suffix in ['.stdout.gz','.stderr']:
            self.receipt['logs'][label+suffix]=preflight.digest(self.output/(label+suffix))
        self.receipt['commands'].append({'label':label,'command':list(map(str,command)),'cap':cap,'exit':result.returncode})
        self.save()
        assert (result.returncode==0)==good,(label,result.stderr)
        self.guard()
        return result
    def build(self,name):
        entry=self.stage/'feature-harness'/(name+'.bend')
        checked=self.run(name+'-check',[self.tools['bend'],entry,'--check-only'],5,False)
        assert b'defs rely on unsafe or foreign code' in checked.stderr and b'timing.capture' in checked.stderr,checked.stderr
        js=self.output/(name+'.js');native_c=self.output/(name+'.c');binary=self.output/name
        for path in [js,native_c,binary]:assert not path.exists(),'Prospective output already exists'
        self.run(name+'-emit-JS',[self.tools['bend'],entry,'-o',js],30);self.pin(js)
        self.run(name+'-emit-Native',[self.tools['bend'],entry,'-o',native_c],30);self.pin(native_c)
        self.run(name+'-compile',[self.tools['clang'],'-O3',native_c,'-o',binary,'-pthread','-lm'],120);self.pin(binary)
        return {'TS':[self.tools['node'],self.stage/'feature-harness'/(name+'.mjs')],'JS':[self.tools['node'],js],'Native':[binary,'--threads','1','--gpu','off']}
