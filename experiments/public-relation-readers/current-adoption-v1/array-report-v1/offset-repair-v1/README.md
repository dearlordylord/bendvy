# Hot Array base precedence repair

`arr_loc` returns a bare conditional base. `arr_cells` embeds it in `base + offset` for box payloads. C binds `+` tighter than `?:`, so `x == h0 ? q0 : loc(x) + 1` adds the offset only on the false branch. In actual completed extraction, array0 is the hot argument: every box cell reads cell0 (Maybe tag1), numeric cells use separate blk_read offsets. Output copies the faulty deliveries value into slot1; the bounded trace observes1 exactly there.

The surgical generated-C copy parenthesizes only these conditional bases followed by addition. Original C, full consumer, all field values and display descriptors remain unchanged; there is no diagnostic logging. `compiler.patch` shows the minimal root repair: parenthesize arr_loc's entire returned expression, including chained hot-array conditionals. Neither reference nor installed compiler is modified.

This is a concrete source correspondence, not yet full Native qualification. A separately admitted build/run against unchanged full12ac typed oracle is required. Patched-copy success must remain distinct from installed compiler success.
