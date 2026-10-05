"""Source-only nested receipt controls; synthetic records are not runtime evidence."""
import copy,hashlib,importlib.util,json,sys,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];HERE=ROOT/'experiments/s-prep/fivehour-connected-gates';sys.path.insert(0,str(HERE))
spec=importlib.util.spec_from_file_location('checks',HERE/'checks.py');C=importlib.util.module_from_spec(spec);spec.loader.exec_module(C)
overlay=Path(sys.argv[1]).resolve();core=overlay/'experiments/s-integrate';status='PASS_LIVE_NOOP_TRUEOLD_JOURNAL_MARK_FULLFIELDS_BOTH';results=[]
with tempfile.TemporaryDirectory(prefix='nested-owner-source-controls-') as directory:
 folder=Path(directory);receipt=folder/'evidence.json';baseline=folder/'baseline.json';records=[{'syntheticValidatorFixture':i} for i in range(144)]
 sources={'overlaySHA256':overlay/'overlay.json','heldAdapterSHA256':core/'held-adapter.bend','cachedPayloadSHA256':core/'cached-payload.bend','fixtureSHA256':HERE/'tx-controls.bend','protectedRawSHA256':ROOT/'experiments/s-integrate/payload.bend','adapterSHA256':HERE/'suppressed-owner.py','fusedAdapterSHA256':HERE/'fused-adaptation.py'}
 binding=C.source_binding(overlay)
 evidence={'status':status,'records':144,'liveMutationSites':['motion_set_fused_done','health_set_fused_done'],'sourcePins':{k:C.sha(v) for k,v in sources.items()},'sourceFiles':{str(v):C.sha(v) for v in sources.values()},'runtimeSources':binding['runtimeSources'],'runtimeClosureSHA256':binding['runtimeClosureSHA256'],'rawObserverFiles':{str(v):C.sha(v) for v in sources.values()},'rawObserverPins':{mode:{'CP':C.sha(core/'cached-payload.bend'),'protectedRaw':C.sha(ROOT/'experiments/s-integrate/payload.bend'),'HA':C.sha(core/'held-adapter.bend'),'callbacks':C.sha(HERE/'tx-controls.bend')} for mode in ('cached','raw')},'expectedRecordsSHA256':hashlib.sha256(json.dumps(records,sort_keys=True,separators=(',',':')).encode()).hexdigest(),'cases':[]}
 for mode in ('cached','raw'):
  for backend in ('Native','JS'):
   raw=folder/(mode+backend+'.jsonl');raw.write_text('\n'.join(map(json.dumps,records))+'\n');program=folder/(mode+backend+'.program');program.write_text('Synthetic pin fixture, not executable.');source=folder/(mode+backend+'.bend');source.write_text('Synthetic source pin fixture.');evidence['cases'].append(dict(getter=mode,backend=backend,records=144,compiling=True,exactNoopFullfieldsEffects=True,trueOldJournalPreserved=True,journalPreserved=True,marksPreserved=True,outputPath=str(raw),outputSHA256=C.sha(raw),programs=[dict(programPath=str(program),programSHA256=C.sha(program),sourcePath=str(source),sourceSHA256=C.sha(source),records=144,schema='both')]))
 def publish(data):
  receipt.write_text(json.dumps(data));baseline.write_text(json.dumps({'suppressedOwner':{'status':status,'receipt':str(receipt),'receiptSHA256':C.sha(receipt),'overlaySHA256':data['sourcePins']['overlaySHA256']}}))
 publish(evidence);C.validate_suppressed_owner(baseline,overlay);results.append({'case':'synthetic-valid-receipt','result':'PASS'})
 for name,mutate in [('missing-nested',lambda d:d.update(status='INCOMPLETE')),('missing-case',lambda d:d['cases'].pop()),('false-journal',lambda d:d['cases'][0].update(journalPreserved=False)),('runtime-repin',lambda d:d['runtimeSources'].update({'experiments/s-integrate/query.bend':'0'*64})),('wrong-fields-hash',lambda d:d.update(expectedRecordsSHA256='0'*64))]:
  changed=copy.deepcopy(evidence);mutate(changed);publish(changed)
  try:C.validate_suppressed_owner(baseline,overlay)
  except (AssertionError,KeyError,ValueError):results.append({'case':name,'result':'REJECTED'})
  else:raise RuntimeError('Missed '+name)
 publish(evidence);receipt.write_text(receipt.read_text()+' ')
 try:C.validate_suppressed_owner(baseline,overlay)
 except AssertionError:results.append({'case':'tampered-nested-bytes','result':'REJECTED'})
 else:raise RuntimeError('Missed receipt tamper')
 publish(evidence);Path(evidence['cases'][0]['outputPath']).write_text('{}\n')
 try:C.validate_suppressed_owner(baseline,overlay)
 except AssertionError:results.append({'case':'tampered-raw-output','result':'REJECTED'})
 else:raise RuntimeError('Missed raw tamper')
 baseline.write_text('{}')
 try:C.validate_suppressed_owner(baseline,overlay)
 except AssertionError:results.append({'case':'absent-subreceipt','result':'REJECTED'})
 else:raise RuntimeError('Missed absent receipt')
print(json.dumps({'status':'SOURCE_ONLY_NESTED_ENFORCEMENT_CONTROLS_PASS','scope':'Synthetic receipt-validator controls, no executable semantic or timing claim','cases':results},indent=2))
