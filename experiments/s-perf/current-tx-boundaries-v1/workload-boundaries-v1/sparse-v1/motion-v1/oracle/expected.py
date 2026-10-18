"""Finite source-derived Sparse64 append/finish trace; no subject output input."""
from pathlib import Path
import gzip,hashlib,json,sys
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE/'source'))
import model

def report(kind,operations,begin,end,iteration):
 current=[0,0,0];boundaries=[]
 for site,delta in operations:
  current=[a+b for a,b in zip(current,delta)]
  boundaries.append(dict(site=site,delta=delta,current=current[:],peak=current[:]))
 return dict(iteration=iteration,completion='committed',tx=dict(kind=kind,namespace=1,beginTick=begin,endTick=end,appendTick=None,boundaries=boundaries,terminal=current,consistent=True))
def expected():
 w=model.World(64);w.reserve_all()
 reports=[report('seed',[(site,delta) for _ in w.order for site,delta in [('commands.spawn_reserved',[0,1,0]),('commands.track_pending',[1,0,0])]],w.clock,w.clock,None)]
 w.populate()
 for iteration in range(64):
  begin=w.clock;selected=w.row_entities();operations=[(site,delta) for _ in selected for site,delta in [('component.tx_written',[1,0,0]),('resource-field.journaled',[1,0,0])]]
  w.update() # Includes all three original independent scans and weights.
  reports.append(report('query-loop',operations,begin,w.clock,iteration))
 assert len(reports)==65 and all(r['tx']['terminal']==[16,0,0] for r in reports[1:])
 return dict(schema='Motion',workloadCount=64,iterations=64,frame=None,reports=reports)
def main():
 canonical,_=model.report(64,64)
 assert len(canonical)==413934 and hashlib.sha256(canonical).hexdigest()=='7bc64f59bd9975f79ff6bf51e1156b90170e345898c3c889779686f37f90002b'
 raw=(json.dumps(expected(),separators=(',',':'))+'\n').encode()
 (HERE/'expected.stats.json').write_bytes(raw)
 (HERE/'expected.stdout.gz').write_bytes(gzip.compress(canonical,mtime=0))
 pins={str(p.relative_to(HERE)):hashlib.sha256(p.read_bytes()).hexdigest() for p in (HERE/'source').glob('*.py')}
 basis=dict(base='41409a5ee',sourcePins=pins,canonical=dict(bytes=len(canonical),sha256=hashlib.sha256(canonical).hexdigest()),stats=dict(bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest()),reports=65,scope='Actual seed and64 ordinary update Tx; each Main+Ledger append followed; beforefinish list traversal; no Tx invented for readonly postcommit scans. Nonempty discard and broader matrix remain outside this finite slice.')
 (HERE/'SOURCE-BASIS.json').write_text(json.dumps(basis,indent=2)+'\n');print(json.dumps(basis))
if __name__=='__main__':main()
