#!/usr/bin/env python3
"""Read-only reconciliation of the four exact C/build/source/count roles."""
import argparse,pathlib,json,hashlib
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,required=True);a=p.parse_args();sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();rows=[]
for role in ['baseline','candidate']:
 source_root=pathlib.Path('/tmp/bendvy-query-frozen-provider-native-v3' if role=='baseline' else '/tmp/bendvy-fourhour-closed-reader-initial-probe');pins=json.loads((source_root/'overlay.json').read_text())['sources'];assert len(pins)==29
 for rel,h in pins.items():assert sha(source_root/rel)==h
 for schema in ['motion','health']:
  source=pathlib.Path('/tmp/bendvy-query-frozen-provider-'+schema+'-build'+('-v2' if schema=='motion' else ''))/'batch.c' if role=='baseline' else pathlib.Path('/tmp/bendvy-fourhour-closed-reader-initial-'+schema+'-build/batch.c')
  receipt=pathlib.Path('/tmp/bendvy-closed-metadata-'+('baseline' if role=='baseline' else 'native')+'-'+schema+'-count/evidence.json');count=json.loads(receipt.read_text());bp=source.parent/'build.json';build=json.loads(bp.read_text());assert build.get('runtimeSources',build.get('sourcePins'))==pins;assert build['artifacts']['batch.c']==sha(source)==count['sourceSHA256']==count['sourceAfterSHA256'];assert build['artifacts']['batch.bend']==sha(source.parent/'batch.bend')==count['entrySHA256'];assert sha(bp)==count['upstreamBuildSHA256'];assert count['runtimeSources']==pins
  rows.append({'role':role,'schema':schema,'source':str(source),'sourceSHA256':sha(source),'sourceRoot':str(source_root),'closureSHA256':hashlib.sha256(json.dumps(pins,sort_keys=True,separators=(',',':')).encode()).hexdigest(),'build':str(bp),'buildSHA256':sha(bp),'countReceipt':str(receipt),'countSHA256':sha(receipt),'status':'PASS'})
a.output.write_text(json.dumps({'status':'ALL_FOUR_C_BUILD_SOURCE_COUNT_PINS_RECONCILED','cases':rows},indent=2)+'\n');print('PASS')
