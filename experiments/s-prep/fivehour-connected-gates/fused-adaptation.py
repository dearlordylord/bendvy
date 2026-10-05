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

def mutation(text,kind,observer=None):
    assert fused_presence(text),'expected live fused targets'
    if observer is not None:assert re.fullmatch(r'[A-Za-z][A-Za-z0-9_]*',observer),'invalid observer alias'
    d=defs(text);sites=[]
    for prefix,stem,raw,view in WRITERS:
        name=prefix+'_set_fused_done';before=d[name];after=before
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
            setter=d[prefix+'_set'];needle='cached,value,P.prototype_'+stem+'_raw_swap(raw,value)';assert setter.count(needle)==1
            getter=(observer+'.'+stem+'_get' if observer else 'P.'+stem+'_uncached')
            changed=setter.replace('      +value = value\n','').replace(needle,getter+'(CC.Cache{raw,cached})')
            assert changed!=setter and text.count(setter)==1
            text=text.replace(setter,changed,1)
        else:raise ValueError(kind)
        assert after!=before and text.count(before)==1
        text=text.replace(before,after,1);sites.append(name)
    return text,sites
