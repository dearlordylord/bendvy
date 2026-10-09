"""Independent pre-output String oracle; source-derived, no execution input."""
import json
from pathlib import Path

def expected():
    # List.show separates elements by comma-space; returned_text separates packets by comma.
    original='[7, 9]:11'
    replacement='[13, 17]:19'
    first=[
        'spawn-before=missing:missing',
        'spawn-after='+original,
        'insert='+replacement,
        'restore='+original,
        'cleanup=absent:absent|ns=1|next=2|high=1|clock=4|returned='+original+','+replacement+',end|installed=0|quarantine=0|errors=0|pending=0',
    ]
    retry=[
        'retry-first=MissingEntity',
        'retry-before=absent:absent',
        'retry-after='+original,
        'retry-cleanup=absent:absent|ns=2|next=2|high=1|clock=2|returned='+original+',end|installed=0|quarantine=0|errors=0|pending=0',
    ]
    # Existing.main and next each call IO.print once; IO.print appends LF.
    return '\n'.join(first)+'\n'+'\n'.join(retry)+'\n'

if __name__=='__main__':
    here=Path(__file__).resolve().parent
    value=expected()
    (here/'expected.stdout').write_bytes(value.encode('utf-8'))
    (here/'expected.json').write_text(json.dumps(value,ensure_ascii=False,indent=2)+'\n')
