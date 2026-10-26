use bevy_ecs::{
    error::{BevyError, ErrorContext, FallbackErrorHandler},
    prelude::*,
    schedule::{ApplyDeferred, ScheduleBuildSettings, SingleThreadedExecutor},
};
use serde_json::json;
use std::sync::atomic::{AtomicU32, Ordering};

#[derive(Component)]
struct Value(u32);
#[derive(Component)]
struct Marker;
#[derive(Resource)]
struct State { target: Entity, observed: Vec<(u32, bool)> }
static ERRORS: AtomicU32 = AtomicU32::new(0);
fn handler(_: BevyError, _: ErrorContext) { ERRORS.fetch_add(1, Ordering::Relaxed); }
fn author(mut commands: Commands, state: Res<State>, mut count: Local<u32>) -> Result {
    *count += 1;
    commands.entity(state.target).insert(Value(*count * 10)).remove::<Marker>();
    Err("handled after enqueue".into())
}
fn observe(query: Query<(&Value, Has<Marker>)>, mut state: ResMut<State>) {
    let (value, marker) = query.get(state.target).unwrap();
    state.observed.push((value.0, marker));
}
fn scenario(mode: &str) {
    ERRORS.store(0, Ordering::Relaxed);
    let mut world = World::new();
    let target = world.spawn((Value(1), Marker)).id();
    world.insert_resource(State { target, observed: vec![] });
    world.insert_resource(FallbackErrorHandler(handler));
    let mut schedule = Schedule::default();
    schedule.set_executor(SingleThreadedExecutor::new());
    match mode {
        "ignored" => { schedule.add_systems((author, observe).chain_ignore_deferred()); }
        "disabled" => {
            schedule.set_build_settings(ScheduleBuildSettings {
                auto_insert_apply_deferred: false, ..Default::default()
            });
            schedule.add_systems((author, observe).chain());
        }
        "explicit" => {
            schedule.add_systems((author, ApplyDeferred, observe).chain_ignore_deferred());
        }
        _ => { schedule.add_systems((author, observe).chain()); }
    }
    for run in 1..=2 {
        schedule.run(&mut world);
        let state = world.resource::<State>();
        println!("{}", json!({"mode":mode,"run":run,"observed":state.observed,
            "final_value":world.get::<Value>(target).unwrap().0,
            "final_marker":world.get::<Marker>(target).is_some(),
            "errors":ERRORS.load(Ordering::Relaxed)}));
    }
}
fn main() { for mode in ["automatic", "ignored", "disabled", "explicit"] { scenario(mode); } }
