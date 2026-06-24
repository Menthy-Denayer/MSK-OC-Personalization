function [besteverF,besteverCnt,worsteverF,worsteverCnt] = save_worker_parameters(X, F, outputFolder)
%% save_worker_parameters 
% - Saves the parameters and associated fitness function for each worker
%
%------------------------------------------------------------- INPUTS -------------------------------------------------------------
% X                             | Nparam x Nworkers Double Array        | Matrix of coefficients used for each worker
% F                             | 1 x Nworkers Double Array             | List of computed fitness values
%
%------------------------------------------------------------- OUTPUTS ------------------------------------------------------------
% besteverF                     | Double                                | Best ever fitness value
% besteverCnt                   | Int                                   | Count of saved best ever solutions
% worsteverF                    | Double                                | Worst ever fitness value
% worsteverCnt                  | Int                                   | Count of saved worst ever solutions
%
%----------------------------------------------------------- REQUIREMENTS ---------------------------------------------------------
% 
%
%----------------------------------------------------------------------------------------------------------------------------------

% Original Author: Menthy Denayer
% Date: 05/February/2025

% Last Update: Menthy Denayer
% Date: 24/June/2026

NworkersDesired = 10;
fileName = fullfile(outputFolder, 'workerparam.mat');
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
    
    % update best ever
    currBestF = min(data.fhist,[],'all');
    if(currBestF < data.besteverF)
        data.besteverCnt = data.besteverCnt + 1;
        data.besteverF = currBestF;
    end
    
    % update worst ever
    currWorstF = max(data.fhist,[],'all');
    if(currWorstF > data.worsteverF)
        data.worsteverCnt = data.worsteverCnt + 1;
        data.worsteverF = currWorstF;
    end
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
    
    % initialize worst/best ever
    data.besteverCnt = 1;
    data.besteverF = min(data.fhist,[],'all');
    data.worsteverCnt = 1;
    data.worsteverF = max(data.fhist,[],'all');
end

save(fileName,"data");
besteverF = data.besteverF;
besteverCnt = data.besteverCnt;
worsteverF = data.worsteverF;
worsteverCnt = data.worsteverCnt;

end