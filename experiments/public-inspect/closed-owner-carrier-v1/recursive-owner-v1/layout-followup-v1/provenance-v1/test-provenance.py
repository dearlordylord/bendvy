import importlib.util,json,hashlib,tempfile,unittest
from pathlib import Path
HERE=Path(__file__).resolve().parent
path=HERE.parent.parent/'cpu-profile-v1/diagnostic-run.py'
namespace={'__file__':str(path),'__name__':'provenance_controls'}
exec(compile(path.read_bytes(),str(path),'exec'),namespace)
validate=namespace['validate_provenance']
class Controls(unittest.TestCase):
 def setUp(self):
  self.temp=tempfile.TemporaryDirectory();self.addCleanup(self.temp.cleanup)
  source=Path(self.temp.name)/'subject.bend';source.write_text('def main() -> U32: 0\n');self.source=str(source)
  digest=hashlib.sha256(source.read_bytes()).hexdigest()
  self.plan={'pins':{self.source:digest},'expectedLoadedSources':[self.source]}
  shape={'width':1,'kinds':['U32'],'arms':None}
  self.data={'templateInstances':[],'observed':{'scope':'diagnostic','calls':3,'omitted':1,'errors':1,'unknownCalls':0,'definitionCounts':[['main',3]],'rows':[{'definition':'main','displayedDefinition':'main','from':shape,'to':shape,'calls':1}]},'bookDefinitions':[{'key':'main','tag':'Def','namespace':''}],'loaded':[[self.source,'']],'mapping':[{'definition':'main','status':'mapped','namespace':'','localName':'main','source':self.source,'line':1,'sourceSHA256':digest}]}
 def test_complete(self):self.assertEqual(validate(self.data,self.plan)['calls'],3)
 def test_partial_publication(self):
  raw=json.dumps(self.data)
  with self.assertRaises(json.JSONDecodeError):json.loads(raw[:-1])
 def test_missing_mapping(self):
  self.data['mapping']=[]
  with self.assertRaises(ValueError):validate(self.data,self.plan)
 def test_bool_counter(self):
  self.data['observed']['calls']=True
  with self.assertRaises(ValueError):validate(self.data,self.plan)
 def test_counter_loss(self):
  self.data['observed']['omitted']=0
  with self.assertRaises(ValueError):validate(self.data,self.plan)
 def test_source_line(self):
  self.data['mapping'][0]['line']=2
  with self.assertRaises(ValueError):validate(self.data,self.plan)
 def test_membership(self):
  self.plan['expectedLoadedSources']=[]
  with self.assertRaises(ValueError):validate(self.data,self.plan)
 def test_duplicate_json(self):
  with self.assertRaises(ValueError):json.loads('{"calls":1,"calls":2}',object_pairs_hook=namespace['unique_object'])
 def test_template_origin(self):
  self.data['bookDefinitions'].append({'key':'main~14','tag':'Def','namespace':None})
  self.data['templateInstances']=[{'template':'main','instances':['main~14']}]
  self.data['observed']['definitionCounts']=[['main~14',3]]
  row=self.data['observed']['rows'][0];row['definition']='main~14';row['displayedDefinition']='main~14'
  self.data['mapping'][0].update(definition='main~14',originTemplate='main')
  self.assertEqual(validate(self.data,self.plan)['mapped'],1)
  self.data['mapping'][0]['originTemplate']='wrong'
  with self.assertRaises(ValueError):validate(self.data,self.plan)
 def test_unknown_suffix_not_origin(self):
  self.data['bookDefinitions'].append({'key':'main~14','tag':'Def','namespace':None})
  self.data['observed']['definitionCounts']=[['main~14',3]]
  row=self.data['observed']['rows'][0];row['definition']='main~14';row['displayedDefinition']='main~14'
  self.data['mapping']=[{'definition':'main~14','status':'missing-namespace'}]
  self.assertEqual(validate(self.data,self.plan)['unmapped'],1)
if __name__=='__main__':unittest.main()
