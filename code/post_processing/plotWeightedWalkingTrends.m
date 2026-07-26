% --------------------------------------------------------------------------
% plotWeightedWalkingTrends
%   Plot the experimental vs predicted changes in sagittal plane 
%   kinematics.
%
% Original author: Menthy Denayer
% Original date: 08/July/2026
%
% Last edit by: Menthy Denayer
% Last edit date: 08/July/2026
% 
% --------------------------------------------------------------------------

clear all
clc
close all

%% Load Libraries
addpath(pwd + "\helperFunctions")

%% Define Variables
% Choose subjects to plot, if empty, plot all
SUBJID = [4,6,7,9,10,11];
NSUBJ = length(SUBJID);
personalKeyWords = "optTrack_rerun";
genericKeyWords = "generic_rerun";
weightedKeyWords = "worker";
dhondt2024_3segKeyWords = "Dhondt2024_3seg";
resultsSubFolder = repmat("trackKIN-compliantTendon-3D",1,NSUBJ);
resultsSubFolder = resultsSubFolder + "/" + ["SUBJ04mtu3D_02421031", "SUBJ06mtu3D_02452315", "SUBJ07mtu3D_02462103", "SUBJ09mtu3D_02472054", "SUBJ10mtu3D_02491301", "SUBJ11mtu3D_02501441"];
trackIGsubFolderPersonal = resultsSubFolder + "/weightedWalking/weighted-trackIG";
expIGsubFolderPersonal = resultsSubFolder + "/weightedWalking/weighted-expIG";
trackIGsubFolderGeneric = resultsSubFolder + "/weightedWalking-generic/weighted-trackIG";
expIGsubFolderGeneric = resultsSubFolder + "/weightedWalking-generic/weighted-expIG";
resampTime = 0:0.01:1;

%% Define Figure Settings
fig_height = 8.89;  % cm
fig_width = 8.89;   % cm
linewidth = 1.5;
export = false;
figFileType = ".pdf";
colors = [[0,0,0]; [0,51,153]/255; [255,102,0]/255; [51,155,155]/255];

%% General Variables
Ndata = length(resampTime);
Nweights = 5;
Nkincol = 19;
Ngrfcol = 6;
Nemgcol = 28;
emg_col_exp = ["bifemsh_r","hamstrings_r","rect_fem_r","vasti_r","","gastroc_r","","soleus_r","bifemsh_l","hamstrings_l","rect_fem_l","vasti_l","","gastroc_l","","soleus_l"];
emg_threshold = 0.1;

%% Load Results
ResultsOneDriveDIR = "C:\Users\medenaye\Documents\programs\GitHub\MSK-OC-Personalization\results";
resultsDIR = uigetdir(ResultsOneDriveDIR,"Choose solution directory");

%% Find Desired Folders
ResultsFolders = find_desired_folders(resultsDIR, SUBJID);

%% Load Experimental Data
[expDataFile, expDataDIR] = uigetfile(".mat","Choose experimental data file");
expData = load(fullfile(expDataDIR, expDataFile));
Ntrials = size(expData.data.SUBJ4.kinematics.IkdataNormal,3);

%% Load Results
% Load generic model results
[GenericKinData, GenericGrfData, GenericKitData, GenericEmgData, ~, SUBJmass, ~, GenericIdxHeelL, ~, ~, ~] = average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, resultsDIR, ResultsFolders, resultsSubFolder, genericKeyWords, 1);

% Load personalized model results
[PersonalKinData, PersonalGrfData, PersonalKitData, PersonalEmgData, ~, ~, ~, PersonalIdxHeelL, kinColHeaders, GRFColHeaders, EMGColHeaders] = average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, resultsDIR, ResultsFolders, resultsSubFolder, personalKeyWords, 1);

% Dhondt2024 3seg 2022 scaled
dhondt2024_3segSubFolders = repmat("Dhondt2024_3seg",1,NSUBJ) + "/" + ["SUBJ04_Dhondt2024_3seg_17062026", "SUBJ06_Dhondt2024_3seg_17062026", "SUBJ07_Dhondt2024_3seg_17062026", "SUBJ09_Dhondt2024_3seg_17062026", "SUBJ10_Dhondt2024_3seg_17062026", "SUBJ11_Dhondt2024_3seg_17062026"];
[Dhondt2024_3segKinData, ~, ~, Dhondt2024_3segEmgData, ~, ~, ~, Dhondt2024_3segIdxHeelL,Dhondt2024_3segkinColHeaders,~,Dhondt2024_3segemgColHeaders] = average_results(resampTime, 29, Ngrfcol, 92, resultsDIR, ResultsFolders, dhondt2024_3segSubFolders, dhondt2024_3segKeyWords, 1);
Dhondt2024_3seg_isLimKin = ismember(Dhondt2024_3segkinColHeaders, kinColHeaders);

Dhondt2024_3segKinDataLim = Dhondt2024_3segKinData(:,Dhondt2024_3seg_isLimKin>0,:);

%% Save Experimental Weighted Results
isKneeFlexion = contains(expData.data.headers.kinematics,"knee_angle") & ~contains(expData.data.headers.kinematics,"beta");
isHipFlexion = contains(expData.data.headers.kinematics,"hip_flexion");
isAnklePlantar = contains(expData.data.headers.kinematics,"ankle_angle");

% store knee data for each subject
normalWalkingKneeMaxExp = NaN(NSUBJ, Ntrials);
WeightedWalking1kgKneeMaxExp = NaN(NSUBJ, Ntrials);
WeightedWalking2kgKneeMaxExp = NaN(NSUBJ, Ntrials);
WeightedWalking3kgKneeMaxExp = NaN(NSUBJ, Ntrials);
WeightedWalking4kgKneeMaxExp = NaN(NSUBJ, Ntrials);
WeightedWalking5kgKneeMaxExp = NaN(NSUBJ, Ntrials);

% store hip data for each subject
normalWalkingHipFlexMaxExp = NaN(NSUBJ, Ntrials);
WeightedWalking1kgHipFlexMaxExp = NaN(NSUBJ, Ntrials);
WeightedWalking2kgHipFlexMaxExp = NaN(NSUBJ, Ntrials);
WeightedWalking3kgHipFlexMaxExp = NaN(NSUBJ, Ntrials);
WeightedWalking4kgHipFlexMaxExp = NaN(NSUBJ, Ntrials);
WeightedWalking5kgHipFlexMaxExp = NaN(NSUBJ, Ntrials);

normalWalkingHipExtMaxExp = NaN(NSUBJ, Ntrials);
WeightedWalking1kgHipExtMaxExp = NaN(NSUBJ, Ntrials);
WeightedWalking2kgHipExtMaxExp = NaN(NSUBJ, Ntrials);
WeightedWalking3kgHipExtMaxExp = NaN(NSUBJ, Ntrials);
WeightedWalking4kgHipExtMaxExp = NaN(NSUBJ, Ntrials);
WeightedWalking5kgHipExtMaxExp = NaN(NSUBJ, Ntrials);

% store ankle data for each subject
normalWalkingAnkleMaxExp = NaN(NSUBJ, Ntrials);
WeightedWalking1kgAnkleMaxExp = NaN(NSUBJ, Ntrials);
WeightedWalking2kgAnkleMaxExp = NaN(NSUBJ, Ntrials);
WeightedWalking3kgAnkleMaxExp = NaN(NSUBJ, Ntrials);
WeightedWalking4kgAnkleMaxExp = NaN(NSUBJ, Ntrials);
WeightedWalking5kgAnkleMaxExp = NaN(NSUBJ, Ntrials);

for subjID = 1:NSUBJ
    normalWalkingKneeMaxExp(subjID,:) = compute_peak_exp(expData, SUBJID(subjID), isKneeFlexion, "Normal", Ntrials, -1, []);
    WeightedWalking1kgKneeMaxExp(subjID,:) = compute_peak_exp(expData, SUBJID(subjID), isKneeFlexion, "1kg", Ntrials, -1, []);
    WeightedWalking2kgKneeMaxExp(subjID,:) = compute_peak_exp(expData, SUBJID(subjID), isKneeFlexion, "2kg", Ntrials, -1, []);
    WeightedWalking3kgKneeMaxExp(subjID,:) = compute_peak_exp(expData, SUBJID(subjID), isKneeFlexion, "3kg", Ntrials, -1, []);
    WeightedWalking4kgKneeMaxExp(subjID,:) = compute_peak_exp(expData, SUBJID(subjID), isKneeFlexion, "4kg", Ntrials, -1, []);
    WeightedWalking5kgKneeMaxExp(subjID,:) = compute_peak_exp(expData, SUBJID(subjID), isKneeFlexion, "5kg", Ntrials, -1, []);

    normalWalkingHipFlexMaxExp(subjID,:) = compute_peak_exp(expData, SUBJID(subjID), isHipFlexion, "Normal", Ntrials, 1, []);
    WeightedWalking1kgHipFlexMaxExp(subjID,:) = compute_peak_exp(expData, SUBJID(subjID), isHipFlexion, "1kg", Ntrials, 1, []);
    WeightedWalking2kgHipFlexMaxExp(subjID,:) = compute_peak_exp(expData, SUBJID(subjID), isHipFlexion, "2kg", Ntrials, 1, []);
    WeightedWalking3kgHipFlexMaxExp(subjID,:) = compute_peak_exp(expData, SUBJID(subjID), isHipFlexion, "3kg", Ntrials, 1, []);
    WeightedWalking4kgHipFlexMaxExp(subjID,:) = compute_peak_exp(expData, SUBJID(subjID), isHipFlexion, "4kg", Ntrials, 1, []);
    WeightedWalking5kgHipFlexMaxExp(subjID,:) = compute_peak_exp(expData, SUBJID(subjID), isHipFlexion, "5kg", Ntrials, 1, []);

    normalWalkingHipExtMaxExp(subjID,:) = compute_peak_exp(expData, SUBJID(subjID), isHipFlexion, "Normal", Ntrials, -1, []);
    WeightedWalking1kgHipExtMaxExp(subjID,:) = compute_peak_exp(expData, SUBJID(subjID), isHipFlexion, "1kg", Ntrials, -1, []);
    WeightedWalking2kgHipExtMaxExp(subjID,:) = compute_peak_exp(expData, SUBJID(subjID), isHipFlexion, "2kg", Ntrials, -1, []);
    WeightedWalking3kgHipExtMaxExp(subjID,:) = compute_peak_exp(expData, SUBJID(subjID), isHipFlexion, "3kg", Ntrials, -1, []);
    WeightedWalking4kgHipExtMaxExp(subjID,:) = compute_peak_exp(expData, SUBJID(subjID), isHipFlexion, "4kg", Ntrials, -1, []);
    WeightedWalking5kgHipExtMaxExp(subjID,:) = compute_peak_exp(expData, SUBJID(subjID), isHipFlexion, "5kg", Ntrials, -1, []);

    normalWalkingAnkleMaxExp(subjID,:) = compute_peak_exp(expData, SUBJID(subjID), isAnklePlantar, "Normal", Ntrials, -1, 50:80);
    WeightedWalking1kgAnkleMaxExp(subjID,:) = compute_peak_exp(expData, SUBJID(subjID), isAnklePlantar, "1kg", Ntrials, -1, 50:80);
    WeightedWalking2kgAnkleMaxExp(subjID,:) = compute_peak_exp(expData, SUBJID(subjID), isAnklePlantar, "2kg", Ntrials, -1, 50:80);
    WeightedWalking3kgAnkleMaxExp(subjID,:) = compute_peak_exp(expData, SUBJID(subjID), isAnklePlantar, "3kg", Ntrials, -1, 50:80);
    WeightedWalking4kgAnkleMaxExp(subjID,:) = compute_peak_exp(expData, SUBJID(subjID), isAnklePlantar, "4kg", Ntrials, -1, 50:80);
    WeightedWalking5kgAnkleMaxExp(subjID,:) = compute_peak_exp(expData, SUBJID(subjID), isAnklePlantar, "5kg", Ntrials, -1, 50:80);
