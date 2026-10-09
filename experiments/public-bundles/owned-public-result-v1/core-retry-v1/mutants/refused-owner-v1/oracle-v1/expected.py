"""Pre-output source-derived full recovery counterfactual; no runtime input."""
import json
from pathlib import Path
def expected():
 baseline=(Path(__file__).parent/'baseline.json').read_text()
 value=json.loads(baseline)
 return value.replace('retry-after=[7, 9]:11','retry-after=[7, 9]:23').replace('retry-cleanup=absent:absent|ns=2|next=2|high=1|clock=2|returned=[7, 9]:11,end','retry-cleanup=absent:absent|ns=2|next=2|high=1|clock=2|returned=[7, 9]:23,end')
