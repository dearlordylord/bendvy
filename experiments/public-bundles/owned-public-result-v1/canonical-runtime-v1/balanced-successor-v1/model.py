"""Independent source-only balanced pure canonical construction model. No runtime inputs."""
import json

def tree(x):
    return "L("+str(x)+")" if isinstance(x,int) else "N("+tree(x[0])+","+tree(x[1])+")"

def context(trail):
    rest="N(L("+tree((70,71))+"),L("+tree(72)+"))"
    return "factory=identity=constructed-array/decl=FiniteNumber/input=FiniteNumber/rest="+rest+"/trail=["+", ".join(trail)+"]"

def raw(wire,fail):
    return tree((11,12))+"/wire="+wire+"/fail="+str(fail)+"/tail="+tail()

def tail():
    return tree(((21,22),(23,24)))+"/tag=True/scalar=31"

def scenario(wire,fail):
    trail=[]
    out="initial:"+context(trail)+"/raw="+raw(wire,fail)+"\n"
    # Head admission and tail stage execute in order; tail runs after invalid head too.
    invalid="Validation($,finite number,Text(bad))" if wire=="Text(bad)" else ("Constructor(Blocked)" if fail else None)
    trail.append("tail")
    if invalid:
        out+="refused:"+context(trail)+"/raw="+raw(wire,fail)+"/positions=["+invalid+", None]\n"
        # Caller explicitly repairs the returned raw head then retries the full stage.
        wire="Number(9)";fail=False;trail.append("tail")
    number=int(wire[7:-1])
    out+="valid:"+tree((11,12))+"/number="+str(number)+"/tail="+tail()+"/positions=[None, None]\n"
    # Undo captures the actual original wire/fail for this successful attempt.
    out+="restored:"+context(trail)+"/raw="+raw(wire,fail)+"\n"
    return out

def text():
    return "validation\n"+scenario("Text(bad)",False)+"custom\n"+scenario("Number(8)",True)+"success\n"+scenario("Number(7)",False)

def report():
    return (json.dumps(text(),ensure_ascii=False)+"\n").encode()

if __name__=="__main__":
    import sys
    sys.stdout.buffer.write(report())
