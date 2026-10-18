#!/usr/bin/env python3
"""Independent, source-derived Health256 FailedTxn expected-output model.

The model renders the complete Health256 scenario from the frozen Bend
call graph and runtime operations. It does not load or call Bend observers,
compiled outputs, JavaScript/native backends, or subject-produced artifacts.
"""
from __future__ import annotations

import argparse
import gzip
import hashlib
import json
import os
from pathlib import Path
import sys
from dataclasses import dataclass, field

N = 256
ITERATIONS = 64
EVENT_KEY = "ping"
COMP_ACCESS = ["Vitals", "HealthLedger", "Audit", "ping:write"]
READ_ACCESS = ["ping:read"]
DISPOSE_ACCESS = ["Vitals", "Armor", "Tracked"]


def sh_u(n: int) -> str:
    return str(n)


def sh_bool(v: bool) -> str:
    return "True" if v else "False"


def json_four(v: list[int]) -> str:
    return '{"a":%d,"b":%d,"c":%d,"d":%d}' % tuple(v)


def json_vitals(v: list[int], reserve: int = 9, class_: int = 2) -> str:
    return '{"levels":%s,"reserve":%d,"class":%d}' % (json_four(v), reserve, class_)


def json_armor(v: list[int], grade: int = 3) -> str:
    return '{"layers":%s,"grade":%d}' % (json_four(v), grade)


def json_tracked(group: int = 8) -> str:
    return '{"group":%d}' % group


def json_ledger(v: list[int], epoch: int = 4) -> str:
    return '{"totals":%s,"epoch":%d}' % (json_four(v), epoch)


def lp(s: str) -> str:
    return f"{len(s)}:{s}"


def show_list(xs, render=lambda x: str(x)) -> str:
    # Base.List.show uses a comma followed by a space between elements.
    return "[" + ", ".join(render(x) for x in xs) + "]"


def tree(values: list[str]) -> str:
    if len(values) == 1:
        return "leaf:" + values[0]
    half = len(values) // 2
    return "node(" + tree(values[:half]) + "," + tree(values[half:]) + ")"


@dataclass
class Column:
    values: list[object | None] = field(default_factory=lambda: [None])
    # Source lifecycle list is newest-entry first.
    stamps: list[tuple[int, int, int]] = field(default_factory=list)

    def ensure(self, target: int) -> None:
        while len(self.values) < target:
            self.values.extend([None] * len(self.values))

    def replace(self, idx: int, value: object | None, tick: int, *, present: bool) -> None:
        self.ensure(idx)
        self.values[idx - 1] = value
        if value is None:
            self.stamps = [e for e in self.stamps if e[0] != idx]
            return
        old = next((e for e in self.stamps if e[0] == idx), None)
        added = old[1] if present and old else tick
        # L.set puts the changed entry at the head even when restoring old data.
        self.stamps = [(idx, added, tick)] + [e for e in self.stamps if e[0] != idx]

    def restore(self, idx: int, value: object | None, stamp: tuple[int, int, int] | None) -> None:
        self.ensure(idx)
        self.values[idx - 1] = value
        if stamp is None:
            self.stamps = [e for e in self.stamps if e[0] != idx]
        else:
            self.stamps = [stamp] + [e for e in self.stamps if e[0] != idx]

    def clear_if_sized(self, idx: int) -> None:
        if idx <= len(self.values):
            self.values[idx - 1] = None
            self.stamps = [e for e in self.stamps if e[0] != idx]

    def render(self, kind: str) -> str:
        def value(v):
            if v is None:
                return "none"
            if kind == "main":
                levels, reserve, class_ = v
                return "some(Vitals{" + tree([str(x) for x in levels]) + ";" + str(reserve) + ";" + str(class_) + "})"
            if kind == "aux":
                layers, grade = v
                return "some(Armor{" + tree([str(x) for x in layers]) + ";" + str(grade) + "})"
            return "some(Tracked{" + str(v) + "})"
        vals = tree([value(v) for v in self.values])
        stamps = show_list(self.stamps, lambda e: f"{e[0]}:{e[1]}:{e[2]}")
        return f"Column{{values={vals};stamps={stamps}}}"


@dataclass
class Slot:
    gen: int = 0
    phase: str = "Consumed"


@dataclass
class Allocator:
    next: int = 1
    high: int = 0
    capacity: int = 1
    slots: list[Slot] = field(default_factory=lambda: [Slot()])
    free: list[int] = field(default_factory=list)
    order: list[tuple[int, int]] = field(default_factory=list)

    def reserve(self) -> tuple[int, int]:
        if self.free:
            idx = self.free.pop(0)
            gen = self.slots[idx].gen
        else:
            idx = self.next
            if idx >= self.capacity:
                self.capacity *= 2
                self.slots.extend(Slot() for _ in range(self.capacity - len(self.slots)))
            gen = 0
            self.next += 1
            self.high = idx
        self.slots[idx] = Slot(gen, "Pending")
        key = (idx, gen)
        self.order.append(key)
        return key

    def abandon(self, key: tuple[int, int]) -> None:
        idx, gen = key
        if idx < len(self.slots) and self.slots[idx].gen == gen and self.slots[idx].phase == "Pending":
            self.slots[idx].phase = "Consumed"
            self.order = [x for x in self.order if x != key]

    def activate(self, key: tuple[int, int]) -> None:
        idx, gen = key
        assert self.slots[idx].gen == gen and self.slots[idx].phase == "Pending"
        self.slots[idx].phase = "Live"

    def release(self, key: tuple[int, int]) -> None:
        idx, gen = key
        assert self.slots[idx].gen == gen and self.slots[idx].phase == "DeadRetained"
        self.slots[idx] = Slot(gen + 1, "Free")
        self.free.insert(0, idx)
        self.order = [x for x in self.order if x != key]

    def is_live(self, key: tuple[int, int]) -> bool:
        idx, gen = key
        return idx < len(self.slots) and self.slots[idx].gen == gen and self.slots[idx].phase == "Live"

    def visible(self) -> list[tuple[int, int]]:
        return [key for key in self.order if self.is_live(key)]

    def render(self) -> str:
        slots = tree([f"{s.gen}:{s.phase}" for s in self.slots])
        order = show_list(self.order, lambda k: f"{k[0]}:{k[1]}")
        return (f"next={self.next};high={self.high};capacity={self.capacity};depth={self.capacity.bit_length()-1};"
                f"slots={slots};free={show_list(self.free)};order={order}")