end

% compute knee average per subject
normalWalkingKneeMaxExpPerSUBJ = mean(normalWalkingKneeMaxExp,2,"omitnan");
WeightedWalking1kgKneeMaxExpPerSUBJ = mean(WeightedWalking1kgKneeMaxExp,2,"omitnan");
WeightedWalking2kgKneeMaxExpPerSUBJ = mean(WeightedWalking2kgKneeMaxExp,2,"omitnan");
WeightedWalking3kgKneeMaxExpPerSUBJ = mean(WeightedWalking3kgKneeMaxExp,2,"omitnan");
WeightedWalking4kgKneeMaxExpPerSUBJ = mean(WeightedWalking4kgKneeMaxExp,2,"omitnan");
WeightedWalking5kgKneeMaxExpPerSUBJ = mean(WeightedWalking5kgKneeMaxExp,2,"omitnan");

% compute hip average per subject
normalWalkingHipFlexMaxExpPerSUBJ = mean(normalWalkingHipFlexMaxExp,2,"omitnan");
WeightedWalking1kgHipFlexMaxExpPerSUBJ = mean(WeightedWalking1kgHipFlexMaxExp,2,"omitnan");
WeightedWalking2kgHipFlexMaxExpPerSUBJ = mean(WeightedWalking2kgHipFlexMaxExp,2,"omitnan");
WeightedWalking3kgHipFlexMaxExpPerSUBJ = mean(WeightedWalking3kgHipFlexMaxExp,2,"omitnan");
WeightedWalking4kgHipFlexMaxExpPerSUBJ = mean(WeightedWalking4kgHipFlexMaxExp,2,"omitnan");
WeightedWalking5kgHipFlexMaxExpPerSUBJ = mean(WeightedWalking5kgHipFlexMaxExp,2,"omitnan");

normalWalkingHipExtMaxExpPerSUBJ = mean(normalWalkingHipExtMaxExp,2,"omitnan");
WeightedWalking1kgHipExtMaxExpPerSUBJ = mean(WeightedWalking1kgHipExtMaxExp,2,"omitnan");
WeightedWalking2kgHipExtMaxExpPerSUBJ = mean(WeightedWalking2kgHipExtMaxExp,2,"omitnan");
WeightedWalking3kgHipExtMaxExpPerSUBJ = mean(WeightedWalking3kgHipExtMaxExp,2,"omitnan");
WeightedWalking4kgHipExtMaxExpPerSUBJ = mean(WeightedWalking4kgHipExtMaxExp,2,"omitnan");
WeightedWalking5kgHipExtMaxExpPerSUBJ = mean(WeightedWalking5kgHipExtMaxExp,2,"omitnan");

% compute ankle average per subject
normalWalkingAnkleMaxExpPerSUBJ = mean(normalWalkingAnkleMaxExp,2,"omitnan");
WeightedWalking1kgAnkleMaxExpPerSUBJ = mean(WeightedWalking1kgAnkleMaxExp,2,"omitnan");
WeightedWalking2kgAnkleMaxExpPerSUBJ = mean(WeightedWalking2kgAnkleMaxExp,2,"omitnan");
WeightedWalking3kgAnkleMaxExpPerSUBJ = mean(WeightedWalking3kgAnkleMaxExp,2,"omitnan");
WeightedWalking4kgAnkleMaxExpPerSUBJ = mean(WeightedWalking4kgAnkleMaxExp,2,"omitnan");
WeightedWalking5kgAnkleMaxExpPerSUBJ = mean(WeightedWalking5kgAnkleMaxExp,2,"omitnan");

%% Save Generic Weighted Results
[GenericKinDataWeightedTrackIG, GenericGrfDataWeightedTrackIG, GenericKitDataWeightedTrackIG, GenericEmgDataWeightedTrackIG, ~, ~, GenericCostDataTrackIG, GenericIdxHeelLTrackIG, ~, ~, ~] = average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, resultsDIR, ResultsFolders, trackIGsubFolderGeneric, weightedKeyWords, Nweights);
[GenericKinDataWeightedExpIG, GenericGrfDataWeightedExpIG, GenericKitDataWeightedExpIG, GenericEmgDataWeightedExpIG, ~, ~, GenericCostDataExpIG, GenericIdxHeelLExpIG, ~, ~, ~] = average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, resultsDIR, ResultsFolders, expIGsubFolderGeneric, weightedKeyWords, Nweights);

%% Save Personal Weighted Results
[PersonalKinDataWeightedTrackIG, PersonalGrfDataWeightedTrackIG, PersonalKitDataWeightedTrackIG, PersonalEmgDataWeightedTrackIG, ~, ~, PersonalCostDataTrackIG, PersonalIdxHeelLTrackIG, ~, ~, ~] = average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, resultsDIR, ResultsFolders, trackIGsubFolderPersonal, weightedKeyWords, Nweights);
[PersonalKinDataWeightedExpIG, PersonalGrfDataWeightedExpIG, PersonalKitDataWeightedExpIG, PersonalEmgDataWeightedExpIG, ~, ~, PersonalCostDataExpIG, PersonalIdxHeelLExpIG, ~, ~, ~] = average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, resultsDIR, ResultsFolders, expIGsubFolderPersonal, weightedKeyWords, Nweights);

%% Choose Lowest Cost Solution
% Generic
[GenericKinDataWeighted, GenericGrfDataWeighted, GenericKitDataWeighted, GenericEmgDataWeighted, GenericIdxHeelLWeighted] = choose_lowest_cost(...
    GenericKinDataWeightedTrackIG, GenericGrfDataWeightedTrackIG, GenericKitDataWeightedTrackIG, GenericEmgDataWeightedTrackIG, GenericIdxHeelLTrackIG, GenericCostDataTrackIG,...
    GenericKinDataWeightedExpIG, GenericGrfDataWeightedExpIG, GenericKitDataWeightedExpIG, GenericEmgDataWeightedExpIG, GenericIdxHeelLExpIG, GenericCostDataExpIG);

% Personal
[PersonalKinDataWeighted, PersonalGrfDataWeighted, PersonalKitDataWeighted, PersonalEmgDataWeighted, PersonalIdxHeelLWeighted] = choose_lowest_cost(...
    PersonalKinDataWeightedTrackIG, PersonalGrfDataWeightedTrackIG, PersonalKitDataWeightedTrackIG, PersonalEmgDataWeightedTrackIG, PersonalIdxHeelLTrackIG, PersonalCostDataTrackIG,...
    PersonalKinDataWeightedExpIG, PersonalGrfDataWeightedExpIG, PersonalKitDataWeightedExpIG, PersonalEmgDataWeightedExpIG, PersonalIdxHeelLExpIG, PersonalCostDataExpIG);

%% Save D'Hondt2024 3 Segment Weighted Results
dhondt2024_3segSubFolders = repmat("Dhondt2024_3seg",1,NSUBJ) + "/" + ["SUBJ04_Dhondt2024_3seg_17062026", "SUBJ06_Dhondt2024_3seg_17062026", "SUBJ07_Dhondt2024_3seg_17062026", "SUBJ09_Dhondt2024_3seg_17062026", "SUBJ10_Dhondt2024_3seg_17062026", "SUBJ11_Dhondt2024_3seg_17062026"];
dhondt2024_3segSubFolders = dhondt2024_3segSubFolders + "/weightedWalking";
[Dhondt2024_3segKinDataWeighted, ~, ~, ~, ~, ~, ~, Dhondt2024_3segIdxHeelLWeighted, ~, ~, ~] = average_results(resampTime, 29, Ngrfcol, 92, resultsDIR, ResultsFolders, dhondt2024_3segSubFolders, weightedKeyWords, Nweights);

Dhondt2024_3segKinDataWeightedLim = Dhondt2024_3segKinDataWeighted(:,Dhondt2024_3seg_isLimKin>0,:,:);

%% Shift Left Simulation Data
% shift kinematics
isLeftKin = contains(kinColHeaders,"_l") & ~contains(kinColHeaders,"pelvis");
[GenericKinDataShifted, PersonalKinDataShifted, Dhondt2024_3segKinDataShifted] = shift_sim_data(isLeftKin, GenericKinData, PersonalKinData, Dhondt2024_3segKinDataLim, GenericIdxHeelL, PersonalIdxHeelL, Dhondt2024_3segIdxHeelL);
[GenericKinDataWeightedShifted, PersonalKinDataWeightedShifted, Dhondt2024_3segKinDataWeightedShifted] = shift_sim_data(isLeftKin, GenericKinDataWeighted, PersonalKinDataWeighted, Dhondt2024_3segKinDataWeightedLim, GenericIdxHeelLWeighted, PersonalIdxHeelLWeighted, Dhondt2024_3segIdxHeelLWeighted);

%% Save Generic Weighted Results
isKneeFlexion = contains(kinColHeaders,"knee_angle") & ~contains(kinColHeaders,"beta");
isHipFlexion = contains(kinColHeaders,"hip_flexion");
isAnklePlantar = contains(kinColHeaders,"ankle_angle");

% knee flexion
normalWalkingKneeMaxGeneric = NaN(NSUBJ, 1);
WeightedWalkingKneeMaxGeneric = NaN(NSUBJ, Nweights);

% hip flexion
normalWalkingHipFlexMaxGeneric = NaN(NSUBJ, 1);
WeightedWalkingHipFlexMaxGeneric = NaN(NSUBJ, Nweights);

% hip extension
normalWalkingHipExtMaxGeneric = NaN(NSUBJ, 1);
WeightedWalkingHipExtMaxGeneric = NaN(NSUBJ, Nweights);

% ankle plantarflexion
normalWalkingAnkleMaxGeneric = NaN(NSUBJ, 1);
WeightedWalkingAnkleMaxGeneric = NaN(NSUBJ, Nweights);

