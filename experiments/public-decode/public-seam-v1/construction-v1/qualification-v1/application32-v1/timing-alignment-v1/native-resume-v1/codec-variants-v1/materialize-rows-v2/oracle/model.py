#!/usr/bin/env python3
"""Independent source-derived expected output for codec-variants-v1.

This models the frozen 40 public fixture calls from source/cases.bend. It does
not read compiler output or a runtime receipt. The world facts below follow
fixture.resource, W.create, F.resource_set, Resource.tx_replace, and Tx.finish.
"""

from __future__ import annotations

from fractions import Fraction
import json
import math
import struct
import sys


def record(tag: str, **fields: object) -> dict[str, object]:
    return {"$": tag, **fields}


def number(value: int) -> dict[str, object]:
    return record("Number", value=value)


def signed(negative: bool, magnitude: int) -> dict[str, object]:
    return record("SignedInteger", negative=negative, magnitude=str(magnitude))


def f32_bits(value: float) -> int:
    return struct.unpack(">I", struct.pack(">f", value))[0]


def float_raw(value: float) -> dict[str, object]:
    return record("Float", bits=f32_bits(value))


def binary64(high: int, low: int) -> dict[str, object]:
    return record("Binary64", high=high, low=low)


def text(value: str) -> dict[str, object]:
    return record("Text", value=value)


def utf16(units: list[int]) -> dict[str, object]:
    return record("Utf16Text", units=units)


def boolean(value: bool) -> dict[str, object]:
    return record("Boolean", value=value)


def raw_numeric(value: dict[str, object]):
    tag = value["$"]
    if tag == "Number":
        return Fraction(value["value"])
    if tag == "SignedInteger":
        magnitude = int(value["magnitude"])
        return Fraction(-magnitude if value["negative"] else magnitude)
    if tag == "Float":
        decoded = struct.unpack(">f", struct.pack(">I", value["bits"]))[0]
    elif tag == "Binary64":
        bits = (value["high"] << 32) | value["low"]
        decoded = struct.unpack(">d", struct.pack(">Q", bits))[0]
    else:
        return None
    if math.isnan(decoded):
        return ("nan",)
    if math.isinf(decoded):
        return ("inf", decoded < 0)
    return Fraction.from_float(decoded)


def numeric_equal(left, right) -> bool:
    a, b = raw_numeric(left), raw_numeric(right)
    if a is None or b is None:
        return False
    # decode-data.equal implements SameValueZero for numeric Raw variants.
    if a == ("nan",) or b == ("nan",):
        return a == b
    return a == b


def utf16_units(value: str) -> list[int]:
    raw = value.encode("utf-16-le", errors="surrogatepass")
    return [raw[i] | (raw[i + 1] << 8) for i in range(0, len(raw), 2)]


def raw_equal(left: dict[str, object], right: dict[str, object]) -> bool:
    left_tag, right_tag = left["$"], right["$"]
    if left_tag in ("Number", "SignedInteger", "Float", "Binary64"):
        return right_tag in ("Number", "SignedInteger", "Float", "Binary64") and numeric_equal(left, right)
    if left_tag == "Text" and right_tag == "Text":
        return left["value"] == right["value"]
    if left_tag == "Utf16Text" and right_tag == "Utf16Text":
        return all(unit <= 65535 for unit in left["units"] + right["units"]) and left["units"] == right["units"]
    if left_tag == "Text" and right_tag == "Utf16Text":
        return all(unit <= 65535 for unit in right["units"]) and utf16_units(left["value"]) == right["units"]
    if left_tag == "Utf16Text" and right_tag == "Text":
        return all(unit <= 65535 for unit in left["units"]) and left["units"] == utf16_units(right["value"])
    if left_tag == "Boolean" and right_tag == "Boolean":
        return left["value"] is right["value"]
    if left_tag == "Null" and right_tag == "Null":
        return True
    return False


def accepted(codec: dict[str, object], value: dict[str, object]) -> bool:
    tag = codec["kind"]
    raw_tag = value["$"]
    if tag == "FiniteNumber":
        if raw_tag in ("Number", "SignedInteger"):
            return True
        if raw_tag == "Float":
            return not isinstance(raw_numeric(value), tuple)
        if raw_tag == "Binary64":
            return ((value["high"] >> 20) & 0x7FF) < 0x7FF
        return False
    if tag == "BoolValue":
        return raw_tag == "Boolean"
    if tag == "StringValue":
        if raw_tag == "Text":
            return True
        return raw_tag == "Utf16Text" and all(unit <= 65535 for unit in value["units"])
    if tag in ("LiteralValues", "LiteralRendered"):
        return any(raw_equal(candidate, value) for candidate in codec["values"])
    raise AssertionError(f"unmodeled codec: {tag}")


def expected_error(codec: dict[str, object]) -> str:
    tag = codec["kind"]
    if tag == "FiniteNumber":
        return "finite number"
    if tag == "BoolValue":
        return "boolean"
    if tag == "StringValue":
        return "string"
    if tag == "LiteralValues":
        return "literal"
    if tag == "LiteralRendered":
        return codec["expected"]
    raise AssertionError(f"unmodeled error for codec: {tag}")


def input_view(value: dict[str, object]) -> dict[str, object]:
    return record("InputView", raw=value, words=[71, 72], flags=[True, False])


def owner_view(value: dict[str, object], original: dict[str, object]) -> dict[str, object]:
    return record("View", raw=value, original=original, words=[71, 72], flags=[True, False])


