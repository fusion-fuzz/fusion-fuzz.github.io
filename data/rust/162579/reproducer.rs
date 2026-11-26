trait Svc<Req> { type Res; }
#[unsafe(rustc_allow_lifetime_dependent_specialization)]
trait MkSvc<Target, Req> = Svc<Target> where <Self as Svc<Target>>::Res: Svc<Req>;
