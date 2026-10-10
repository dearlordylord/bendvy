"""Independent pure model of pinned TS constructor/entryRaw/spawn serialization."""
import json

def scenario(schema):
    calls=[];heads=[];snapshots=[]
    for i,(label,wire,scalar,replace) in enumerate([('refused-prefix',7,31,False),('refused-both','bad',31,False),('repaired',9,32,False),('replacement',17,61,True)]):
        raw={'head':{'owned':[41,42] if replace else [11,12],'wire':wire,'fail':False},'tail':{'owned':[51,52,53,54] if replace else [21,22,23,24],'tag':not replace,'scalar':scalar},'tag':{},'data':202 if replace else 101}
        calls.append('head')
        he=None if isinstance(wire,int) else 'ValidationFiniteNumber'
        if he is None:heads.append({'owned':raw['head']['owned'].copy(),'number':wire})
        calls.append('tail');te='ConstructorBlocked' if scalar==31 else None
        cooked=None if he or te else [{'family':'constructed-array','value':{'owned':raw['head']['owned'].copy(),'number':wire}},{'family':'canonical-tail','value':raw['tail']},{'family':'canonical-tag','value':{}},{'family':'canonical-data','value':raw['data']}]
        snapshots.append({'label':label,'calls':calls.copy(),'raw':raw,'positions':[he,te,None,None],'cooked':cooked,'retainedSuccessfulHeads':[{'owned':x['owned'].copy(),'number':x['number']} for x in heads]})
    return {'schema':schema,'snapshots':snapshots}
def report():return (json.dumps([scenario('A'),scenario('B')],separators=(',',':'),ensure_ascii=False)+'\n').encode()
if __name__=='__main__':
    import sys
    sys.stdout.buffer.write(report())
