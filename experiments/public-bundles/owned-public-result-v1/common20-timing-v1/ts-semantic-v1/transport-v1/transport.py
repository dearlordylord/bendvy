"""Full pinned TS source-stage identity plus exact whole literal String gate."""
from pathlib import Path
import hashlib,json
TERM_PATH=Path(__file__).resolve()
class TERM:
 @staticmethod
 def strict_equal(actual,expected):
  if type(actual) is not str or type(expected) is not str or actual!=expected:raise ValueError('Entire literal output differs')
class Transport:
 def __init__(self,entry):self.entry=Path(entry).resolve();self.here=self.entry.parents[1]
 def inventory(self):
  binding=json.loads((self.here/'SOURCE-BINDING.json').read_bytes());stage=self.here/'stage-v1';core=Path(binding['core'])
  def files(root):return {str(f.relative_to(root)):hashlib.sha256(f.read_bytes()).hexdigest() for f in sorted(root.rglob('*')) if f.is_file()}
  original=files(core/'src');copied=files(stage/'core/src')
  if original!=binding['coreSourceMembership'] or copied!=binding['stageCoreMembership'] or copied!=original:raise ValueError('Full original/staged core membership or bytes changed')
  def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
  if digest(core/'package.json')!=binding['packageSHA256'] or digest(stage/'core/package.json')!=binding['packageSHA256']:raise ValueError('Core package source-stage join changed')
  raw=Path(binding['originalCallable']).read_bytes();staged=(stage/'reference.mjs').read_bytes()
  if digest(Path(binding['originalReference']))!=binding['originalReferenceSHA256']:raise ValueError('Original qualified reference changed')
  if digest(Path(binding['originalCallable']))!=binding['originalCallableSHA256'] or staged!=raw.replace(b'../../../../.references/bevy-ts/packages/core/src/',b'./core/src/'):raise ValueError('Only exact fixture import rewrite allowed')
  if digest(stage/'main.mjs')!=binding['mainSHA256'] or digest(stage/'reference.mjs')!=binding['stagedReferenceSHA256']:raise ValueError('Exact whole callable entry changed')
  paths=[self.here/'SOURCE-BINDING.json',Path(binding['originalCallable']),Path(binding['originalReference']),core/'package.json',stage/'core/package.json',stage/'reference.mjs',stage/'main.mjs',*sorted((core/'src').rglob('*')),*sorted((stage/'core/src').rglob('*'))]
  sources={str(f.resolve()):digest(f) for f in paths if f.is_file()}
  return {'entrypoint':str(self.entry),'sourceSHA256':sources}
 def normalize(self,text):
  if type(text) is not str:raise ValueError('String output required')
  return text