@dataclass
class World:
    ns: int
    allocator: Allocator = field(default_factory=Allocator)
    main: Column = field(default_factory=Column)
    aux: Column = field(default_factory=Column)
    flag: Column = field(default_factory=Column)
    ledger: list[int] = field(default_factory=lambda: [0, 101, 102, 103])
    audit: list[str] = field(default_factory=list)  # cons order, newest first
    events: list[int] = field(default_factory=list)
    pending: list[str] = field(default_factory=list)  # command kinds, newest first
    registrations: list[tuple[int, str, list[str]]] = field(default_factory=list)
    next_system: int = 1
    clock: int = 0

    def reg(self, name: str, access: list[str]) -> int:
        ident = self.next_system
        self.next_system += 1
        self.registrations.insert(0, (ident, name, list(access)))
        return ident

    def reserve(self) -> tuple[int, int]:
        return self.allocator.reserve()

    def component_set(self, key: tuple[int, int], value: object, kind: str) -> None:
        assert self.allocator.is_live(key) or self.allocator.slots[key[0]].phase == "Pending"
        self.clock += 1
        col = self.main if kind == "main" else self.aux if kind == "aux" else self.flag
        present = key[0] <= len(col.values) and col.values[key[0] - 1] is not None
        col.replace(key[0], value, self.clock, present=present)

    def publish_event(self, n: int) -> None:
        self.events.append(n)


def fmt_handle(ns: int, key: tuple[int, int]) -> str:
    return f"{ns}:{key[0]}:{key[1]}"


def event_text(n: int) -> str:
    return f"Original{{{n}}}"


def audit_effect(text: str) -> str:
    return lp(text)


def world_text(w: World) -> str:
    main = w.main.render("main")
    aux = w.aux.render("aux")
    flag = w.flag.render("flag")
    store = f"main={{{main}}};aux={{{aux}}};flag={{{flag}}}"
    ledger = "HealthLedger{" + tree([str(x) for x in w.ledger]) + ";4}"
    audit = "Recorded" + show_list(w.audit, audit_effect)
    resources = f"ledger={{{ledger}}};audit={{{audit}}}"
    ev = show_list(w.events, event_text)
    kinds = "".join(k + ";" for k in w.pending) + "end"
    regs = show_list(w.registrations, lambda r: f"{r[0]}:{r[1]}:{show_list(r[2],lambda x:x)}")
    return (f"namespace={w.ns}|allocator={{{w.allocator.render()}}}|store={{{store}}}|resource={{{resources}}}|"
            f"events={ev}|pending={len(w.pending)}:{kinds}|registrations={regs}|nextSystem={w.next_system}|clock={w.clock}")


def access_json(kind: str, value) -> str:
    if value is None:
        return "Absent"
    if kind == "main":
        levels, reserve, class_ = value
        return "Found{" + json_vitals(levels, reserve, class_) + "}"
    if kind == "aux":
        layers, grade = value
        return "Found{" + json_armor(layers, grade) + "}"
    return "Found{" + json_tracked(value) + "}"


def get_vitals(w: World, key: tuple[int, int]) -> tuple[str, tuple[list[int], int, int] | None]:
    if not w.allocator.is_live(key):
        return "Missing", None
    idx = key[0]
    if idx > len(w.main.values) or w.main.values[idx - 1] is None:
        return "Absent", None
    levels, reserve, class_ = w.main.values[idx - 1]
    return "Found{" + json_vitals(levels, reserve, class_) + "}", (list(levels), reserve, class_)


def rows_text(w: World) -> str:
    def observed(kind: str, value) -> str:
        if value is None:
            return "ComponentAbsent"
        if kind == "main":
            levels, reserve, class_ = value
            rendered = json_vitals(levels, reserve, class_)
        elif kind == "aux":
            layers, grade = value
            rendered = json_armor(layers, grade)
        else:
            rendered = json_tracked(value)
        return "Found(" + rendered + ")"

    out = []
    for idx, gen in w.allocator.visible():
        if idx > len(w.main.values) or w.main.values[idx - 1] is None:
            continue
        m = w.main.values[idx - 1]
        a = w.aux.values[idx - 1] if idx <= len(w.aux.values) else None
        f = w.flag.values[idx - 1] if idx <= len(w.flag.values) else None
        out.append(f"handle={fmt_handle(w.ns,(idx,gen))};main={observed('main',m)};aux={observed('aux',a)};flag={observed('flag',f)}")
    return show_list(out)


