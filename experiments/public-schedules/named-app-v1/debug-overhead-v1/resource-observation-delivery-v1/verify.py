"""Offline exact source/plan/receipt/full-stream joins; no executable replay."""
import copy,gzip,hashlib,json,sys,zipfile,tempfile
from pathlib import Path
sha=lambda b:hashlib.sha256(b).hexdigest()
def need(test,message):
    if not test:raise ValueError(message)
def verify(here,selftest=False):
    root=next(p for p in here.parents if (p/'src/ecs').is_dir())
    delivery=json.loads((here/'DELIVERY.json').read_text())
    for name,row in delivery['artifacts'].items():
        b=(here/name).read_bytes();need(len(b)==row['bytes'] and sha(b)==row['sha256'],'delivery bytes')
    m=json.loads((here/'MANIFEST.json').read_text());need(json.loads((here/'OWNERSHIP.json').read_text())['paths']==m['ownedPaths'],'ownership')
    def current(checkout):
        for rel,digest in m['rootSources'].items():need(sha((checkout/rel).read_bytes())==digest,'selected current source drift')
    current(root)
    with zipfile.ZipFile(here/'EVIDENCE.zip') as z:
        need(len(z.namelist())==len(set(z.namelist())) and set(z.namelist())==set(m['archiveMembers']),'members')
        for name,row in m['archiveMembers'].items():
            b=z.read(name);need(sha(b)==row['sha256'] and len(b)==row['bytes'],'member bytes')
        def read(path,digest):
            row=m['pathHashToMember'][path+'@'+digest]
            need(row['sourcePath']==path and row['sha256']==digest,'full sourcePath identity')
            b=z.read(row['member']);need(sha(b)==digest and len(b)==row['bytes'],'path bytes');return b
        def role_check(role,receipt):
            plan=json.loads(read(role['planPath'],role['planSHA256']));out=Path(role['output']);kind=role['kind'];n=role['scale']
            need(receipt['commands']==role['commands'],'exact admitted command rows')
            need(receipt['status']==('COMPLETE_N4_REPEAT16_V8_PROFILES_VALIDATED' if kind=='profile' else 'PASS'),'status')
            need(receipt['stageReceiptSHA']==(plan['stageReceiptSHA256'] if 'stageReceiptSHA256' in plan else plan['pins'][str(Path(plan['stage'])/'stage.json')]),'stage receipt')
            for path,digest in plan['pins'].items():
                if path in m['externalPins']:need(m['externalPins'][path]==digest,'tool identity')
                else:read(path,digest)
            for name,digest in (receipt['logs']|receipt['artifacts']).items():read(str(out/name),digest)
            oracle=read(role['oraclePath'],role['oracleSHA256']);need(len(oracle)==role['oracleBytes'],'oracle bytes')
            commands=receipt['commands'];need(len(commands)==(4 if kind=='profile' else 3 if kind=='baseline' else 7),'command count')
            expectedcaps=[5]*4 if kind=='profile' else [5,30,5] if kind=='baseline' else [5,30,30,120,5,5,5]
            need([c['cap'] for c in commands]==expectedcaps,'caps')
            need([c['exit'] for c in commands]==([0]*4 if kind=='profile' else [1]+[0]*(len(commands)-1)),'exits')
            for c in commands:
                label=c['label'];paths=[str(out/(label+'.stdout.gz')),str(out/(label+'.stderr'))]
                raw=[]
                for path in paths:raw.append(read(path,receipt['logs'][Path(path).name]))
                stdout=gzip.decompress(raw[0]);stderr=raw[1]
                if kind=='profile' or '-semantic-' in label:
                    need(stdout==oracle*(16 if kind=='profile' else 1),'complete oracle')
                    lines=stderr.splitlines();need(len(lines)==(16 if kind=='profile' else 1),'all timer records')
                    digest=2166136261
                    for b in oracle:digest=((digest^b)*16777619)&0xffffffff
                    for line in lines:
                        timer=json.loads(line);need(set(timer)=={'bytes','digest','elapsedNs'} and timer['bytes']==len(oracle) and timer['digest']==digest and str(int(timer['elapsedNs']))==timer['elapsedNs'],'timer full capture')
            if kind=='profile':
                need(receipt['diagnosticPlanSHA256']==role['planSHA256'] and receipt['repeatCount']==16,'profile plan')
                source=json.loads(read(plan['sourceReceipt'],plan['pins'][plan['sourceReceipt']]));js=Path(plan['sourceJS'])
                need(js.parent==Path(plan['sourceReceipt']).parent and source['artifacts'][js.name]==plan['pins'][str(js)],'full source artifact parent')
                need([c['command'] for c in commands]==[c['argv'] for c in plan['commands']],'profile argv')
            return True
        for role in m['roles'].values():role_check(role,json.loads(read(role['receiptPath'],role['receiptSHA256'])))
        controls=0
        if selftest:
            with tempfile.TemporaryDirectory() as temporary:
                relocated=Path(temporary)
                for rel in m['rootSources']:
                    target=relocated/rel;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes((root/rel).read_bytes())
                current(relocated);controls+=1
                target.write_bytes(target.read_bytes()+b'body-drift')
                try:current(relocated)
                except ValueError:controls+=1
                else:raise ValueError('local drift accepted')
            role=m['roles']['after'];r=json.loads(read(role['receiptPath'],role['receiptSHA256']))
            for kind in ['cap','argv','status','exit']:
                bad=copy.deepcopy(r)
                if kind=='cap':bad['commands'][0]['cap']=6
                if kind=='argv':bad['commands'][0]['command'][-1]='/wrong/repeat-js.js'
                if kind=='status':bad['status']='INCOMPLETE'
                if kind=='exit':bad['commands'][0]['exit']=1
                try:role_check(role,bad)
                except (ValueError,KeyError):controls+=1
                else:raise ValueError('malformed receipt accepted')
            path=role['output']+'/JS-cpu.stdout.gz';digest=r['logs']['JS-cpu.stdout.gz'];key=path+'@'+digest;old=m['pathHashToMember'][key]['sourcePath'];m['pathHashToMember'][key]['sourcePath']='/wrong-parent/JS-cpu.stdout.gz'
            try:read(path,digest)
            except ValueError:controls+=1
            else:raise ValueError('same basename wrong parent accepted')
            m['pathHashToMember'][key]['sourcePath']=old
    return {'status':'PASS','members':len(m['archiveMembers']),'roles':5,'malformedControls':controls,'timingAcceptance':False}
if __name__=='__main__':print(json.dumps(verify(Path(__file__).resolve().parent,'--selftest' in sys.argv),sort_keys=True))
