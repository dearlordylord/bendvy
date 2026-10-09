"""Source-derived full spine wrapper; historical complete model is immutable input."""
import hashlib,json
from pathlib import Path
BASE_SHA="ca88bdec56290ba3b5460463f59c4ddda389d2dcc7ecfa58d6d633c35016e075"
def expected(base):
    if hashlib.sha256(base).hexdigest()!=BASE_SHA: raise ValueError("Historical complete model drift")
    prior=json.loads(base)
    result={"$":"Candidate"}
    for name in ("insert","spawn","resource","otherSchema"):
        result[name]={"$":"Some","value":prior["baseline"][name]}
    result["foreign"]=prior["baseline"]["foreign"]
    result["extension"]={"$":"Some","value":prior["extension"]}
    return result
if __name__=="__main__":
    import sys
    print(json.dumps(expected(Path(sys.argv[1]).read_bytes()),indent=2))