def reservation(key: tuple[int, int] | None, ns: int) -> str:
    return "None" if key is None else "Some{Reserved(" + fmt_handle(ns, key) + ")}"


def maybe_handle(key: tuple[int, int] | None, ns: int) -> str:
    return "None" if key is None else "Some{" + fmt_handle(ns, key) + "}"


@dataclass
class Batch:
    tick: int
    values: list[int]


@dataclass
class Position:
    ident: int
    cursor: int
    registered: int


@dataclass
class Meta:
    batches: list[Batch] = field(default_factory=list)
    positions: list[Position] = field(default_factory=list)  # newest reader first
    journal: list[Batch] = field(default_factory=list)
    route_tick: int = 0
    failures_tick: int = 0
    b_cursor: int = 0
    pub_cursor: int = 0

    def pos(self, ident: int) -> Position | None:
        return next((p for p in self.positions if p.ident == ident), None)

    def add_position_if_missing(self, ident: int, registered: int) -> None:
        if self.pos(ident) is None:
            self.positions.insert(0, Position(ident, 0, registered))

    def set_cursor(self, ident: int, cursor: int, registered: int | None = None) -> None:
        p = self.pos(ident)
        if p is None:
            self.positions.insert(0, Position(ident, cursor, registered if registered is not None else 0))
        else:
            p.cursor = cursor

    def events_since(self, ident: int) -> list[int]:
        p = self.pos(ident)
        cursor = p.cursor if p else 0
        return [n for b in self.batches if b.tick > cursor for n in b.values]

    def ingest(self, w: World, tick: int) -> None:
        # Mixed.ingest replaces the failure-runtime tick at every sync.
        self.failures_tick = tick
        seen = sum(len(b.values) for b in self.journal)
        fresh = w.events[seen:]
        if fresh:
            b = Batch(tick, list(fresh))
            self.journal.append(b)
            self.batches.append(Batch(tick, list(fresh)))

    def render(self) -> str:
        bs = show_list(self.batches, lambda b: f"tick={b.tick};values={show_list(b.values,event_text)}")
        ps = show_list(self.positions, lambda p: f"id={p.ident};cursor={p.cursor};registered={p.registered}")
        stream = f"domain=ping;batches={bs};positions={ps};nextReader=3;frameStart=0;boundary=0;capacity=65536;dropped=0"
        jb = show_list(self.journal, lambda b: f"tick={b.tick};values={show_list(b.values)}")
        typed = f"typed={{family={{ping={{{stream}}}}};owner=Unit;journal={jb};frameStart=0}}"
        failures = f"failures={{domains=[];positions=[];tick={self.failures_tick};frameStart=0;boundary=0;capacity=65536;nextReader=1}}"
        return typed + ";" + failures


@dataclass
class Frame:
    first: tuple[int, int]
    second: tuple[int, int]
    iteration: int = 0
    phase: int = 0
    pending_a: tuple[int, int] | None = None
    retry_b: tuple[int, int] | None = None
    failed: list[tuple[int, int]] = field(default_factory=list)
    calls: list[str] = field(default_factory=list)


