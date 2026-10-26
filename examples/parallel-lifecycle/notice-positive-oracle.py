"""Full independent observation for ordinary notice capability specialization."""
from pathlib import Path
import runpy

HERE = Path(__file__).resolve().parent
query = runpy.run_path(str(HERE.parent / "parallel-query" / "oracle.py"))
notice = runpy.run_path(str(HERE / "notice-model.py"))


def scenario(namespace):
    journal = notice["Journal"](namespace)
    reader, registration = journal.register("removed/output")
    assert registration == "registered"
    assert journal.read(reader) == "empty/0"
    # Execute.run is a bare admitted-system invocation, not a completed RootApp
    # update. It advances system time once without journal maintenance.
    state = (f"namespace={namespace};allocator={{{query['allocator'](0)}}};"
             f"input={query['column'](query['INPUTS'], {})};"
             f"output={query['column'](query['INITIAL_OUTPUTS'], {})};"
             "resource=800;events=0;pending=0;"
             "registrations=[1:notice-positive:[removed/output]];"
             "nextSystem=2;clock=0:1:[]")
    return (f"empty/0;reader={reader.text()};"
            f"system={namespace}:1:notice-positive:[removed/output]:0:1;"
            f"world={{journal={{{journal.text()}}};state={{{state}}}}}")


if __name__ == "__main__":
    print("First=" + scenario(1))
    print("Second=" + scenario(2))
