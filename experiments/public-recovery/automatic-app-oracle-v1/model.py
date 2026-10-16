"""Independent finite recovery state plus exact fixture string projection."""
from state_model import State,pair,array

def leaf(x):return 'leaf:'+str(x)
def tree(xs):return leaf(xs) if isinstance(xs,(int,str)) else 'node('+','.join(tree(x) for x in xs)+')'
def nested(xs):return 'node('+','.join('leaf:'+tree(x) for x in xs)+')'
def listing(xs):return '['+', '.join(xs)+']'
def cons(xs):return '[]' if not xs else 'cons('+xs[0]+','+cons(xs[1:])+')'
class App(State):
    def __init__(self,ns):super().__init__();self.ns=ns;self.debug=False
    def ident(self,id,name,access,cursor):return f'namespace={self.ns};id={id};name={name};access={listing(access)};cursor={cursor}'
    def world(self):
        return f'world{{namespace={self.ns};nextId=2;highWater=1;live=node(leaf:False,leaf:True);capacity=2;depth=1;store={{Column{{values=leaf:some({nested(self.component)});stamps=[1:1:{self.changed}]}}}};resources={{target={nested(self.resource)};sameSibling={nested(array(800))};otherSibling={tree(pair(900))}}};events=[];pending=0;registrations=[2:recoverable-ordinary-app:[Payload, Target], 1:prior-readonly-capture:[Payload]];nextSystemId=3;clock={self.clock}}}'
    def prior(self):return 'previous{initial=Unit;prior{'+self.ident(1,'prior-readonly-capture',['Payload'],0)+';capture='+tree(pair(600))+'}}'
    def actual(self):return f'app{{debug={self.debug};previousOwners='+self.prior()+';recipe=Recipe|'+self.world()+'|owner{'+self.ident(2,'recoverable-ordinary-app',['Payload','Target'],self.cursor)+';capture='+nested(self.capture)+'}}'
    def binding(self,id,name,access,cursor,clauses):return 'binding{'+self.ident(id,name,access,cursor)+';slot='+name+';clauses='+listing(clauses)+'}'
    def debug_view(self):
        if not self.debug:return 'None'
        return 'Some{bindings='+listing([self.binding(1,'prior-readonly-capture',['Payload'],0,['Payload:Read']),self.binding(2,'recoverable-ordinary-app',['Payload','Target'],self.cursor,['Payload:Write','Target:Write'])])+';observation={rows=Unit;rendered=[]}}'
    def index(self):
        if not self.debug:return 'None'
        def use(id,name,mode,role):return f'use{{namespace={self.ns};id={id};name={name};mode={mode};role={role}}}'
        return 'Some{'+listing(['entry{category=Components;key=Payload;uses='+listing([use(1,'prior-readonly-capture','Read','Reader'),use(2,'recoverable-ordinary-app','Write','Writer')])+'}','entry{category=Resources;key=Target;uses='+listing([use(2,'recoverable-ordinary-app','Write','Writer')])+'}'])+'}'
    def args(self,seed,fail):return f'args{{target={self.ns}:1;component={nested(array(seed))};resource={nested(array(seed+20))};resourceElement={tree(pair(seed+30))};capture={nested(array(seed+40))};captureElement={tree(pair(seed+50))};fail={fail}}}'
    def recovery(self,r):
        components=[f'component{{handle={self.ns}:{id};stamp={a}:{c};payload=some({nested(v)})}}' for id,a,c,v in r['components']]
        def ar(rows):return cons(['Replaced{'+nested(row[1])+'}' if row[0]=='Replaced' else 'Swapped{index='+str(row[1])+';value='+tree(row[2])+'}' for row in rows])
        return 'recovery{components='+cons(components)+';resource='+ar(r['resource'])+';capture='+ar(r['capture'])+'}'
def schema(ns):
    s=App(ns);rows=[]
    def snap(label):rows.append(label+'|debug='+s.debug_view()+'|index='+s.index()+'|actual={'+s.actual()+'}\n')
    def run(label,seed,fail):
        rows.append('input:'+label+'|'+s.args(seed,fail)+'\n');r=s.run(seed,fail);rows.append('returned:'+label+'|output={output{components=[];arrays=[];elements=[];errors=[]}}|recovery={'+s.recovery(r)+'}\n')
        snap(label+(':failed|retryOwners={'+s.args(seed,True)+'}' if fail else ':success'))
    snap('registered-disabled');s.debug=True;snap('enabled-first');snap('enabled-repeated');run('commit',100,False);run('failed',200,True);run('retry-success',200,False);snap('repeated-final');s.debug=False;snap('disabled-final');rows.append('terminal|actual={'+s.actual()+'}\n');return ''.join(rows)
def render():return ('Workshop\n'+schema(1)+'Garden\n'+schema(2)+'\n').encode()
def selftest():
    from state_model import selftest as arithmetic
    arithmetic()
    raw=render()
    assert raw.count(b'\n')==33 and raw.endswith(b'\n\n')
    assert b'PENDING' not in raw
    assert raw.count(b'prior{namespace=')==18
    assert raw.count(b'retryOwners=')==2
if __name__=='__main__':
    import sys
    selftest()
    if '--selftest' not in sys.argv:sys.stdout.buffer.write(render())
