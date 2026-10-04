#!/usr/bin/env python3
"""New fair-lane subject; old guarded evidence untouched."""
import pathlib,shutil,re,json,hashlib
H=pathlib.Path(__file__).resolve().parent;D=H/'failure-quiet-overlay';S=H/'failure-indexed-overlay'
shutil.copytree(S,D,dirs_exist_ok=True)
p=D/'experiments/s-integrate/measurement-failure-observe.bend';s=p.read_text()
for lane,sc in [('motion','Motion'),('health','Health')]:
 s=s.replace(f'{lane}_guard(FV.{lane}(FV.seed_count(T.{sc}Schema,bindings),iteration,step,rows,lookups,ledger),D.Invoked',f'IO.pure(D.Invoked<F.{sc}Failure,S.Handle<T.{sc}Schema>>,D.Invoked')
p.write_text(s)
p=D/'experiments/s-integrate/measurement-failure-host.bend';s=p.read_text()
for lane in ['motion','health']:
 # Remove only the extra finite service value guard; retain actual invoker/finish.
 line=next(x for x in s.splitlines() if 'FG.guard(' in x and f'F.{lane}_invoke' in x)
 prefix=line[:line.index('result =>')];suffix=line[line.index(f'checked => H.{lane}_service')+len('checked => '):]
 suffix=suffix.replace('checked)))','result))')
 s=s.replace(line,prefix+'result => '+suffix)
 line=next(x for x in s.splitlines() if x.strip().startswith(lane+'_read_guard(FV.read'))
 start=line.index('unit => ')+len('unit => ');body=line[start:];assert body.endswith('))');s=s.replace(line,'      '+body[:-1])
p.write_text(s)
p=D/'experiments/s-integrate/dispatcher.bend';s=p.read_text();s=s.replace('case Recorded{effects}: recorded_audit(Nat.is_le(String.length(text),100n),effects,text)','case Recorded{effects}: IO.pure(Audit,Recorded{text <> effects})');p.write_text(s)
# Codec imports this exact nominal copy, not unrelated constructor aliases.
p=H/'failure-quiet-codec.bend';s=p.read_text().replace('failure-indexed-overlay/','failure-quiet-overlay/');p.write_text(s)
report={'parent_manifest_sha256':hashlib.sha256((H/'failure-indexed-manifest.json').read_bytes()).hexdigest(),'removed_timed_guards':['observation finite expected fields','service finite expected fields','reader finite expected clock/values','Audit finite length guard'],'source_sha256':{str(p.relative_to(D)):hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(D.rglob('*.bend'))}}
(H/'failure-quiet-manifest.json').write_text(json.dumps(report,indent=2)+'\n')
