"""Transport private actual Tx records through Dense/Sparse query completion."""
from pathlib import Path

def prepare(dest):
 p=Path(dest)/'measurement-bend.bend';text=p.read_text().replace('X.storage_commit(', 'X.diag_storage_commit(')
 for low,schema,main,aux,flag,ledger,mode in [('motion','Motion','Position','Velocity','Selected','MotionLedger','MotionMode'),('health','Health','Vitals','Armor','Tracked','HealthLedger','HealthMode')]:
  world=f'S.World<T.{schema}Schema,T.{main},T.{aux},T.{flag},T.{ledger},T.{mode}>'
  marker='def '+low+'_committed_queries('
  helper=f'''def {low}_diag_queries(meter: String,pair: {world} & U32) -> {world} & (U32 & String):
  match pair:
    case (world,total): (world,(total,meter))
'''
  text=text.replace(marker,helper+marker,1)
  start=text.index(marker);end=text.index('\ndef ',start+1);part=text[start:end]
  part=part.replace('& List<&2,U32>', '& (List<&2,U32> & String)').replace('-> '+world+' & U32:', '-> '+world+' & (U32 & String):').replace('case (world,_): '+low+'_queries(sparse,world)', 'case (world,(_,meter)): '+low+'_diag_queries(meter,'+low+'_queries(sparse,world))')
  text=text[:start]+part+text[end:]
  start=text.index('def '+low+'_committed(');end=text.index('\ndef ',start+1);part=text[start:end]
  part=part.replace('pair:'+world+' & U32)', 'pair:'+world+' & (U32 & String))')
  part=part.replace('case (world,querysum): ', 'case (world,(querysum,meter)): ')
  prefix,term=part.rsplit(': ',1);typ=f'D.Invoked<{schema}Bench,S.Handle<T.{schema}Schema>>'
  part=prefix+': IO.bind(Unit,'+typ+',IO.print("txdiag:" ++ meter),_ => '+term+')'
  text=text[:start]+part+text[end:]
 p.write_text(text)
