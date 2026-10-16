"""Independent provisional numeric/owner transitions; no serialized golden yet."""
def pair(seed):return (seed,seed+1)
def array(seed):return (pair(seed),pair(seed+2))
class State:
    def __init__(self):
        self.component=array(10);self.resource=array(20);self.capture=array(700)
        self.clock=1;self.added=1;self.changed=1;self.cursor=0
    def run(self,seed,fail):
        incoming=(array(seed),array(seed+20),pair(seed+30),array(seed+40),pair(seed+50))
        old=(self.component,self.resource,self.capture);oldstamp=(self.added,self.changed)
        self.clock+=1
        if fail:
            # LIFO undo returns each actual incoming owner. Replacement snapshots
            # are reconstructed before swapping its returned element again.
            return {'components':[(1,self.added,self.clock,incoming[0])],
                    'resource':[('Replaced',incoming[1]),('Swapped',1,incoming[2])],
                    'capture':[('Replaced',incoming[3]),('Swapped',1,incoming[4])]}
        self.component=incoming[0];self.resource=(incoming[1][0],incoming[2]);self.capture=(incoming[3][0],incoming[4]);self.changed=self.clock;self.cursor=self.clock
        # Journal is unwound in reverse; recoverable-owner.append prepends records.
        return {'components':[(1,*oldstamp,old[0])],
                'resource':[('Replaced',old[1]),('Swapped',1,incoming[1][1])],
                'capture':[('Replaced',old[2]),('Swapped',1,incoming[3][1])]}
def selftest():
    s=State();a=s.run(100,False);assert s.component==array(100) and s.resource==(pair(120),pair(130)) and s.capture==(pair(140),pair(150)) and (s.clock,s.cursor)==(2,2)
    b=s.run(200,True);assert s.component==array(100) and (s.clock,s.changed,s.cursor)==(3,2,2)
    c=s.run(200,False);assert s.component==array(200) and s.resource==(pair(220),pair(230)) and s.capture==(pair(240),pair(250)) and (s.clock,s.cursor)==(4,4)
if __name__=='__main__':selftest()
