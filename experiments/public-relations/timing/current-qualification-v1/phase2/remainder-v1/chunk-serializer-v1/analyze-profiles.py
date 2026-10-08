"""Read-only finite sampled attribution; lexical locations do not establish causality."""
from pathlib import Path
import bisect,collections,hashlib,json,re
H=Path(__file__).resolve().parent;R=H.parents[6];D=R/'.artifacts/relations-chunk-profiles-1791419733173894934';A=R/'.artifacts/relations-chunk-coarse-profiles-1791420272919275021';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def locations(wrapper):
 declarations=[(n,re.match(r'^function ([^\s(]+)',line).group(1)) for n,line in enumerate(wrapper.read_text().splitlines()) if re.match(r'^function ([^\s(]+)',line)];lines=[n for n,_ in declarations]
 def enclosing(frame):
  if Path(frame['url'].removeprefix('file://'))==wrapper and frame['lineNumber']>=0:
   n=bisect.bisect_right(lines,frame['lineNumber'])-1
   if n>=0:return declarations[n][1]
  return frame['functionName']
 return enclosing
roles={}
for role in ['original','candidate']:
 cpu=D/(role+'-cpu.profile.json');allocation=A/(role+'-allocation.profile.json');cp=json.loads(cpu.read_text())['profile'];ap=json.loads(allocation.read_text())['profile'];cn={n['id']:n for n in cp['nodes']};cl=locations(D/'wrappers'/(role+'-cpu.cjs'));al=locations(A/'wrappers'/(role+'-allocation.cjs'));sampled=collections.Counter();weights=collections.Counter();sites=collections.Counter()
 for ident,count in collections.Counter(cp['samples']).items():sampled[cl(cn[ident]['callFrame'])]+=count
 pending=[ap['head']]
 while pending:
  n=pending.pop();frame=n['callFrame'];name=al(frame);weights[name]+=n['selfSize'];sites[(name,frame['lineNumber'],frame['columnNumber'])]+=n['selfSize'];pending.extend(n['children'])
 classify=lambda n:'serializer lexical declaration' if 'serialize' in n else 'forcing lexical declaration' if 'force' in n else 'GC' if n=='(garbage collector)' else 'other'
 cg=collections.Counter();ag=collections.Counter()
 for n,s in sampled.items():cg[classify(n)]+=s
 for n,s in weights.items():ag[classify(n)]+=s
 roles[role]={'cpuProfileSHA256':sha(cpu),'allocationProfileSHA256':sha(allocation),'CPUWrapperSHA256':sha(D/'wrappers'/(role+'-cpu.cjs')),'allocationWrapperSHA256':sha(A/'wrappers'/(role+'-allocation.cjs')),'CPUtotalSamples':len(cp['samples']),'CPUbyLexicalDeclarationGroup':dict(cg),'allocationReportedSelfSizeSum':sum(weights.values()),'allocationByLexicalDeclarationGroup':dict(ag),'topCPUEnclosingDeclarations':[{'declaration':n,'selfSamples':s} for n,s in sampled.most_common(10)],'topAllocationEnclosingDeclarations':[{'declaration':n,'reportedSelfSize':s} for n,s in weights.most_common(10)],'topAllocationSites':[{'declaration':n,'lineNumberZeroBased':line,'columnNumberZeroBased':col,'reportedSelfSize':s} for (n,line,col),s in sites.most_common(8)]}
result={'scope':'One original/candidate matched depth16 instrumented full30; CPU100us and matchedHeap1MiB sampling. ReportedselfSize/sample counts and source locations, not totalallocation/RSS/fairtiming/speed/cause/statisticalacceptance. Failed16KiB allocation remainsinconclusive.','method':'Leaf frame source URL andzero-basedline mapped to enclosing generated top-level function declaration; anonymous continuation allocations inside serialize.walk are included by lexical location. Earliernearestnamedancestor heuristics undercounted these. Externalframes preserve functionname. Lexical enclosure is source-location attribution, not operationcausality; helperList.append allocations stay other. Generatedwrappers/source review remain local/hash-bound if artifactbytes excluded.','roles':roles};(H/'profile-analysis.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps({r:{k:v for k,v in x.items() if k in ['CPUtotalSamples','CPUbyLexicalDeclarationGroup','allocationReportedSelfSizeSum','allocationByLexicalDeclarationGroup','topAllocationEnclosingDeclarations']} for r,x in roles.items()},indent=2))
