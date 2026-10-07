"""Independent slow chronological-edge model; no maintained-inverse imports."""
def cleanup(descriptors, edges, owners, entity):
    edges = list(edges)
    owners = {k: tuple(v) for k, v in owners.items()}
    live = set(owners)
    removed, despawned = [], []
    def unlink(key, source):
        edges[:] = [(k,s,t) for k,s,t in edges if (k,s)!=(key,source)]
    def destroy(entity):
        if entity not in live:
            return
        # Preserve entered-frame semantics, even after nested deletion.
        for key, linked in descriptors:
            children = [s for k,s,t in edges if k==key and t==entity]
            for source in children:
                if linked:
                    destroy(source)
                else:
                    unlink(key,source)
            unlink(key,entity)
        previous = owners.pop(entity,None)
        if previous is not None:
            removed.append((entity,list(previous)))
        live.discard(entity)
        despawned.append(entity)
    destroy(entity)
    return {'owners':sorted((k,list(v)) for k,v in owners.items()),'edges':edges,
            'removed':removed,'despawned':despawned}

if __name__=='__main__':
    import json
    owners={1:[100,10],2:[200,20,21],3:[300,30,31,32,33],4:[400,40,41,42,43,44,45,46,47]}
    subjects=[('ordinary',[(1,False)],[(1,3,1),(1,2,1)],1),
              ('ordinary-source',[(1,False)],[(1,3,1),(1,2,1)],3),
              ('hierarchy',[(1,True)],[(1,3,1),(1,2,1),(1,4,2)],1),
              ('cycle-one',[(1,True),(2,True)],[(1,1,2),(2,2,1)],1),
              ('cycle-two',[(1,True),(2,True)],[(1,1,2),(2,2,1)],2)]
    for label,descriptors,edges,entity in subjects:
        print(json.dumps({'case':label,**cleanup(descriptors,edges,owners,entity)},separators=(',',':')))
