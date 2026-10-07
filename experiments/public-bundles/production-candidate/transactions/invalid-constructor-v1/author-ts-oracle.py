"""Literal expected reference checkpoints; does not import/execute Node or Bend."""
from pathlib import Path
import json
out=[]
for schema in ['A','B']:
 for action in ['spawn','insert']:
  for retry in [False,True]:
   valid=action=='insert';raw={'stock':[11,12],'value':{'valid':valid,'value':17},'tag':{},'queue':{'valid':False,'front':[31,32],'back':[41,42],'queued':[[51,52]]}}
   record={'schema':schema,'action':action,'retry':retry,'refusal':{'errors':[None,None if valid else 'bad-1',None,'bad-3'],'calls':[0,1,3]*3,'raw':raw},'retried':None,'checkpoints':[]}
   if retry:
    fixed={'stock':[11,12],'value':{'valid':True,'value':17},'tag':{},'queue':{'valid':True,'front':[31,32],'back':[41,42],'queued':[[51,52]]}}
    record['retried']={'sameRawObjects':True,'id':2 if action=='spawn' else 1,'calls':[0,1,3]*4,'raw':fixed}
   before={'id':1,'stock':[501,502],'back':[1041,1042],'tag':{},'value':17}
   after=[{'id':1,'stock':[1091,1092],'back':[1101,1102],'tag':{},'value':27}]
   if retry:
    fixed={'id':2 if action=='spawn' else 1,'stock':[1031,1032],'back':[1041,1042],'tag':{},'value':17}
    after=after+[fixed] if action=='spawn' else [fixed]
   record['checkpoints']=[{'label':'before','rows':[before]},{'label':'after','rows':after}];out.append(record)
Path(__file__).with_name('expected-reference.stdout').write_text(json.dumps(out,separators=(',',':'))+'\n')