@dataclass
class Model:
    world: World
    meta: Meta
    a_id: int
    b_id: int
    pub_id: int
    dispose_id: int
    a_capture: int
    b_capture: int
    a_key: tuple[int, int]
    b_key: tuple[int, int]
    frame: Frame
    boundaries: list[str] = field(default_factory=list)
    schedule_texts: list[str] = field(default_factory=list)
    spool: Path | None = None

    def provider_text(self, pub: bool) -> str:
        ident = 2 if pub else 1
        name = "FailedTxn/Publications" if pub else "FailedTxn/B-reader"
        cursor = self.meta.pub_cursor if pub else self.meta.b_cursor
        access = READ_ACCESS if pub else READ_ACCESS + COMP_ACCESS
        owner = f"facts={{ns={self.world.ns};id={ident};name={name};access={show_list(access,lambda x:x)}}};reader={{namespace={self.world.ns};id={ident};registryId={ident}}}"
        return (f"registry={{ns={self.world.ns};id={ident};name={name};access={show_list(access,lambda x:x)};cursor={cursor}}};"
                f"parameter={show_list(READ_ACCESS if pub else READ_ACCESS + COMP_ACCESS,lambda x:x)};declaration=Unit;owners={{{owner}}}")

    def instance_text(self, a: bool) -> str:
        if a:
            return (f"namespace={self.world.ns};id={self.a_id};name={lp('FailedTxn/A')};access={show_list(COMP_ACCESS,lambda x:lp(x))};"
                    f"local={{A{{capture={tree([str(self.a_capture), '101'])}}}}}")
        return (f"namespace={self.world.ns};id={self.b_id};name={lp('FailedTxn/B')};access={show_list(COMP_ACCESS,lambda x:lp(x))};"
                f"local={{B{{capture={tree([str(self.b_capture), '102'])};reader={{{self.provider_text(False)}}}}}}}")

    def meta_text(self) -> str:
        return self.meta.render()

    def dispose_registry_text(self) -> str:
        return (f"namespace={self.world.ns};id={self.dispose_id};name={lp('FailedTxn/DisposeTransient')};"
                f"access={show_list(DISPOSE_ACCESS,lambda x:lp(x))};cursor=0")

    def registered_text(self) -> str:
        registered = (f"a={{{self.instance_text(True)}}};b={{{self.instance_text(False)}}};"
                      f"publications={{{self.provider_text(True)}}};meta={{{self.meta_text()}}};tick={self.meta.route_tick}")
        return registered

    def owner_text(self) -> str:
        registered = self.registered_text()
        fr = (f"first={fmt_handle(self.world.ns,self.frame.first)};second={fmt_handle(self.world.ns,self.frame.second)};"
              f"iteration={self.frame.iteration};phase={self.frame.phase};pendingA={maybe_handle(self.frame.pending_a,self.world.ns)};"
              f"retryB={maybe_handle(self.frame.retry_b,self.world.ns)};failed={show_list(self.frame.failed,lambda k:fmt_handle(self.world.ns,k))};"
              f"calls={show_list(self.frame.calls,lp)}")
        return f"registered={{{registered}}};dispose={{{self.dispose_registry_text()}}};frame={{{fr}}}"

    def state_prefix(self) -> str:
        return (f"namespace={self.world.ns};ids={show_list([self.a_id,self.b_id,self.pub_id,self.dispose_id])};"
                f"world={{{world_text(self.world)}}};owners={{{self.owner_text()}}};")

    def state_small(self) -> str:
        return self.state_prefix() + "boundaries=[];schedules=" + show_list(self.schedule_texts, lp) + ";status=Complete"

    def append_boundary(self, phase_name: str) -> None:
        w = self.world
        pending = "None" if self.frame.pending_a is None else get_vitals(w, self.frame.pending_a)[0]
        failed_key = self.frame.failed[-1] if self.frame.failed else None
        failed = "None" if failed_key is None else get_vitals(w, failed_key)[0]
        retry = "None" if self.frame.retry_b is None else get_vitals(w, self.frame.retry_b)[0]
        all_failed = [get_vitals(w, h)[0] for h in self.frame.failed]
        parts = (f"iteration={self.frame.iteration};phase={lp(phase_name)};before={{{world_text(w)}}};rows={rows_text(w)};"
                 f"pending={pending};failed={failed};retry={retry};allFailed={show_list(all_failed,lp)};"
                 f"after={{{world_text(w)}}};owners={{{self.registered_text()}}}")
        assert self.spool is not None
        with self.spool.open("a", encoding="ascii") as f:
            f.write(parts + "\n")

    def schedule(self, phase: int, steps: list[str], req: list[str], obs: list[str], failed: bool = False) -> None:
        name = f"FailedTxn/phase{phase}"
        self.schedule_texts.append(
            f"namespace={self.world.ns};name={lp(name)};steps={show_list(steps)};requirements={show_list(req)};"
            f"failed={sh_bool(failed)};observations={show_list(obs)}")

    def request_audit(self, who: str, iteration: int, capture: int) -> None:
        effect = json.dumps({"who": who, "iteration": iteration, "capture": capture}, separators=(",", ":"))
        self.world.audit.insert(0, effect)

    def snapshot_component(self, col: Column, idx: int):
        value = col.values[idx - 1] if idx <= len(col.values) else None
        stamp = next((e for e in col.stamps if e[0] == idx), None)
        return value, stamp

    def set_component_tx(self, key: tuple[int, int], value: tuple[list[int], int, int], *, outcome_success: bool) -> str:
        idx = key[0]
        col = self.world.main
        old_value, old_stamp = self.snapshot_component(col, idx)
        self.world.component_set(key, value, "main")
        return "Found{" + json_vitals(value[0], value[1], value[2]) + "}"

    def reserve_tx(self, payload: tuple[list[int], int, int]) -> tuple[tuple[int, int], str]:
        key = self.world.reserve()
        # The private deferred spawn changes the reservation to Pending before
        # the callback's read of the actual returned full handle.
        return key, "Vitals"

    def prefinish_facts(self, undo: int, event: int | None) -> str:
        evs = [] if event is None else [event_text(event)]
        kinds = "Raw;end"
        return (f"undo={undo};commands=1;kinds={kinds};events={show_list(evs)};trace=Off{{}};"
                f"world={{{world_text(self.world)}}}")

    def callback_text(self, *, who: str, iteration: int, capture: int, key: tuple[int, int] | None,
                      payload: tuple[list[int], int, int] | None, writes: list[str], ledger: list[int],
                      reading: list[int], outcome_success: bool, facts: str, prime: bool = False) -> str:
        if prime:
            reserved = "None"
            payload_text = "None"
            write_text = "[]"
            ledger_text = "None"
            pending_lookup = "None"
            rejected = "None"
            err = "None"
            outcome = "Success"
            read_text = "values=[];lagged=False"
        else:
            reserved = reservation(key, self.world.ns)
            assert payload is not None
            payload_text = "Some{" + json_vitals(payload[0], payload[1], payload[2]) + "}"
            write_text = show_list(writes)
            ledger_text = "Some{" + json_ledger(ledger) + "}"
            pending_lookup = "Some{Missing}"
            rejected = "None"
            err = "None"
            outcome = "Success" if outcome_success else "Failure{7}"
            read_text = "Unit" if who == "A" else "values=" + show_list(reading,event_text) + ";lagged=False"
        return (f"outcome={outcome};reading={{{read_text}}};reservation={reserved};payload={payload_text};writes={write_text};"
                f"ledger={ledger_text};rejected={rejected};error={err};pendingLookup={pending_lookup}")

    def do_a(self, iteration: int) -> None:
        self.frame.phase = 1
        before_instance = self.instance_text(True)
        self.a_capture += 1
        cap = self.a_capture
        old_levels, reserve, class_ = self.world.main.values[self.a_key[0] - 1]
        new_levels = [old_levels[0] + 1, *old_levels[1:]]
        # Keep the exact pre-write state for the independent Tx journal model.
        old_val, old_stamp = self.snapshot_component(self.world.main, self.a_key[0])
        write = self.set_component_tx(self.a_key, (new_levels, reserve, class_), outcome_success=True)
        self.world.ledger[0] += 1
        # Resource-field write has no component clock.
        payload = ([iteration, 20, 30, 40], 9, 2)
        key, _ = self.reserve_tx(payload)
        event = 2 * iteration
        self.request_audit("A", iteration, cap)
        facts = self.prefinish_facts(3, event)
        cb = self.callback_text(who="A", iteration=iteration, capture=cap, key=key,
                                payload=payload, writes=[write], ledger=list(self.world.ledger),
                                reading=[], outcome_success=True, facts=facts)
        call = f"A{{outcome=Success;callback={{{cb}}};facts={{{facts}}}}}"
        # On first failed A-system? Not in this scenario; all A calls commit.
        self.world.pending.insert(0, "Raw")
        self.world.publish_event(event)
        self.frame.pending_a = key
        self.frame.calls.append(f"beforeLocal={{{before_instance}}};afterLocal={{{self.instance_text(True)}}};call={{{call}}}")

    def _reader_attempt(self, ident: int, *, callback_kind: str, iteration: int, fail: bool = False,
                        prime: bool = False) -> tuple[list[int], int, int]:
        """Run one typed reader boundary; returns (values, syncEpoch, routeTick)."""
        epoch = max(1, self.meta.route_tick, self.meta.failures_tick, self.world.clock)
        self.meta.ingest(self.world, epoch)
        self.world.clock += 1
        attempt_tick = epoch + 1
        self.meta.route_tick = attempt_tick
        pos = self.meta.pos(ident)
        if pos is None:
            # prepare reads at attempt_tick; completed(False) activates the
            # first position at readThrough - 1 = epoch - 1.
            self.meta.add_position_if_missing(ident, epoch - 1)
            pos = self.meta.pos(ident)
        assert pos is not None
        values = self.meta.events_since(ident)
        return values, epoch, attempt_tick

    def do_b(self, iteration: int, *, fail: bool, prime: bool = False) -> None:
        self.frame.phase = 0 if prime else 1 if fail else 3
        old_registry_cursor = self.meta.b_cursor
        before_local = self.instance_text(False)
        values, epoch, attempt_tick = self._reader_attempt(1, callback_kind="B", iteration=iteration, fail=fail, prime=prime)
        self.b_capture += 1
        capture = self.b_capture
        callback_facts = ""
        reservation_key = None
        payload = None
        writes: list[str] = []
        ledger_view: list[int] | None = None
        old_component = None
        old_stamp = None
        if not prime:
            old_component, old_stamp = self.snapshot_component(self.world.main, self.b_key[0])
            old_levels, reserve, class_ = old_component
            first_levels = [old_levels[0] + 10, *old_levels[1:]]
            writes.append(self.set_component_tx(self.b_key, (first_levels, reserve, class_), outcome_success=not fail))
            second_levels = [old_levels[0] + 30, *old_levels[1:]]
            writes.append(self.set_component_tx(self.b_key, (second_levels, reserve, class_), outcome_success=not fail))
            self.world.ledger[0] += 100
            payload = ([iteration, 200, 300, 400], 9, 2)
            reservation_key, _ = self.reserve_tx(payload)
            ev = 2 * iteration + 1
            self.request_audit("B", iteration, capture)
            undo = 0 if prime else 4
            callback_facts = self.prefinish_facts(undo, ev)
            ledger_view = list(self.world.ledger)
        else:
            callback_facts = f"undo=0;commands=0;kinds=end;events=[];trace=Off{{}};world={{{world_text(self.world)}}}"
        cb = self.callback_text(who="B", iteration=iteration, capture=capture, key=reservation_key,
                                payload=payload, writes=writes, ledger=ledger_view or [], reading=values,
                                outcome_success=not fail, facts=callback_facts, prime=prime)
        if prime:
            reader_read = f"callback={{{cb}}};facts={{{callback_facts}}}"
            output = f"Some{{{reader_read}}}"
            status = 0
            err = "None"
        else:
            reader_read = f"callback={{{cb}}};facts={{{callback_facts}}}"
            output = f"Some{{{reader_read}}}"
            status = 1 if fail else 0
            err = "Some{7}" if fail else "None"
        before = self.provider_text(False)
        if not fail and not prime:
            self.world.pending.insert(0, "Raw")
            self.world.publish_event(2 * iteration + 1)
        if not fail:
            # prepare returns readThrough=attempt_tick - 1 = epoch. The stream
            # and Sys.Registry cursors are separate values.
            self.meta.set_cursor(1, epoch)
            self.meta.b_cursor = self.world.clock
            self.meta.ingest(self.world, attempt_tick)
        else:
            # CallbackFailed skips RP.commit, after_success, and Sys cursor
            # completion. Preparation's position activation stays.
            pass
        after = self.provider_text(False)
        if prime:
            call = f"B{{status=0;error=None;output={output}}}"
        else:
            call = f"B{{status={status};error={err};output={output}}}"
        self.b_capture = capture
        self.frame.calls.append(f"beforeLocal={{{before_local}}};afterLocal={{{self.instance_text(False)}}};call={{{call}}}")
        if not prime:
            if fail:
                self.frame.failed.append(reservation_key)
                # Failure replays component/resource inverses, but preserves
                # clock, request-side Audit, and other owners. Its allocation
                # inverse abandons the new reservation without freeing it.
                assert old_component is not None
                self.world.main.restore(self.b_key[0], old_component, old_stamp)
                self.world.ledger[0] -= 100
                self.world.allocator.abandon(reservation_key)
            else:
                self.frame.retry_b = reservation_key
        # The caller uses the stream's captured values to form output text.

    def do_publication(self, phase: int, iteration: int, prime: bool = False) -> None:
        self.frame.phase = phase
        epoch = max(1, self.meta.route_tick, self.meta.failures_tick, self.world.clock)
        self.meta.ingest(self.world, epoch)
        self.world.clock += 1
        route_tick = epoch + 1
        self.meta.route_tick = route_tick
        if self.meta.pos(2) is None:
            self.meta.add_position_if_missing(2, epoch - 1)
        view = self.meta.events_since(2)
        before = self.provider_text(True)
        self.meta.set_cursor(2, epoch)
        # Ordinary tracked Registry cursor captures the post-boundary World clock.
        self.meta.pub_cursor = self.world.clock
        self.meta.ingest(self.world, route_tick)
        after = self.provider_text(True)
        read = (f"Some{{phase={phase};iteration={iteration};view={{values={show_list(view,event_text)};lagged=False}}}}")
        self.frame.calls.append(f"Publications{{before={{{before}}};after={{{after}}};status=0;read={read}}}")

    def do_barrier_spawns(self) -> None:
        # Each successful Tx prepends its reversed command buffer to the
        # global queue. W.drain_fifo recurses through the tail before applying
        # the head, so the pending list's order is reversed at application.
        pending = list(self.world.pending)
        self.world.pending.clear()
        # Retry B is at the pending head, but A's older command applies first.
        keys = [self.frame.pending_a, self.frame.retry_b]
        assert len(pending) == len(keys) == 2
        for key in keys:
            assert key is not None
            self.world.allocator.activate(key)
            idx = key[0]
            iteration = self.frame.iteration
            is_a = key == self.frame.pending_a
            payload = ([iteration, 20, 30, 40], 9, 2) if is_a else ([iteration, 200, 300, 400], 9, 2)
            self.world.component_set(key, payload, "main")

    def do_dispose(self) -> None:
        keys = [self.frame.pending_a, self.frame.retry_b]
        assert all(k is not None for k in keys)
        statuses = ["Accepted", "Accepted"]
        facts = (f"undo=0;commands=2;kinds=Raw;Raw;end;events=[];trace=Off{{}};"
                 f"world={{{world_text(self.world)}}}")
        self.frame.calls.append(f"Dispose{{statuses={show_list(statuses)};facts={{{facts}}}}}")
        self.world.pending = ["Raw", "Raw"]
        for key in keys:
            idx, gen = key
            self.world.allocator.slots[idx].phase = "DeadRetained"
            self.world.main.clear_if_sized(idx)
            self.world.aux.clear_if_sized(idx)
            self.world.flag.clear_if_sized(idx)
            self.world.allocator.release(key)
        self.world.pending.clear()


