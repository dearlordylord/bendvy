import Base

# Trusted schema provisioning. An affine view can replace its returned owner.
# Its use requires exclusive storage access and does not establish purity.
type Affine<-P:Type,-V:Data,-project:P -> P & V> is Data:
  Affine{}
def trusted_affine(~P:Type,~V:Data,~project:P -> P & V) -> Affine<P,V,project>:
  Affine{}
