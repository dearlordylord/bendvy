#!/usr/bin/env python3
"""Offline complete-output/command/stage/model joins; starts no consumer."""
import copy,gzip,hashlib,json,pathlib,random,re,statistics,sys,zipfile
HERE=pathlib.Path(__file__).resolve().parent
SHA=lambda raw:hashlib.sha256(raw).hexdigest()
BEND='/home/node/.bend/bin/bend-2.0.35'
NODE='/home/node/.local/share/mise/installs/node/24.20.0/bin/node'
CLANG='/tmp/bendvy-clang19-diagnostic/clang19'

def fnv(raw):
    value=2166136261
    for byte in raw:value=((value^byte)*16777619)&0xffffffff
    return value

def expected_commands(stage,attempt):
    output=attempt['path'];commands=[];generator=random.Random(20261007)
    for feature in attempt['features']:
        for scale in attempt['scales']:
            name=f'{feature}-{scale}';entry=stage['path']+'/stage/feature-harness/'+name
            commands.extend([(name+'-check',[BEND,entry+'.bend','--check-only'],5,1),(name+'-emit-JS',[BEND,entry+'.bend','-o',output+'/'+name+'.js'],30,0),(name+'-emit-Native',[BEND,entry+'.bend','-o',output+'/'+name+'.c'],30,0),(name+'-compile',[CLANG,'-O3',output+'/'+name+'.c','-o',output+'/'+name,'-pthread','-lm'],120,0)])
            backends={'TS':[NODE,entry+'.mjs'],'JS':[NODE,output+'/'+name+'.js'],'Native':[output+'/'+name,'--threads','1','--gpu','off']}
            if attempt.get('kind')=='comparative':
                prefix=['/usr/bin/taskset','-c','11']
                for backend in backends:
                    for warmup in range(2):commands.append((f'{name}-{backend}-warmup{warmup}',prefix+backends[backend],5,0))
                for backend in ['JS','Native']:
                    orders=[['TS',backend]]*10+[[backend,'TS']]*10;generator.shuffle(orders)
                    for index,order in enumerate(orders):
                        for role in order:commands.append((f'{name}-{backend}-pair{index}-{role}',prefix+backends[role],5,0))
            else:
                for backend,argv in backends.items():commands.append((name+'-semantic-'+backend,argv,5,0))
    return commands

def expected_output(feature,scale,manifest,read):
    row=manifest['oracles'][f'{feature}:{scale}'];return read(row)

