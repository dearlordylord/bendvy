"""Independent finite fixture semantics and reporting-only counter transform.

Declared-input basis: source checkpoint 7b97daefd, controls/fixture.bend
SHA256 ed824242c27d54132658eb272655f1209661270579efae8ed3d4ecf06502729f.
Inputs are the finite constructors/operations, never candidate runtime output.
Counter transform is reporting-only and deliberately differs from normal gold."""
from pathlib import Path
import copy,json,hashlib
from itertools import zip_longest
P=Path(__file__).parent
compact=lambda x:json.dumps(x,separators=(',',':')).encode()
def shape(tree):
 if tree['kind']=='leaf':return [1,0]
 assert tree['kind']=='node';a=shape(tree['left']);b=shape(tree['right']);return [a[0]+b[0],1+a[1]+b[1]]
def flags(tree):
 if tree['kind']=='leaf':return [tree['value']>0]
 return flags(tree['left'])+flags(tree['right'])
def array_stats(tree):return shape(tree)+[sum(flags(tree))]
def entries(rows):return [len(rows),sum(r['first']>0 for r in rows),sum(r['last']>0 for r in rows),sum(r['first']>0 or r['last']>0 for r in rows)]
def metadata(state):
 return {'added':array_stats(state['added']),'changed':array_stats(state['changed']),'capacity':state['capacity'],'depth':state['depth'],'exceptional':entries(state['exceptional']),'populated':sum(a or b for a,b in zip_longest(flags(state['added']),flags(state['changed']),fillvalue=False))}
def counter_gold():
 normal=json.loads((P/'expected.stats.json').read_bytes());counter=copy.deepcopy(normal);changed=0
 for samples in counter.values():
  for sample in samples:
   s=sample['snapshot']
   if s['kind']=='indexed':
    for name in ['added','changed']:s['metadata'][name][2]+=1;changed+=1
 raw=compact(counter);assert changed==732 and raw!=(P/'expected.stats.json').read_bytes();return raw
def leaf(v):return {'kind':'leaf','value':v}
def node(a,b):return {'kind':'node','left':a,'right':b}
def flatten(t):return [t['value']]if t['kind']=='leaf'else flatten(t['left'])+flatten(t['right'])
def zeros(depth):return leaf(0)if depth==0 else node(zeros(depth-1),zeros(depth-1))
def set_tree(t,index,value):
 if t['kind']=='leaf':assert index==0;return leaf(value)
 half=shape(t['left'])[0]
 return node(set_tree(t['left'],index,value),copy.deepcopy(t['right']))if index<half else node(copy.deepcopy(t['left']),set_tree(t['right'],index-half,value))
def empty_meta():return {'added':leaf(0),'changed':leaf(0),'capacity':1,'depth':0,'exceptional':[]}
def set_meta(m,index,first,last):
 m=copy.deepcopy(m)
 if not 1<=index<=131072:
  m['exceptional']=[{'id':index,'first':first,'last':last}]+[r for r in m['exceptional']if r['id']!=index];return m
 while m['capacity']<index:
  for name in ['added','changed']:m[name]=node(m[name],zeros(m['depth']))
  m['capacity']*=2;m['depth']+=1
 m['added']=set_tree(m['added'],index-1,first);m['changed']=set_tree(m['changed'],index-1,last);return m
def clear_meta(m,index):
 m=copy.deepcopy(m)
 if not 1<=index<=131072:m['exceptional']=[r for r in m['exceptional']if r['id']!=index];return m
 if index<=m['capacity']:
  for name in ['added','changed']:m[name]=set_tree(m[name],index-1,0)
 return m
