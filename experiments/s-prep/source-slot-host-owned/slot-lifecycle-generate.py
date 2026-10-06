#!/usr/bin/env python3
"""Finite Slot Rows ownership/liveness trace; all payload cells observed afterward."""
import pathlib,re
H=pathlib.Path(__file__).resolve().parent
for schema,slot in [('motion','PrototypeMotionMainSlot'),('health','PrototypeHealthMainSlot')]:
 source=(H/(schema+'-slot.bend')).read_text();source=source.replace('import Base\n','import Base\nimport ./storage.bend as S\n')
 ty='CP.'+slot;rows=f'S.Rows<{ty},Unit,Unit>';row=f'S.Row<{ty},Unit,Unit>'
 helper=f'''def taken(label:U32,result:{rows} & Maybe<{row}>) -> IO(Unit):
  match result:
    case (rows,Some{{S.Row{{+id,Some{{owner}},None{{}},None{{}},+added,+changed}}}}):
      do IO<Unit>:
        IO.print("live:" ++ U32.show(label) ++ ":" ++ U32.show(id) ++ ":" ++ U32.show(added) ++ ":" ++ U32.show(changed))
        removed(label,S.rows_remove({ty},Unit,Unit,S.rows_restore({ty},Unit,Unit,rows,S.Row{{id,Some{{owner}},None{{}},None{{}},added,changed}}),3))
        return Unit{{}}
    case _: IO.print("unexpected-live")
def placed(label:U32,result:S.Placement<{ty},Unit,Unit>) -> IO(Unit):
  match result:
    case S.Placed{{S.Rows{{main,aux,metadata,+capacity,+depth,+high}}}}:
      do IO<Unit>:
        IO.print("shape:" ++ U32.show(label) ++ ":" ++ U32.show(capacity) ++ ":" ++ Nat.show(depth) ++ ":" ++ U32.show(high))
        taken(label,S.rows_extract({ty},Unit,Unit,S.Rows{{main,aux,metadata,capacity,depth,high}},3))
        return Unit{{}}
    case _: IO.print("unexpected-place")
def removed(label:U32,result:{rows} & Maybe<{row}>) -> IO(Unit):
  match result:
    case (rows,Some{{S.Row{{+id,Some{{owner}},None{{}},None{{}},added,changed}}}}):
      do IO<Unit>:
        IO.print("removed:" ++ U32.show(label) ++ ":" ++ U32.show(id) ++ ":" ++ U32.show(added) ++ ":" ++ U32.show(changed))
        absences(label,owner,rows,[0,2,3,5,4294967295])
        return Unit{{}}
    case _: IO.print("unexpected-remove")
def absence(label:U32,owner:{ty},id:U32,ids:List<&2,U32>,result:{rows} & Maybe<{row}>) -> IO(Unit):
  match result:
    case (rows,None{{}}):
      do IO<Unit>:
        IO.print("missing:" ++ U32.show(label) ++ ":" ++ U32.show(id))
        absences(label,owner,rows,ids)
        return Unit{{}}
    case _: IO.print("unexpected-present")
def absences(label:U32,owner:{ty},rows:{rows},ids:List<&2,U32>) -> IO(Unit):
  match ids:
    case Nil{{}}: reinstalled(label,S.rows_place({ty},Unit,Unit,rows,S.Row{{3,Some{{owner}},None{{}},None{{}},31,32}}))
    case Con{{id,tail}}: absence(label,owner,id,tail,S.rows_extract({ty},Unit,Unit,rows,id))
def reinstalled(label:U32,result:S.Placement<{ty},Unit,Unit>) -> IO(Unit):
  match result:
    case S.Placed{{rows}}: restored(label,S.rows_extract({ty},Unit,Unit,rows,3))
    case _: IO.print("unexpected-reinstall")
def restored(label:U32,result:{rows} & Maybe<{row}>) -> IO(Unit):
  match result:
    case (rows,Some{{S.Row{{id,Some{{owner}},None{{}},None{{}},added,changed}}}}):
      do IO<Unit>:
        IO.print("restored:" ++ U32.show(label) ++ ":" ++ U32.show(id) ++ ":" ++ U32.show(added) ++ ":" ++ U32.show(changed))
        got(label,CP.prototype_slot_{'position' if schema=='motion' else 'vitals'}_get(owner))
        return Unit{{}}
    case _: IO.print("unexpected-restored")
'''
 # Finite explicit missing-ID stages avoid exposing a recursive affine closure.
 at=list(re.finditer(r'^def ([a-z_]+)\(',helper,re.M));parts={m.group(1):helper[m.start():at[i+1].start() if i+1<len(at) else len(helper)] for i,m in enumerate(at)}
 missing='';ids=[0,2,3,5,4294967295]
 for i in reversed(range(len(ids))):
  id=ids[i]
  nxt=('reinstalled(label,S.rows_place('+ty+',Unit,Unit,rows,S.Row{3,Some{owner},None{},None{},31,32}))' if i==len(ids)-1 else 'missing'+str(ids[i+1])+'(label,owner,S.rows_extract('+ty+',Unit,Unit,rows,'+str(ids[i+1])+'))')
  missing+='def missing'+str(id)+'(+label:U32,owner:'+ty+',result:'+rows+' & Maybe<'+row+'>) -> IO(Unit):\n  match result:\n    case (rows,None{}):\n      do IO<Unit>:\n        IO.print("missing:" ++ U32.show(label) ++ ":'+str(id)+'")\n        '+nxt+'\n        return Unit{}\n    case _: IO.print("unexpected-present")\n'
 parts['removed']=parts['removed'].replace('absences(label,owner,rows,[0,2,3,5,4294967295])','missing0(label,owner,S.rows_extract('+ty+',Unit,Unit,rows,0))')
 helper=parts['restored']+parts['reinstalled']+missing+''.join(parts[n] for n in ['removed','taken','placed'])
 helper=helper.replace('(label:U32,','(+label:U32,')
 start=source.index('def run(');end=source.index('def main()',start)
 owner='CP.PrototypeMotionMainSlot{array,4,999,200,300,400,77}' if schema=='motion' else 'CP.PrototypeHealthMainSlot{array,4,5,999,200,300,400,77,88}'
 newrun=f'def run(label:U32,array:Array<U32>) -> IO(Unit):\n  placed(label,S.rows_place({ty},Unit,Unit,S.rows_empty({ty},Unit,Unit),S.Row{{3,Some{{{owner}}},None{{}},None{{}},11,22}}))\n'
 source=source[:start]+helper+newrun+source[end:];(H/(schema+'-slot-lifecycle.bend')).write_text(source)
 payload=(H/(schema+'-slot-expected.txt')).read_text().splitlines();lines=[]
 for length,observed in zip([1,2,4,8,16],payload):
  lines += [f'shape:{length}:4:2:3',f'live:{length}:3:11:22',f'removed:{length}:3:11:22']+[f'missing:{length}:{id}' for id in [0,2,3,5,4294967295]]+[f'restored:{length}:3:31:32',observed]
 (H/(schema+'-slot-lifecycle-expected.txt')).write_text('\n'.join(lines)+'\n')
