#!/usr/bin/env python3
"""Fail-closed general query frozen-provider source-only overlay."""
import argparse,hashlib,json,pathlib,shutil
HERE=pathlib.Path(__file__).resolve().parent
EXPECTED_INPUT_CLOSURE='857255d8ddf64fd5c9c91dcb99273f86b0605eb0e219cfbf49b762011e325787'
TARGETS=['experiments/s-integrate/query.bend','experiments/s-integrate/observations.bend','experiments/s-integrate/measurement-bend.bend','experiments/s-integrate/host.bend','experiments/s-integrate/audited-invoker.bend']
def digest(data):return hashlib.sha256(data).hexdigest()
def closure(pins):return digest(json.dumps(pins,sort_keys=True,separators=(',',':')).encode())
def bodies(text):
 return '\n'.join(l.replace('~','') for l in text.splitlines() if not l.startswith(('def ','  -P: Type,-U: Type,main_get:','  ~P: Type,~U: Type,~main_get:','  aux_get: U ->','  ~aux_get: U ->')))
def materialize(source,output):
 source=source.resolve(strict=True);output=output.absolute();assert not output.exists();assert not output.is_relative_to(source)
 overlay=json.loads((source/'overlay.json').read_text());cache=json.loads((source/'cache-specialization.json').read_text())
 pins={str(p.relative_to(source)):digest(p.read_bytes()) for p in source.rglob('*.bend')};assert len(pins)==29;assert pins==overlay['sources']==cache['runtimeClosure']==cache['specializedClosure'];assert cache['runtimeClosureSHA256']==closure(pins);assert closure(pins)==EXPECTED_INPUT_CLOSURE,'Unsupported input closure'
 shutil.copytree(source,output)
 q=output/TARGETS[0];old=q.read_text();needle='@-P: Type -> @-U: Type -> (P -> Tok -> P & V) -> (U -> U & Maybe<&2,AV>) ->'
 assert old.count(needle)==20,old.count(needle)
 new=old.replace(needle,'@-P: Type -> @-U: Type -> @-get: (P -> Tok -> P & V) -> @-ag: (U -> U & Maybe<&2,AV>) ->');assert bodies(old)==bodies(new);q.write_text(new)
 o=output/TARGETS[1];old=o.read_text();new=old.replace('def client_main(-Schema: Data,-P: Type,-U: Type,-V: Data,-AV: Data,-F: Data,','def client_main(~Schema: Data,~P: Type,~U: Type,~V: Data,~AV: Data,~F: Data,').replace('  aux_get: U -> U & Maybe<&2,AV>,handle:', '  ~aux_get: U -> U & Maybe<&2,AV>,handle:').replace('  -P: Type,-U: Type,main_get: P -> Tok -> P & V,aux_get:', '  ~P: Type,~U: Type,~main_get: P -> Tok -> P & V,~aux_get:').replace('client_main(Schema,P,U,V,AV,F,aux_get,','client_main(~Schema,~P,~U,~V,~AV,~F,~aux_get,')
 assert new!=old;assert bodies(old)==bodies(new);o.write_text(new)
 m=output/TARGETS[2];old=m.read_text();new=old.replace('-Owner:Type,-Aux:Type,get:Owner -> Unit -> Owner & Unit,ag:', '~Owner:Type,~Aux:Type,~get:Owner -> Unit -> Owner & Unit,~ag:');assert new!=old;assert bodies(old)==bodies(new);m.write_text(new)
 h=output/TARGETS[3];old=h.read_text();needle='@-Owner:Type -> @-Aux:Type -> (Owner -> Tok -> Owner & V) -> (Aux -> Aux & Maybe<&2,AV>) ->'
 assert old.count(needle)==10,old.count(needle)
 new=old.replace(needle,'@-Owner:Type -> @-Aux:Type -> @-get:(Owner -> Tok -> Owner & V) -> @-ag:(Aux -> Aux & Maybe<&2,AV>) ->');assert bodies(old)==bodies(new);h.write_text(new)
 a=output/TARGETS[4];old=a.read_text();new=old.replace('def motion_lookup_client(-Main:Type,-Aux:Type,get:','def motion_lookup_client(~Main:Type,~Aux:Type,~get:').replace('def health_lookup_client(-Main:Type,-Aux:Type,get:','def health_lookup_client(~Main:Type,~Aux:Type,~get:')
 new=new.replace('Main & T.PositionView,aux_get:Aux ->','Main & T.PositionView,~aux_get:Aux ->').replace('Main & T.VitalsView,aux_get:Aux ->','Main & T.VitalsView,~aux_get:Aux ->');assert bodies(old)==bodies(new);a.write_text(new)
 newpins={str(p.relative_to(output)):digest(p.read_bytes()) for p in output.rglob('*.bend')};assert sorted(n for n in pins if pins[n]!=newpins[n])==sorted(TARGETS)
 cache['runtimeClosure']=newpins;cache['specializedClosure']=newpins.copy();cache['runtimeClosureSHA256']=closure(newpins);overlay['sources']=newpins;overlay['cacheSpecialization']=cache
 receipt={'status':'SOURCE_ONLY_UNMEASURED','variant':'general-frozen-query-providers-v1','inputSources':pins,'sources':newpins,'inputClosureSHA256':closure(pins),'outputClosureSHA256':closure(newpins),'changedModules':TARGETS,'callbackAlgorithmTokensUnchangedIgnoringFreezeMarkers':True,'handleAndAuditedCallbackBodyBytesUnchanged':True,'transportSyntaxChanges':['observations.client helper call adds leading~markers'],'runtimeModules':29,'performanceAcceptance':False,'fullGatesComplete':False}
 for n,v in [('overlay.json',overlay),('cache-specialization.json',cache),('query-frozen-provider.json',receipt)]:(output/n).write_text(json.dumps(v,indent=2)+'\n')
 return output/'experiments/s-integrate'
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--input',type=pathlib.Path,required=True);p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();print(materialize(a.input,a.output))
