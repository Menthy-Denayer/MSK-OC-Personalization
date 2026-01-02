function fvals = parallelObjectiveWrapper(X, params)
    % define variables
    Ncandidates = size(X,2);                                                % number of candidate solutions
    fvals = NaN(1,Ncandidates);                                             % list to store fitness values
    cot = NaN(1,Ncandidates);                                               % list to store computed COT
    [activePath,~,~] = fileparts(params.adaptedModelPath);

    % debug
    fprintf('----------------------------------------------------------------\n');
    fprintf('There are %d candidates \n', Ncandidates);
    fprintf('----------------------------------------------------------------\n');
    
    % loop over candidates in parallel
%     for i = 1:Ncandidates
%         % log the start of the evaluation
%         fprintf('Worker starting candidate %d\n', i);
%  
%         % change parameters depending on the method
%         modelFile = replace(params.adaptedModelPath,'.osim',['_c' num2str(i) '.osim']);
%         outputName = char("worker" + num2str(i));
% 
%         % evaluate the objective, i.e. run the predictive methods
%         try 
%             [fvals(i),cot(i)] = runPredictiveWalking(X(:,i), params, modelFile, outputName);
%         catch ME
%             disp(getReport(ME));
%         end
% 
%         % log the completion
%         fprintf('Worker finished candidate %d with function evaluation of %0.2f\n', i, fvals(i));
%     end

    %% Start Worker Jobs (PredSim batch)
    for i = 1:Ncandidates
        % log the start of the evaluation
        fprintf('Worker starting candidate %d\n', i);
 
        % change parameters depending on the method
        modelFile = replace(params.adaptedModelPath,'.osim',['_c' num2str(i) '.osim']);
        outputName = char("worker" + num2str(i));

        % add worker to batch (run predictive simulation)
        try 
            runPredictiveWalking_vBatch(X(:,i), params, modelFile, outputName);
        catch ME
            disp(getReport(ME));
        end

        % add small pause to prevent race condition
        activeDir = dir([char(activePath) '/*.dll']);
        if(length(activeDir) < 2*Ncandidates)
            fprintf('Only found %d geometry files, so waiting to prevent race conditions...\n', length(activeDir))
            pause(60);
        end
    end

    %% Check Job State
    c = parcluster;                                                         % retrieve job cluster
    jobs = c.Jobs;                                                          % get jobs
    arrayfun(@wait, jobs);                                                  % wait for all jobs to finish

    %% Evaluate Results 
    % job list fetch outputs
    Njobs = length(jobs);
    for i = 1:Njobs
        % get outputs from current job
        current_job = jobs(i);
        try 
            outputs = current_job.fetchOutputs;                             % run_predsim outputs: sim name, R structure, model_info structure

            % evaluate the cost function
            [fvals(i), cot] = compute_fitness(X(:,i), outputs{2}, outputs{3}, params);
            
            % log the completion
            fprintf([outputs{1} ' finished job %d with function evaluation of %0.2f\n'], i, fvals(i));

        catch ME
            disp(getReport(ME));
        end
    end

    %% Reset
    % reset jobs
    delete(jobs);

    % clear directory to create new models
    sprintf("Clear results directory: %s",char(activePath))
    delete([char(activePath) '/*_f_lMT_vMT_dM_poly_3_9*'])                  % keep external function but reset musculoskeletal geometry

    % debug & save
    [bestF, bestCandidate] = min(fvals);

    fprintf('----------------------------------------------------------------\n');
    fprintf('All workers finished, best value is %0.2f for candidate %d\n', bestF, bestCandidate);
    fprintf('----------------------------------------------------------------\n');

    try 
        simpleCMAESplotter(cot(bestCandidate))
    catch
        fprintf('No plot made.')
    end

    % save parameters
    save_worker_parameters(X, fvals)
end