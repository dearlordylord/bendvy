#if !__has_attribute(preserve_none)
#error "preserve_none is required"
#endif
#if !__has_attribute(preserve_most)
#error "preserve_most is required"
#endif
#if !defined(__aarch64__)
#error "this diagnostic plan is pinned to AArch64"
#endif
#if !defined(__OPTIMIZE__)
#error "Bend special ABI requires an optimized build"
#endif
BENDVY_BOTH_PRESERVE_ATTRIBUTES_AND_OPTIMIZATION