def empty_world_text(ns: int) -> str:
    # Initial W.World after the actual public factory, before seed transaction.
    w = World(ns)
    return world_text(w)


def populate_seed(world: World, count: int = N) -> list[tuple[int, int]]:
    reservations = []
    for j in range(count):
        key = world.reserve()
        reservations.append(key)
    # Seed transaction commits all Raw spawn commands, in reservation order.
    for j, key in enumerate(reservations):
        world.allocator.activate(key)
        levels = [j, j+1, j+2, j+3]
        world.component_set(key, (levels, 9, 2), "main")
        if j % 3 == 0:
            world.component_set(key, ([1,2,3,4], 3), "aux")
        if j % 3 == 1:
            world.component_set(key, 8, "flag")
    return reservations


def setup_model(ns: int, count: int = N) -> tuple[World, list[tuple[int,int]], Model]:
    w = World(ns)
    reservations = populate_seed(w, count)
    # Five public registrations, insertion newest first.
    b_reader = w.reg("FailedTxn/B-reader", READ_ACCESS + COMP_ACCESS)
    pub_id = w.reg("FailedTxn/Publications", READ_ACCESS)
    a_id = w.reg("FailedTxn/A", COMP_ACCESS)
    b_id = w.reg("FailedTxn/B", COMP_ACCESS)
    dispose_id = w.reg("FailedTxn/DisposeTransient", DISPOSE_ACCESS)
    # Family.start inherits the seed World clock for failure state while its
    # route cursor begins independently at zero.
    meta = Meta(failures_tick=w.clock)
    model = Model(w, meta, a_id, b_id, pub_id, dispose_id, 0, 0,
                  reservations[0], reservations[1], Frame(reservations[0], reservations[1]))
    return w, reservations, model


