# Resource field feasibility

Pinned Bevy ad678262 SystemParam uses one ComponentId for Res<T>/ResMut<T> and applies read/write access to that ID (system_param.rs:867–938). The current Bend aggregate capability accepts replacement R, even when access names one ordinary Resource. This prototype narrows replacement to selected affine P.

Existing owner-product.bend provides typed Lens<R,P,Rest>, canonical left/right constructors and nested composition. field.bend uses its take/put to retain arbitrary affine Rest internally. A read projects P and immediately reconstructs R. A write replaces only P; W.observe_resource already supports Type-valued output, so the displaced P transfers into the existing affine inverse journal. Rollback replaces P in the current R, preserving the current sibling Rest, then discards the displaced replacement using existing semantics. No aggregate R or sibling Rest is exposed to the opaque body.

The smallest ordinary seam is a registration binding generated from Schema.Resource<S,P> and canonical product path/lens, with read/write capability ValueRead<H,V>/ValueWrite<H,P,V>. The normal component/resource schema builder must generate this path; callers should not repeat names or author metadata. This file is plumbing feasibility, not that completed builder or provider integration.

Raw user-authored lenses remain trusted and can alter siblings. Canonical product lenses are source-inspected, not proved here. Only generic module source checked at stock default five seconds (exit0, updater stderr retained). No concrete two-field transaction run, authority refusals, rollback runtime oracle, ticks/change detection, optional/missing resource behavior, public API promotion or full #56 qualification. No new laws or contracts.
