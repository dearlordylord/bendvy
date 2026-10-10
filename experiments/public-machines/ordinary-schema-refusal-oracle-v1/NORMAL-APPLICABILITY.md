Normal consumer nonimport body is byte-identical. Frontend successful registration/body/queries/formatter unchanged; only rejection result variants and callbacks now retain the failed registered application. Normal successful paths do not reach these variants. Parent independent13505/dc2fd49b whole model applies; source07 predecessor execution is not a new successor runtime receipt.

```diff
---

+++

@@ -56,16 +56,15 @@

   (Unit & Leaf.Record<S,Records.Token<Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Unit & U32,Q.Error<Unit>,List<&2,Unit>,Ord.observable_runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~component_ops,~Unit,~Unit,~Unit,~C.Access<U32>,~query(~S),~component_body)>>>) & Leaf.Record<S,Records.Token<Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Args,Error,Output,Field.runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~resource_ops(~S),~Args,~Error,~Output,~D.ordinary(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~resource_ops(~S),~U32,resource_declaration(~S)),~resource_body(~S))>>>
 type SetupResult<S:Data> is Type:
   Ready{app:RegisteredApp(~S)}
-  Failed{world:W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>}
+  ResourceRejected{app:FirstApp(~S)}
+  ComponentRejected{app:Build.Registered<S,W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>,Unit,Unit,Build.empty_observe(~W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>),Leaf.empty(~S)>}
 def resource_ready(~S:Data,app:RegisteredApp(~S)) -> SetupResult<S>:
   Ready{app}
 def resource_failed(~S:Data,app:FirstApp(~S)) -> SetupResult<S>:
-  match app:
-    case Build.Registered{world,_,_,_}:Failed{world}
+  ResourceRejected{app}
 def component_ready(~S:Data,app:FirstApp(~S)) -> SetupResult<S>:
   ResourceRegistration.register(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~(Unit & Leaf.Record<S,Records.Token<Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Unit & U32,Q.Error<Unit>,List<&2,Unit>,Ord.observable_runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~component_ops,~Unit,~Unit,~Unit,~C.Access<U32>,~query(~S),~component_body)>>>),~DTO.Product<Unit,DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,C.Access<U32>>>>>,~Tree.observe_pair(~W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>,~Unit,~DTO.Product<Unit,List<&2,IQ.ProjectedRow<S,C.Access<U32>>>>,~Build.empty_observe(~W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>),~Leaves.component_observe(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~component_ops,~C.Access<U32>,~query(~S),~render_component)),~Leaf.fold_pair(~S,~Unit,~Leaf.Record<S,Records.Token<Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Unit & U32,Q.Error<Unit>,List<&2,Unit>,Ord.observable_runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~component_ops,~Unit,~Unit,~Unit,~C.Access<U32>,~query(~S),~component_body)>>>,~Leaf.empty(~S),~Leaf.observed(~S,~Records.Token<Sys.Registry<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32,Unit & U32,Q.Error<Unit>,List<&2,Unit>,Ord.observable_runner(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~component_ops,~Unit,~Unit,~Unit,~C.Access<U32>,~query(~S),~component_body)>>)),~resource_ops(~S),~Args,~Error,~Output,~U32,~resource_declaration(~S),~resource_body(~S),~SetupResult<S>,resource_ready(~S),resource_failed(~S),app,"CounterUpdate","Update")
 def component_failed(~S:Data,app:Build.Registered<S,W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>,Unit,Unit,Build.empty_observe(~W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>),Leaf.empty(~S)>) -> SetupResult<S>:
-  match app:
-    case Build.Registered{world,_,_,_}:Failed{world}
+  ComponentRejected{app}
 def register(~S:Data,world:W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>) -> SetupResult<S>:
   ComponentRegistration.register(~S,~Setup.store(~S,~Array<U32>),~Setup.resources(~Array<U32>),~U32,~Unit,~Unit,~Build.empty_observe(~W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>),~Leaf.empty(~S),~component_ops,~Unit,~Unit,~Unit,~C.Access<U32>,~query(~S),~render_component,~component_body,~SetupResult<S>,component_ready(~S),component_failed(~S),Build.empty(~S,~W.World<S,Setup.store(~S,~Array<U32>),Setup.resources(~Array<U32>),U32>,world),"PositionRead","Update")
```