for subjID = 1:NSUBJ
    normalWalkingKneeMaxGeneric(subjID) = compute_peak_sim(GenericKinDataShifted, isKneeFlexion, subjID, -1, []);
    WeightedWalkingKneeMaxGeneric(subjID,:) = compute_peak_sim(GenericKinDataWeightedShifted, isKneeFlexion, subjID, -1, []);

    normalWalkingHipFlexMaxGeneric(subjID) = compute_peak_sim(GenericKinDataShifted, isHipFlexion, subjID, 1, []);
    WeightedWalkingHipFlexMaxGeneric(subjID,:) = compute_peak_sim(GenericKinDataWeightedShifted, isHipFlexion, subjID, 1, []);

    normalWalkingHipExtMaxGeneric(subjID) = compute_peak_sim(GenericKinDataShifted, isHipFlexion, subjID, -1, []);
    WeightedWalkingHipExtMaxGeneric(subjID,:) = compute_peak_sim(GenericKinDataWeightedShifted, isHipFlexion, subjID, -1, []);

    normalWalkingAnkleMaxGeneric(subjID) = compute_peak_sim(GenericKinDataShifted, isAnklePlantar, subjID, -1, 50:100);
    WeightedWalkingAnkleMaxGeneric(subjID,:) = compute_peak_sim(GenericKinDataWeightedShifted, isAnklePlantar, subjID, -1, 50:100);
end

%% Save Personal Weighted Results

% knee flexion
normalWalkingKneeMaxPersonal = NaN(NSUBJ, 1);
WeightedWalkingKneeMaxPersonal = NaN(NSUBJ, Nweights);

% hip flexion
normalWalkingHipFlexMaxPersonal = NaN(NSUBJ, 1);
WeightedWalkingHipFlexMaxPersonal = NaN(NSUBJ, Nweights);

% hip extension
normalWalkingHipExtMaxPersonal = NaN(NSUBJ, 1);
WeightedWalkingHipExtMaxPersonal = NaN(NSUBJ, Nweights);

% ankle plantarflexion
normalWalkingAnkleMaxPersonal = NaN(NSUBJ, 1);
WeightedWalkingAnkleMaxPersonal = NaN(NSUBJ, Nweights);

for subjID = 1:NSUBJ
    normalWalkingKneeMaxPersonal(subjID) = compute_peak_sim(PersonalKinDataShifted, isKneeFlexion, subjID, -1, []);
    WeightedWalkingKneeMaxPersonal(subjID,:) = compute_peak_sim(PersonalKinDataWeightedShifted, isKneeFlexion, subjID, -1, []);

    normalWalkingHipFlexMaxPersonal(subjID) = compute_peak_sim(PersonalKinDataShifted, isHipFlexion, subjID, 1, []);
    WeightedWalkingHipFlexMaxPersonal(subjID,:) = compute_peak_sim(PersonalKinDataWeightedShifted, isHipFlexion, subjID, 1, []);

    normalWalkingHipExtMaxPersonal(subjID) = compute_peak_sim(PersonalKinDataShifted, isHipFlexion, subjID, -1, []);
    WeightedWalkingHipExtMaxPersonal(subjID,:) = compute_peak_sim(PersonalKinDataWeightedShifted, isHipFlexion, subjID, -1, []);

    normalWalkingAnkleMaxPersonal(subjID) = compute_peak_sim(PersonalKinDataShifted, isAnklePlantar, subjID, -1, 50:100);
    WeightedWalkingAnkleMaxPersonal(subjID,:) = compute_peak_sim(PersonalKinDataWeightedShifted, isAnklePlantar, subjID, -1, 50:100);
end

%% Save D'Hondt 2024 3seg Weighted Results

% knee flexion
normalWalkingKneeMaxDhondt2024_3seg = NaN(NSUBJ, 1);
WeightedWalkingKneeMaxDhondt2024_3seg = NaN(NSUBJ, Nweights);

% hip flexion
normalWalkingHipFlexMaxDhondt2024_3seg = NaN(NSUBJ, 1);
WeightedWalkingHipFlexMaxDhondt2024_3seg = NaN(NSUBJ, Nweights);

% hip extension
normalWalkingHipExtMaxDhondt2024_3seg = NaN(NSUBJ, 1);
WeightedWalkingHipExtMaxDhondt2024_3seg = NaN(NSUBJ, Nweights);

% ankle plantarflexion
normalWalkingAnkleMaxDhondt2024_3seg = NaN(NSUBJ, 1);
WeightedWalkingAnkleMaxDhondt2024_3seg = NaN(NSUBJ, Nweights);

for subjID = 1:NSUBJ
    normalWalkingKneeMaxDhondt2024_3seg(subjID) = compute_peak_sim(Dhondt2024_3segKinDataShifted, isKneeFlexion, subjID, -1, []);
    WeightedWalkingKneeMaxDhondt2024_3seg(subjID,:) = compute_peak_sim(Dhondt2024_3segKinDataWeightedShifted, isKneeFlexion, subjID, -1, []);

    normalWalkingHipFlexMaxDhondt2024_3seg(subjID) = compute_peak_sim(Dhondt2024_3segKinDataShifted, isHipFlexion, subjID, 1, []);
    WeightedWalkingHipFlexMaxDhondt2024_3seg(subjID,:) = compute_peak_sim(Dhondt2024_3segKinDataWeightedShifted, isHipFlexion, subjID, 1, []);

    normalWalkingHipExtMaxDhondt2024_3seg(subjID) = compute_peak_sim(Dhondt2024_3segKinDataShifted, isHipFlexion, subjID, -1, []);
    WeightedWalkingHipExtMaxDhondt2024_3seg(subjID,:) = compute_peak_sim(Dhondt2024_3segKinDataWeightedShifted, isHipFlexion, subjID, -1, []);

    normalWalkingAnkleMaxDhondt2024_3seg(subjID) = compute_peak_sim(Dhondt2024_3segKinDataShifted, isAnklePlantar, subjID, -1, 50:100);
    WeightedWalkingAnkleMaxDhondt2024_3seg(subjID,:) = compute_peak_sim(Dhondt2024_3segKinDataWeightedShifted, isAnklePlantar, subjID, -1, 50:100);
end

%% Extract Experimental Data
% find kinematics corresponding columns
kin_col_exp = expData.data.headers.kinematics;
[isLimKINexp,~]=ismember(kin_col_exp,kinColHeaders);

% find GRF corresponding columns
grf_col_exp = expData.data.headers.GRF;
isForce = contains(grf_col_exp,"ground_force") & contains(grf_col_exp,"v");

[normalWalkingKinExpAvgLim, normalWalkingKinExpStdLim, weightedWalkingKinExpAvgLim, weightedWalkingKinExpStdLim] = extract_experimental_data(expData, "kinematics", "Ik", SUBJID, Ndata, Nweights, isLimKINexp>0);
[~,~,weightedWalkingGrfExpAvgLim, weightedWalkingGrfExpStdLim] = extract_experimental_data(expData, "GRF", "GRF", SUBJID, Ndata, Nweights, isForce);

%% Split Labels
isTrans = contains(kinColHeaders,"pelvis_tx") | contains(kinColHeaders,"pelvis_ty") | contains(kinColHeaders,"pelvis_tz");
kinLabels = repmat("[°]",Nkincol,1); kinLabels(isTrans) = "[m]";
grfLabels = repmat("Force [N]", Ngrfcol, 1);
kitLabels = repmat("Joint Moment [Nm]", Nkincol, 1); kitLabels(isTrans) = "Joint Force [N]";
emgLabels = repmat("Activation [-]", Nemgcol, 1);

jointNames = extractBefore(kinColHeaders,"_"); jointNames = strcat(upper(extractBefore(jointNames,2)), extractAfter(jointNames,1));
kitLabels = jointNames + " " + kitLabels;

%% Add Labels Directions
kinLabelsExt = strings(Nkincol,2); kinLabelsExt(:,1) = kinLabels;

% ankle
isAnkle = contains(kinColHeaders,"ankle_angle");
kinLabelsExt(isAnkle,:) = [kinLabelsExt(isAnkle,1), repmat("\leftarrow plantar flexion dorsiflexion \rightarrow",2,1)]; 

% knee
isKnee = contains(kinColHeaders,"knee_angle");
kinLabelsExt(isKnee,:) = [kinLabelsExt(isKnee,1), repmat("\leftarrow flexion extension \rightarrow",2,1)]; 

% hip
isHip = contains(kinColHeaders,"hip_flexion");
kinLabelsExt(isHip,:) = [kinLabelsExt(isHip,1), repmat("\leftarrow extension flexion \rightarrow",2,1)]; 

%% Compute Knee Flexion Reduction
KneeMax1kgRedExpPerSUBJ = compute_red(normalWalkingKneeMaxExpPerSUBJ, WeightedWalking1kgKneeMaxExpPerSUBJ);
KneeMax2kgRedExpPerSUBJ = compute_red(normalWalkingKneeMaxExpPerSUBJ, WeightedWalking2kgKneeMaxExpPerSUBJ);
KneeMax3kgRedExpPerSUBJ = compute_red(normalWalkingKneeMaxExpPerSUBJ, WeightedWalking3kgKneeMaxExpPerSUBJ);
KneeMax4kgRedExpPerSUBJ = compute_red(normalWalkingKneeMaxExpPerSUBJ, WeightedWalking4kgKneeMaxExpPerSUBJ);
KneeMax5kgRedExpPerSUBJ = compute_red(normalWalkingKneeMaxExpPerSUBJ, WeightedWalking5kgKneeMaxExpPerSUBJ);

KneeMax1kgRedGenPerSUBJ = compute_red(normalWalkingKneeMaxGeneric, WeightedWalkingKneeMaxGeneric(:,1));
KneeMax2kgRedGenPerSUBJ = compute_red(normalWalkingKneeMaxGeneric, WeightedWalkingKneeMaxGeneric(:,2));
KneeMax3kgRedGenPerSUBJ = compute_red(normalWalkingKneeMaxGeneric, WeightedWalkingKneeMaxGeneric(:,3));
KneeMax4kgRedGenPerSUBJ = compute_red(normalWalkingKneeMaxGeneric, WeightedWalkingKneeMaxGeneric(:,4));
KneeMax5kgRedGenPerSUBJ = compute_red(normalWalkingKneeMaxGeneric, WeightedWalkingKneeMaxGeneric(:,5));

KneeMax1kgRedPerPerSUBJ = compute_red(normalWalkingKneeMaxPersonal, WeightedWalkingKneeMaxPersonal(:,1));
KneeMax2kgRedPerPerSUBJ = compute_red(normalWalkingKneeMaxPersonal, WeightedWalkingKneeMaxPersonal(:,2));
KneeMax3kgRedPerPerSUBJ = compute_red(normalWalkingKneeMaxPersonal, WeightedWalkingKneeMaxPersonal(:,3));
KneeMax4kgRedPerPerSUBJ = compute_red(normalWalkingKneeMaxPersonal, WeightedWalkingKneeMaxPersonal(:,4));
KneeMax5kgRedPerPerSUBJ = compute_red(normalWalkingKneeMaxPersonal, WeightedWalkingKneeMaxPersonal(:,5));

