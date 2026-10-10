"""Independent #70 provisioning fixture; no compiler/runtime observations."""
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
SEEDED = HERE.parent / "resource-fields-seeded-oracle-v1" / "model.py"
spec = importlib.util.spec_from_file_location("seeded_fields", SEEDED)
seeded = importlib.util.module_from_spec(spec)
spec.loader.exec_module(seeded)


def observation():
    # Reuse the independently authored seeded Before state. Provisioning binds
    # fragments before operational SelectedResources registration, so only the
    # seed's unrelated registration is present and no selected Registry exists.
    before = seeded.scenario("a").split("\n", 1)[0]
    world = before.split("|world{", 1)[1][:-1]
    world = world.replace(
        "registrations=[2:SelectedResources:[First, Second], 1:Unrelated:[unrelated:Read]]|nextSystemId=3",
        "registrations=[1:Unrelated:[unrelated:Read]]|nextSystemId=2",
    )
    assert "SelectedResources" not in world
    rows = ["CanonicalValidation=DuplicateKey{First}", "OrdinaryEntry=SCHEMA_REJECTED"]
    for result in ["DuplicateKey{First}", "UndeclaredDescriptor{Second:Second}", "BUILD_REACHED"]:
        rows.append(result + "|Before{" + world + "}|After{" + world + "}")
    return "\n".join(rows)


def output():
    return (json.dumps(observation()) + "\n").encode()
