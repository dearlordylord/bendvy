"""Whole pre-backend expected root; no runtime observations."""
import gzip,json
from pathlib import Path
def expected():
    parent=Path(__file__).resolve().parent.parent/'expected.json.gz'
    with gzip.open(parent,'rt') as stream: candidate=json.load(stream)
    assert candidate['$']=='Candidate' and candidate['result']['$']=='Some'
    return [candidate]