def check_attempt(receipt,attempt,manifest,read):
    stage=manifest['stages'][attempt.get('stage','baseline')];comparative=attempt.get('kind')=='comparative'
    assert receipt['status']==('COMPLETE_FEATURE_OBSERVATIONS' if comparative else 'PASS')
    assert receipt['stageReceiptSHA']==stage['metadata']['sha256']
    if not comparative:assert receipt['features']==attempt['features'] and receipt['scales']==attempt['scales']
    assert receipt['childEnvironmentFixed']=={'BEND_NO_TELEMETRY':'1'}
    expected=expected_commands(stage,attempt);assert len(receipt['commands'])==len(expected)
    for actual,(label,argv,cap,exitcode) in zip(receipt['commands'],expected):assert actual=={'label':label,'command':argv,'cap':cap,'exit':exitcode}
    labels=[row[0] for row in expected];logs={label+suffix for label in labels for suffix in ['.stdout.gz','.stderr']}
    artifacts={f'{feature}-{scale}'+suffix for feature in attempt['features'] for scale in attempt['scales'] for suffix in ['.js','.c','']}
    assert set(receipt['logs'])==logs and set(receipt['artifacts'])==artifacts
    assert set(attempt['files'])==logs|artifacts|{'receipt.json'}
    for name,digest in {**receipt['logs'],**receipt['artifacts']}.items():
        row=attempt['files'][name];assert row['path']==attempt['path']+'/'+name and row['sha256']==digest;assert SHA(read(row))==digest
    assert receipt['installedTools']['pins']==manifest['installedTools']['pins']
    assert {k:v for k,v in receipt['installedTools']['environment'].items() if k!='processAffinity'}=={k:v for k,v in manifest['installedTools']['environment'].items() if k!='processAffinity'}
    regions={};outputs=0
    for label,_,_,_ in expected:
        stdout=gzip.decompress(read(attempt['files'][label+'.stdout.gz']));stderr=read(attempt['files'][label+'.stderr'])
        if label.endswith('-check'):
            assert stdout==b'' and b'defs rely on unsafe or foreign code' in stderr and b'timing.capture' in stderr
        elif label.endswith(('-emit-JS','-emit-Native','-compile')):assert stdout==stderr==b''
        else:
            feature=next(f for f in sorted(attempt['features'],key=len,reverse=True) if label.startswith(f+'-'))
            scale=int(label[len(feature)+1:].split('-',1)[0]);assert stdout==expected_output(feature,scale,manifest,read)
            region=json.loads(stderr);assert set(region)=={'elapsedNs','bytes','digest'}
            assert isinstance(region['elapsedNs'],str) and re.fullmatch('0|[1-9][0-9]*',region['elapsedNs'])
            assert type(region['bytes']) is int and region['bytes']==len(stdout) and type(region['digest']) is int and region['digest']==fnv(stdout)
            regions[label]=region;outputs+=1
    if comparative:
        assert receipt['pairs']==20 and receipt['warmups']==2 and receipt['cpu']==11
        assert len(receipt['observations'])==40*len(attempt['features'])*len(attempt['scales']) and len(receipt['summary'])==2*len(attempt['features'])*len(attempt['scales'])
        expected_summaries=[];index=0
        for feature in attempt['features']:
            for scale in attempt['scales']:
                name=f'{feature}-{scale}'
                for backend in ['JS','Native']:
                    ratios=[]
                    for pair in range(20):
                        row=receipt['observations'][index];index+=1
                        assert (row['feature'],row['lifecycles'],row['backend'],row['pair'])==(feature,scale,backend,pair)
                        order=[label.rsplit('-',1)[-1] for label,_,_,_ in expected if label.startswith(f'{name}-{backend}-pair{pair}-')]
                        assert row['order']==order and set(row['regions'])=={'TS',backend}
                        for role in order:assert row['regions'][role]==regions[f'{name}-{backend}-pair{pair}-{role}']
                        assert int(row['regions']['TS']['elapsedNs'])>0
                        ratio=int(row['regions'][backend]['elapsedNs'])/int(row['regions']['TS']['elapsedNs']);assert row['ratio']==ratio;ratios.append(ratio)
                        for phase in ['before','after']:assert 'loadavg' in row[phase] and row[phase]['cpuStat'].startswith('cpu11 ')
                    expected_summaries.append({'feature':feature,'lifecycles':scale,'backend':backend,'medianPairedRatio':statistics.median(ratios),'minimum':min(ratios),'maximum':max(ratios),'allPairedRatios':ratios})
        assert receipt['summary']==expected_summaries
    return outputs