def seed_pending_world(ns: int, count: int = N) -> World:
    w = World(ns)
    keys = []
    for _ in range(count):
        keys.append(w.reserve())
    w.pending = ["Raw"] * count
    return w


def schedule0(model: Model) -> None:
    model.frame.phase = 0
    model.do_b(0, fail=False, prime=True)
    model.do_publication(0, 0, prime=True)
    model.schedule(0, [f"System{{{model.b_id};0}}", f"System{{{model.pub_id};0}}"], ["Service{1}"],
                   [f"Ran{{{model.b_id}}}", f"Ran{{{model.pub_id}}}"])


def do_iteration(model: Model, i: int) -> None:
    f = model.frame
    f.iteration = i
    f.phase = 1
    f.pending_a = None
    f.retry_b = None
    model.do_a(i)
    model.do_b(i, fail=True)
    model.schedule(1, [f"System{{{model.a_id};0}}", f"System{{{model.b_id};0}}"], ["Service{1}"],
                   [f"Ran{{{model.a_id}}}", f"Ran{{{model.b_id}}}"], failed=True)
    model.append_boundary("failed-before-barrier")

    model.frame.phase = 2
    model.do_publication(2, i)
    model.schedule(2, [f"System{{{model.pub_id};0}}"], [], [f"Ran{{{model.pub_id}}}"])

    model.frame.phase = 3
    model.do_b(i, fail=False)
    model.schedule(3, [f"System{{{model.b_id};0}}"], ["Service{1}"], [f"Ran{{{model.b_id}}}"])
    model.append_boundary("retry-before-barrier")

    model.frame.phase = 4
    model.do_publication(4, i)
    model.schedule(4, [f"System{{{model.pub_id};0}}"], [], [f"Ran{{{model.pub_id}}}"])

    model.frame.phase = 5
    model.do_barrier_spawns()
    model.schedule(5, ["Barrier"], [], ["Applied"])
    model.append_boundary("applied-FIFO")

    model.frame.phase = 6
    model.do_dispose()
    model.schedule(6, [f"System{{{model.dispose_id};0}}", "Barrier"], [],
                   [f"Ran{{{model.dispose_id}}}", "Applied"])
    model.append_boundary("disposed")


