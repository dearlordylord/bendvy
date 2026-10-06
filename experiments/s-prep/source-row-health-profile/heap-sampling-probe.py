#!/usr/bin/env python3
"""Install diagnostic V8 allocation sampling at existing phase markers only."""
import argparse, hashlib, json
from pathlib import Path
p=argparse.ArgumentParser()
p.add_argument('--input',type=Path,required=True)
p.add_argument('--output',type=Path,required=True)
p.add_argument('--profile',type=Path,required=True)
a=p.parse_args()
assert not a.output.exists() and not a.profile.exists()
source=a.input.read_text()
hook='if(typeof __allocation_phase === "function") __allocation_phase(phase); '
if '__allocation_phase' in source:
    assert source.count(hook)==1 and source.count('__allocation_phase')==2, 'Unexpected existing allocation hook'
    assert source.startswith('function __profile_mark(phase) { '+hook), 'Unexpected marker location'
else:
    assert 'function __profile_mark(phase)' in source
prefix='''const __heap_fs = require('node:fs');
const __heap_inspector = require('node:inspector');
const __heap_session = new __heap_inspector.Session();
__heap_session.connect();
let __heap_started = false;
function __allocation_phase(phase) {
  let done = false;
  if (phase === 'start') {
    if (__heap_started) throw Error('Duplicate allocation phase');
    __heap_session.post('HeapProfiler.startSampling', {
      samplingInterval: 32768,
      includeObjectsCollectedByMajorGC: true,
      includeObjectsCollectedByMinorGC: true
    }, (error) => { if (error) throw error; done = true; });
    __heap_started = true;
  } else if (phase === 'end') {
    if (!__heap_started) throw Error('Allocation phase not started');
    __heap_session.post('HeapProfiler.stopSampling', (error, result) => {
      if (error) throw error;
      __heap_fs.writeFileSync(PROFILE_PATH, JSON.stringify(result.profile));
      done = true;
    });
    __heap_session.disconnect();
  } else throw Error('Unexpected allocation phase');
  if (!done) throw Error('Inspector callback must complete synchronously');
}
'''.replace('PROFILE_PATH',json.dumps(str(a.profile.absolute())))
a.output.write_text(prefix+source)
sha=lambda x:hashlib.sha256(x).hexdigest()
a.output.with_suffix('.recipe.json').write_text(json.dumps({'scope':'V8 sampled allocations inside existing execution phase only; includes collected objects; not exact allocation accounting or timing acceptance','intervalBytes':32768,'originalSHA256':sha(source.encode()),'derivedSHA256':sha(a.output.read_bytes()),'recipeSHA256':sha(Path(__file__).read_bytes())},indent=2)+'\n')
