import * as B from './bend.ts';
const book=B.book_nil();
const data=B.Typ(B.Qua(B.Many()));
const owner=B.Typ(B.Qua(B.Lone()));
const checks=[
 ['EQ distinguishes quantities',B.term_compare('EQ',book,data,owner),false],
 ['LE data fits owner kind',B.term_compare('LE',book,data,owner),true],
 ['LE owner does not fit data',B.term_compare('LE',book,owner,data),false],
 ['different labels',B.term_compare('EQ',book,B.Ref('Left'),B.Ref('Right')),false],
 ['alpha binder',B.term_compare('EQ',book,B.All(B.Many(),'x',0,data,x=>x),B.All(B.Many(),'y',0,data,y=>y)),true],
 ['binder quantities',B.term_compare('EQ',book,B.All(B.Many(),'x',0,data,x=>x),B.All(B.Lone(),'x',0,data,x=>x)),false],
 ['variable depth',B.term_compare('EQ',book,B.Var('x',0),B.Var('x',1)),false],
];
for(const [name,actual,expected] of checks){if(actual!==expected)throw Error(name);}
console.log(JSON.stringify(checks));