def main():
    delivery=json.loads((HERE/'DELIVERY.json').read_text())
    assert set(delivery['files'])=={'EVIDENCE.zip','MANIFEST.json','OWNERSHIP.json','README.md','RESULT.json','verify.py'}
    for name,digest in delivery['files'].items():assert SHA((HERE/name).read_bytes())==digest
    manifest=json.loads((HERE/'MANIFEST.json').read_text())
    with zipfile.ZipFile(HERE/'EVIDENCE.zip') as archive:
        assert len(archive.namelist())==len(set(archive.namelist())) and set(archive.namelist())==set(manifest['members'])
        for name,row in manifest['members'].items():
            raw=archive.read(name);assert SHA(raw)==row['sha256'] and len(raw)==row['bytes']
        def read(row):
            binding=manifest['pathHashToMember'][row['path']+'@'+row['sha256']];assert binding['sourcePath']==row['path'] and binding['sha256']==row['sha256']
            raw=archive.read(binding['member']);assert SHA(raw)==row['sha256'];return raw
        for stage in manifest['stages'].values():
            meta=json.loads(read(stage['metadata']));assert meta['namedSchedules'] is True and meta['scales']==[1,2,4]
            for key,target in [('stageInventory','files'),('sources','sources'),('external','external')]:
                assert set(meta[key])==set(stage[target])
                for path,digest in meta[key].items():assert SHA(read(stage[target][path]))==digest
        outputs=0;commands=0
        for attempt in manifest['attempts']:
            assert attempt['outerExit']==0 and attempt['files']['receipt.json']==attempt['receipt']
            receipt=json.loads(read(attempt['receipt']));outputs+=check_attempt(receipt,attempt,manifest,read);commands+=len(receipt['commands'])
        profile_count=0
        for item in manifest['profiles']:
            plan=json.loads(read(item['plan']));r=json.loads(read(item['receipt']));stage=manifest['stages'][item['stage']]
            assert r['status']=='FULL_NAMED_PLAN_JS_PROFILES_VALIDATED' and r['stageReceiptSHA']==stage['metadata']['sha256']
            assert r['consumedSourcePins']==plan['pins']
            for path,digest in plan['pins'].items():read({'path':path,'sha256':digest})
            profile_commands=[]
            for program in plan['programs']:
                n=program['scale'];path=program['path'];assert SHA(read({'path':path,'sha256':program['sha256']}))==program['sha256']
                sourcePath=program.get('sourceReceipt',plan.get('pairedReceipt'));source=json.loads(read({'path':sourcePath,'sha256':plan['pins'][sourcePath]}))
                assert str(pathlib.Path(path).parent)==str(pathlib.Path(sourcePath).parent) and source['artifacts'][pathlib.Path(path).name]==program['sha256']
                assert source['stageReceiptSHA']==stage['metadata']['sha256'] and source['status']==('PASS' if 'sourceReceipt' in program else 'COMPLETE_FEATURE_OBSERVATIONS')
                assert source['installedTools']['pins']==r['installedTools']['pins']
                se=source['installedTools']['environment'];ce=r['installedTools']['environment']
                assert {k:v for k,v in se.items() if k!='processAffinity'}=={k:v for k,v in ce.items() if k!='processAffinity'}
                assert ce['processAffinity']==[11] and se['processAffinity']==([5] if 'sourceReceipt' in program else [11])
                allocation=next(p for p in plan['pins'] if p.endswith('/allocate.mjs'))
                profile_commands.extend([(f'cpu-scale{n}',['/usr/bin/taskset','-c','11',NODE,'--cpu-prof','--cpu-prof-interval=100','--cpu-prof-dir='+item['path'],f'--cpu-prof-name=cpu-scale{n}.cpuprofile',path]),(f'allocation-scale{n}',['/usr/bin/taskset','-c','11',NODE,allocation,path,item['path']+f'/allocation-scale{n}.heapprofile'])])
            assert r['commands']==[{'label':label,'command':argv,'cap':5,'exit':0} for label,argv in profile_commands]
            assert set(r['logs'])=={label+suffix for label,_ in profile_commands for suffix in ['.stdout.gz','.stderr']}
            assert set(r['artifacts'])=={f'{kind}-scale{n}.'+('cpuprofile' if kind=='cpu' else 'heapprofile') for n in [1,4] for kind in ['cpu','allocation']}
            assert set(item['files'])==set(r['logs'])|set(r['artifacts'])|{'receipt.json'}
            for name,digest in {**r['logs'],**r['artifacts']}.items():
                row=item['files'][name];assert row['path']==item['path']+'/'+name and row['sha256']==digest;read(row)
            for label,_ in profile_commands:
                n=int(label[-1]);stdout=gzip.decompress(read(item['files'][label+'.stdout.gz']));assert stdout==expected_output('named-schedules',n,manifest,read)
                region=json.loads(read(item['files'][label+'.stderr']));assert region['bytes']==len(stdout) and region['digest']==fnv(stdout) and re.fullmatch('0|[1-9][0-9]*',region['elapsedNs'])
                profile_count+=1
        portable=json.loads(read(manifest['portabilityControl']));assert portable['status']=='PASS_RELOCATED_COPY_AND_LOCAL_DRIFT_REFUSAL' and portable['positive']['exit']==0 and portable['negative']['exit']!=0
        for row in manifest['history']:read(row)
        for row in manifest['candidateSourcesArchiveOnly']:read(row)
        read(manifest['candidatePatchArchiveOnly'])
        failed=next(row for row in manifest['history'] if row['path']=='/tmp/bendvy56-named-schedules-1-profiles-actual01/receipt.json');failure=json.loads(read(failed))
        assert failure['status']=='INCOMPLETE' and failure['commands']==[] and failure['artifacts']=={} and failure['logs']=={} and failure['diagnosticChildrenStarted']==0
        for i,row in enumerate(manifest['models']):
            module=type(sys)('named_mode_model_'+str(i));sys.modules[module.__name__]=module;exec(compile(read(row['source']),row['source']['path'],'exec'),module.__dict__)
            basis=json.loads(read(row['basis']))
            for path,digest in basis['sourceInventory'].items():read({'path':path,'sha256':digest})
            for scale in [1,2,4]:
                if row['kind']=='complete':assert module.generate(scale)==expected_output('named-schedules',scale,manifest,read)
                else:
                    for mode in ['enabled','disabled']:assert module.generate_mode(scale,mode=='enabled')==expected_output('named-schedules-'+mode,scale,manifest,read)
        controls=0;attempt=manifest['attempts'][0];receipt=json.loads(read(attempt['receipt']))
        edits=[lambda x:x['commands'].pop(),lambda x:x['commands'].append(x['commands'][0]),lambda x:x['commands'].reverse(),lambda x:x['commands'][0].update(cap=6),lambda x:x['commands'][1]['command'].__setitem__(1,str(pathlib.Path(x['commands'][1]['command'][1]).parent.parent/'wrong-parent'/pathlib.Path(x['commands'][1]['command'][1]).name)),lambda x:x['logs'].pop(next(iter(x['logs']))),lambda x:x['artifacts'].pop(next(iter(x['artifacts']))),lambda x:x.update(stageReceiptSHA='0'*64)]
        for edit in edits:
            bad=copy.deepcopy(receipt);edit(bad)
            try:check_attempt(bad,attempt,manifest,read)
            except (AssertionError,KeyError,ValueError,IndexError):controls+=1
            else:raise AssertionError('malformed receipt accepted')
        row=attempt['files'][next(name for name in attempt['files'] if '-semantic-Native.stdout.gz' in name)];key=row['path']+'@'+row['sha256'];original=manifest['pathHashToMember'][key]['sourcePath'];manifest['pathHashToMember'][key]['sourcePath']=str(pathlib.Path(original).parent.parent/'wrong-parent'/pathlib.Path(original).name)
        try:check_attempt(receipt,attempt,manifest,read)
        except AssertionError:controls+=1
        else:raise AssertionError('manifest wrong-parent accepted')
        finally:manifest['pathHashToMember'][key]['sourcePath']=original
        ownership=json.loads((HERE/'OWNERSHIP.json').read_text());repo=HERE.parents[4].resolve()
        for row in manifest['rootSources']:
            relative=pathlib.Path(row['repoPath']);assert not relative.is_absolute() and '..' not in relative.parts and row['repoPath'] in ownership['paths']
            target=repo/relative;assert target.resolve().is_relative_to(repo) and target.is_file() and target.read_bytes()==read(row)
        for name in ownership['paths']:
            relative=pathlib.Path(name);target=repo/relative
            assert not relative.is_absolute() and '..' not in relative.parts and target.resolve().is_relative_to(repo) and target.is_file()
    print('PASS_RETAINED_NAMED_MODES',len(manifest['members']),'members;',commands,'commands;',outputs,'completeoutputs;',profile_count,'profileoutputs;',controls,'malformedcontrols')
if __name__=='__main__':main()
