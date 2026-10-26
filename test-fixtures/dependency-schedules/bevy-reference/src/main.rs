use bevy_ecs::{error::{BevyError, ErrorContext, FallbackErrorHandler}, prelude::*, schedule::SingleThreadedExecutor};
use serde_json::json;
use std::sync::Mutex;

#[derive(Resource, Default)]
struct State { value: u32, local: u32, calls: Vec<&'static str> }
#[derive(Component)]
struct Missing;
#[derive(Resource)]
struct MissingResource;
static ERRORS: Mutex<Vec<&'static str>> = Mutex::new(Vec::new());
fn handler(_: BevyError, context: ErrorContext) {
    ERRORS.lock().unwrap().push(match context {
        ErrorContext::System { .. } => "system",
        ErrorContext::RunCondition { .. } => "condition",
        _ => "other",
    });
}
fn fail(mut state: ResMut<State>, mut local: Local<u32>) -> Result {
    *local += 1;
    state.local = *local;
    state.value += 1;
    state.calls.push("write-error");
    Err("expected body error".into())
}
fn observe_dependency(state: Res<State>) -> bool { state.value == state.local && state.value > 0 }
fn dependent(mut state: ResMut<State>) { state.calls.push("after-error"); }
fn disabled() -> bool { false }
fn condition_error() -> Result<bool> { Err("expected condition error".into()) }
fn must_not_run(mut state: ResMut<State>) { state.calls.push("unexpected-body"); }
fn after_disabled(mut state: ResMut<State>) { state.calls.push("after-disabled"); }
fn after_condition_error(mut state: ResMut<State>) { state.calls.push("after-condition-error"); }
fn refused(_missing: Single<&Missing>, mut state: ResMut<State>) { state.calls.push("unexpected-refused-body"); }
fn refused_resource(_missing: Res<MissingResource>, mut state: ResMut<State>) { state.calls.push("unexpected-refused-body"); }
fn after_refused(mut state: ResMut<State>) { state.calls.push("after-refused"); }
fn main() {
    let mut world = World::new();
    world.insert_resource(State::default());
    world.insert_resource(FallbackErrorHandler(handler));
    let mut schedule = Schedule::default();
    schedule.set_executor(SingleThreadedExecutor::new());
    let missing_resource = std::env::args().any(|arg| arg == "--missing-resource");
    if missing_resource {
    schedule.add_systems((
        fail,
        dependent.run_if(observe_dependency),
        must_not_run.run_if(disabled),
        after_disabled,
        must_not_run.run_if(condition_error),
        after_condition_error,
        refused_resource,
        after_refused,
    ).chain());
    } else {
    schedule.add_systems((
        fail,
        dependent.run_if(observe_dependency),
        must_not_run.run_if(disabled),
        after_disabled,
        must_not_run.run_if(condition_error),
        after_condition_error,
        refused,
        after_refused,
    ).chain());
    }
    for run in 1..=2 {
        schedule.run(&mut world);
        let state = world.resource::<State>();
        println!("{}", json!({"admission":if missing_resource { "missing-resource" } else { "skippable" },"run":run,"value":state.value,"local":state.local,"calls":state.calls,"errors":*ERRORS.lock().unwrap()}));
    }
}
