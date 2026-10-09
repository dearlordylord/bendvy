"""Whole separately versioned source model for59f17d6c; no observations read."""
import copy,json
from pathlib import Path
import expected as Prior

def expected():
 value=Prior.expected()
 case=Prior.ref.expected()['struct64']
 original=Prior.converted(case['original']);canonical=Prior.converted(case['checked'])['value']
 trace=value['foreign']['result']['trace']
 trace['outcome']=Prior.tag('OperationRefused',original=copy.deepcopy(original),incoming=Prior.some(Prior.payload(copy.deepcopy(original),[111,222])),error=Prior.tag('MissingEntity'))
 trace['canonical']=Prior.some(copy.deepcopy(canonical))
 return value
if __name__=='__main__':Path(__file__).with_name('expected-v2.json').write_text(json.dumps(expected(),indent=2)+'\n')
