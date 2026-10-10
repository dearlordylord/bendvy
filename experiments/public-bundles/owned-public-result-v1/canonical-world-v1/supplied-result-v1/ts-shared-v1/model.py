"""Pure source-derived actual Command entryResult/spawn/insert observation model."""
import json

def run(schema):
    snapshots=[];calls=[]
    base=[{'family':'canonical-tag','value':{}},{'family':'canonical-data','value':101}]
    for label,ok,replacement in [('refused',False,False),('repaired',True,False),('replacement',True,True)]:
        owner={'owned':[41,42] if replacement else [11,12],'number':17 if replacement else 7}
        tail={'owned':[51,52,53,54] if replacement else [21,22,23,24],'tag':not replacement,'scalar':61 if replacement else 32}
        data=202 if replacement else 101
        calls.append('tail')
        pair=[{'family':'supplied-array','value':owner},{'family':'canonical-tail','value':tail}]
        snapshots.append({'label':label,'calls':calls.copy(),'supplied':{'state':'Ready' if ok else 'Rejected','owner':owner,'error':None if ok else 'ConstructorBlocked'},'raw':{'head':owner,'tail':tail,'tag':{},'data':data},'positions':[None,None,None,None] if ok else ['ConstructorBlocked',None,None,None],'cooked':pair+[{'family':'canonical-tag','value':{}},{'family':'canonical-data','value':data}] if ok else None,'insertPositions':[None,None] if ok else ['ConstructorBlocked',None],'inserted':base+pair if ok else None,'retainedBase':base})
    return {'schema':schema,'snapshots':snapshots}
def report():return (json.dumps([run('A'),run('B')],separators=(',',':'),ensure_ascii=False)+'\n').encode()
if __name__=='__main__':
    import sys
    sys.stdout.buffer.write(report())
