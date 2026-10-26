clear all
clc
close all

%% Import OpenSim Libraries
import org.opensim.modeling.*

%% Select Worker Parameter File
[workerFileName, workerFileDir] = uigetfile("*.mat", "Choose worker parameter file");
workerParameters = load(fullfile(workerFileDir, workerFileName));

%% Select Result File
res_DIR = uigetdir("", "Choose personal results folder");
res_info = dir(res_DIR);
all_files = string({res_info.name});
isMAT = contains(all_files,".mat");
mat_files = all_files(isMAT);

%% Get Subject ID
SUBJID = string(extractBefore(extractAfter(res_DIR,"SUBJ"),"\calibration"));

%% Best/Worst Results
isBestWorst = extractAfter(res_DIR,"_vFinal\");

%% Sort Result Files
iter = double(strrep(extractAfter(mat_files,"bestResult_"),".mat",""));
[~,sortedIdx] = sort(iter);
mat_files_sorted = mat_files(sortedIdx);

%% Select Generic File
[gen_file_name, gen_DIR] = uigetfile(".mat", "Choose generic results file");
generic = load(fullfile(gen_DIR, gen_file_name));

%% Select Desired Kinematics
[mot_file_name, mot_file_loc] = uigetfile(".mot", "Choose kinematics initial guess.");
KINdata = importdata(fullfile(mot_file_loc, mot_file_name));

%% Select Generic OpenSim Model
[osim_file_name_generic, osim_file_loc_generic] = uigetfile(".osim","Choose Generic OpenSim model.");
genericModel = Model(fullfile(osim_file_loc_generic,osim_file_name_generic));

%% Select Optimal OpenSim Model
isOSIM = contains(all_files,".osim");
osim_files = all_files(isOSIM);
osim_files_sorted = osim_files(sortedIdx);

%% Define Parameters
% kinematics reference
[IKdata, normTime] = loadIKdata(fullfile(mot_file_loc, mot_file_name),"mtp");
paramsOpt.IKtime = normTime;
paramsOpt.IKdesired = IKdata;
paramsOpt.ExcludeTrackingJoints = 'mtp';

% fitness shape
paramsOpt.trackGRF = false;
paramsOpt.IKweight = 1;
paramsOpt.PennAnglePenalty = true;
paramsOpt.PennAngleweight = 50;
paramsOpt.lMoptPenalty = true;
paramsOpt.lMoptweight = 100;
paramsOpt.lTstrainPenalty = true;
paramsOpt.lTstrainweight = 1;
paramsOpt.paramDeviationPenalty = true;
paramsOpt.paramDeviationweight = 10;
paramsOpt.FpassPenalty = true;
paramsOpt.Fpassweight = 50;
paramsOpt.FpassWorkPenalty = false;
paramsOpt.FpassWorkweight = 50;

% plotting
paramsOpt.plot = false;

%% Read Initial Geneeric Coefficients
[lMoptGen, lTslackGen, ~] = readMTUparameters(genericModel);

%% Loop Over Files
fOpt = NaN(length(mat_files),1);
workerID = NaN(length(mat_files),1);
for i = 1:length(mat_files_sorted)
    % Load result
    results = load(fullfile(res_DIR, mat_files_sorted(i)));
    workerID(i) = double(strrep(extractAfter(results.model_info.osim_path,"SUBJ" + SUBJID + "mtu3D_c"),".osim",""));
    
    % Load model
    optimalModel = Model(fullfile(res_DIR, osim_files_sorted(i)));
    
    [lMoptOpt, lTslackOpt, ~] = readMTUparameters(optimalModel);
    
    % Add Results to Parameters
    sol = [lMoptOpt; lTslackOpt];
    paramsOpt.initialCoefficients = [lMoptGen; lTslackGen];
    
    % Compute Fitness
    [fOpt(i), cotOpt] = compute_fitness(sol, results.R, results.model_info, paramsOpt);
end

%% Save Worker Fitness Evolution 
fhist = workerParameters.data.fhist;
fbest_idx = [];
fbest_hist = [];
fworst_idx = [];
fworst_hist = [];
currBest = Inf;
currWorst = 0;

for i = 1:size(fhist,3)
    
    [fbest_curr, fbest_curr_idx] = min(fhist(:,:,i),[],"omitnan");
    [fworst_curr, fworst_curr_idx] = max(fhist(:,:,i),[],"omitnan");
    
    if(fbest_curr < currBest)
        fbest_idx = [fbest_idx fbest_curr_idx];
        fbest_hist = [fbest_hist fbest_curr];
        currBest = fbest_curr;
    end

    if(fworst_curr > currWorst)
        fworst_idx = [fworst_idx fworst_curr_idx];
        fworst_hist = [fworst_hist fworst_curr];
        currWorst = fworst_curr;
    end

end

%% Compare Results

if(strcmp(isBestWorst,"best"))
    workerIdxErr = workerID' - fbest_idx;
    fitnessErr = fOpt' - fbest_hist;
elseif(strcmp(isBestWorst,"worst"))
    workerIdxErr = workerID' - fworst_idx;
    fitnessErr = fOpt' - fworst_hist;
end

for i = 1:length(workerIdxErr)

    fprintf("Iteration %d: worker ID error = %.0f, fitness error = %.6g\n", ...
        i, workerIdxErr(i), fitnessErr(i));

end