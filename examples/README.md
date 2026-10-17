# Examples

Start with [Scheduled health](scheduled-health/README.md): world creation,
declaration-derived query access, a registered system, an explicit schedule,
deferred spawn and complete output checks on JS and Native.

| Example | Purpose | Execution style |
| --- | --- | --- |
| [Scheduled health](scheduled-health/README.md) | Application starting point | Ordinary declarations and registered schedule |
| [Health decay](health-decay/README.md) | Small query mechanics example | Direct query execution |
| [Health browser demo](health-decay/demo/README.md) | Interactive view of health decay | Browser host, direct query execution |
| [Arena](arena/README.md) | Playable browser simulation | Browser host, direct query orchestration |
| [User simulation](user-simulation/README.md) | Transaction/event/retry regression story | Explicit provider and runner integration |
| [Workshop](query-composition/README.md) | Query composition and rollback regression story | Explicit query/provider and runner integration |

The advanced regression stories retain their fixed reference checkpoints. Their
handwritten access lists and raw setup are not the application starting pattern.
Each linked README describes the actual API used and its verification command.
