#!/usr/bin/env python3
"""Independent complete lookup outputs; not generated from Bend poststates."""
import copy
import importlib.util
import json
from pathlib import Path
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('storage_contract',HERE/'storage-observation-contracts.py')
C=importlib.util.module_from_spec(spec);spec.loader.exec_module(C)

def expected(schema,count):
    w=C.world(schema,1)
    def found(entity):
        return dict(kind='Found',handle=C.handle(w,entity),row=C.row(schema,entity,10,True,True))
    middle=count//2+1
    return {'retainedBefore':True,'retainedAfter':True,'lookups':[
        dict(label=label,result=found(entity)) for label,entity in
        [('first',1),('middle',middle),('last',count),('first-again',1)]]+[
        dict(label='last-flag-mismatch',result={'kind':'QueryMismatch'}),
        dict(label='missing',result={'kind':'MissingEntity'}),
        dict(label='foreign',result={'kind':'MissingEntity'}),
        dict(label='aux-only-mismatch',result={'kind':'QueryMismatch'}),
        dict(label='aux-only-mismatch-again',result={'kind':'QueryMismatch'}),
        dict(label='restored',result=found(middle))]}

def run():
    cases=[]
    for schema in ['Motion','Health']:
        for count in [5,65537]:
            valid=expected(schema,count)
            wrong=copy.deepcopy(valid);wrong['lookups'][7]['result']['kind']='MissingEntity'
            cases.append(C.check_case(f'{schema}/{count}',lambda x:x==expected(schema,count),valid,[('live-aux-classified-missing',wrong)]))
    return {'runtimeExecuted':False,'proof':False,'cases':cases,'rejectedObservations':sum(x['perturbedObservationsRejected'] for x in cases)}
if __name__=='__main__': print(json.dumps(run(),indent=2))
