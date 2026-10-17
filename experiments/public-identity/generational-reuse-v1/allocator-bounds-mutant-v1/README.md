# Reached central allocator masked-access control

The exact failed-growth consumer and its full observations run against a private
copied source closure. The single change replaces Allocator.checked's positive,
next-index and physical-capacity guard with True before its actual slot Array.get.
Namespace, generation and phase checks remain unchanged.

Before growth, the normal consumer's clearly marked malformed-admin key has the
actual World's namespace, generation zero, and index three while actual pending
index one occupies a capacity-two tree. Without the new guard, the masked read
therefore reaches that actual Pending slot. Canonical despawn admission and the
complete Tx expose the changed result and staged callback; this is not the
Consumed default-slot U32max case that would remain false for unrelated reasons.

MUTATION.json binds all normal/private source bodies and the exact inverse. No
fixture, prepared position, owner observer, namespace sidecar or expected output
is changed. CPU6/default five-second source check reports only four actual IO
dependencies. Independent counter oracle and actual execution remain pending.
