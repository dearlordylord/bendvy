"""Exact Base.Unit transport correction before any backend; old model preserved."""
import json
from pathlib import Path
import expected as Prior

def expected():
 value=Prior.expected()
 for category in ['plain','transient','constructed']:
  for snapshot in value[category]['Reported']['report']['observations']:
   snapshot['world']['events']=[{'Unit':{}} for _ in snapshot['world']['events']]
 return value

def resource_expected():
 value=Prior.resource_expected()
 for phase in ['before','after']:value['Reported']['report'][phase]['store']={'Unit':{}}
 return value
if __name__=='__main__':
 p=Path(__file__);p.with_name('expected-v2.json').write_text(json.dumps(expected(),indent=2)+'\n');p.with_name('resource-expected-v2.json').write_text(json.dumps(resource_expected(),indent=2)+'\n')
