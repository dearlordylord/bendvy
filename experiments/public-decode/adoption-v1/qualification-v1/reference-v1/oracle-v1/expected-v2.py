"""Separately versioned source-only TS Runtime.make wrapper correction."""
import json
from pathlib import Path
import expected as Prior

def expected():
 value=Prior.expected()
 # Runtime.make2052 returns Result.failure({resources:validated.error}).
 old=value['selectors']['initializeBoolean']['error']
 value['selectors']['initializeBoolean']['error']={'resources':old}
 return value
if __name__=='__main__':Path(__file__).with_name('expected-v2.json').write_text(json.dumps(expected(),indent=2)+'\n')