def resource_owner_view(value: dict[str, object], original: dict[str, object]) -> dict[str, object]:
    # fixture.owned initializes resource payloads independently of construct's
    # Input, so its arbitrary affine fields must remain visible in every view.
    return record("View", raw=value, original=original, words=[81, 82], flags=[False, True])


def construct_case(schema: str, label: str, codec: dict[str, object], value: dict[str, object]) -> dict[str, object]:
    recovered = input_view(value)
    if accepted(codec, value):
        # All selected codecs leave these scalar Raw cases canonical as supplied.
        result = record("Constructed", owner=owner_view(value, value), recovered=recovered)
    else:
        result = record("Rejected", input=recovered, error=record(
            "Invalid", path="$", expected=expected_error(codec), actual=value
        ))
    return record("ConstructedCase", schema=schema, label=label, value=result)


def meta() -> dict[str, object]:
    return record(
        "Meta", namespace=1, nextId=1, highWater=0, capacity=1, depth="0",
        events=[], registrations=[], nextSystemId=1, clock=0,
    )


def initial_resource() -> dict[str, object]:
    value = number(100)
    return resource_owner_view(value, value)


def snapshot(resource: dict[str, object]) -> dict[str, object]:
    return record(
        # Array.new(Bool, 0n, False{}) is the one-leaf id-0 sentinel at
        # capacity 1; snapshot serializes that physical array, including it.
        "Snapshot", meta=meta(), live=[False], store=record("Unit"),
        resource=resource, pending=0,
    )


def resource_case(
    schema: str,
    label: str,
    codec: dict[str, object],
    value: dict[str, object],
    abort: bool = False,
) -> dict[str, object]:
    before_resource = initial_resource()
    before = snapshot(before_resource)
    if accepted(codec, value):
        result = record("Replaced", canonical=value)
        # W.replace_resource changes only the resource field; no clock or queue
        # operation occurs. Tx.finish rolls this write back only for abort.
        after_resource = before_resource if abort else resource_owner_view(value, value)
        undo_count = "1"
    else:
        result = record(
            "Refused",
            owner=resource_owner_view(value, value),
            error=record("Invalid", path="$", expected=expected_error(codec), actual=value),
        )
        after_resource = before_resource
        undo_count = "0"
    outcome = record("Failure") if abort else record("Success")
    report = record(
        "ResourceReport", before=before, after=snapshot(after_resource), result=result,
        outcome=outcome, pending=0, undoCount=undo_count,
    )
    return record("ResourceCase", schema=schema, label=label, value=report)


def codec(kind: str, values: list[dict[str, object]] | None = None, expected: str | None = None) -> dict[str, object]:
    return {"kind": kind, "values": values or [], "expected": expected}


def constructor_rows(schema: str) -> list[dict[str, object]]:
    literal_values = [number(1), text("alternate")]
    literal_rendered = [text("alpha")]
    rows = [
        ("finite-number-u32", codec("FiniteNumber"), number(7)),
        ("finite-number-signed", codec("FiniteNumber"), signed(False, 7)),
        ("finite-f32", codec("FiniteNumber"), float_raw(2.5)),
        ("finite-f32-infinity", codec("FiniteNumber"), float_raw(math.inf)),
        ("finite-binary64", codec("FiniteNumber"), binary64(1072693248, 0)),
        ("finite-binary64-infinity", codec("FiniteNumber"), binary64(2146435072, 0)),
        ("boolean-true", codec("BoolValue"), boolean(True)),
        ("boolean-wrong-kind", codec("BoolValue"), float_raw(1.0)),
        ("literal-values-number-float", codec("LiteralValues", literal_values), float_raw(1.0)),
        ("literal-values-mismatch", codec("LiteralValues", literal_values), number(2)),
        ("literal-rendered-text-utf16", codec("LiteralRendered", literal_rendered, "expected alpha"), utf16([97, 108, 112, 104, 97])),
        ("literal-rendered-custom-error", codec("LiteralRendered", literal_rendered, "expected alpha"), utf16([98, 101, 116, 97])),
        ("utf16-string-lone-surrogate", codec("StringValue"), utf16([65, 55296])),
        ("utf16-string-out-of-range", codec("StringValue"), utf16([65536])),
    ]
    return [construct_case(schema, label, selected_codec, value) for label, selected_codec, value in rows]


def resource_rows(schema: str) -> list[dict[str, object]]:
    literal_rendered = [text("alpha")]
    return [
        resource_case(schema, "resource-f32-accepted", codec("FiniteNumber"), float_raw(2.5)),
        resource_case(schema, "resource-binary64-accepted", codec("FiniteNumber"), binary64(1072693248, 0)),
        resource_case(schema, "resource-boolean-accepted", codec("BoolValue"), boolean(True)),
        resource_case(schema, "resource-literal-rendered-refused", codec("LiteralRendered", literal_rendered, "expected alpha"), utf16([98, 101, 116, 97])),
        resource_case(schema, "resource-utf16-refused", codec("StringValue"), utf16([65536])),
        resource_case(schema, "resource-f32-aborted", codec("FiniteNumber"), float_raw(2.5), abort=True),
    ]


def derive() -> bytes:
    rows = []
    for schema in ("First", "Second"):
        rows.extend(constructor_rows(schema))
        rows.extend(resource_rows(schema))
    assert len(rows) == 40
    assert sum(row["$"] == "ConstructedCase" for row in rows) == 28
    assert sum(row["$"] == "ResourceCase" for row in rows) == 12
    return (json.dumps(rows, ensure_ascii=True, separators=(",", ":")) + "\n").encode("ascii")


if __name__ == "__main__":
    sys.stdout.buffer.write(derive())
