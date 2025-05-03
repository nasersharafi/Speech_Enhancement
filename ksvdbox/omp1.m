function x=omp1(y,D,m)
% OMP (Orthogonal Mathing Persuit method):
%inputs: 
%    y        :L dimentional signal in initial space
%    D(L by K): the transformation from x(sparsity) space to y space:y=Dx
%         note: in overcomplete cases K>L (k=dimansion in sparsity space,
%         l:dimension in initial space)
%    m        :number of nonzero elements of x (sparsity degree)

% initialization:
r=y;
t=1;
Lambda=[];
Dm=[];
clear x

for t=1:m
    pr=r'*D; %projection of r by D
    [m0,lambda]=max(pr);
    Lambda=[Lambda,lambda];
    Dm=[Dm,D(:,lambda)];
    x1=pinv(Dm)*y;
    r=y-Dm*x1;
end
x=zeros(size(D,2),1);
x(Lambda)=x1;