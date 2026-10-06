#!/usr/bin/env python3
"""Finite generic public query with an actual nonidentity affine getter."""
import pathlib,re
H=pathlib.Path(__file__).resolve().parent;s=(H/'full-shape.bend').read_text();at=s.index('def cursor_handles(');end=s.index('def world0()',at)
s=s[:at]+'''def getter(value:Owned) -> Owned & String:
  match value:
    case Owned{items,scalar}: owned(Owned{items,U32.add(scalar,1)})
def client_return(-P:Type,-U:Type,handle:S.Handle<Schema>,aux:U,result:P & String) -> P & (U & S.Handle<Schema>):
  match result:
    case (main,_): (main,(aux,handle))
def client(~P:Type,~U:Type,~get:P -> Unit -> P & String,~ag:U -> U & Maybe<&2,String>,handle:S.Handle<Schema>,flag:Maybe<&2,Unit>,main:P,aux:U) -> P & (U & S.Handle<Schema>):
  client_return(P,U,handle,aux,get(main,Unit{}))
def snapshot(result:S.World<Schema,Owned,Owned,Unit,Owned,U32> & List<&2,S.Handle<Schema>>) -> String:
  match result:
    case (S.World{ns,next,rows,Nil{},Some{ledger},mode},values): snapshot_rows(ns,next,ledger,mode,values,rows)
    case _: "unexpected-context"
'''+s[end:]
old='Q.prototype_cursor_each(Schema,Owned,Owned,Unit,Owned,U32,';assert s.count(old)==20;s=s.replace(old,'Q.each(Schema,Owned,Owned,Unit,Unit,String,String,S.Handle<Schema>,Owned,U32,getter,owned,client,');(H/'public-query-full-shape.bend').write_text(s)
lines=[]
for line in (H/'full-shape-expected.txt').read_text().splitlines():
 parts=line.split('|');ids={int(x.split(':')[1]) for x in parts[-1].split(';') if ':' in x}
 # Independent original literal state; only selected Main scalar gains one.
 parts[2]=re.sub(r'@(\d+)',lambda m:'@'+str(int(m.group(1))+(int(m.group(1)) in ids)),parts[2]);lines.append('|'.join(parts))
(H/'public-query-full-shape-expected.txt').write_text('\n'.join(lines)+'\n')
