function fvals = parallelObjectiveWrapper(X, params)
%% parallelObjectiveWrapper 
% - Allows for the parallel execution of the optimization process
% - For each worker, a parallel job is started
% - Once all jobs are started, the code waits until all the jobs are ready
% - The results are then evaluated and the all-time best/worst are saved
%
%------------------------------------------------------------- INPUTS -------------------------------------------------------------
% X                             | Nmuscles x Nworkers Double Array      | Desired coefficients
% params                        | struct                                | Structure of problem settings
%   adaptedModelPath            | string                                | Path to the adapted OpenSim model
%   cmaesResultsDir             | string                                | Results folder for optimization
%   predsimResultFolder         | string                                | Results folder for PredSim/worker results
%   S                           | struct                                | PredSim settings structure
%
%------------------------------------------------------------- OUTPUTS ------------------------------------------------------------
% fvals                         | Nworkers x 1 Double Array             | List of computed fitness values
%
%----------------------------------------------------------- REQUIREMENTS ---------------------------------------------------------
% 
%
%----------------------------------------------------------------------------------------------------------------------------------

% Original Author: Menthy Denayer
% Date: 01/February/2026

% Last Update: Menthy Denayer
% Date: 01/February/2026

%% Define Variables
Ncandidates = size(X,2);                                                    % number of candidate solutions
fvals = NaN(1,Ncandidates);                                                 % list to store fitness values
cot = NaN(1,Ncandidates);                                                   % list to store computed COT

% debug
fprintf('----------------------------------------------------------------\n');
fprintf('There are %d candidates \n', Ncandidates);
fprintf('----------------------------------------------------------------\n');

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
end

%% Check Job State
c = parcluster;                                                             % retrieve job cluster
% c.JobStorageLocation = getenv('VSC_DATA') + "/matlab_job_storage";
jobs = c.Jobs;                                                              % get jobs
arrayfun(@wait, jobs);                                                      % wait for all jobs to finish

%% Evaluate Results 
% job list fetch outputs
Njobs = length(jobs);
for i = 1:Njobs
    % get outputs from current job
    current_job = jobs(i);
    outputs = current_job.fetchOutputs;                                     % run_predsim outputs: sim name, R structure, model_info structure

    % evaluate the cost function
    [fvals(i), cot] = compute_fitness(X(:,i), outputs{2}, outputs{3}, params);

    % log the completion
    fprintf([outputs{1} ' finished job %d with function evaluation of %0.2f\n'], i, fvals(i));
end

% Reset
% reset jobs
delete(jobs);

% clear directory to create new models
[activePath,~,~] = fileparts(params.adaptedModelPath);
sprintf("Clear results directory: %s",char(activePath))
delete([char(activePath) '/*_f_lMT_vMT_dM_poly_3_9*'])

% debug & save
[bestF, bestCandidate] = min(fvals);
[worstF, worstCandidate] = max(fvals);

fprintf('----------------------------------------------------------------\n');
fprintf('All workers finished, best value is %0.2f for candidate %d\n', bestF, bestCandidate);
fprintf('----------------------------------------------------------------\n');

% try 
%     simpleCMAESplotter(cot(bestCandidate))
% catch
%     fprintf('No plot made.')
% end

% save parameters
[besteverF,besteverCnt,worsteverF,worsteverCnt] = save_worker_parameters(X, fvals, params.cmaesResultsDir);

%% Save Best Ever
if(bestF <= besteverF)
    % original result files
    BestmodelFile = replace(params.adaptedModelPath,'.osim',['_c' num2str(bestCandidate) '.osim']);
    BestoutputName = char("worker" + num2str(bestCandidate));
    
    % file names
    currBestModelFile = fullfile(params.cmaesResultsDir,'best',['bestModel_' num2str(besteverCnt) '.osim']);
    currBestMatFile = fullfile(params.cmaesResultsDir,'best',['bestResult_' num2str(besteverCnt) '.mat']);
    currBestMotFile = fullfile(params.cmaesResultsDir,'best',['bestResult_' num2str(besteverCnt) '.mot']);

    fprintf('Copying %s to %s \n', BestmodelFile, currBestModelFile)
    fprintf('Copying %s to %s \n', fullfile(params.predsimResultFolder,params.S.subject.name,[BestoutputName '.mat']), currBestMatFile)
    fprintf('Copying %s to %s \n',fullfile(params.predsimResultFolder,params.S.subject.name,[BestoutputName '.mot']), currBestMotFile)

    % copy files
    copyfile(BestmodelFile, currBestModelFile)
    copyfile(fullfile(params.predsimResultFolder,params.S.subject.name,[BestoutputName '.mat']), currBestMatFile)
    copyfile(fullfile(params.predsimResultFolder,params.S.subject.name,[BestoutputName '.mot']), currBestMotFile)
end

%% Save Worst Ever
if(worstF >= worsteverF)
    % original result files
    WorstmodelFile = replace(params.adaptedModelPath,'.osim',['_c' num2str(worstCandidate) '.osim']);
    WorstoutputName = char("worker" + num2str(worstCandidate));
    
    % file names
    currWorstModelFile = fullfile(params.cmaesResultsDir,'worst',['worstModel_' num2str(worsteverCnt) '.osim']);
    currWorstMatFile = fullfile(params.cmaesResultsDir,'worst',['worstResult_' num2str(worsteverCnt) '.mat']);
    currWorstMotFile = fullfile(params.cmaesResultsDir,'worst',['worstResult_' num2str(worsteverCnt) '.mot']);

    fprintf('Copying %s to %s \n', WorstmodelFile, currWorstModelFile)
    fprintf('Copying %s to %s \n', fullfile(params.predsimResultFolder,params.S.subject.name,[WorstoutputName '.mat']), currWorstMatFile)
    fprintf('Copying %s to %s \n',fullfile(params.predsimResultFolder,params.S.subject.name,[WorstoutputName '.mot']), currWorstMotFile)

    % copy files
    copyfile(WorstmodelFile, currWorstModelFile)
    copyfile(fullfile(params.predsimResultFolder,params.S.subject.name,[WorstoutputName '.mat']), currWorstMatFile)
    copyfile(fullfile(params.predsimResultFolder,params.S.subject.name,[WorstoutputName '.mot']), currWorstMotFile)
end

end