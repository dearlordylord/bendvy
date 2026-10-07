"""Task-local immutable command-log guard over the reviewed descendant supervisor.

The supervisor returns MERGED stdout/stderr, not raw split streams. Existing
.stdout names hold this merged capture; .stderr files are synthetic empty
compatibility placeholders. Diagnostic spans are asserted against merged text.
"""
from pathlib import Path
import importlib.util
BASE=Path(__file__).resolve().parent.parent/'public-bundles/guarded-harness.py'
spec=importlib.util.spec_from_file_location('feature_shared_guard',BASE)
shared=importlib.util.module_from_spec(spec);spec.loader.exec_module(shared)
ROOT=shared.ROOT
sha=shared.sha
class Harness(shared.Harness):
 def guard(self):
  super().guard()
  planned={}
  for record in self.r['commands']:
   for stream in ['stdout','stderr']:
    path=record['label']+'.'+stream
    assert path not in planned,('duplicate command log',path)
    planned[path]=record[stream+'_sha256']
  observed={str(path.relative_to(self.out)):sha(path) for pattern in ['*.stdout','*.stderr'] for path in self.out.glob(pattern)}
  assert observed==planned,('command-log inventory/bytes drift',observed,planned)
 def run(self,label,argv,cap,good=True,produces=None):
  self.guard()
  assert not (self.out/(label+'.stdout')).exists(),('prospective command capture exists',label)
  assert not (self.out/(label+'.stderr')).exists(),('prospective command placeholder exists',label)
  try:
   return super().run(label,argv,cap,good,produces)
  finally:
   if self.r['commands'] and self.r['commands'][-1]['label']==label:
    self.r['commands'][-1]['capture']={'stdout_file':'merged stdout/stderr from reviewed supervisor','stderr_file':'synthetic empty compatibility placeholder; not raw stderr','diagnostic_assertions':'exact merged text including responsible source span'}
   self.guard()
 def save(self):
  self.guard()
  self.r['command_log_guard']='Exact immutable prior-command .stdout/.stderr membership and hashes before/after every command and at final save'
  super().save()