def write_state(prefix: str, model: Model, stream, *, boundaries: Path | None = None) -> None:
    stream.write(prefix)
    stream.write(model.state_prefix())
    stream.write("boundaries=[")
    first = True
    if boundaries is not None:
        with boundaries.open("r", encoding="ascii") as f:
            for line in f:
                if not first:
                    stream.write(", ")
                stream.write(line.rstrip("\n"))
                first = False
    stream.write("];schedules=")
    stream.write(show_list(model.schedule_texts, lp))
    stream.write(";status=Complete}\n")


def setup_output(count: int, iterations: int, ns: int, stream) -> tuple[Model, Path]:
    # Emit created, seedPending, and seedApplied from independent runtime state.
    empty = World(ns)
    stream.write(f"count={count};iterations={iterations};created={{{world_text(empty)}}}\n")
    pending = seed_pending_world(ns, count)
    pending_keys = pending.allocator.order[:]
    reservations_text = show_list([f"Reserved({fmt_handle(ns,k)})" for k in pending_keys])
    stream.write(f"seedOutcome=Success;reservations={reservations_text}\n")
    stream.write(f"seedPending={{{world_text(pending)}}}\n")
    # The modeled seed barrier applies the same reservations FIFO.
    # Seed application is still on the pre-registration World. Registrations
    # happen only after this public barrier has completed.
    seed_applied = World(ns)
    reservations = populate_seed(seed_applied, count)
    stream.write(f"seedApplied={{{world_text(seed_applied)}}}\n")
    # Registration has already happened in setup_model; preserve initial state.
    _, reservations, model = setup_model(ns, count)
    stream.write(f"registered={{{model.state_small()}}}\n")
    spool = Path(f"/tmp/failedtxn-health256-oracle-ns-{ns}-boundaries.txt")
    if spool.exists():
        spool.unlink()
    model.spool = spool
    schedule0(model)
    # The primed state has only phase0 schedule and no boundaries.
    stream.write(f"primed={{{model.state_small()}}}\n")
    return model, spool


class TeeHash:
    def __init__(self, raw_path: Path, gz_path: Path):
        self.raw = raw_path.open("wb")
        self.gz_file = gz_path.open("wb")
        self.gz = gzip.GzipFile(filename="", mode="wb", fileobj=self.gz_file, mtime=0, compresslevel=9)
        self.hash = hashlib.sha256()
        self.size = 0

    def write(self, text: str) -> None:
        data = text.encode("utf-8")
        self.raw.write(data)
        self.gz.write(data)
        self.hash.update(data)
        self.size += len(data)

    def close(self):
        self.raw.close()
        self.gz.close()
        self.gz_file.close()