KneeMax1kgRedDhondtPerSUBJ = compute_red(normalWalkingKneeMaxDhondt2024_3seg, WeightedWalkingKneeMaxDhondt2024_3seg(:,1));
KneeMax2kgRedDhondtPerSUBJ = compute_red(normalWalkingKneeMaxDhondt2024_3seg, WeightedWalkingKneeMaxDhondt2024_3seg(:,2));
KneeMax3kgRedDhondtPerSUBJ = compute_red(normalWalkingKneeMaxDhondt2024_3seg, WeightedWalkingKneeMaxDhondt2024_3seg(:,3));
KneeMax4kgRedDhondtPerSUBJ = compute_red(normalWalkingKneeMaxDhondt2024_3seg, WeightedWalkingKneeMaxDhondt2024_3seg(:,4));
KneeMax5kgRedDhondtPerSUBJ = compute_red(normalWalkingKneeMaxDhondt2024_3seg, WeightedWalkingKneeMaxDhondt2024_3seg(:,5));

%% Compute Hip Flexion Reduction
HipFlexMax1kgRedExpPerSUBJ = compute_red(normalWalkingHipFlexMaxExpPerSUBJ, WeightedWalking1kgHipFlexMaxExpPerSUBJ);
HipFlexMax2kgRedExpPerSUBJ = compute_red(normalWalkingHipFlexMaxExpPerSUBJ, WeightedWalking2kgHipFlexMaxExpPerSUBJ);
HipFlexMax3kgRedExpPerSUBJ = compute_red(normalWalkingHipFlexMaxExpPerSUBJ, WeightedWalking3kgHipFlexMaxExpPerSUBJ);
HipFlexMax4kgRedExpPerSUBJ = compute_red(normalWalkingHipFlexMaxExpPerSUBJ, WeightedWalking4kgHipFlexMaxExpPerSUBJ);
HipFlexMax5kgRedExpPerSUBJ = compute_red(normalWalkingHipFlexMaxExpPerSUBJ, WeightedWalking5kgHipFlexMaxExpPerSUBJ);

HipFlexMax1kgRedGenPerSUBJ = compute_red(normalWalkingHipFlexMaxGeneric, WeightedWalkingHipFlexMaxGeneric(:,1));
HipFlexMax2kgRedGenPerSUBJ = compute_red(normalWalkingHipFlexMaxGeneric, WeightedWalkingHipFlexMaxGeneric(:,2));
HipFlexMax3kgRedGenPerSUBJ = compute_red(normalWalkingHipFlexMaxGeneric, WeightedWalkingHipFlexMaxGeneric(:,3));
HipFlexMax4kgRedGenPerSUBJ = compute_red(normalWalkingHipFlexMaxGeneric, WeightedWalkingHipFlexMaxGeneric(:,4));
HipFlexMax5kgRedGenPerSUBJ = compute_red(normalWalkingHipFlexMaxGeneric, WeightedWalkingHipFlexMaxGeneric(:,5));

HipFlexMax1kgRedPerPerSUBJ = compute_red(normalWalkingHipFlexMaxPersonal, WeightedWalkingHipFlexMaxPersonal(:,1));
HipFlexMax2kgRedPerPerSUBJ = compute_red(normalWalkingHipFlexMaxPersonal, WeightedWalkingHipFlexMaxPersonal(:,2));
HipFlexMax3kgRedPerPerSUBJ = compute_red(normalWalkingHipFlexMaxPersonal, WeightedWalkingHipFlexMaxPersonal(:,3));
HipFlexMax4kgRedPerPerSUBJ = compute_red(normalWalkingHipFlexMaxPersonal, WeightedWalkingHipFlexMaxPersonal(:,4));
HipFlexMax5kgRedPerPerSUBJ = compute_red(normalWalkingHipFlexMaxPersonal, WeightedWalkingHipFlexMaxPersonal(:,5));

HipFlexMax1kgRedDhondtPerSUBJ = compute_red(normalWalkingHipFlexMaxDhondt2024_3seg, WeightedWalkingHipFlexMaxDhondt2024_3seg(:,1));
HipFlexMax2kgRedDhondtPerSUBJ = compute_red(normalWalkingHipFlexMaxDhondt2024_3seg, WeightedWalkingHipFlexMaxDhondt2024_3seg(:,2));
HipFlexMax3kgRedDhondtPerSUBJ = compute_red(normalWalkingHipFlexMaxDhondt2024_3seg, WeightedWalkingHipFlexMaxDhondt2024_3seg(:,3));
HipFlexMax4kgRedDhondtPerSUBJ = compute_red(normalWalkingHipFlexMaxDhondt2024_3seg, WeightedWalkingHipFlexMaxDhondt2024_3seg(:,4));
HipFlexMax5kgRedDhondtPerSUBJ = compute_red(normalWalkingHipFlexMaxDhondt2024_3seg, WeightedWalkingHipFlexMaxDhondt2024_3seg(:,5));

%% Compute Hip Extension Reduction
HipExtMax1kgRedExpPerSUBJ = compute_red(normalWalkingHipExtMaxExpPerSUBJ, WeightedWalking1kgHipExtMaxExpPerSUBJ);
HipExtMax2kgRedExpPerSUBJ = compute_red(normalWalkingHipExtMaxExpPerSUBJ, WeightedWalking2kgHipExtMaxExpPerSUBJ);
HipExtMax3kgRedExpPerSUBJ = compute_red(normalWalkingHipExtMaxExpPerSUBJ, WeightedWalking3kgHipExtMaxExpPerSUBJ);
HipExtMax4kgRedExpPerSUBJ = compute_red(normalWalkingHipExtMaxExpPerSUBJ, WeightedWalking4kgHipExtMaxExpPerSUBJ);
HipExtMax5kgRedExpPerSUBJ = compute_red(normalWalkingHipExtMaxExpPerSUBJ, WeightedWalking5kgHipExtMaxExpPerSUBJ);

HipExtMax1kgRedGenPerSUBJ = compute_red(normalWalkingHipExtMaxGeneric, WeightedWalkingHipExtMaxGeneric(:,1));
HipExtMax2kgRedGenPerSUBJ = compute_red(normalWalkingHipExtMaxGeneric, WeightedWalkingHipExtMaxGeneric(:,2));
HipExtMax3kgRedGenPerSUBJ = compute_red(normalWalkingHipExtMaxGeneric, WeightedWalkingHipExtMaxGeneric(:,3));
HipExtMax4kgRedGenPerSUBJ = compute_red(normalWalkingHipExtMaxGeneric, WeightedWalkingHipExtMaxGeneric(:,4));
HipExtMax5kgRedGenPerSUBJ = compute_red(normalWalkingHipExtMaxGeneric, WeightedWalkingHipExtMaxGeneric(:,5));

HipExtMax1kgRedPerPerSUBJ = compute_red(normalWalkingHipExtMaxPersonal, WeightedWalkingHipExtMaxPersonal(:,1));
HipExtMax2kgRedPerPerSUBJ = compute_red(normalWalkingHipExtMaxPersonal, WeightedWalkingHipExtMaxPersonal(:,2));
HipExtMax3kgRedPerPerSUBJ = compute_red(normalWalkingHipExtMaxPersonal, WeightedWalkingHipExtMaxPersonal(:,3));
HipExtMax4kgRedPerPerSUBJ = compute_red(normalWalkingHipExtMaxPersonal, WeightedWalkingHipExtMaxPersonal(:,4));
HipExtMax5kgRedPerPerSUBJ = compute_red(normalWalkingHipExtMaxPersonal, WeightedWalkingHipExtMaxPersonal(:,5));

HipExtMax1kgRedDhondtPerSUBJ = compute_red(normalWalkingHipExtMaxDhondt2024_3seg, WeightedWalkingHipExtMaxDhondt2024_3seg(:,1));
HipExtMax2kgRedDhondtPerSUBJ = compute_red(normalWalkingHipExtMaxDhondt2024_3seg, WeightedWalkingHipExtMaxDhondt2024_3seg(:,2));
HipExtMax3kgRedDhondtPerSUBJ = compute_red(normalWalkingHipExtMaxDhondt2024_3seg, WeightedWalkingHipExtMaxDhondt2024_3seg(:,3));
HipExtMax4kgRedDhondtPerSUBJ = compute_red(normalWalkingHipExtMaxDhondt2024_3seg, WeightedWalkingHipExtMaxDhondt2024_3seg(:,4));
HipExtMax5kgRedDhondtPerSUBJ = compute_red(normalWalkingHipExtMaxDhondt2024_3seg, WeightedWalkingHipExtMaxDhondt2024_3seg(:,5));

%% Compute Ankle Plantarflexion Reduction
AnkleMax1kgRedExpPerSUBJ = compute_red(normalWalkingAnkleMaxExpPerSUBJ, WeightedWalking1kgAnkleMaxExpPerSUBJ);
AnkleMax2kgRedExpPerSUBJ = compute_red(normalWalkingAnkleMaxExpPerSUBJ, WeightedWalking2kgAnkleMaxExpPerSUBJ);
AnkleMax3kgRedExpPerSUBJ = compute_red(normalWalkingAnkleMaxExpPerSUBJ, WeightedWalking3kgAnkleMaxExpPerSUBJ);
AnkleMax4kgRedExpPerSUBJ = compute_red(normalWalkingAnkleMaxExpPerSUBJ, WeightedWalking4kgAnkleMaxExpPerSUBJ);
AnkleMax5kgRedExpPerSUBJ = compute_red(normalWalkingAnkleMaxExpPerSUBJ, WeightedWalking5kgAnkleMaxExpPerSUBJ);

AnkleMax1kgRedGenPerSUBJ = compute_red(normalWalkingAnkleMaxGeneric, WeightedWalkingAnkleMaxGeneric(:,1));
AnkleMax2kgRedGenPerSUBJ = compute_red(normalWalkingAnkleMaxGeneric, WeightedWalkingAnkleMaxGeneric(:,2));
AnkleMax3kgRedGenPerSUBJ = compute_red(normalWalkingAnkleMaxGeneric, WeightedWalkingAnkleMaxGeneric(:,3));
AnkleMax4kgRedGenPerSUBJ = compute_red(normalWalkingAnkleMaxGeneric, WeightedWalkingAnkleMaxGeneric(:,4));
AnkleMax5kgRedGenPerSUBJ = compute_red(normalWalkingAnkleMaxGeneric, WeightedWalkingAnkleMaxGeneric(:,5));

