"""Source-only frame normalization correction; original model retained."""
import json
from pathlib import Path
import counterfactuals as Prior

def expected():
 value=Prior.wrong_reader()
 for schema in ['alpha','beta']:
  queue=value[schema]['retry']['value']['domains'][0]['queue']
  # Queue.trim always normalizes before retention test; boundary0 retains tick8.
  assert not queue['front'] and len(queue['back'])==2
  queue['front']=list(reversed(queue['back']));queue['back']=[]
 return value
if __name__=='__main__':Path(__file__).with_name('wrong-reader-advance-expected-v2.json').write_text(json.dumps(expected(),indent=2)+'\n')
