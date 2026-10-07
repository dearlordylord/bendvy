"""Independent complete metadata observations, authored before actual TS run.

Requirement IDs are fixture labels for actual nominal descriptor keys, not a
replacement public TS field. Bend output is separately frozen, with all cells
of its two affine Array owners. It does not claim TS callback/array identity.
"""
import json
CASES=['empty','query-only','resource-absent','resource-present','aliases','same-name-interned-aliases']
def requirements(schema,case):
 if case in ['empty','query-only']:return []
 if case in ['resource-absent','resource-present']:return [{'kind':'resource','id':1,'name':schema+'/Score'}]
 if case=='aliases':return [{'kind':'resource','id':2,'name':schema+'/Bonus'},{'kind':'resource','id':1,'name':schema+'/Score'}]
 return [{'kind':'resource','id':3,'name':schema+'/Shared'}]
def expected():
 rows=[]
 for schema in ['Workshop','Garden']:
  for case in CASES:
   for read in ['first','repeat']:
    rows.append({'schema':schema,'case':case,'read':read,'kind':'inspector','name':schema+'/Metadata/'+case,'systemName':schema+'/Metadata/'+case,'requirements':requirements(schema,case),'readCallbackIsSupplied':True,'requirementsAreSystemRequirements':True,'callbackCalls':0,'runtimeSetup':'absent' if case=='resource-absent' else 'present' if case=='resource-present' else 'not-created','factory':'low-level-metadata-only' if case=='same-name-interned-aliases' else 'bound'})
 return {'format':1,'application':'InspectorDefinitionMetadata','observations':rows}
EXPECTED=expected()
def bend_text():
 lines=[]
 for schema in ['Workshop','Garden']:
  for case in CASES:
   for read in ['first','repeat']:
    reqs=requirements(schema,case)
    req='['+', '.join('resource:'+str(r['id'])+':'+r['name'] for r in reqs)+']'
    lines.append(schema+'|'+case+'|'+read+'|kind=inspector|name='+schema+'/Metadata/'+case+'|requirements='+req+'|left=[101, 102, 103, 104]|right=[201, 202, 203, 204]')
 return '\n'.join(lines)+'\n'
BEND_EXPECTED=bend_text()
if __name__=='__main__':print(json.dumps(EXPECTED))