AnkleMax1kgRedPerPerSUBJ = compute_red(normalWalkingAnkleMaxPersonal, WeightedWalkingAnkleMaxPersonal(:,1));
AnkleMax2kgRedPerPerSUBJ = compute_red(normalWalkingAnkleMaxPersonal, WeightedWalkingAnkleMaxPersonal(:,2));
AnkleMax3kgRedPerPerSUBJ = compute_red(normalWalkingAnkleMaxPersonal, WeightedWalkingAnkleMaxPersonal(:,3));
AnkleMax4kgRedPerPerSUBJ = compute_red(normalWalkingAnkleMaxPersonal, WeightedWalkingAnkleMaxPersonal(:,4));
AnkleMax5kgRedPerPerSUBJ = compute_red(normalWalkingAnkleMaxPersonal, WeightedWalkingAnkleMaxPersonal(:,5));

AnkleMax1kgRedDhondtPerSUBJ = compute_red(normalWalkingAnkleMaxDhondt2024_3seg, WeightedWalkingAnkleMaxDhondt2024_3seg(:,1));
AnkleMax2kgRedDhondtPerSUBJ = compute_red(normalWalkingAnkleMaxDhondt2024_3seg, WeightedWalkingAnkleMaxDhondt2024_3seg(:,2));
AnkleMax3kgRedDhondtPerSUBJ = compute_red(normalWalkingAnkleMaxDhondt2024_3seg, WeightedWalkingAnkleMaxDhondt2024_3seg(:,3));
AnkleMax4kgRedDhondtPerSUBJ = compute_red(normalWalkingAnkleMaxDhondt2024_3seg, WeightedWalkingAnkleMaxDhondt2024_3seg(:,4));
AnkleMax5kgRedDhondtPerSUBJ = compute_red(normalWalkingAnkleMaxDhondt2024_3seg, WeightedWalkingAnkleMaxDhondt2024_3seg(:,5));

%% Compute RMSE
% knee flexion
KneeRMSEGenPerSUBJ = compute_RMSE_per_subj(NSUBJ, Nweights, KneeMax1kgRedExpPerSUBJ, KneeMax2kgRedExpPerSUBJ, KneeMax3kgRedExpPerSUBJ, KneeMax4kgRedExpPerSUBJ, KneeMax5kgRedExpPerSUBJ, KneeMax1kgRedGenPerSUBJ, KneeMax2kgRedGenPerSUBJ, KneeMax3kgRedGenPerSUBJ, KneeMax4kgRedGenPerSUBJ, KneeMax5kgRedGenPerSUBJ);
KneeRMSEPerPerSUBJ = compute_RMSE_per_subj(NSUBJ, Nweights, KneeMax1kgRedExpPerSUBJ, KneeMax2kgRedExpPerSUBJ, KneeMax3kgRedExpPerSUBJ, KneeMax4kgRedExpPerSUBJ, KneeMax5kgRedExpPerSUBJ, KneeMax1kgRedPerPerSUBJ, KneeMax2kgRedPerPerSUBJ, KneeMax3kgRedPerPerSUBJ, KneeMax4kgRedPerPerSUBJ, KneeMax5kgRedPerPerSUBJ);
KneeRMSEDhondtPerSUBJ = compute_RMSE_per_subj(NSUBJ, Nweights, KneeMax1kgRedExpPerSUBJ, KneeMax2kgRedExpPerSUBJ, KneeMax3kgRedExpPerSUBJ, KneeMax4kgRedExpPerSUBJ, KneeMax5kgRedExpPerSUBJ, KneeMax1kgRedDhondtPerSUBJ, KneeMax2kgRedDhondtPerSUBJ, KneeMax3kgRedDhondtPerSUBJ, KneeMax4kgRedDhondtPerSUBJ, KneeMax5kgRedDhondtPerSUBJ);

% hip flexion
HipFlexRMSEGenPerSUBJ = compute_RMSE_per_subj(NSUBJ, Nweights, HipFlexMax1kgRedExpPerSUBJ, HipFlexMax2kgRedExpPerSUBJ, HipFlexMax3kgRedExpPerSUBJ, HipFlexMax4kgRedExpPerSUBJ, HipFlexMax5kgRedExpPerSUBJ, HipFlexMax1kgRedGenPerSUBJ, HipFlexMax2kgRedGenPerSUBJ, HipFlexMax3kgRedGenPerSUBJ, HipFlexMax4kgRedGenPerSUBJ, HipFlexMax5kgRedGenPerSUBJ);
HipFlexRMSEPerPerSUBJ = compute_RMSE_per_subj(NSUBJ, Nweights, HipFlexMax1kgRedExpPerSUBJ, HipFlexMax2kgRedExpPerSUBJ, HipFlexMax3kgRedExpPerSUBJ, HipFlexMax4kgRedExpPerSUBJ, HipFlexMax5kgRedExpPerSUBJ, HipFlexMax1kgRedPerPerSUBJ, HipFlexMax2kgRedPerPerSUBJ, HipFlexMax3kgRedPerPerSUBJ, HipFlexMax4kgRedPerPerSUBJ, HipFlexMax5kgRedPerPerSUBJ);
HipFlexRMSEDhondtPerSUBJ = compute_RMSE_per_subj(NSUBJ, Nweights, HipFlexMax1kgRedExpPerSUBJ, HipFlexMax2kgRedExpPerSUBJ, HipFlexMax3kgRedExpPerSUBJ, HipFlexMax4kgRedExpPerSUBJ, HipFlexMax5kgRedExpPerSUBJ, HipFlexMax1kgRedDhondtPerSUBJ, HipFlexMax2kgRedDhondtPerSUBJ, HipFlexMax3kgRedDhondtPerSUBJ, HipFlexMax4kgRedDhondtPerSUBJ, HipFlexMax5kgRedDhondtPerSUBJ);

% hip extension
HipExtRMSEGenPerSUBJ = compute_RMSE_per_subj(NSUBJ, Nweights, HipExtMax1kgRedExpPerSUBJ, HipExtMax2kgRedExpPerSUBJ, HipExtMax3kgRedExpPerSUBJ, HipExtMax4kgRedExpPerSUBJ, HipExtMax5kgRedExpPerSUBJ, HipExtMax1kgRedGenPerSUBJ, HipExtMax2kgRedGenPerSUBJ, HipExtMax3kgRedGenPerSUBJ, HipExtMax4kgRedGenPerSUBJ, HipExtMax5kgRedGenPerSUBJ);
HipExtRMSEPerPerSUBJ = compute_RMSE_per_subj(NSUBJ, Nweights, HipExtMax1kgRedExpPerSUBJ, HipExtMax2kgRedExpPerSUBJ, HipExtMax3kgRedExpPerSUBJ, HipExtMax4kgRedExpPerSUBJ, HipExtMax5kgRedExpPerSUBJ, HipExtMax1kgRedPerPerSUBJ, HipExtMax2kgRedPerPerSUBJ, HipExtMax3kgRedPerPerSUBJ, HipExtMax4kgRedPerPerSUBJ, HipExtMax5kgRedPerPerSUBJ);
HipExtRMSEDhondtPerSUBJ = compute_RMSE_per_subj(NSUBJ, Nweights, HipExtMax1kgRedExpPerSUBJ, HipExtMax2kgRedExpPerSUBJ, HipExtMax3kgRedExpPerSUBJ, HipExtMax4kgRedExpPerSUBJ, HipExtMax5kgRedExpPerSUBJ, HipExtMax1kgRedDhondtPerSUBJ, HipExtMax2kgRedDhondtPerSUBJ, HipExtMax3kgRedDhondtPerSUBJ, HipExtMax4kgRedDhondtPerSUBJ, HipExtMax5kgRedDhondtPerSUBJ);

% ankle plantar flexion
AnkleRMSEGenPerSUBJ = compute_RMSE_per_subj(NSUBJ, Nweights, AnkleMax1kgRedExpPerSUBJ, AnkleMax2kgRedExpPerSUBJ, AnkleMax3kgRedExpPerSUBJ, AnkleMax4kgRedExpPerSUBJ, AnkleMax5kgRedExpPerSUBJ, AnkleMax1kgRedGenPerSUBJ, AnkleMax2kgRedGenPerSUBJ, AnkleMax3kgRedGenPerSUBJ, AnkleMax4kgRedGenPerSUBJ, AnkleMax5kgRedGenPerSUBJ);
AnkleRMSEPerPerSUBJ = compute_RMSE_per_subj(NSUBJ, Nweights, AnkleMax1kgRedExpPerSUBJ, AnkleMax2kgRedExpPerSUBJ, AnkleMax3kgRedExpPerSUBJ, AnkleMax4kgRedExpPerSUBJ, AnkleMax5kgRedExpPerSUBJ, AnkleMax1kgRedPerPerSUBJ, AnkleMax2kgRedPerPerSUBJ, AnkleMax3kgRedPerPerSUBJ, AnkleMax4kgRedPerPerSUBJ, AnkleMax5kgRedPerPerSUBJ);
AnkleRMSEDhondtPerSUBJ = compute_RMSE_per_subj(NSUBJ, Nweights, AnkleMax1kgRedExpPerSUBJ, AnkleMax2kgRedExpPerSUBJ, AnkleMax3kgRedExpPerSUBJ, AnkleMax4kgRedExpPerSUBJ, AnkleMax5kgRedExpPerSUBJ, AnkleMax1kgRedDhondtPerSUBJ, AnkleMax2kgRedDhondtPerSUBJ, AnkleMax3kgRedDhondtPerSUBJ, AnkleMax4kgRedDhondtPerSUBJ, AnkleMax5kgRedDhondtPerSUBJ);

%% Print Results
RMSEPerPerSUBJ = [mean(KneeRMSEPerPerSUBJ,2) mean(HipFlexRMSEPerPerSUBJ,2) mean(HipExtRMSEPerPerSUBJ,2) mean(AnkleRMSEPerPerSUBJ,2)];
RMSEGenPerSUBJ = [mean(KneeRMSEGenPerSUBJ,2) mean(HipFlexRMSEGenPerSUBJ,2) mean(HipExtRMSEGenPerSUBJ,2) mean(AnkleRMSEGenPerSUBJ,2)];
RMSEDhondtPerSUBJ = [mean(KneeRMSEDhondtPerSUBJ,2) mean(HipFlexRMSEDhondtPerSUBJ,2) mean(HipExtRMSEDhondtPerSUBJ,2) mean(AnkleRMSEDhondtPerSUBJ,2)];

isBestPer = RMSEPerPerSUBJ < RMSEGenPerSUBJ;
isBestDhondt = RMSEDhondtPerSUBJ < RMSEPerPerSUBJ;

rowNames = ["knee flexion", "hip flexion", "hip extension", "ankle plantar flexion"];
print_matrix_latex(RMSEPerPerSUBJ', [], ["S4", "S6", "S7", "S9", "S10", "S11"], rowNames, isBestPer', [])
print_matrix_latex(RMSEGenPerSUBJ', [], ["S4", "S6", "S7", "S9", "S10", "S11"], rowNames, ~isBestPer', [])
print_matrix_latex(RMSEDhondtPerSUBJ', [], ["S4", "S6", "S7", "S9", "S10", "S11"], rowNames, isBestDhondt', [])

