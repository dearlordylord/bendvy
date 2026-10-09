"""Source-authored full Raw wire model. No host adapter/runtime execution."""
import json
from pathlib import Path

def c(tag,**fields):return {'$':tag,**fields}
def string(text):return {'$codepoints':[ord(x) for x in text]}
def field(name,value):return c('Field',name=string(name),value=value)
def raw_tokens(raw):
    tag=raw['$'];value=raw.get('value')
    if tag in ('Missing','Null'):return [tag.lower()]
    if tag=='Number':return ['number',str(value)]
    if tag=='SignedInteger':return ['signed','1' if raw['negative'] else '0',str(raw['magnitude'])]
    if tag=='Float':return ['float',str(value['$f32Bits'])]
    if tag=='Binary64':return ['binary64',str(raw['high']),str(raw['low'])]
    if tag=='Text':return ['text',str(len(value['$codepoints'])),*map(str,value['$codepoints'])]
    if tag=='Utf16Text':return ['utf16',str(len(raw['units'])),*map(str,raw['units'])]
    if tag=='Boolean':return ['bool','1' if value else '0']
    if tag=='Handle':return ['handle',str(raw['namespace']),str(raw['id'])]
    if tag=='Array':return ['array',str(len(raw['items'])),*[t for x in raw['items']for t in raw_tokens(x)]]
    if tag=='Object':return ['object',str(len(raw['fields'])),*[t for f in raw['fields']for t in [str(len(f['name']['$codepoints'])),*map(str,f['name']['$codepoints']),*raw_tokens(f['value'])]]]
    raise ValueError(tag)
def positive():
    return [
    ('missing',c('Missing')),('null',c('Null')),('number',c('Number',value=4294967295)),
    ('signedMaximum',c('SignedInteger',negative=True,magnitude=281474976710655)),
    *[(label,c('Float',value={'$f32Bits':bits}))for label,bits in [('positiveZero',0),('negativeZero',2147483648),('subnormal',1),('nan',2143289344),('infinity',2139095040),('negativeInfinity',4286578688)]],
    ('binary64',c('Binary64',high=4294967295,low=2147483648)),('astral',c('Text',value=string('A🌍'))),
    ('loneUtf16',c('Utf16Text',units=[55296])),('invalidUtf16Unit',c('Utf16Text',units=[65536])),
    ('boolean',c('Boolean',value=False)),('handle',c('Handle',namespace=17,id=19)),
    ('emptyArray',c('Array',items=[])),('emptyObject',c('Object',fields=[])),
    ('nestedDuplicate',c('Object',fields=[field('x',c('Text',value=string('first'))),field('x',c('Array',items=[c('Boolean',value=True),c('Null')])),field('🌍',c('Binary64',high=1,low=2))]))]
def expected():
    rows=[dict(label=label,output=dict(argv=[string(t)for t in raw_tokens(raw)],result=c('Parsed',raw=raw)))for label,raw in positive()]
    rows.append(dict(label='knownNan',output=dict(argv=[string(t)for t in ['float','2143289344']],result=c('Parsed',raw=c('Float',value={'$f32Bits':2143289344})))))
    for label,tokens in [('signedOverflow',['signed','0','281474976710656']),('u32Overflow',['number','4294967296']),('badBoolean',['bool','2']),('nonScalarText',['text','1','55296']),('truncatedArray',['array','2','null']),('extraToken',['null','null']),('maximumTextCount',['text','281474976710655']),('maximumUtf16Count',['utf16','281474976710655']),('maximumFieldNameCount',['object','1','281474976710655'])]:
        result=c('Extra',raw=c('Null'),remaining=[string('null')]) if label=='extraToken' else c('TransportRefused',remaining=[])
        rows.append(dict(label=label,output=dict(argv=[string(t)for t in tokens],result=result)))
    return rows
if __name__=='__main__':Path(__file__).with_name('transport-expected.json').write_text(json.dumps(expected(),indent=2)+'\n')
