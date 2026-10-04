import pathlib
H=pathlib.Path(__file__).resolve().parent;p=H/'failure-quiet-overlay/experiments/s-integrate/measurement-failure-driver.bend';s=p.read_text().replace('import Base','import Base\nimport ../../../failure-quiet-codec.bend as C',1)
audit='''def audit_take(value:Maybe<D.Audit>) -> Maybe<D.Audit> & List<&2,U32>:
  match value:
    case Some{D.Recorded{+effects}}: (Some{D.Recorded{effects}},C.list(~String,~(value => C.text(value)),List.reverse(&2,String,effects)))
    case other: (other,[0])
'''
at=s.index('def ');s=s[:at]+audit+s[at:]
for lane,sc,v,av,flag in [('motion','Motion','PositionView','VelocityView','Selected'),('health','Health','VitalsView','ArmorView','Tracked')]:
 runtime=f'D.Runtime<F.{sc}Failure,S.Handle<T.{sc}Schema>>';etype=f'E.TraceEvent<T.{sc}Schema,T.{v},T.{av},T.{flag},T.LedgerView,T.{sc}Mode,T.{sc}Ping>'
 block=f'''def {lane}_capture_audit(world:F.{sc}Failure,registry:K.Registry,readers:R.Readers,clock:R.Clock,style:LC.Style,last:List<&2,S.Handle<T.{sc}Schema>>,views:List<&2,U.Observation>,foreign:Maybe<&2,Bool>,tuple:List<&2,U32>,pair:Maybe<D.Audit> & List<&2,U32>) -> {runtime} & List<&2,U32>:
  match pair:
    case (audit,effects): (D.Runtime{{world,registry,readers,clock,audit,style,last,views,foreign}},C.concat([tuple,effects]))
def {lane}_capture(owner:{runtime}) -> {runtime} & List<&2,U32>:
  match owner:
    case D.Runtime{{F.{sc}Failure{{H.Host{{world,logs,bindings,name,step,prior,+events}},iteration,failed}},registry,readers,clock,audit,style,last,views,foreign}}:
      {lane}_capture_audit(F.{sc}Failure{{H.Host{{world,logs,bindings,name,step,prior,events}},iteration,failed}},registry,readers,clock,style,last,views,foreign,C.list(~{etype},~C.{lane}_event,events),audit_take(audit))
def {lane}_timed(start:Nat,pair:{runtime} & List<&2,U32>) -> IO(Unit):
  match pair:
    case (owner,+tuple):
      do IO<Unit>:
        IO.print("FAILURE-FOLD:" ++ U32.show(C.fold(tuple,0)))
        end : Nat <- IO.now()
        IO.print("FAILURE-TIMING:" ++ Nat.show(Nat.sub(end,start)))
        IO.print("FAILURE-TUPLE:" ++ C.show(tuple))
        {lane}_compact_counts(owner)
def {lane}_compact_counts(owner:{runtime}) -> IO(Unit):
  match owner:
    case D.Runtime{{_,registry,_,clock,_,_,_,_,_}}: {lane}_counts(clock,H.count_registry(registry))
'''
 # Definition order: compact_counts before timed.
 a=block.index('def '+lane+'_timed');b=block.index('def '+lane+'_compact_counts');block=block[:a]+block[b:]+block[a:b]
 at=s.index('def '+lane+'_ready');s=s[:at]+block+s[at:]
 ending='''        end : Nat <- IO.now()
        IO.print("FAILURE-TIMING:" ++ Nat.show(Nat.sub(end,start)))
        '''+lane+'''_final(final)'''
 assert ending in s;s=s.replace(ending,f'        {lane}_timed(start,{lane}_capture(final))')
# Match imports already used by the actual driver; source style module aliases.
if ' as LC' not in s:s=s.replace('import Base','import Base\nimport ./capture.bend as LC\nimport ./systems.bend as U',1)
p.write_text(s)