%% Plot Experimental vs. Simulation Changes

markers = ["^", "square", "diamond", "o", "v", "pentagram"];
colorPer = makeGroupColors(24/360,Nweights+1,1,0.5,1)';
colorGen = makeGroupColors(220/360,Nweights+1,1,0.5,1)';

fig = figure;
set(gcf,"Units","centimeters")                                              % cm units for position
set(gcf,"Position",[0 0 fig_width*2 fig_height*1.5])                        % IEEE 1-column: 8.89cm
t = tiledlayout(2,4, "TileSpacing", "tight");
t.InnerPosition = [0.05 0.07 0.93 0.78];

ax1 = nexttile;
hold on
plot(-5:25,-5:25,"LineWidth",0.5,"Color",[0.9 0.9 0.9])
for i = 1:NSUBJ
    scatter(KneeMax1kgRedExpPerSUBJ(i), KneeMax1kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,1), "MarkerEdgeColor", "none")
    scatter(KneeMax2kgRedExpPerSUBJ(i), KneeMax2kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,2), "MarkerEdgeColor", "none")
    scatter(KneeMax3kgRedExpPerSUBJ(i), KneeMax3kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,3), "MarkerEdgeColor", "none")
    scatter(KneeMax4kgRedExpPerSUBJ(i), KneeMax4kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,4), "MarkerEdgeColor", "none")
    scatter(KneeMax5kgRedExpPerSUBJ(i), KneeMax5kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,5), "MarkerEdgeColor", "none")
end
xlim([-5 25])
ylim([-5 25])
cmap = colormap(ax1, colorGen');
c1 = colorbar(ax1, "northoutside");
c1.TickLabels = ["1 kg", "2 kg", "3 kg", "4 kg", "5 kg"];
c1.Ticks = 1:5;
clim([1 5]);
xlabel("")
ylabel("Predicted Reduction [%]", "FontWeight", "bold")
title("Peak Knee Flexion", "FontWeight", "bold")
hold off

ax2 = nexttile;
hold on
plot(-10:11,-10:11,"LineWidth",0.5,"Color",[0.9 0.9 0.9])
for i = 1:NSUBJ
    scatter(HipFlexMax1kgRedExpPerSUBJ(i), HipFlexMax1kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,1), "MarkerEdgeColor", "none")
    scatter(HipFlexMax2kgRedExpPerSUBJ(i), HipFlexMax2kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,2), "MarkerEdgeColor", "none")
    scatter(HipFlexMax3kgRedExpPerSUBJ(i), HipFlexMax3kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,3), "MarkerEdgeColor", "none")
    scatter(HipFlexMax4kgRedExpPerSUBJ(i), HipFlexMax4kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,4), "MarkerEdgeColor", "none")
    scatter(HipFlexMax5kgRedExpPerSUBJ(i), HipFlexMax5kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,5), "MarkerEdgeColor", "none")
end
xlim([-10 11])
ylim([-10 11])
xlabel("")
ylabel("")
title("Peak Hip Flexion", "FontWeight", "bold")
hold off

nexttile
hold on
plot(-25:35,-25:35,"LineWidth",0.5,"Color",[0.9 0.9 0.9])
for i = 1:NSUBJ
    scatter(HipExtMax1kgRedExpPerSUBJ(i), HipExtMax1kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,1), "MarkerEdgeColor", "none")
    scatter(HipExtMax2kgRedExpPerSUBJ(i), HipExtMax2kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,2), "MarkerEdgeColor", "none")
    scatter(HipExtMax3kgRedExpPerSUBJ(i), HipExtMax3kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,3), "MarkerEdgeColor", "none")
    scatter(HipExtMax4kgRedExpPerSUBJ(i), HipExtMax4kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,4), "MarkerEdgeColor", "none")
    scatter(HipExtMax5kgRedExpPerSUBJ(i), HipExtMax5kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,5), "MarkerEdgeColor", "none")
end
xlim([-25 35])
ylim([-25 35])
xlabel("")
ylabel("")
title("Peak Hip Extension", "FontWeight", "bold")
hold off

nexttile
hold on
plot(-200:100,-200:100,"LineWidth",0.5,"Color",[0.9 0.9 0.9])
for i = 1:NSUBJ
    scatter(AnkleMax1kgRedExpPerSUBJ(i), AnkleMax1kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,1), "MarkerEdgeColor", "none")
    scatter(AnkleMax2kgRedExpPerSUBJ(i), AnkleMax2kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,2), "MarkerEdgeColor", "none")
    scatter(AnkleMax3kgRedExpPerSUBJ(i), AnkleMax3kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,3), "MarkerEdgeColor", "none")
    scatter(AnkleMax4kgRedExpPerSUBJ(i), AnkleMax4kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,4), "MarkerEdgeColor", "none")
    scatter(AnkleMax5kgRedExpPerSUBJ(i), AnkleMax5kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,5), "MarkerEdgeColor", "none")
end
xlim([-200 100])
ylim([-200 100])
xlabel("")
ylabel("")
title("Peak Ankle Plantar Flexion", "FontWeight", "bold")
lg = legend(["" "S 4" repmat("",1,Nweights-1) "S 6" repmat("",1,Nweights-1) "S 7" repmat("",1,Nweights-1) "S 9" repmat("",1,Nweights-1) "S 10" repmat("",1,Nweights-1) "S 11" repmat("",1,Nweights-1)], ...
    "Location","northoutside","Box","off", "Orientation","horizontal");
lg.NumColumns = 2;
hold off

ax3 = nexttile;
hold on
plot(-5:25,-5:25,"LineWidth",0.5,"Color",[0.9 0.9 0.9])
for i = 1:NSUBJ
    scatter(KneeMax1kgRedExpPerSUBJ(i), KneeMax1kgRedPerPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorPer(:,1), "MarkerEdgeColor", "none")
    scatter(KneeMax2kgRedExpPerSUBJ(i), KneeMax2kgRedPerPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorPer(:,2), "MarkerEdgeColor", "none")
    scatter(KneeMax3kgRedExpPerSUBJ(i), KneeMax3kgRedPerPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorPer(:,3), "MarkerEdgeColor", "none")
    scatter(KneeMax4kgRedExpPerSUBJ(i), KneeMax4kgRedPerPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorPer(:,4), "MarkerEdgeColor", "none")
    scatter(KneeMax5kgRedExpPerSUBJ(i), KneeMax5kgRedPerPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorPer(:,5), "MarkerEdgeColor", "none")
end
xlim([-5 25])
ylim([-5 25])
c2 = colorbar(ax3, "northoutside");
c2.TickLabels = ["1 kg", "2 kg", "3 kg", "4 kg", "5 kg"];
c2.Ticks = 1:5;
colormap(ax3, colorPer')
clim([1 5]);
c2.Position = [0.3354, 0.9008, 0.1587, 0.0302] - ([0.3678 0.8912 0.1323 0.0288] - [0.3354, 0.9008, 0.1587, 0.0302]);
c2.Ruler.TickLabelRotation = 0;
xlabel("Experimental Reduction [%]", "FontWeight", "bold")
ylabel("Predicted Reduction [%]", "FontWeight", "bold")
hold off

nexttile
hold on
plot(-10:11,-10:11,"LineWidth",0.5,"Color",[0.9 0.9 0.9])
for i = 1:NSUBJ
    scatter(HipFlexMax1kgRedExpPerSUBJ(i), HipFlexMax1kgRedPerPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorPer(:,1), "MarkerEdgeColor", "none")
    scatter(HipFlexMax2kgRedExpPerSUBJ(i), HipFlexMax2kgRedPerPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorPer(:,2), "MarkerEdgeColor", "none")
    scatter(HipFlexMax3kgRedExpPerSUBJ(i), HipFlexMax3kgRedPerPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorPer(:,3), "MarkerEdgeColor", "none")
    scatter(HipFlexMax4kgRedExpPerSUBJ(i), HipFlexMax4kgRedPerPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorPer(:,4), "MarkerEdgeColor", "none")
    scatter(HipFlexMax5kgRedExpPerSUBJ(i), HipFlexMax5kgRedPerPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorPer(:,5), "MarkerEdgeColor", "none")
end
xlim([-10 11])
ylim([-10 11])
xlabel("Experimental Reduction [%]", "FontWeight", "bold")
ylabel("")
hold off

nexttile
hold on
plot(-25:35,-25:35,"LineWidth",0.5,"Color",[0.9 0.9 0.9])
for i = 1:NSUBJ
    scatter(HipExtMax1kgRedExpPerSUBJ(i), HipExtMax1kgRedPerPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorPer(:,1), "MarkerEdgeColor", "none")
    scatter(HipExtMax2kgRedExpPerSUBJ(i), HipExtMax2kgRedPerPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorPer(:,2), "MarkerEdgeColor", "none")
    scatter(HipExtMax3kgRedExpPerSUBJ(i), HipExtMax3kgRedPerPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorPer(:,3), "MarkerEdgeColor", "none")
    scatter(HipExtMax4kgRedExpPerSUBJ(i), HipExtMax4kgRedPerPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorPer(:,4), "MarkerEdgeColor", "none")
    scatter(HipExtMax5kgRedExpPerSUBJ(i), HipExtMax5kgRedPerPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorPer(:,5), "MarkerEdgeColor", "none")
end
xlim([-25 35])
ylim([-25 35])
xlabel("Experimental Reduction [%]", "FontWeight", "bold")
ylabel("")
hold off

nexttile
hold on
plot(-200:100,-200:100,"LineWidth",0.5,"Color",[0.9 0.9 0.9])
for i = 1:NSUBJ
    scatter(AnkleMax1kgRedExpPerSUBJ(i), AnkleMax1kgRedPerPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorPer(:,1), "MarkerEdgeColor", "none")
    scatter(AnkleMax2kgRedExpPerSUBJ(i), AnkleMax2kgRedPerPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorPer(:,2), "MarkerEdgeColor", "none")
    scatter(AnkleMax3kgRedExpPerSUBJ(i), AnkleMax3kgRedPerPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorPer(:,3), "MarkerEdgeColor", "none")
    scatter(AnkleMax4kgRedExpPerSUBJ(i), AnkleMax4kgRedPerPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorPer(:,4), "MarkerEdgeColor", "none")
    scatter(AnkleMax5kgRedExpPerSUBJ(i), AnkleMax5kgRedPerPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorPer(:,5), "MarkerEdgeColor", "none")
end
xlim([-200 100])
ylim([-200 100])
xlabel("Experimental Reduction [%]", "FontWeight", "bold")
ylabel("")
hold off

% figure settings
set(findall(fig,'-property','FontSize'),'FontSize',8)                       % font size
set(0,"DefaultFigureColor","w")                                             % white background
set(0,"defaulttextinterpreter","tex")                                       % tex style font
set(0,"DefaultAxesFontName","SansSerif")                                    % times new roman font


if(export)
    figName = "figures/WeightedPeakReduction_perSUBJ" + ".pdf";
    exportgraphics(fig,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
end
 
%% Plot Experimental vs. Simulation Changes (D'Hondt 2024 3 seg)
colorDhondt2024 = makeGroupColors(180/360,Nweights+1,1,0.5,1)';

fig = figure;
set(gcf,"Units","centimeters")                                              % cm units for position
set(gcf,"Position",[0 0 fig_width*2 fig_height*1.5])                        % IEEE 1-column: 8.89cm
t = tiledlayout(2,4, "TileSpacing", "tight");
t.InnerPosition = [0.05 0.07 0.93 0.78];

ax1 = nexttile;
hold on
plot(-7:25,-7:25,"LineWidth",0.5,"Color",[0.9 0.9 0.9])
for i = 1:NSUBJ
    scatter(KneeMax1kgRedExpPerSUBJ(i), KneeMax1kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,1), "MarkerEdgeColor", "none")
    scatter(KneeMax2kgRedExpPerSUBJ(i), KneeMax2kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,2), "MarkerEdgeColor", "none")
    scatter(KneeMax3kgRedExpPerSUBJ(i), KneeMax3kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,3), "MarkerEdgeColor", "none")
    scatter(KneeMax4kgRedExpPerSUBJ(i), KneeMax4kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,4), "MarkerEdgeColor", "none")
    scatter(KneeMax5kgRedExpPerSUBJ(i), KneeMax5kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,5), "MarkerEdgeColor", "none")