def generate(outdir: Path, count: int = N, iterations: int = ITERATIONS) -> dict:
    outdir.mkdir(parents=True, exist_ok=True)
    raw = outdir / "expected.stdout"
    gz = outdir / "expected.stdout.gz"
    tee = TeeHash(raw, gz)
    try:
        for name, ns in (("warmup", 1), ("measured", 2)):
            tee.write(name + "={")
            model, spool = setup_output(count, iterations, ns, tee)
            for i in range(iterations):
                do_iteration(model, i)
            write_state("final={", model, tee, boundaries=spool)
            tee.write("}\n")
            spool.unlink()
        # both host roots are forced in-process; no namespace reset is modeled
    finally:
        tee.close()
    result = {"path": str(raw), "gzip": str(gz), "sha256": tee.hash.hexdigest(), "bytes": tee.size}
    (outdir / "EXPECTED-META.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    return result


def self_check() -> None:
    count = N
    seed_clock = count + sum(1 for j in range(count) if j % 3 in (0, 1))
    world, reservations, model = setup_model(1, count)
    assert world.ns == 1
    assert world.clock == seed_clock
    assert model.meta.route_tick == 0 and model.meta.failures_tick == seed_clock
    assert len(reservations) == count
    assert reservations[0] == (1, 0) and reservations[-1] == (count, 0)
    assert world.allocator.next == count + 1 and world.allocator.high == count
    assert world.allocator.capacity == 512 and len(world.allocator.slots) == 512
    assert world.ledger == [0, 101, 102, 103]
    assert world.audit == []
    assert world.main.values[0] == ([0, 1, 2, 3], 9, 2)
    assert world.main.values[count - 1] == ([count - 1, count, count + 1, count + 2], 9, 2)
    assert sum(value is not None for value in world.aux.values) == (count + 2) // 3
    assert sum(value is not None for value in world.flag.values) == (count + 1) // 3
    assert all(value is None or value[1] == 3 for value in world.aux.values)
    assert all(value is None or value == 8 for value in world.flag.values)

    model.spool = Path("/tmp/failedtxn-health256-oracle-selfcheck-boundaries.txt")
    model.spool.unlink(missing_ok=True)
    schedule0(model)
    assert (world.clock, model.meta.route_tick, model.meta.failures_tick) == (seed_clock + 2,) * 3
    assert (model.meta.b_cursor, model.meta.pub_cursor) == (seed_clock + 1, seed_clock + 2)
    assert [(p.ident, p.cursor, p.registered) for p in model.meta.positions] == [
        (2, seed_clock + 1, seed_clock), (1, seed_clock, seed_clock - 1)
    ]

    model.frame.iteration = 0
    model.do_a(0)
    assert world.main.values[0] == ([1, 1, 2, 3], 9, 2)
    assert world.ledger == [1, 101, 102, 103]
    assert world.audit == ['{"who":"A","iteration":0,"capture":1}']
    model.do_b(0, fail=True)
    # Failed B restores its component and Ledger writes; the independent
    # Audit service effect and Local capture remain visible.
    assert world.main.values[1] == ([1, 2, 3, 4], 9, 2)
    assert world.ledger == [1, 101, 102, 103]
    assert model.b_capture == 2
    assert world.audit[:2] == [
        '{"who":"B","iteration":0,"capture":2}',
        '{"who":"A","iteration":0,"capture":1}',
    ]
    model.do_publication(2, 0)
    model.do_b(0, fail=False)
    assert world.main.values[1] == ([31, 2, 3, 4], 9, 2)
    assert world.ledger == [101, 101, 102, 103]
    assert model.b_capture == 3
    model.do_publication(4, 0)
    model.do_barrier_spawns()
    assert world.main.values[count] == ([0, 20, 30, 40], 9, 2)
    assert world.main.values[count + 2] == ([0, 200, 300, 400], 9, 2)
    assert all(world.aux.values[i] is None if i < len(world.aux.values) else True for i in (count, count + 2))
    assert all(world.flag.values[i] is None if i < len(world.flag.values) else True for i in (count, count + 2))
    assert model.world.main.stamps[:2] == [
        (count + 3, seed_clock + 13, seed_clock + 13),
        (count + 1, seed_clock + 12, seed_clock + 12),
    ]
    assert (world.clock, model.meta.route_tick, model.meta.failures_tick) == (seed_clock + 13, seed_clock + 11, seed_clock + 11)
    assert (model.meta.b_cursor, model.meta.pub_cursor) == (seed_clock + 10, seed_clock + 11)
    assert [(b.tick, b.values) for b in model.meta.batches] == [
        (seed_clock + 3, [0]), (seed_clock + 8, [1])
    ]
    assert [(p.ident, p.cursor, p.registered) for p in model.meta.positions] == [
        (2, seed_clock + 10, seed_clock), (1, seed_clock + 7, seed_clock - 1)
    ]
    assert model.frame.pending_a == (count + 1, 0)
    assert model.frame.failed[-1] == (count + 2, 0)
    assert model.frame.retry_b == (count + 3, 0)
    assert world.allocator.is_live((count + 1, 0)) and world.allocator.is_live((count + 3, 0))
    assert not world.allocator.is_live((count + 2, 0))
    model.do_dispose()
    assert model.world.allocator.free[:2] == [count + 3, count + 1]

    do_iteration(model, 1)
    assert model.frame.pending_a == (count + 3, 1)
    assert model.frame.failed[-1] == (count + 1, 1)
    assert model.frame.retry_b == (count + 4, 0)
    assert model.world.allocator.free[:2] == [count + 4, count + 3]
    model.spool.unlink(missing_ok=True)

    assert "|pending=0:end|" in world_text(World(1))
    assert "|nextSystem=1|" in world_text(World(1))
    assert "main=Found({\"levels\"" in rows_text(world)

def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--outdir", type=Path, default=Path(__file__).parent)
    ap.add_argument("--count", type=int, default=N)
    ap.add_argument("--iterations", type=int, default=ITERATIONS)
    ap.add_argument("--verify", action="store_true")
    ap.add_argument("--self-check", action="store_true")
    args = ap.parse_args()
    if args.self_check:
        self_check()
        print("independent model invariants: PASS")
        return 0
    result = generate(args.outdir, args.count, args.iterations)
    print(json.dumps(result, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
