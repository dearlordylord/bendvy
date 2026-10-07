"""Normalize only shared feature observations; retain the full Bend records too.

World namespace/live/stamp/registry structures have no claimed TS equivalence.
They remain checked in the separate full literal Bend oracle. No missing or
unexpected record may be silently discarded during this normalization.
"""
import json

def normalized(text):
 result=[]
 for line in text.strip().splitlines():
  case,body=line.split('=',1)
  assert case in {root+'-'+size+'-'+mode for root in ['A','B'] for size in ['small','grown'] for mode in ['selected','duplicate','missing','priority']}
  status=body.split('|',1)[0]
  assert status=='executed' or status.startswith('refused='),status
  fields={part.split('=',1)[0]:part.split('=',1)[1] for part in body.split('|')[1:]}
  trace=fields['trace'];assert trace.startswith('[') and trace.endswith(']')
  trace=[] if trace=='[]' else trace[1:-1].split(', ')
  owner=fields['owners'].split('/');assert len(owner)==5 and owner[4]=='tag'
  result.append({'case':case,'status':'executed' if status=='executed' else 'refused','error':None if status=='executed' else status[len('refused='):], 'trace':trace,'calls':json.loads(fields['calls']),'owners':{'front':json.loads(owner[0]),'back':json.loads(owner[1]),'queued':json.loads(owner[2]),'core':json.loads(owner[3]),'tag':owner[4]},'empty':fields.get('empty-label')})
 assert len(result)==16 and len({item['case'] for item in result})==16
 return result
