"""Exact live fused-writer recognition and control-only mutations."""
import re

WRITERS=(('motion','position','Position','PositionView'),('health','vitals','Vitals','VitalsView'))
RAW_HELPERS=('position','vitals','motion_ledger','health_ledger')

def defs(text):
    entries=list(re.finditer(r'^def ([A-Za-z0-9_]+)[\s\S]*?(?=^def |\Z)',text,re.M))
    names=[m[1] for m in entries]
    assert len(names)==len(set(names)),'duplicate definitions'
    return {m[1]:m[0] for m in entries}

def fused_presence(text,cached_text=None):
    d=defs(text)
    helpers=[p+'_'+op+'_fused_done' for p in ('motion','health') for op in ('set','setledger')]
    present=[n in d for n in helpers]
    raw_present=[] if cached_text is None else ['prototype_'+n+'_raw_swap' in defs(cached_text) for n in RAW_HELPERS]
    assert not any(present) or all(present),'partial fused catalog: no generic fallback'
    assert not any(raw_present) or all(raw_present),'partial fused Raw catalog'
    if not any(present):
        assert not any(raw_present) and not any('P.prototype_'+n+'_raw_swap(' in text for n in RAW_HELPERS),'unrecognized live fused Raw path'
        return False
    if cached_text is not None:assert all(raw_present),'fused done without Raw helpers'
    for prefix,stem,_raw,_view in WRITERS:
        for op,rawstem in [('set',stem),('setledger',prefix+'_ledger')]:
            body=d[prefix+'_'+op]
            assert body.count(prefix+'_'+op+'_fused_done(')==1,'fused completion call absent/ambiguous'
            assert body.count('P.prototype_'+rawstem+'_raw_swap(raw,value)')==1,'fused Raw call absent/ambiguous'
            assert 'H.main_write' not in body and 'H.ledger_write' not in body,'mixed generic/fused writer'
    return True

def main_sites(text):
    """Select the actual guarded owner family; refuse partial/mixed catalogs."""
    d=defs(text)
    cacheboxed=['prototype_cacheboxed_'+p+'_set_fused_done' for p in ('motion','health')]
    cache_present=[name in d for name in cacheboxed]
    assert not any(cache_present) or all(cache_present), 'partial cache-boxed writer catalog'
    if all(cache_present):
        for prefix in ('motion','health'):
            stem='prototype_cacheboxed_'+prefix
            assert d[prefix+'_fields_checked'].count(stem+'_taken(')==1
            assert d[stem+'_set'].count(stem+'_set_fused_done(')==1
            assert d[stem+'_invoke'].count(','+stem+'_set,')==1
            assert d[stem+'_taken'].count(stem+'_invoke(')==1
            assert d[stem+'_set'].count('P.prototype_'+('position' if prefix=='motion' else 'vitals')+'_raw_swap(raw,value)')==1
            assert 'PrototypeWorldRoot{CC.Cache{' in d[stem+'_set']
        return cacheboxed
    flat=['prototype_flat_'+p+'_set_done' for p in ('motion','health')]
    present=[name in d for name in flat]
    assert not any(present) or all(present), 'partial flat writer catalog'
    boxed=['prototype_boxed_'+p+'_set_fused_done' for p in ('motion','health')]
    boxed_present=[name in d for name in boxed]
    assert not any(boxed_present) or all(boxed_present), 'partial boxed writer catalog'
    assert not (any(present) and any(boxed_present)), 'mixed private writer catalogs'
    if all(present) or all(boxed_present):
        family='prototype_flat_' if all(present) else 'prototype_boxed_'
        for prefix in ('motion','health'):
            stem=family+prefix
            done=stem+('_set_done' if all(present) else '_set_fused_done')
            assert d[prefix+'_fields_checked'].count(stem+'_taken(')==1
            assert d[stem+'_set'].count(done+'(')==1
            assert d[stem+'_invoke'].count(','+stem+'_set,')==1
            if all(present):
                assert d[stem+'_taken'].count(stem+'_open_ledger(')==1
                assert d[stem+'_open_ledger'].count(stem+'_invoke(')==1
            else:
                assert d[stem+'_taken'].count(stem+'_invoke(')==1
        return flat if all(present) else boxed
    return [p+'_set_fused_done' for p in ('motion','health')]

