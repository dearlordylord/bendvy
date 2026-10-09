"""Pure artifact transformation; no tool execution and no new report renderer."""
JS_OLD = '      io_out(1, io_bytes(show_val(...show, 0, run_loop(main()), 0) + "\\n"));'
JS_NEW = '''      const simulationStart = process.hrtime.bigint();
      const simulationValue = run_loop(main());
      const simulationStop = process.hrtime.bigint();
      const transportStart = process.hrtime.bigint();
      const simulationText = io_bytes(show_val(...show, 0, simulationValue, 0) + "\\n");
      const transportStop = process.hrtime.bigint();
      io_out(1, simulationText);
      io_out(2, io_bytes(JSON.stringify({simulationNs: String(simulationStop-simulationStart), transportNs: String(transportStop-transportStart), bytes: simulationText.length}) + "\\n"));'''
C_OLD = '''  Term m = corpus_eval(H, term_tsk(MAIN_FID, task_node(e, MAIN_FID,
    TERM_HOLE, 0, 0)));
#if MAIN_PURE
  show_val(e, 0, H + H_ROOT_WORD, 0);
  putchar('\\n');'''
C_NEW = '''  struct timespec simulationStart, simulationStop, transportStop;
  if (clock_gettime(CLOCK_MONOTONIC, &simulationStart)) err_fail("simulation clock failed");
  Term m = corpus_eval(H, term_tsk(MAIN_FID, task_node(e, MAIN_FID,
    TERM_HOLE, 0, 0)));
  if (clock_gettime(CLOCK_MONOTONIC, &simulationStop)) err_fail("simulation clock failed");
#if MAIN_PURE
  show_val(e, 0, H + H_ROOT_WORD, 0);
  putchar('\\n');
  if (clock_gettime(CLOCK_MONOTONIC, &transportStop)) err_fail("simulation clock failed");
  fprintf(stderr, "{\\"simulationNs\\":\\"%lld\\",\\"transportNs\\":\\"%lld\\"}\\n",
    (long long)(simulationStop.tv_sec-simulationStart.tv_sec)*1000000000LL+simulationStop.tv_nsec-simulationStart.tv_nsec,
    (long long)(transportStop.tv_sec-simulationStop.tv_sec)*1000000000LL+transportStop.tv_nsec-simulationStop.tv_nsec);'''
def instrument(kind, source):
    old, new = {'JS': (JS_OLD, JS_NEW), 'Native': (C_OLD, C_NEW)}[kind]
    if source.count(old) != 1 or new in source: raise ValueError('unexpected generated entry seam')
    changed = source.replace(old, new)
    assert changed.replace(new, old) == source
    return changed
