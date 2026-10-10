# Typechecking change, source only

The four private pair helpers lose two erased DeclaredSelection parameters. Matching helpers also lose unused erased A/B; their runtime callbacks have identical H/Handle<S>/Bool signatures. Projection retains H/S/A/B and receives H->Handle<S>->H&A and H->Handle<S>->H&B as live arguments. Public pair still checks the same erased declarations and constructs the same two actual fields.

Installed def_inst (2916 onward) slices only def.x erased arguments for its serialized specialization key. Therefore these helper keys can no longer contain left/right declaration bodies. This is a structural consequence of the signature delta, not a measurement of completed instances.

It also changes checking work: term_infer App (2655 onward) term-checks each live callback argument against its All/function domain and combines affine uses. tele_check (2695 onward) still checks erased H/S/A/B on each template application before its instance lookup; public pair and the four field extraction expressions remain checked. Thus removing serialized declaration arguments does not make the whole check free or establish lower total checker work. Closure construction and live higher-order argument checking are now explicit work boundaries.

Actual24434 reached only a stock5 deadline with empty streams. No instantiated template census, checker phase, callback multiplicity failure or timing attribution was observed. No further rewrite or retry is justified by that receipt alone.
