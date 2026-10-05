#!/usr/bin/env python3
"""Bounded correctness checks; deliberately collects no timing or benchmark data."""
import hashlib,json,os,pathlib,signal,subprocess
P=pathlib.Path(__file__).resolve().parent

def run(args,limit,expected=0):
    p=subprocess.Popen([str(x) for x in args],cwd=P,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True)
    try: out,err=p.communicate(timeout=limit)
    except subprocess.TimeoutExpired:
        os.killpg(p.pid,signal.SIGKILL);p.communicate();raise RuntimeError(f'Exceeded {limit}s: {args}')
    assert p.returncode==expected,(args,p.returncode,out,err)
    return out+err

def normalize(line):
    label,value=line.split(':',1); observation,value=value.split(';',1)
    fields=value.split('|'); shape=label.rsplit('/',1)[1]
    if shape=='original':
        meta=[x.split('/') for x in fields[2][1:-1].split(', ')]
        canonical=[fields[0],fields[1],meta,fields[3]]
    else:
        cols=[x[1:-1].split(', ') for x in fields[2:6]]
        canonical=[fields[0],fields[1],[list(x) for x in zip(*cols,strict=True)],fields[6]]
    return label.rsplit('/',1)[0],observation,canonical

def verify(out):
    lines=out.splitlines();assert len(lines)==42,len(lines)
    cases=[]
    for a,b,c in zip(lines[::3],lines[1::3],lines[2::3],strict=True):
        original=normalize(a);columns=normalize(b);assert original==columns==normalize(c),(original,columns,normalize(c))
        key,observation,state=original;name,target=key.split('/');target=int(target)
        name,variant=(name.split('-',1)+['normal'])[:2] if '-' in name else (name,'normal')
        high={'normal':2,'highzero':0,'highone':1}[variant]
        marked=target==1 and target<=high
        owners={'one':('[Some(Scalar(41)), None]','[Some(Array[7, 8]), None]'),'two':('[Some(Array[51, 52]), None]','[Some(Scalar(61)), None]')}[name]
        assert state[:2]==list(owners)
        assert state[2]==[['True','Some(9)','3','88' if marked else '4'],['True' if variant=='highone' else 'False','Some(99)','13','14']]
        assert state[3]==f'2/1/{high}'
        expected=f'Some(True/Some(9)/3/{88 if marked else 4})' if target==1 else f'Some({"True" if variant=="highone" else "False"}/Some(99)/13/14)' if target==2 else 'None'
        assert observation==expected,(key,observation)
        cases.append(key)
    return cases

for f in ['transport.bend','schema.bend','schema-positive.bend','fixture.bend']:
    out=run(['bend',P/f,'--check-only'],5);assert 'ALL PROOFS CHECK' in out
negatives={ 'negative-duplicate':'consumed more than once','negative-schema':'observed : S.ReadPermit<S.Health>','negative-undeclared':'observed : S.Scoped<S.Motion'}
for name,diagnostic in negatives.items():
    out=run(['bend',P/(name+'.bend'),'--check-only'],5,1);assert diagnostic in out,out
    (P/(name+'.out')).write_text(out)
run(['bend',P/'fixture.bend','-o',P/'fixture.js'],30)
run(['bend',P/'fixture.bend','-o',P/'fixture.c'],30)
run(['clang','-std=c11','-O3',P/'fixture.c','-lpthread','-lm','-o',P/'fixture-native'],120)
js=run(['node',P/'fixture.js'],5);native=run([P/'fixture-native','--threads','1','--gpu','off'],5)
assert js==native
cases=verify(js)
(P/'js.out').write_text(js);(P/'native.out').write_text(native)
report={'status':'FINITE_TRANSPORT_MATCH','scope':'two Type payload placements; 14 complete field comparisons per backend against independent columns and destructive conversion; no integration/proof/performance acceptance','cases':cases,'limits_seconds':{'check':5,'codegen':30,'clang':120,'runtime':5},'compiler':run(['bend','version'],5).strip(),'node':run(['node','--version'],5).strip(),'clang':run(['clang','--version'],5).splitlines()[0],'sources':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(P.glob('*.bend'))},'negative_controls':negatives,'output_sha256':hashlib.sha256(js.encode()).hexdigest()}
(P/'evidence.json').write_text(json.dumps(report,indent=2)+'\n')
print('PASS: 14 full-field cases on Native/JS; 3 intended checker negatives; no timing collected')