def flat_suppression(text,observer):
    d=defs(text);sites=main_sites(text)
    for prefix,stem,raw,view in WRITERS:
        name='prototype_flat_'+prefix+'_set_done';before=d[name]
        after=before.replace(',main_view:T.'+view,'',1)
        needle=',value:U32,result:T.'+raw+' & U32';assert after.count(needle)==1
        after=after.replace(needle,',result:CC.Cache<T.'+raw+',T.'+view+'> & T.'+view)
        pattern='T.'+view+'{T.Four{old,_,_,_},'+('_' if prefix=='motion' else '_,_')+'}'
        assert after.count('case (main,old):')==1
        after=after.replace('case (main,old):','case (CC.Cache{main,main_view},'+pattern+'):')
        needle='P.'+stem+'_patch(main_view,value)';assert after.count(needle)==1
        after=after.replace(needle,'main_view')
        setter=d['prototype_flat_'+prefix+'_set'];changed=setter.replace('      +value = value\n','')
        call=name+'(world,main_view,';assert changed.count(call)==1
        changed=changed.replace(call,name+'(world,',1)
        needle=',value,P.prototype_'+stem+'_raw_swap(main,value)';assert changed.count(needle)==1
        getter=observer+'.'+stem+'_get' if observer else 'P.'+stem+'_uncached'
        changed=changed.replace(needle,','+getter+'(CC.Cache{main,main_view})',1)
        assert text.count(before)==text.count(setter)==1
        text=text.replace(before,after,1).replace(setter,changed,1)
    return text,sites

def mutation(text,kind,observer=None):
    assert fused_presence(text),'expected live fused targets'
    if observer is not None:assert re.fullmatch(r'[A-Za-z][A-Za-z0-9_]*',observer),'invalid observer alias'
    if main_sites(text)[0].startswith('prototype_flat_') and kind=='suppressed-setter':
        return flat_suppression(text,observer)
    d=defs(text);sites=[]
    targets=main_sites(text)
    for prefix,stem,raw,view in WRITERS:
        name=targets[0 if prefix=='motion' else 1];before=d[name];after=before
        if kind=='lost-mark':
            assert before.count('handle <> marks')==1
            after=before.replace('handle <> marks','marks')
        elif kind=='inverse-order':
            needle='X.MainInverse{handle,old} <> undo';assert before.count(needle)==1
            after=before.replace(needle,'List.append(&2,X.Inverse<S.Handle<T.'+prefix.title()+'Schema>>,undo,[X.MainInverse{handle,old}])')
        elif kind=='suppressed-setter':
            old=',cached:T.'+view+',value:U32,result:T.'+raw+' & U32'
            assert before.count(old)==1
            after=before.replace(old,',result:CC.Cache<T.'+raw+',T.'+view+'> & T.'+view)
            pattern='T.'+view+'{T.Four{old,_,_,_},'+('_' if prefix=='motion' else '_,_')+'}'
            assert after.count('case (raw,old):')==1
            after=after.replace('case (raw,old):','case (CC.Cache{raw,cached},'+pattern+'):')
            patch='P.'+stem+'_patch(cached,value)';assert after.count(patch)==1
            after=after.replace(patch,'cached')
            setter=d[name.removesuffix('_fused_done')];needle='cached,value,P.prototype_'+stem+'_raw_swap(raw,value)';assert setter.count(needle)==1
            getter=(observer+'.'+stem+'_get' if observer else 'P.'+stem+'_uncached')
            changed=setter.replace('      +value = value\n','').replace(needle,getter+'(CC.Cache{raw,cached})')
            assert changed!=setter and text.count(setter)==1
            text=text.replace(setter,changed,1)
        else:raise ValueError(kind)
        assert after!=before and text.count(before)==1
        text=text.replace(before,after,1);sites.append(name)
    return text,sites
