function fvals = parallelObjectiveWrapper(X)
    % define variables
    Ncandidates = size(X,2);                                                % number of candidate solutions
    fvals = NaN(1,Ncandidates);                                             % list to store fitness values
    
    % debug
    % fprintf('----------------------------------------------------------------\n');
    % fprintf('There are %d candidates \n', Ncandidates);
    % fprintf('----------------------------------------------------------------\n');

    %% Start Worker Jobs (PredSim batch)
    for i = 1:Ncandidates
        % log the start of the evaluation
        % fprintf('Worker starting candidate %d\n', i);
 
        fvals(i) = frosenbrock(X(:,i));
    end