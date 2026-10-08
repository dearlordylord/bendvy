"""Independent fixture expectations authored before any consumer output.
No imports from the Bend implementation or TypeScript reference.
"""
import json
import copy
from pathlib import Path

def rows(base, edges, stock_required, title_required, mode):
    result=[]
    stock={1:base+11,2:base+12,4:base+14}
    title={2:str(base+22),3:str(base+23),4:str(base+24)}
    for entity in range(1,5):
        target=next((b for a,b in edges if a==entity),None)
        incoming=[a for a,b in edges if b==entity]
        accepted={'optional-both':True,'required-out':target is not None,
                  'required-in':bool(incoming),'required-both':target is not None and bool(incoming),
                  'with-out':target is not None,'without-out':target is None,
                  'with-in':bool(incoming),'without-in':not incoming}[mode]
        if not accepted or stock_required and entity not in stock or title_required and entity not in title:
            continue
        cells=[]
        if mode not in ('with-out','without-out','with-in','without-in'):
            if mode in ('optional-both','required-both','required-out'):
                cells.append({'key':'out','end':'outgoing','value':None if target is None else {'target':target}})
            if mode in ('optional-both','required-both','required-in'):
                cells.append({'key':'in','end':'incoming','value':None if not incoming else {'sources':incoming}})
        result.append({'entity':entity,'stock':stock.get(entity),'title':title.get(entity),'cells':cells})
    return result

def schema(name,base):
    phases=[]
    # Queued relation updates are invisible until the actual barrier.
    initial=[(1,2),(3,2),(2,4)]
    changed=[(2,4),(1,4)]
    for tick,(phase,edges,pending) in enumerate([('initial',initial,0),('queued',initial,2),('barrier',changed,0)]):
        queries=[]
        for sr,tr in [(False,False),(True,False),(False,True),(True,True)]:
            for mode in ['optional-both','required-out','required-in','required-both','with-out','without-out','with-in','without-in']:
                selected=rows(base,edges,sr,tr,mode)
                count=len(selected)
                single={'error':'NoEntities'} if count==0 else {'row':selected[0]} if count==1 else {'error':'MultipleEntities','count':count}
                optional={'row':None} if count==0 else single
                byid={r['entity']:r for r in selected}
                lookups=[{'entity':i,**({'row':byid[i]} if i in byid else {'error':'QueryMismatch'})} for i in range(1,5)]
                lookups += [{'entity':0,'error':'MissingEntity'},{'entity':5,'error':'MissingEntity'},{'entity':1,'foreign':True,'error':'MissingEntity'}]
                queries.append({'stockRequired':sr,'titleRequired':tr,'mode':mode,'each':selected,'get':lookups,'single':single,'singleOptional':optional})
        phases.append({'phase':phase,'pending':pending,'queries':queries,'cursorBefore':tick,'cursorAfter':tick,'worldClockBefore':tick,'worldClockAfter':tick,'ownersBefore':{'stock':[base+11,base+12,base+14],'title':[str(base+22),str(base+23),str(base+24)],'resources':[[base+31],[base+32]]},'ownersAfter':{'stock':[base+11,base+12,base+14],'title':[str(base+22),str(base+23),str(base+24)],'resources':[[base+31],[base+32]]}})
    return {'schema':name,'phases':phases,'finalInspectorCursor':3,'finalWorldClock':3,'errors':'','retainedInitialInverse':[1,3],'currentInverse2':[],'currentInverse4':[2,1]}

if __name__=='__main__':
    oracle={'schemas':[schema('Workshop',0),schema('Garden',100)],'scope':'finite relation Inspector development fixture; no full55 qualification'}
    Path(__file__).with_name('expected-relations.json').write_text(json.dumps(oracle,indent=2)+'\n')
    ts=copy.deepcopy(oracle)
    ts['scope']='finite TS relation Inspector counterpart; foreign raw-ID aliasing is recorded separately'
    for subject in ts['schemas']:
        for key in ['finalInspectorCursor','finalWorldClock','errors']:subject.pop(key)
        for phase in subject['phases']:
            for key in ['pending','cursorBefore','cursorAfter','worldClockBefore','worldClockAfter']:phase.pop(key)
            for query in phase['queries']:
                # Pinned TS Runtime.makeQueryHandle resolves target.value only.
                # Keep this observed contract distinct from Bend namespace safety.
                query['get'][-1]={**copy.deepcopy(query['get'][0]),'foreign':True}
    Path(__file__).with_name('expected-ts-relations.json').write_text(json.dumps(ts,indent=2)+'\n')