def tree_string(t):return 'leaf'if t['kind']=='leaf'else 'node('+tree_string(t['left'])+','+tree_string(t['right'])+')'
def raw_meta(m):return {'addedTree':tree_string(m['added']),'changedTree':tree_string(m['changed']),'added':flatten(m['added']),'changed':flatten(m['changed']),'capacity':m['capacity'],'depth':m['depth'],'exceptional':[[r['id'],r['first'],r['last']]for r in m['exceptional']]}
def payload(tag):return {'tag':tag,'token':[tag,tag+100],'captured':[tag+1000,tag+2000]}
def indexed(values,m):return {'kind':'indexed','values':shape(values),'metadata':metadata(m)}
def first_six():
 stamps=[{'id':1,'first':0,'last':0},{'id':2,'first':5,'last':0},{'id':3,'first':0,'last':7}];raw_stamps=[[r['id'],r['first'],r['last']]for r in stamps]
 plain={'snapshot':{'kind':'plain','values':[1,0],'entries':entries(stamps)},'returned':{'valuesTree':'leaf','values':[payload(11)],'stamps':raw_stamps}}
 exceptional=set_meta(set_meta(empty_meta(),0,2,0),131073,0,3)
 exceptional_cases=[{'snapshot':metadata(m),'returned':raw_meta(m)}for m in [exceptional,clear_meta(exceptional,0)]]
 unmatched=[{'added':node(leaf(1),leaf(0)),'changed':leaf(2),'capacity':8,'depth':3,'exceptional':[]},{'added':leaf(0),'changed':node(leaf(0),leaf(2)),'capacity':8,'depth':3,'exceptional':[]}]
 unequal=[{'snapshot':metadata(m),'returned':raw_meta(m)}for m in unmatched]
 state={'wrappers':2,'capacity':4,'current':2,'owner':True,'remaining':[3,4],'past':[1]}
 recovered=[payload(tag)for tag in [11,22,33,44]]
 prepared={'snapshot':{'kind':'plain','values':[4,3],'entries':entries(stamps)},'state':copy.deepcopy(state),'returned':{'valuesTree':'node(node(leaf,leaf),node(leaf,leaf))','values':recovered,'stamps':raw_stamps}}
 pm=set_meta(set_meta(empty_meta(),1,1,2),4,0,3)
 prepared_indexed={'snapshot':{'kind':'indexed','values':[4,3],'metadata':metadata(pm)},'state':copy.deepcopy(state),'returned':{'valuesTree':'node(node(leaf,leaf),node(leaf,leaf))','values':copy.deepcopy(recovered),'metadata':raw_meta(pm)}}
 m0=empty_meta();m1=set_meta(m0,1,5,5);m2=set_meta(m1,1,0,0)
 restore={'trace':[{'site':site,'snapshot':indexed(leaf(None),m)}for site,m in [('empty',m0),('mark',m1),('restore_stamp',m2)]],'returned':{'valuesTree':'leaf','values':[None],'metadata':raw_meta(m2)}}
 return {'plain':plain,'exceptional':exceptional_cases,'unequal':unequal,'prepared':prepared,'preparedIndexed':prepared_indexed,'restore':restore}

def rollback():
 # F.seed starts payload index0. Its main/aux component writes advance clock
 # to1/2; the failing replacement advances it to3. Inverse raw swap does
 # not mark; restore_stamp restores(1,1) without rewinding World.clock.
 m0=empty_meta();seed=set_meta(m0,1,1,1);written=set_meta(seed,1,1,3)
 def trace(states):return [{'site':site,'snapshot':indexed(leaf(None),m)}for site,m in states]
 return {'outcome':'Failure','handle':[1,1,0],'position':{'kind':'Found','value':{'coordinates':{'a':0,'b':1,'c':2,'d':3},'frame':7}},'stamp':[1,1],'clock':3,'trace':{'main':trace([('empty',m0),('mark',seed),('mark',written),('restore_stamp',seed)]),'aux':trace([('empty',m0),('mark',set_meta(m0,1,2,2))]),'flag':trace([('empty',m0)])}}

def fixture():
 six=first_six();out={}
 for key,value in six.items():
  out[key]=value
  if key=='unequal':
   m=empty_meta();values=zeros(3)
   out['capacitySplit']={'snapshot':indexed(values,m),'returned':{'valuesTree':tree_string(values),'values':[None]*8,'metadata':raw_meta(m)}}
 out['rollback']=rollback()
 assert out['plain']['snapshot']['entries']==[3,1,1,2]
 assert out['preparedIndexed']['snapshot']['metadata']['populated']==2
 assert [v['snapshot']['metadata']['populated']for v in out['restore']['trace']]==[0,1,0]
 assert out['capacitySplit']['snapshot']['values']==[8,7]
 return out

if __name__=='__main__':
 assert counter_gold()==(P/'counter.stats.json').read_bytes()
 raw=compact(fixture())+b'\n'
 (P/'expected.fixture.stdout').write_bytes(raw)
 print(json.dumps({'fixtureBytes':len(raw),'fixtureSha256':hashlib.sha256(raw).hexdigest(),'counterBytes':len(counter_gold()),'counterSha256':hashlib.sha256(counter_gold()).hexdigest()},separators=(',',':')))
