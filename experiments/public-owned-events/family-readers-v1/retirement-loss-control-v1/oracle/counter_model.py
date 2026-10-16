"""Source-derived retirement-loss counter for family-readers-v1.

The frozen mutation changes only Log.partitioned's False arm. It leaves the
retained log unchanged but drops the accumulated retired rows from the returned
receipt. This wrapper applies exactly that return-value change to the corrected
normal state model; it does not inspect or transform a generated backend output.
"""
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
SUCCESSOR = HERE.parents[1] / "oracle-successor-v2"
NORMAL_ORACLE = HERE.parents[1] / "oracle"
sys.path.insert(0, str(SUCCESSOR))
sys.path.insert(1, str(NORMAL_ORACLE))
import model as normal_model

_normal_frame = normal_model._frame
EMPTY_RECEIPT = ([], [], [])


def _mutated_frame(runtime):
    # Source path: Log.retire -> partition -> partitioned(False,...). The
    # mutant returns the unchanged retired accumulator, initially [], so the
    # caller receives no retired rows. _frame's retained-log, stream and
    # journal updates are independent of this returned receipt.
    _normal_frame(runtime)
    return EMPTY_RECEIPT


def _with_mutant_frame(call):
    previous = normal_model._frame
    normal_model._frame = _mutated_frame
    try:
        return call()
    finally:
        normal_model._frame = previous


def derive_schema(primary_namespace, foreign_namespace):
    return _with_mutant_frame(
        lambda: normal_model.derive_workshop_for_namespaces(
            primary_namespace, foreign_namespace))


def derive_complete():
    workshop = derive_schema(1, 2)[0]
    garden = derive_schema(3, 4)[0]
    return "Workshop\n" + workshop + "Garden\n" + garden + "\n"


def _retirement_receipts(text, operation):
    """Read one source-labeled family retirement receipt at a time."""
    receipts = []
    cursor = 0
    marker = operation + ":retired("
    while True:
        start = text.find(marker, cursor)
        if start < 0:
            return receipts
        open_paren = start + len(operation + ":retired")
        depth = 0
        end = None
        for index in range(open_paren, len(text)):
            if text[index] == "(":
                depth += 1
            elif text[index] == ")":
                depth -= 1
                if depth == 0:
                    end = index + 1
                    break
        if end is None:
            raise AssertionError("unterminated source-labeled frame receipt")
        receipts.append(text[start:end])
        cursor = end


def _without_frame_receipts(text):
    """Mask only source-labeled frame return values for the differential check."""
    pieces = []
    cursor = 0
    for receipt in _retirement_receipts(text, "frame"):
        start = text.find(receipt, cursor)
        assert start >= 0
        pieces.append(text[cursor:start])
        pieces.append("<FRAME-RETIRE-RETURN>")
        cursor = start + len(receipt)
    pieces.append(text[cursor:])
    return "".join(pieces)


def _selftest():
    normal_workshop = normal_model.derive_workshop_for_namespaces(1, 2)
    normal_garden = normal_model.derive_workshop_for_namespaces(3, 4)
    mutant_workshop = derive_schema(1, 2)
    mutant_garden = derive_schema(3, 4)

    # The source change discards the returned retirement list only. Complete
    # state and ownership observations remain equal in each nominal schema.
    for normal, mutant in ((normal_workshop, mutant_workshop),
                           (normal_garden, mutant_garden)):
        assert normal[1:] == mutant[1:]
        before_receipts = _retirement_receipts(normal[0], "frame")
        after_receipts = _retirement_receipts(mutant[0], "frame")
        assert len(before_receipts) == len(after_receipts) == 2
        assert all(receipt != "frame:retired(Cargo=[],Alerts=[],Crates=[])"
                   for receipt in before_receipts)
        assert after_receipts == ["frame:retired(Cargo=[],Alerts=[],Crates=[])"] * 2
        assert _without_frame_receipts(normal[0]) == _without_frame_receipts(mutant[0])
        normal_shutdown = _retirement_receipts(normal[0], "shutdown")
        mutant_shutdown = _retirement_receipts(mutant[0], "shutdown")
        assert len(normal_shutdown) == len(mutant_shutdown) == 2
        assert normal_shutdown == mutant_shutdown
        assert normal_shutdown[0] != "shutdown:retired(Cargo=[],Alerts=[],Crates=[])"
        assert normal_shutdown[1] == "shutdown:retired(Cargo=[],Alerts=[],Crates=[])"

    complete = derive_complete()
    assert complete.endswith("disposed-all\n\n")
    assert complete.count("frame:retired(Cargo=[],Alerts=[],Crates=[])\n") == 4
    assert complete.count("shutdown:retired(Cargo=") == 4
    print("family reader retirement-loss counter selftest passed")


if __name__ == "__main__":
    _selftest()
