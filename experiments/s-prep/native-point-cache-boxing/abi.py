#!/usr/bin/env python3
"""Describe the actual emitted spin helpers reached from Motion row dispatch."""
import argparse,hashlib,json,pathlib,re

def inspect(path):
 text=path.read_text(); funcs={}
 for m in re.finditer(r'(?:INLINE|FAR) Term (spin_\d+)\(([^\n]*)\) \{',text):
  end=text.find('\n}\n',m.end());body=text[m.end():end]
  args=m.group(2).split(', ')
  funcs[m.group(1)]={'signature':m.group(0)[:-2],'valueParameters':sum(bool(re.fullmatch(r'(?:Term|u32|u64|double) r\d+',a)) for a in args),'quantityParameters':sum(bool(re.fullmatch(r'u64 q\d+',a)) for a in args),'returnWords':max([int(n)+1 for n in re.findall(r'\bo\[(\d+)\]',body)] or [0]),'calls':sorted(set(re.findall(r'\b(spin_\d+)\(',body)))}
 marker=re.search(r'  WL_CASE\(FID_\w+HELD_ADAPTER_MOTION_ROW_0\)',text)
 assert marker
 end=text.find('\n  WL_CASE(',marker.end());row=text[marker.end():end]
 direct=sorted(set(re.findall(r'\b(spin_\d+)\(',row))); reached=set();todo=direct[:]
 while todo:
  key=todo.pop()
  if key in reached:continue
  reached.add(key);todo.extend(funcs[key]['calls'])
 return {'source':str(path),'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'direct':direct,'reached':{k:funcs[k] for k in sorted(reached)}}
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('baseline',type=pathlib.Path);p.add_argument('candidate',type=pathlib.Path);a=p.parse_args();print(json.dumps({'baseline':inspect(a.baseline),'candidate':inspect(a.candidate),'performanceAcceptance':False},indent=2))