end
xlim([-7 25])
ylim([-7 25])
cmap = colormap(ax1, colorGen');
c1 = colorbar(ax1, "northoutside");
c1.TickLabels = ["1 kg", "2 kg", "3 kg", "4 kg", "5 kg"];
c1.Ticks = 1:5;
clim([1 5]);
xlabel("")
ylabel("Predicted Reduction [%]", "FontWeight", "bold")
title("Peak Knee Flexion", "FontWeight", "bold")
hold off

ax2 = nexttile;
hold on
plot(-10:11,-10:11,"LineWidth",0.5,"Color",[0.9 0.9 0.9])
for i = 1:NSUBJ
    scatter(HipFlexMax1kgRedExpPerSUBJ(i), HipFlexMax1kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,1), "MarkerEdgeColor", "none")
    scatter(HipFlexMax2kgRedExpPerSUBJ(i), HipFlexMax2kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,2), "MarkerEdgeColor", "none")
    scatter(HipFlexMax3kgRedExpPerSUBJ(i), HipFlexMax3kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,3), "MarkerEdgeColor", "none")
    scatter(HipFlexMax4kgRedExpPerSUBJ(i), HipFlexMax4kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,4), "MarkerEdgeColor", "none")
    scatter(HipFlexMax5kgRedExpPerSUBJ(i), HipFlexMax5kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,5), "MarkerEdgeColor", "none")
end
xlim([-10 11])
ylim([-10 11])
xlabel("")
ylabel("")
title("Peak Hip Flexion", "FontWeight", "bold")
hold off

nexttile
hold on
plot(-25:35,-25:35,"LineWidth",0.5,"Color",[0.9 0.9 0.9])
for i = 1:NSUBJ
    scatter(HipExtMax1kgRedExpPerSUBJ(i), HipExtMax1kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,1), "MarkerEdgeColor", "none")
    scatter(HipExtMax2kgRedExpPerSUBJ(i), HipExtMax2kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,2), "MarkerEdgeColor", "none")
    scatter(HipExtMax3kgRedExpPerSUBJ(i), HipExtMax3kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,3), "MarkerEdgeColor", "none")
    scatter(HipExtMax4kgRedExpPerSUBJ(i), HipExtMax4kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,4), "MarkerEdgeColor", "none")
    scatter(HipExtMax5kgRedExpPerSUBJ(i), HipExtMax5kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,5), "MarkerEdgeColor", "none")
end
xlim([-25 35])
ylim([-25 35])
xlabel("")
ylabel("")
title("Peak Hip Extension", "FontWeight", "bold")
hold off

nexttile
hold on
plot(-200:100,-200:100,"LineWidth",0.5,"Color",[0.9 0.9 0.9])
for i = 1:NSUBJ
    scatter(AnkleMax1kgRedExpPerSUBJ(i), AnkleMax1kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,1), "MarkerEdgeColor", "none")
    scatter(AnkleMax2kgRedExpPerSUBJ(i), AnkleMax2kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,2), "MarkerEdgeColor", "none")
    scatter(AnkleMax3kgRedExpPerSUBJ(i), AnkleMax3kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,3), "MarkerEdgeColor", "none")
    scatter(AnkleMax4kgRedExpPerSUBJ(i), AnkleMax4kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,4), "MarkerEdgeColor", "none")
    scatter(AnkleMax5kgRedExpPerSUBJ(i), AnkleMax5kgRedGenPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorGen(:,5), "MarkerEdgeColor", "none")
end
xlim([-200 100])
ylim([-200 100])
xlabel("")
ylabel("")
title("Peak Ankle Plantar Flexion", "FontWeight", "bold")
lg = legend(["" "S 4" repmat("",1,Nweights-1) "S 6" repmat("",1,Nweights-1) "S 7" repmat("",1,Nweights-1) "S 9" repmat("",1,Nweights-1) "S 10" repmat("",1,Nweights-1) "S 11" repmat("",1,Nweights-1)], ...
    "Location","northoutside","Box","off", "Orientation","horizontal");
lg.NumColumns = 2;
hold off

ax3 = nexttile;
hold on
plot(-7:25,-7:25,"LineWidth",0.5,"Color",[0.9 0.9 0.9])
for i = 1:NSUBJ
    scatter(KneeMax1kgRedExpPerSUBJ(i), KneeMax1kgRedDhondtPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorDhondt2024(:,1), "MarkerEdgeColor", "none")
    scatter(KneeMax2kgRedExpPerSUBJ(i), KneeMax2kgRedDhondtPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorDhondt2024(:,2), "MarkerEdgeColor", "none")
    scatter(KneeMax3kgRedExpPerSUBJ(i), KneeMax3kgRedDhondtPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorDhondt2024(:,3), "MarkerEdgeColor", "none")
    scatter(KneeMax4kgRedExpPerSUBJ(i), KneeMax4kgRedDhondtPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorDhondt2024(:,4), "MarkerEdgeColor", "none")
    scatter(KneeMax5kgRedExpPerSUBJ(i), KneeMax5kgRedDhondtPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorDhondt2024(:,5), "MarkerEdgeColor", "none")
