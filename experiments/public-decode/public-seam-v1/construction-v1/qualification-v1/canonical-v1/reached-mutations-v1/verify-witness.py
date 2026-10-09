"""Complete source-current reached mutation witness; every unlisted observation remains exact."""
import copy
import json
from pathlib import Path


def witness(expected, kind):
    result = copy.deepcopy(expected)
    if kind == 'skip-input-validation':
        for schema in ('first','second'):
            output=copy.deepcopy(result[schema]['success'])
            def replace(value):
                if isinstance(value,dict):
                    if value.get('$')=='View' and value.get('original')=={'$':'Text','value':'7,8'}:
                        value['original']={'$':'Number','value':7}
                    for child in value.values():replace(child)
                elif isinstance(value,list):
                    for child in value:replace(child)
            replace(output)
            result[schema]['wrongKind']=output
        assert result!=expected
        return result
    for schema in ("first", "second"):
        if kind == "partial-write":
            case = result["initial"][schema]["invalidResource"]
            case["after"]["meta"]["clock"] = case["before"]["meta"]["clock"] + 1
        elif kind == "skip-validation":
            raw = {"$": "Number", "value": 999}
            for name in ("rejected", "foreign"):
                owner = result["initial"][schema][name]["input"]
                result["initial"][schema][name] = {
                    "$": "Constructed",
                    "owner": {"$": "View", "raw": copy.deepcopy(raw),
                              "original": copy.deepcopy(owner["raw"]),
                              "words": copy.deepcopy(owner["words"]),
                              "flags": copy.deepcopy(owner["flags"])},
                    "recovered": copy.deepcopy(owner)}
            error = {"$": "Invalid", "path": "$", "expected": "object", "actual": raw}
            result["request"][schema]["invalidSpawn"]["result"]["error"]["error"] = copy.deepcopy(error)
            result["materialization"][schema]["invalid"]["result"]["output"]["error"]["error"] = copy.deepcopy(error)
            result["raw-resource"][schema]["refused"]["result"]["error"] = copy.deepcopy(error)
        else:
            raise ValueError("unknown mutation")
    assert result != expected
    return result


def verify(expected, actual, kind):
    def equal(a,b):
        assert type(a) is type(b), 'witness scalar kind differs'
        if isinstance(a,dict):
            assert set(a)==set(b)
            for key in a:equal(a[key],b[key])
        elif isinstance(a,list):
            assert len(a)==len(b)
            for left,right in zip(a,b):equal(left,right)
        else:assert a==b
    equal(actual,witness(expected,kind))
    return "REACHED_COMPLETE_MUTANT_KILLED"


if __name__ == "__main__":
    import argparse
    p = argparse.ArgumentParser()
    p.add_argument("kind", choices=("skip-validation", "partial-write", "skip-input-validation"))
    p.add_argument("expected", type=Path)
    p.add_argument("actual", type=Path)
    a = p.parse_args()
    print(verify(json.loads(a.expected.read_bytes()), json.loads(a.actual.read_bytes()), a.kind))
