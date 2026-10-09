import copy,json
from pathlib import Path
def expected():
    result=copy.deepcopy(json.loads((Path(__file__).parent.parent/'list-report-v1/expected.json').read_text()))
    for schema in ('alpha','beta'):
        report=result['result']['value'][schema]
        for case in ('neverActivatedSkip','activatedSkip','successfulDisposal'):
            snapshot=report['lifecycle'][case]
            if case!='successfulDisposal': snapshot=snapshot['final']
            for registry in snapshot['value']['registrations']:
                registry['access']={'alpha':['Parent:read'],'beta':['ParentB:read'],'both':['Parent:read','ParentB:read']}[registry['name']]
        mixed=report['mixed']['value']
        mixed['relationRegistry']['access']=['Parent:read']
        for registry in mixed['registrations']:
            if registry['name']=='relation': registry['access']=['Parent:read']
    return result
if __name__=='__main__': print(json.dumps(expected(),indent=2))
