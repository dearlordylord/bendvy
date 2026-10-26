# Ordinary App consumer

This example composes a Health/HealthDecay component query and an owned service
counter through ordinary App factories. Three retained entity handles are observed
before execution and after each of three ticks.

`main.bend` creates the World and prints the counter followed by Health values.
Each printed row has a trailing space and newline.

```text
0 40 70 90
1 37 65 90
2 34 60 90
3 31 55 90
```

Check the source with `scripts/bend-check test-fixtures/ordinary-app/main.bend`.
The [ordinary App guide](../../docs/reference/ordinary-app.md) explains the API.
Historical audit logs and compiled artifacts remain in Git history at
`b50440d867dbeafbcdd475ac8ee1dd73b48210bd:audits/blind-user-73/`.
