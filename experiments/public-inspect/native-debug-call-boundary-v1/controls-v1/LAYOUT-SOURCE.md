# Actual erased layout boundary

controls09 is immutable INCOMPLETE: four emission controls passed; its final ~A target specialized to Report, was flat and returned the same four-word layout as main. No layout cut occurred and no Native builds ran.

The repaired target uses ordinary erased `-A:Data`, rather than compile-time specialized `~A`. Its uninstantiated return type is A. It consumes the same Array121/122 using existing recursive observe, passes the returned owner and list to sized, and drops both there while returning the unchanged A value. The whole Report literal and independent expected model remain exact. Observation of those dropped Array values is not claimed as a Report field.

Pinned comp.ts:1184–1193 computes fun_of's return using tele_fill with DUMMY erased arguments; lay_of938–946 maps unknown A to BOX. Main's concrete Report retains its inline constructor arms. Existing recursive observe makes target dependency traversal nonflat (flat_of1263–1268 sets recursive visitation false). The single-site fusion guard2501 also rejects boxed target return into nonboxed main. Consequently2505–2508 has the source-derived differing-layout route into a cut. This is a prospective static derivation; actual frozen emission witness remains mandatory and the cut gate has not changed.

Source5-v8 exit0 under CPU5/cap5/shared lock is retained. All five models and compiler semantics unchanged. No new backend execution is admitted by this document.
