function save_worker_parameters(X, F)
% X: 28x8 matrix of parameters for worker 1-8
% F: 1x8 matrix of function evaluations for worker 1-8

NworkersDesired = 8;
fileName = "workerparam.mat";
if(isfile(fileName))
    load(fileName,"data");
    Nworkers = size(data.xhist,2);
    Nparam = size(data.xhist,1);
    Xfull = NaN(Nparam, Nworkers);
    Ffull = NaN(1,Nworkers);

    NworkersCurr = size(X,2);
    Xfull(:,1:NworkersCurr) = X;
    Ffull(1:NworkersCurr) = F;
    data.xhist = cat(3, data.xhist, Xfull);
    data.fhist = cat(3, data.fhist, Ffull);
else
    data.start = datetime("now","Format","HH:mm:ss");
    Nparam = size(X,1);
    Xfull = NaN(Nparam, NworkersDesired);
    Ffull = NaN(1,NworkersDesired);

    NworkersCurr = size(X,2);
    Xfull(:,1:NworkersCurr) = X;
    Ffull(1:NworkersCurr) = F;
    data.xhist = Xfull;
    data.fhist = Ffull;
end

save(fileName,"data");


end