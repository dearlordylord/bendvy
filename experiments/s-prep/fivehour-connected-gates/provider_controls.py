"""Fail-closed runtime membership and live erased-provider callback controls."""
import hashlib,json,re
from pathlib import Path

BASE_MODULES=frozenset('''audited-invoker.bend cache.bend cached-payload.bend capture.bend commands.bend dispatcher.bend held-adapter.bend held.bend host-observations.bend host-render.bend host.bend identity.bend measurement-bend.bend observations.bend payload.bend query.bend raw-boundaries.bend reader-host.bend readers.bend schedule.bend storage.bend streams.bend structural-invoker.bend systems.bend transaction-dispatch-adapters.bend transaction.bend types.bend uncached-payload.bend'''.split())
STATIC_MODULE='prototype-static-client.bend'
CALLBACK_NAMES=('first','sum','motion_body_ledger','motion_body_read','motion_body','health_body_ledger','health_body_read','health_body')
ROOT=Path(__file__).resolve().parents[3]
def sha(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def definitions(text):
    entries=list(re.finditer(r'^def ([\w.]+)\([^\n]*\n(?:(?!^(?:def |type |import |#)).*\n)*',text,re.M))
    names=[m[1] for m in entries];assert len(names)==len(set(names)),'Duplicate callback definition'
    return {m[1]:m[0] for m in entries}
def normalized_algorithm(block):
    # Only erased template binding/call markers and formatting differ. No
    # identifier, operation, branch, literal or field rewrite is permitted.
    return re.sub(r'\s+','',block.replace('~','').replace('-Owner:Type','Owner:Type'))
def static_registration(core):
    core=Path(core);measurement=(core/'measurement-bend.bend').read_text();static=core/STATIC_MODULE
    has_import='import ./'+STATIC_MODULE+' as SC\n' in measurement
    if not static.exists():
        assert not has_import and '~SC.motion_body' not in measurement and '~SC.health_body' not in measurement,'Missing live static callback module'
        return False
    assert has_import,'Static module present without measured registration'
    for lane in ('motion','health'):
        assert measurement.count('HA.'+lane+'_row(~SC.'+lane+'_body,')==1,'Static measured callback absent/ambiguous'
        assert 'HA.'+lane+'_row(~'+lane+'_body,' not in measurement,'Unused dynamic callback remains measured'
    original=definitions(measurement);actual=definitions(static.read_text())
    assert set(actual)==set(CALLBACK_NAMES),'Unexpected static client definitions'
    pins=json.loads((ROOT/'experiments/s-prep/owned-write-query-integration/prepare-evidence.json').read_text())['callbackFunctionSHA256']
    assert all(hashlib.sha256(original[n].encode()).hexdigest()==v for n,v in pins.items()),'Original opaque callback bytes changed'
    for name in CALLBACK_NAMES:
        assert normalized_algorithm(actual[name])==normalized_algorithm(original[name]),'Static callback algorithm differs: '+name
        if name not in ('first','sum'):
            assert actual[name].startswith('def '+name+'(~Owner:Type,'),'Static owner binder changed'
            original_header=original[name].splitlines()[0];actual_header=actual[name].splitlines()[0]
            for provider in ('get','set','ledger','setledger'):
                if re.search(r'(?<=[,(])'+provider+r':',original_header):
                    assert '~'+provider+':' in actual_header,'Static provider binder changed: '+name+':'+provider
    held=(core/'held-adapter.bend').read_text()
    for lane in ('motion','health'):
        for suffix in ('invoke','taken','checked','row'):
            header=next(line for line in held.splitlines() if line.startswith('def '+lane+'_'+suffix+'('))
            for provider in ('get','set','ledger','setledger'):
                assert '@-'+provider+':' in header,'Erased provider registration differs: '+lane+'_'+suffix
    return True

def runtime_sources(overlay):
    overlay=Path(overlay).resolve();manifest=json.loads((overlay/'overlay.json').read_text());seen={}
    def visit(source):
        assert not source.is_symlink();source=source.resolve();assert source.is_relative_to(overlay),'Runtime import escaped overlay'
        relative=source.relative_to(overlay).as_posix()
        if relative in seen:return
        assert relative in manifest['sources'],'Actual runtime member absent from manifest'
        pin=sha(source);assert pin==manifest['sources'][relative],'Runtime source pin changed';seen[relative]=pin
        for name in re.findall(r'^import (\S+)',source.read_text(),re.M):
            if name=='Base':continue
            assert name.startswith('./') and name.endswith('.bend'),'Unsupported runtime import'
            visit(source.parent/name)
    core=overlay/'experiments/s-integrate';is_static=static_registration(core)
    visit(core/'measurement-bend.bend')
    expected={'experiments/s-integrate/'+name for name in BASE_MODULES|({STATIC_MODULE} if is_static else set())}
    assert set(seen)==expected,'Exact checked runtime closure membership differs'
    cache=json.loads((overlay/'cache-specialization.json').read_text())
    assert cache['runtimeClosure']==seen,'Recipe runtime membership/hash ledger differs'
    digest=hashlib.sha256(json.dumps(seen,sort_keys=True,separators=(',',':')).encode()).hexdigest()
    assert digest==cache['runtimeClosureSHA256'],'Recipe runtime closure digest differs'
    return dict(sorted(seen.items()))

def extract_callbacks(core):
    core=Path(core);full=(core/'measurement-bend.bend').read_text();original=definitions(full)
    pins=json.loads((ROOT/'experiments/s-prep/owned-write-query-integration/prepare-evidence.json').read_text())['callbackFunctionSHA256']
    assert all(hashlib.sha256(original[n].encode()).hexdigest()==v for n,v in pins.items()),'Original callback bytes changed'
    is_static=static_registration(core)
    text=(core/STATIC_MODULE).read_text() if is_static else 'import Base\nimport ./types.bend as T\n'+''.join(original[n] for n in CALLBACK_NAMES)
    (core/'gate-callbacks.bend').write_text(text)
    return {'mode':'ACTUAL_ERASED_PROVIDER_CLIENT' if is_static else 'ORIGINAL_DYNAMIC_CLIENT','originalCallbackDefinitionPins':pins,'consumedCallbackSHA256':hashlib.sha256(text.encode()).hexdigest(),'sourceCallbackModule':STATIC_MODULE if is_static else 'measurement-bend.bend'}

def adapt_metadata_fixture(text,core):
    """Translate only the two original constructed rows, preserving every field."""
    primitive='type MetadataColumns<-F: Data> is Type:' in (Path(core)/'storage.bend').read_text()
    if not primitive:return text,None
    changes=[]
    for flag in ('Selected','Tracked'):
        before='ANode{ALeaf{S.Metadata{True{},Some{T.'+flag+'{8}},3,4}},ALeaf{S.Metadata{second_live(scenario),None{},5,6}}}'
        after='S.MetadataColumns{ANode{ALeaf{True{}},ALeaf{second_live(scenario)}},ANode{ALeaf{Some{T.'+flag+'{8}}},ALeaf{None{}}},ANode{ALeaf{3},ALeaf{5}},ANode{ALeaf{4},ALeaf{6}}}'
        assert text.count(before)==1,'Original metadata construction missing/ambiguous: '+flag
        text=text.replace(before,after)
        changes.append({'flag':flag,'before':before,'after':after})
    assert 'S.Metadata{' not in text,'Unadapted metadata construction'
    return text,{'scope':'Constructed fixture representation only; original live/flag/tick values and scenario functions unchanged','changes':changes,'adapterSHA256':sha(Path(__file__))}

def adapt_tx_fixture(text,is_static):
    if not is_static:return text
    for lane in ('motion','health'):
        lines=text.splitlines(keepends=True);sites=0
        for i,line in enumerate(lines):
            if line.lstrip().startswith('M.'+lane+'_body(X.Tx<'):
                changed=line.replace('M.'+lane+'_body(X.Tx<','M.'+lane+'_body(~X.Tx<',1)
                for provider in ('read_main','set_main0','read_ledger','set_ledger0'):
                    needle=',A.'+lane+'_'+provider
                    assert changed.count(needle)==1,'Point provider call changed'
                    changed=changed.replace(needle,',~A.'+lane+'_'+provider,1)
                lines[i]=changed;sites+=1
        assert sites==1,'Actual point client fixture absent/ambiguous'
        text=''.join(lines)
    return text