end
xlim([-7 25])
ylim([-7 25])
c2 = colorbar(ax3, "northoutside");
c2.TickLabels = ["1 kg", "2 kg", "3 kg", "4 kg", "5 kg"];
c2.Ticks = 1:5;
colormap(ax3, colorDhondt2024')
clim([1 5]);
c2.Position = [0.3354, 0.9008, 0.1587, 0.0302] - ([0.3678 0.8912 0.1323 0.0288] - [0.3354, 0.9008, 0.1587, 0.0302]);
c2.Ruler.TickLabelRotation = 0;
xlabel("Experimental Reduction [%]", "FontWeight", "bold")
ylabel("Predicted Reduction [%]", "FontWeight", "bold")
hold off

nexttile
hold on
plot(-10:11,-10:11,"LineWidth",0.5,"Color",[0.9 0.9 0.9])
for i = 1:NSUBJ
    scatter(HipFlexMax1kgRedExpPerSUBJ(i), HipFlexMax1kgRedDhondtPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorDhondt2024(:,1), "MarkerEdgeColor", "none")
    scatter(HipFlexMax2kgRedExpPerSUBJ(i), HipFlexMax2kgRedDhondtPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorDhondt2024(:,2), "MarkerEdgeColor", "none")
    scatter(HipFlexMax3kgRedExpPerSUBJ(i), HipFlexMax3kgRedDhondtPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorDhondt2024(:,3), "MarkerEdgeColor", "none")
    scatter(HipFlexMax4kgRedExpPerSUBJ(i), HipFlexMax4kgRedDhondtPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorDhondt2024(:,4), "MarkerEdgeColor", "none")
    scatter(HipFlexMax5kgRedExpPerSUBJ(i), HipFlexMax5kgRedDhondtPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorDhondt2024(:,5), "MarkerEdgeColor", "none")
end
xlim([-10 11])
ylim([-10 11])
xlabel("Experimental Reduction [%]", "FontWeight", "bold")
ylabel("")
hold off

nexttile
hold on
plot(-25:35,-25:35,"LineWidth",0.5,"Color",[0.9 0.9 0.9])
for i = 1:NSUBJ
    scatter(HipExtMax1kgRedExpPerSUBJ(i), HipExtMax1kgRedDhondtPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorDhondt2024(:,1), "MarkerEdgeColor", "none")
    scatter(HipExtMax2kgRedExpPerSUBJ(i), HipExtMax2kgRedDhondtPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorDhondt2024(:,2), "MarkerEdgeColor", "none")
    scatter(HipExtMax3kgRedExpPerSUBJ(i), HipExtMax3kgRedDhondtPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorDhondt2024(:,3), "MarkerEdgeColor", "none")
    scatter(HipExtMax4kgRedExpPerSUBJ(i), HipExtMax4kgRedDhondtPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorDhondt2024(:,4), "MarkerEdgeColor", "none")
    scatter(HipExtMax5kgRedExpPerSUBJ(i), HipExtMax5kgRedDhondtPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorDhondt2024(:,5), "MarkerEdgeColor", "none")
end
xlim([-25 35])
ylim([-25 35])
xlabel("Experimental Reduction [%]", "FontWeight", "bold")
ylabel("")
hold off

nexttile
hold on
plot(-200:100,-200:100,"LineWidth",0.5,"Color",[0.9 0.9 0.9])
for i = 1:NSUBJ
    scatter(AnkleMax1kgRedExpPerSUBJ(i), AnkleMax1kgRedDhondtPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorDhondt2024(:,1), "MarkerEdgeColor", "none")
    scatter(AnkleMax2kgRedExpPerSUBJ(i), AnkleMax2kgRedDhondtPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorDhondt2024(:,2), "MarkerEdgeColor", "none")
    scatter(AnkleMax3kgRedExpPerSUBJ(i), AnkleMax3kgRedDhondtPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorDhondt2024(:,3), "MarkerEdgeColor", "none")
    scatter(AnkleMax4kgRedExpPerSUBJ(i), AnkleMax4kgRedDhondtPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorDhondt2024(:,4), "MarkerEdgeColor", "none")
    scatter(AnkleMax5kgRedExpPerSUBJ(i), AnkleMax5kgRedDhondtPerSUBJ(i), "Marker", markers(i), "MarkerFaceColor", colorDhondt2024(:,5), "MarkerEdgeColor", "none")
end
xlim([-200 100])
ylim([-200 100])
xlabel("Experimental Reduction [%]", "FontWeight", "bold")
ylabel("")
hold off

% figure settings
set(findall(fig,'-property','FontSize'),'FontSize',8)                       % font size
set(0,"DefaultFigureColor","w")                                             % white background
set(0,"defaulttextinterpreter","tex")                                       % tex style font
set(0,"DefaultAxesFontName","SansSerif")                                    % times new roman font


if(export)
    figName = "figures/WeightedPeakReduction_perSUBJ_dhondt2024_3seg" + ".pdf";
    exportgraphics(fig,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
end

%% Functions
function [normalWalkingExpAvgLim, normalWalkingExpStdLim, weightedWalkingExpAvgLim, weightedWalkingExpStdLim] = extract_experimental_data(expData, dataDelim, dataPrefix, SUBJID, Ndata, Nweights, dataBool)
    col_exp = expData.data.headers.(dataDelim);
    Ncolexp = length(col_exp);
    NSUBJ = length(SUBJID);
    
    normalWalkingExpAvg = NaN(Ndata, Ncolexp, NSUBJ);
    normalWalkingExpStd = NaN(Ndata, Ncolexp, NSUBJ);
    weightedWalkingExpAvg = NaN(Ndata, Ncolexp, NSUBJ, Nweights);
    weightedWalkingExpStd = NaN(Ndata, Ncolexp, NSUBJ, Nweights);
    
    for i = 1:NSUBJ
        normalWalkingExpAvg(:,:,i) = mean(expData.data.("SUBJ"+ SUBJID(i)).(dataDelim).(dataPrefix+"dataNormal"),3,"omitnan");
        weightedWalkingExpAvg(:,:,i,1) = mean(expData.data.("SUBJ" + SUBJID(i)).(dataDelim).(dataPrefix+"dataWeighted1kg"),3,"omitnan");
        weightedWalkingExpAvg(:,:,i,2) = mean(expData.data.("SUBJ" + SUBJID(i)).(dataDelim).(dataPrefix+"dataWeighted2kg"),3,"omitnan");
        weightedWalkingExpAvg(:,:,i,3) = mean(expData.data.("SUBJ" + SUBJID(i)).(dataDelim).(dataPrefix+"dataWeighted3kg"),3,"omitnan");
        weightedWalkingExpAvg(:,:,i,4) = mean(expData.data.("SUBJ" + SUBJID(i)).(dataDelim).(dataPrefix+"dataWeighted4kg"),3,"omitnan");
        weightedWalkingExpAvg(:,:,i,5) = mean(expData.data.("SUBJ" + SUBJID(i)).(dataDelim).(dataPrefix+"dataWeighted5kg"),3,"omitnan");
    
        normalWalkingExpStd(:,:,i) = std(expData.data.("SUBJ"+ SUBJID(i)).(dataDelim).(dataPrefix+"dataNormal"),0,3,"omitnan");
        weightedWalkingExpStd(:,:,i,1) = std(expData.data.("SUBJ" + SUBJID(i)).(dataDelim).(dataPrefix+"dataWeighted1kg"),0,3,"omitnan");
        weightedWalkingExpStd(:,:,i,2) = std(expData.data.("SUBJ" + SUBJID(i)).(dataDelim).(dataPrefix+"dataWeighted2kg"),0,3,"omitnan");
        weightedWalkingExpStd(:,:,i,3) = std(expData.data.("SUBJ" + SUBJID(i)).(dataDelim).(dataPrefix+"dataWeighted3kg"),0,3,"omitnan");
        weightedWalkingExpStd(:,:,i,4) = std(expData.data.("SUBJ" + SUBJID(i)).(dataDelim).(dataPrefix+"dataWeighted4kg"),0,3,"omitnan");
        weightedWalkingExpStd(:,:,i,5) = std(expData.data.("SUBJ" + SUBJID(i)).(dataDelim).(dataPrefix+"dataWeighted5kg"),0,3,"omitnan");
    end

    % find corresponding columns
    normalWalkingExpAvgLim = normalWalkingExpAvg(:,dataBool,:,:);
    normalWalkingExpStdLim = normalWalkingExpStd(:,dataBool,:,:);
    weightedWalkingExpAvgLim = weightedWalkingExpAvg(:,dataBool,:,:);
    weightedWalkingExpStdLim = weightedWalkingExpStd(:,dataBool,:,:);
end


function WalkingKneeMaxAvg = compute_peak_exp(expData, SUBJID, isJoint, weight, Ntrials, sign, IdxRange)
% returns peak knee flexion angle, averaged over left/right

    if(isempty(IdxRange))
        IdxRange = 1:size(expData.data.("SUBJ" + SUBJID).kinematics.IkdataNormal,1);
    end

    WalkingKneeMaxAvg = NaN(1,Ntrials);
    if(weight == "Normal")
        % normal walking peak knee flexion
        WalkingKin = expData.data.("SUBJ" + SUBJID).kinematics.IkdataNormal;
    else
        % weighted walking peak knee flexion
        WalkingKin = expData.data.("SUBJ" + SUBJID).kinematics.("IkdataWeighted" + weight);
    end

    WalkingKneeKin = WalkingKin(IdxRange,isJoint,:)*sign;
    [WalkingKneeMaxLR, ~] = max(WalkingKneeKin);
    NtrialsSUBJ = size(WalkingKneeMaxLR,3);
    WalkingKneeMaxAvg(1:NtrialsSUBJ) = mean(WalkingKneeMaxLR,2);
    WalkingKneeMaxAvg = WalkingKneeMaxAvg(1:Ntrials);


end

function WalkingKneeMax = compute_peak_sim(KinData, isKneeFlexion, subjID, sign, IdxRange)
% returns peak knee flexion angle, averaged over left/right

    Nworkers = size(KinData,4);
    WalkingKneeMax = NaN(1,Nworkers);

    if(isempty(IdxRange))
        IdxRange = 1:size(KinData,1);
    end

    for i = 1:Nworkers
        if(~isnan(KinData(:,:,subjID,i)))
            WalkingKneeKin = KinData(IdxRange,isKneeFlexion,subjID,i);
            [WalkingKneeMaxLR,~] = max(WalkingKneeKin*sign);
            WalkingKneeMax(i) = mean(WalkingKneeMaxLR);
        end
    end

end

function WalkingKneeRed = compute_red(normalData, weightedData)

    WalkingKneeRed = (normalData-weightedData)./normalData*100;

end


function [KinData, GrfData, KitData, EmgData, IdxHeelL] = choose_lowest_cost(...
    KinDataTrackIG, GrfDataTrackIG, KitDataTrackIG, EmgDataTrackIG, IdxHeelLTrackIG, CostDataTrackIG,...
    KinDataExpIG, GrfDataExpIG, KitDataExpIG, EmgDataExpIG, IdxHeelLExpIG, CostDataExpIG)

% Choose solution with lowest cost function value
    isExpIGlower = CostDataExpIG < CostDataTrackIG;
    
    KinData = KinDataTrackIG;
    GrfData = GrfDataTrackIG;
    KitData = KitDataTrackIG;
    EmgData = EmgDataTrackIG;
    IdxHeelL = IdxHeelLTrackIG;

    NSUBJ = size(KinData,3);
    Ncol = size(KinData,4);
    
    for i = 1:NSUBJ
        for j = 1:Ncol
            if(isExpIGlower(i,j))
                KinData(:,:,i,j) = KinDataExpIG(:,:,i,j);
                GrfData(:,:,i,j) = GrfDataExpIG(:,:,i,j);
                KitData(:,:,i,j) = KitDataExpIG(:,:,i,j);
                EmgData(:,:,i,j) = EmgDataExpIG(:,:,i,j);
                IdxHeelL(i,j) = IdxHeelLExpIG(i,j);
            end
        end
    end
end

function [GenericDataWeightedShifted, PersonalDataWeightedShifted, Dhondt2024_3segDataWeightedShifted] = shift_sim_data(conditionBool, GenericDataWeighted, PersonalDataWeighted, Dhondt2024_3segDataWeighted, GenericIdxHeelLWeighted, PersonalIdxHeelLWeighted, Dhondt2024_3segIdxHeelLWeighted)
% experimental data starts at left heel strike for left side data
    
    GenericDataWeightedShifted = GenericDataWeighted;
    PersonalDataWeightedShifted = PersonalDataWeighted;
    Dhondt2024_3segDataWeightedShifted = Dhondt2024_3segDataWeighted;
    
    NSUBJ = size(GenericDataWeightedShifted,3);
    Nweights = size(GenericDataWeightedShifted,4);

    for i = 1:NSUBJ
        for j = 1:Nweights
            GenericDataWeightedShifted(:,conditionBool,i,j) = circshift(GenericDataWeighted(:,conditionBool,i,j),-GenericIdxHeelLWeighted(i,j),1);
            PersonalDataWeightedShifted(:,conditionBool,i,j) = circshift(PersonalDataWeighted(:,conditionBool,i,j),-PersonalIdxHeelLWeighted(i,j),1);
            Dhondt2024_3segDataWeightedShifted(:,conditionBool,i,j) = circshift(Dhondt2024_3segDataWeighted(:,conditionBool,i,j),-Dhondt2024_3segIdxHeelLWeighted(i,j),1);
        end
    end
end

function RMSEPerSUBJ = compute_RMSE_per_subj(NSUBJ, Nweights, Max1kgRedExpPerSUBJ, Max2kgRedExpPerSUBJ, Max3kgRedExpPerSUBJ, Max4kgRedExpPerSUBJ, Max5kgRedExpPerSUBJ, Max1kgRedSimPerSUBJ, Max2kgRedSimPerSUBJ, Max3kgRedSimPerSUBJ, Max4kgRedSimPerSUBJ, Max5kgRedSimPerSUBJ)

RMSEPerSUBJ = NaN(NSUBJ, Nweights);

for i = 1:NSUBJ
    RMSEPerSUBJ(i,1) = rmse(Max1kgRedExpPerSUBJ(i), Max1kgRedSimPerSUBJ(i));
    RMSEPerSUBJ(i,2) = rmse(Max2kgRedExpPerSUBJ(i), Max2kgRedSimPerSUBJ(i));
    RMSEPerSUBJ(i,3) = rmse(Max3kgRedExpPerSUBJ(i), Max3kgRedSimPerSUBJ(i));
    RMSEPerSUBJ(i,4) = rmse(Max4kgRedExpPerSUBJ(i), Max4kgRedSimPerSUBJ(i));
    RMSEPerSUBJ(i,5) = rmse(Max5kgRedExpPerSUBJ(i), Max5kgRedSimPerSUBJ(i));
end

end
