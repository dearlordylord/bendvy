#!/usr/bin/env python3
"""Copy the pinned TS core and add read-only physical diagnostic seams."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[2]
REFERENCE = ROOT / '.references/bevy-ts'
PIN = '3040a3b2a3f28fa8554d856f9ccb6bf5433fa334'


def patch(path, before, after):
    text = path.read_text()
    assert text.count(before) == 1, (path, before, text.count(before))
    path.write_text(text.replace(before, after))


def prepare(destination):
    assert subprocess.check_output(['git', '-C', REFERENCE, 'rev-parse', 'HEAD'], text=True).strip() == PIN
    destination = Path(destination).resolve()
    destination.mkdir(parents=True, exist_ok=False)
    names = subprocess.check_output(['git', '-C', REFERENCE, 'ls-files', 'packages/core/src'], text=True).splitlines()
    # Preserve the pinned ESM package boundary; otherwise Node emits a module
    # reparsing warning and adds work absent from the original reference.
    names.append('packages/core/package.json')
    original = {}
    for name in names:
        data = subprocess.check_output(['git', '-C', REFERENCE, 'show', f'{PIN}:{name}'])
        target = destination / name
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)
        original[name] = hashlib.sha256(data).hexdigest()
    src = destination / 'packages/core/src'
    streams = src / 'internal/streams.ts'
    patch(streams, '  readonly oldestTick: number | undefined', '''  readonly oldestTick: number | undefined
  readonly ticks: ReadonlyArray<number>
  readonly batchLengths: ReadonlyArray<number>
  readonly physicalValues: number
  readonly physicalBatches: number
  readonly droppedThrough: number
  readonly logPresent: boolean''')
    patch(streams, '          oldestTick: log?.ticks[0],', '''          oldestTick: log?.ticks[0],
          ticks: [...(log?.ticks ?? [])],
          batchLengths: (log?.batches ?? []).map(batch => batch.length),
          physicalValues: (log?.batches ?? []).reduce((sum, batch) => sum + batch.length, 0),
          physicalBatches: log?.batches.length ?? 0,
          droppedThrough: log?.droppedThrough ?? 0,
          logPresent: log !== undefined,''')
    command = src / 'Command.ts'
    patch(command, '    flush() {\n      return queue.splice(0, queue.length)', '''    inspectQueue() {
      return { length: queue.length, tags: queue.map(command => command.tag) }
    },
    flush() {
      return queue.splice(0, queue.length)''')
    # Node strips types. Preserve a typed API for the new diagnostic method too.
    patch(command, '  readonly flush:', '  readonly inspectQueue: () => { readonly length: number; readonly tags: ReadonlyArray<string> }\n  readonly flush:')
    world = src / 'internal/world.ts'
    patch(world, '      journalValues.push(record.values[ordinal])', '''      journalValues.push(record.values[ordinal])
      diagnosticJournalPeak = Math.max(diagnosticJournalPeak, journalValues.length)''')
    patch(world, '  const despawnedReaders = new Set<LifecycleCursor>()', '''  const despawnedReaders = new Set<LifecycleCursor>()
  let diagnosticJournalPeak = 0''')
    patch(world, '    removedSince: (ordinal: number, since: number)', '''    inspectPhysical: () => ({
      inverseEntries: journalValues.length,
      inversePeak: diagnosticJournalPeak,
      allocatedMarkCells: [...records.values()].reduce((sum, record) => sum + record.marks.length, 0),
      lifecycle: [
        ...Array.from({ length: Math.max(removedLogs.length, removedReaders.length) }, (_, ordinal) => {
          const log = removedLogs[ordinal]
          return { kind: "removed", ordinal, ids: [...(log?.ids ?? [])], ticks: [...(log?.ticks ?? [])],
            droppedThrough: log?.droppedThrough ?? 0, logPresent: log !== undefined,
            readers: [...(removedReaders[ordinal] ?? [])] }
        }).filter((entry) => entry.logPresent || entry.readers.length > 0),
        { kind: "despawned", ordinal: undefined, ids: [...despawnedLog.ids], ticks: [...despawnedLog.ticks],
          droppedThrough: despawnedLog.droppedThrough, logPresent: true, readers: [...despawnedReaders] }
      ]
    }),
    removedSince: (ordinal: number, since: number)''')
    runtime = src / 'Runtime.ts'
    patch(runtime, '  const slots = new WeakMap<SystemDefinition<any, any, any>, SystemSlot>()', '''  const slots = new WeakMap<SystemDefinition<any, any, any>, SystemSlot>()
  const diagnosticSlots = new Map<SystemDefinition<any, any, any>, SystemSlot>()''')
    patch(runtime, '      slots.set(stateKey(system), slot)', '''      slots.set(stateKey(system), slot)
      diagnosticSlots.set(stateKey(system), slot)''')
    patch(runtime, '  const emittedEvents = new Map<symbol, Array<unknown>>()', '''  const emittedEvents = new Map<symbol, Array<unknown>>()
  const diagnosticPeaks = { pendingCommands: 0, stagedCommands: 0, stagedEvents: 0,
    resourceInverses: 0, machineInverses: 0 }
  const diagnosticBeforeDrain = (): void => {
    diagnosticPeaks.pendingCommands = Math.max(diagnosticPeaks.pendingCommands, pendingCommands.length)
    diagnosticPeaks.stagedCommands = Math.max(diagnosticPeaks.stagedCommands,
      ...[...diagnosticSlots.values()].map(slot => slot.context.commands.inspectQueue().length))
    diagnosticPeaks.stagedEvents = Math.max(diagnosticPeaks.stagedEvents,
      [...emittedEvents.values()].reduce((sum, values) => sum + values.length, 0))
    diagnosticPeaks.resourceInverses = Math.max(diagnosticPeaks.resourceInverses, resourceOriginals.size)
    diagnosticPeaks.machineInverses = Math.max(diagnosticPeaks.machineInverses, machineOriginals.size)
  }''')
    # Counts are sampled before every destructive drain, not guessed after it.
    text = runtime.read_text()
    tracing_drain = '      if (tracing) emit(traceSystem(system, reader, thisRun, started,'
    assert text.count(tracing_drain) == 2
    text = text.replace(tracing_drain, '      diagnosticBeforeDrain()\n' + tracing_drain)
    assert text.count('    commitSystemTransaction()') == 1
    text = text.replace('    commitSystemTransaction()', '    diagnosticBeforeDrain()\n    commitSystemTransaction()')
    assert text.count('      rollbackSystemTransaction()') == 2
    text = text.replace('      rollbackSystemTransaction()', '      diagnosticBeforeDrain()\n      rollbackSystemTransaction()')
    # Successful command flush precedes commit, so sample its still-owned queue.
    assert text.count('    const queued = context.commands.flush()') == 1
    text = text.replace('    const queued = context.commands.flush()', '    diagnosticBeforeDrain()\n    const queued = context.commands.flush()')
    assert text.count('    const commands = pendingCommands.splice(0, pendingCommands.length)') == 1
    text = text.replace('    const commands = pendingCommands.splice(0, pendingCommands.length)', '    diagnosticBeforeDrain()\n    const commands = pendingCommands.splice(0, pendingCommands.length)')
    runtime.write_text(text)
    patch(runtime, '  const handle: Debug.Handle<S, Root> = {', '''  const physicalDiagnostics = () => {
    diagnosticBeforeDrain()
    const all = [...diagnosticSlots].map(([system, slot]) => ({ system: system.name, slot }))
    const readerName = (cursor: { readonly lastRun?: number; readonly streamLastRun?: number }) =>
      all.find(entry => entry.slot.reader === cursor)?.system ?? "(unknown)"
    const streams = events.inspect().map(entry => ({
      stream: debugNames!.events.get(entry.key) ?? "?",
      size: entry.size, physicalValues: entry.physicalValues, physicalBatches: entry.physicalBatches,
      ticks: entry.ticks, batchLengths: entry.batchLengths, droppedThrough: entry.droppedThrough,
      logPresent: entry.logPresent,
      readers: entry.readers.map(cursor => {
        const known = all.find(entry => entry.slot.reader === cursor)
        const registeredAt = known?.slot.reader.registeredAt
        return { system: readerName(cursor), streamLastRun: cursor.streamLastRun, registeredAt,
          unread: events.since(entry.key, cursor.streamLastRun).length,
          lagged: registeredAt === undefined ? null : events.lagged(entry.key, cursor.streamLastRun, registeredAt) }
      })
    }))
    const physical = world.inspectPhysical()
    const lifecycle = physical.lifecycle.map(entry => ({
      ...entry, physicalValues: entry.ids.length,
      readers: entry.readers.map(cursor => {
        const known = all.find(entry => entry.slot.reader === cursor)
        const registeredAt = known?.slot.reader.registeredAt
        const unread = entry.kind === "removed" ? world.removedSince(entry.ordinal!, cursor.lastRun).length
          : world.despawnedSince(cursor.lastRun).length
        const lagged = registeredAt === undefined ? null : entry.kind === "removed"
          ? world.removedLagged(entry.ordinal!, cursor.lastRun, registeredAt)
          : world.despawnedLagged(cursor.lastRun, registeredAt)
        return { system: readerName(cursor), lastRun: cursor.lastRun, registeredAt, unread, lagged }
      })
    }))
    return { tick: world.currentTick(), frame: frameCount, retainedAfter: world.retainedAfter(),
      pendingCommands: pendingCommands.length,
      stagedCommands: all.map(entry => ({ system: entry.system, ...entry.slot.context.commands.inspectQueue() })),
      stagedEvents: [...emittedEvents.values()].reduce((sum, values) => sum + values.length, 0),
      resourceInverses: resourceOriginals.size, machineInverses: machineOriginals.size,
      componentInverses: physical.inverseEntries, componentInversePeak: physical.inversePeak,
      allocatedMarkCells: physical.allocatedMarkCells, peaks: { ...diagnosticPeaks }, streams, lifecycle,
      readers: all.map(entry => ({ system: entry.system, ...entry.slot.reader })) }
  }
  Object.assign(runtime, { physicalDiagnostics })

  const handle: Debug.Handle<S, Root> = {''')
    copied = {name: hashlib.sha256((destination / name).read_bytes()).hexdigest() for name in names}
    manifest = {'referenceCommit': PIN, 'scope': 'separate diagnostic copy; never timing reference',
                'original': original, 'copied': copied,
                'overrides': [name for name in names if original[name] != copied[name]]}
    (destination / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    return manifest


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('destination', type=Path)
    args = parser.parse_args()
    manifest = prepare(args.destination)
    print(json.dumps({'referenceCommit': PIN, 'overrides': manifest['overrides']}))
