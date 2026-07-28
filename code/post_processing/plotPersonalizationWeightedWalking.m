% --------------------------------------------------------------------------
% plotPersonalizationWeightedWalking
%   Process the results of the weighted walking simulations and create all
%   the related plots from the manuscript.
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
[Dhondt2024_3segKinData, Dhondt2024_3segGrfData, Dhondt2024_3segKitData, Dhondt2024_3segEmgData, ~, ~, ~, Dhondt2024_3segIdxHeelL,Dhondt2024_3segkinColHeaders,~,Dhondt2024_3segemgColHeaders] = average_results(resampTime, 29, Ngrfcol, 92, resultsDIR, ResultsFolders, dhondt2024_3segSubFolders, dhondt2024_3segKeyWords, 1);
Dhondt2024_3seg_isLimKin = ismember(Dhondt2024_3segkinColHeaders, kinColHeaders);

Dhondt2024_3segKinDataLim = Dhondt2024_3segKinData(:,Dhondt2024_3seg_isLimKin>0,:);
Dhondt2024_3segGrfDataLim = Dhondt2024_3segGrfData(:,:,:);
Dhondt2024_3segKitDataLim = Dhondt2024_3segKitData(:,Dhondt2024_3seg_isLimKin>0,:);

%% Assign EMG Columns
[isLimEMG,isLimEMGexp]=ismember(EMGColHeaders,emg_col_exp);
EMGColHeadersLim = EMGColHeaders(isLimEMG>0);                               % simulation data only for muscle with experimental data
PersonalEmgDataLim = PersonalEmgData(:,isLimEMG>0,:);
GenericEmgDataLim = GenericEmgData(:,isLimEMG>0,:);

%% Extract Subject-Specific EMG Data
Nemgcolexp = length(emg_col_exp);
normalWalkingEMGexp = NaN(Ndata, Nemgcolexp, NSUBJ);
weightedWalkingEMGexp = NaN(Ndata, Nemgcolexp, NSUBJ, Nweights);

for subjID = 1:NSUBJ
    % select subject-specific data
    subjEMGdata = expData.data.("SUBJ" + SUBJID(subjID)).EMG.EMGdataNormal;
    subjEMGdata1kg = expData.data.("SUBJ" + SUBJID(subjID)).EMG.EMGdataWeighted1kg;
    subjEMGdata2kg = expData.data.("SUBJ" + SUBJID(subjID)).EMG.EMGdataWeighted2kg;
    subjEMGdata3kg = expData.data.("SUBJ" + SUBJID(subjID)).EMG.EMGdataWeighted3kg;
    subjEMGdata4kg = expData.data.("SUBJ" + SUBJID(subjID)).EMG.EMGdataWeighted4kg;
    subjEMGdata5kg = expData.data.("SUBJ" + SUBJID(subjID)).EMG.EMGdataWeighted5kg;

    normalWalkingEMGexp(:,:,subjID) = mean(subjEMGdata,3,"omitnan");
    weightedWalkingEMGexp(:,:,subjID,1) = mean(subjEMGdata1kg,3,"omitnan");
    weightedWalkingEMGexp(:,:,subjID,2) = mean(subjEMGdata2kg,3,"omitnan");
    weightedWalkingEMGexp(:,:,subjID,3) = mean(subjEMGdata3kg,3,"omitnan");
    weightedWalkingEMGexp(:,:,subjID,4) = mean(subjEMGdata4kg,3,"omitnan");
    weightedWalkingEMGexp(:,:,subjID,5) = mean(subjEMGdata5kg,3,"omitnan");
end

% select columns corresponding to simulation muscles
NemgcolLim = length(EMGColHeadersLim);
normalWalkingEMGexpLim = normalWalkingEMGexp(:,isLimEMGexp(isLimEMGexp>0),:);
weightedWalkingEMGexpLim = weightedWalkingEMGexp(:,isLimEMGexp(isLimEMGexp>0),:,:);

% extract average EMG data
normalWalkingEMGavgLim = mean(normalWalkingEMGexpLim,3,"omitnan");
normalWalkingEMGstdLim = std(normalWalkingEMGexpLim,0,3,"omitnan");
weightedWalkingEMGavgLim = mean(weightedWalkingEMGexpLim,3,"omitnan");
weightedWalkingEMGstdLim = std(weightedWalkingEMGexpLim,0,3,"omitnan");

%% Assign Dhondt2024 3seg EMG Columns
emg_col_dhondt2024 = ["semiten_r", "bifemsh_r", "rect_fem_r", "vas_lat_r", "med_gas_r", "soleus_r","semiten_l", "bifemsh_l", "rect_fem_l", "vas_lat_l", "med_gas_l", "soleus_l"];
[Dhondt2024_3seg_isLimEmg, Dhondt2024_3seg_isLimEmgIdxs] = ismember(Dhondt2024_3segemgColHeaders, emg_col_dhondt2024);
Dhondt2024_3segEmgDataLim = Dhondt2024_3segEmgData(:,Dhondt2024_3seg_isLimEmg>0,:);

%% Average Results
GenericKinDataAvg = mean(GenericKinData,3,"omitnan");
GenericKinDataSTD = std(GenericKinData,0,3,"omitnan");
GenericGRFDataAvg = mean(GenericGrfData,3,"omitnan");
GenericGRFDataSTD = std(GenericGrfData,0,3,"omitnan");
GenericKitDataAvg = mean(GenericKitData,3,"omitnan");
GenericKitDataSTD = std(GenericKitData,0,3,"omitnan");
GenericEmgDataAvg = mean(GenericEmgDataLim,3,"omitnan");
GenericEmgDataSTD = std(GenericEmgDataLim,0,3,"omitnan");

PersonalKinDataAvg = mean(PersonalKinData,3,"omitnan");
PersonalKinDataSTD = std(PersonalKinData,0,3,"omitnan");
PersonalGRFDataAvg = mean(PersonalGrfData,3,"omitnan");
PersonalGRFDataSTD = std(PersonalGrfData,0,3,"omitnan");
PersonalKitDataAvg = mean(PersonalKitData,3,"omitnan");
PersonalKitDataSTD = std(PersonalKitData,0,3,"omitnan");
PersonalEmgDataAvg = mean(PersonalEmgDataLim,3,"omitnan");
PersonalEmgDataSTD = std(PersonalEmgDataLim,0,3,"omitnan");

Dhondt2024_3segKinDataAvg = mean(Dhondt2024_3segKinDataLim,3,"omitnan");
Dhondt2024_3segKinDataSTD = std(Dhondt2024_3segKinDataLim,0,3,"omitnan");
Dhondt2024_3segGRFDataAvg = mean(Dhondt2024_3segGrfDataLim,3,"omitnan");
Dhondt2024_3segGRFDataSTD = std(Dhondt2024_3segGrfDataLim,0,3,"omitnan");
Dhondt2024_3segKitDataAvg = mean(Dhondt2024_3segKitDataLim,3,"omitnan");
Dhondt2024_3segKitDataSTD = std(Dhondt2024_3segKitDataLim,0,3,"omitnan");
Dhondt2024_3segEmgDataAvg = mean(Dhondt2024_3segEmgDataLim,3,"omitnan");
Dhondt2024_3segEmgDataSTD = std(Dhondt2024_3segEmgDataLim,0,3,"omitnan");

%% Save Experimental Weighted Results
isKneeFlexion = contains(expData.data.headers.kinematics,"knee_angle") & ~contains(expData.data.headers.kinematics,"beta");

% store data for each subject
normalWalkingKneeMaxExp = NaN(NSUBJ, Ntrials);
WeightedWalking1kgKneeMaxExp = NaN(NSUBJ, Ntrials);
WeightedWalking2kgKneeMaxExp = NaN(NSUBJ, Ntrials);
WeightedWalking3kgKneeMaxExp = NaN(NSUBJ, Ntrials);
WeightedWalking4kgKneeMaxExp = NaN(NSUBJ, Ntrials);
WeightedWalking5kgKneeMaxExp = NaN(NSUBJ, Ntrials);

for subjID = 1:NSUBJ
    normalWalkingKneeMaxExp(subjID,:) = compute_peak_knee_flex_exp(expData, SUBJID(subjID), isKneeFlexion, "Normal", Ntrials, -1);
    WeightedWalking1kgKneeMaxExp(subjID,:) = compute_peak_knee_flex_exp(expData, SUBJID(subjID), isKneeFlexion, "1kg", Ntrials, -1);
    WeightedWalking2kgKneeMaxExp(subjID,:) = compute_peak_knee_flex_exp(expData, SUBJID(subjID), isKneeFlexion, "2kg", Ntrials, -1);
    WeightedWalking3kgKneeMaxExp(subjID,:) = compute_peak_knee_flex_exp(expData, SUBJID(subjID), isKneeFlexion, "3kg", Ntrials, -1);
    WeightedWalking4kgKneeMaxExp(subjID,:) = compute_peak_knee_flex_exp(expData, SUBJID(subjID), isKneeFlexion, "4kg", Ntrials, -1);
    WeightedWalking5kgKneeMaxExp(subjID,:) = compute_peak_knee_flex_exp(expData, SUBJID(subjID), isKneeFlexion, "5kg", Ntrials, -1);
end

% compute average per subject
normalWalkingKneeMaxExpPerSUBJ = mean(normalWalkingKneeMaxExp,2,"omitnan");
WeightedWalking1kgKneeMaxExpPerSUBJ = mean(WeightedWalking1kgKneeMaxExp,2,"omitnan");
WeightedWalking2kgKneeMaxExpPerSUBJ = mean(WeightedWalking2kgKneeMaxExp,2,"omitnan");
WeightedWalking3kgKneeMaxExpPerSUBJ = mean(WeightedWalking3kgKneeMaxExp,2,"omitnan");
WeightedWalking4kgKneeMaxExpPerSUBJ = mean(WeightedWalking4kgKneeMaxExp,2,"omitnan");
WeightedWalking5kgKneeMaxExpPerSUBJ = mean(WeightedWalking5kgKneeMaxExp,2,"omitnan");

% compute average over all subjects
normalWalkingKneeMaxExpAvg = mean(normalWalkingKneeMaxExpPerSUBJ,"all");
WeightedWalking1kgKneeMaxExpAvg = mean(WeightedWalking1kgKneeMaxExpPerSUBJ,"all");
WeightedWalking2kgKneeMaxExpAvg = mean(WeightedWalking2kgKneeMaxExpPerSUBJ,"all");
WeightedWalking3kgKneeMaxExpAvg = mean(WeightedWalking3kgKneeMaxExpPerSUBJ,"all");
WeightedWalking4kgKneeMaxExpAvg = mean(WeightedWalking4kgKneeMaxExpPerSUBJ,"all");
WeightedWalking5kgKneeMaxExpAvg = mean(WeightedWalking5kgKneeMaxExpPerSUBJ,"all");

% compute STD over all subjects
normalWalkingKneeMaxExpStd = std(normalWalkingKneeMaxExpPerSUBJ,0,"all");
WeightedWalking1kgKneeMaxExpStd = std(WeightedWalking1kgKneeMaxExpPerSUBJ,0,"all");
WeightedWalking2kgKneeMaxExpStd = std(WeightedWalking2kgKneeMaxExpPerSUBJ,0,"all");
WeightedWalking3kgKneeMaxExpStd = std(WeightedWalking3kgKneeMaxExpPerSUBJ,0,"all");
WeightedWalking4kgKneeMaxExpStd = std(WeightedWalking4kgKneeMaxExpPerSUBJ,0,"all");
WeightedWalking5kgKneeMaxExpStd = std(WeightedWalking5kgKneeMaxExpPerSUBJ,0,"all");

% compute knee flexion reduction
WeightedWalking1kgKneeRedExpAvg = mean(compute_peek_knee_flex_red(normalWalkingKneeMaxExpPerSUBJ, WeightedWalking1kgKneeMaxExpPerSUBJ),"all","omitnan");
WeightedWalking2kgKneeRedExpAvg = mean(compute_peek_knee_flex_red(normalWalkingKneeMaxExpPerSUBJ, WeightedWalking2kgKneeMaxExpPerSUBJ),"all","omitnan");
WeightedWalking3kgKneeRedExpAvg = mean(compute_peek_knee_flex_red(normalWalkingKneeMaxExpPerSUBJ, WeightedWalking3kgKneeMaxExpPerSUBJ),"all","omitnan");
WeightedWalking4kgKneeRedExpAvg = mean(compute_peek_knee_flex_red(normalWalkingKneeMaxExpPerSUBJ, WeightedWalking4kgKneeMaxExpPerSUBJ),"all","omitnan");
WeightedWalking5kgKneeRedExpAvg = mean(compute_peek_knee_flex_red(normalWalkingKneeMaxExpPerSUBJ, WeightedWalking5kgKneeMaxExpPerSUBJ),"all","omitnan");

WeightedWalking1kgKneeRedExpStd = std(compute_peek_knee_flex_red(normalWalkingKneeMaxExpPerSUBJ, WeightedWalking1kgKneeMaxExpPerSUBJ),0,"all","omitnan");
WeightedWalking2kgKneeRedExpStd = std(compute_peek_knee_flex_red(normalWalkingKneeMaxExpPerSUBJ, WeightedWalking2kgKneeMaxExpPerSUBJ),0,"all","omitnan");
WeightedWalking3kgKneeRedExpStd = std(compute_peek_knee_flex_red(normalWalkingKneeMaxExpPerSUBJ, WeightedWalking3kgKneeMaxExpPerSUBJ),0,"all","omitnan");
WeightedWalking4kgKneeRedExpStd = std(compute_peek_knee_flex_red(normalWalkingKneeMaxExpPerSUBJ, WeightedWalking4kgKneeMaxExpPerSUBJ),0,"all","omitnan");
WeightedWalking5kgKneeRedExpStd = std(compute_peek_knee_flex_red(normalWalkingKneeMaxExpPerSUBJ, WeightedWalking5kgKneeMaxExpPerSUBJ),0,"all","omitnan");

%% Save Generic Weighted Results
[GenericKinDataWeightedTrackIG, GenericGrfDataWeightedTrackIG, GenericKitDataWeightedTrackIG, GenericEmgDataWeightedTrackIG, ~, ~, GenericCostDataTrackIG, GenericIdxHeelLTrackIG, ~, ~, ~] = average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, resultsDIR, ResultsFolders, trackIGsubFolderGeneric, weightedKeyWords, Nweights);
[GenericKinDataWeightedExpIG, GenericGrfDataWeightedExpIG, GenericKitDataWeightedExpIG, GenericEmgDataWeightedExpIG, ~, ~, GenericCostDataExpIG, GenericIdxHeelLExpIG, ~, ~, ~] = average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, resultsDIR, ResultsFolders, expIGsubFolderGeneric, weightedKeyWords, Nweights);

%% Save Personal Weighted Results
isKneeFlexion = contains(kinColHeaders,"knee_angle");
[PersonalKinDataWeightedTrackIG, PersonalGrfDataWeightedTrackIG, PersonalKitDataWeightedTrackIG, PersonalEmgDataWeightedTrackIG, ~, ~, PersonalCostDataTrackIG, PersonalIdxHeelLTrackIG, ~, ~, ~] = average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, resultsDIR, ResultsFolders, trackIGsubFolderPersonal, weightedKeyWords, Nweights);
[PersonalKinDataWeightedExpIG, PersonalGrfDataWeightedExpIG, PersonalKitDataWeightedExpIG, PersonalEmgDataWeightedExpIG, ~, ~, PersonalCostDataExpIG, PersonalIdxHeelLExpIG, ~, ~, ~] = average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, resultsDIR, ResultsFolders, expIGsubFolderPersonal, weightedKeyWords, Nweights);

%% Choose Lowest Cost Solution
% Generic
[GenericKinDataWeighted, GenericGrfDataWeighted, GenericKitDataWeighted, GenericEmgDataWeighted, GenericIdxHeelLWeighted, GenericCostData] = choose_lowest_cost(...
    GenericKinDataWeightedTrackIG, GenericGrfDataWeightedTrackIG, GenericKitDataWeightedTrackIG, GenericEmgDataWeightedTrackIG, GenericIdxHeelLTrackIG, GenericCostDataTrackIG,...
    GenericKinDataWeightedExpIG, GenericGrfDataWeightedExpIG, GenericKitDataWeightedExpIG, GenericEmgDataWeightedExpIG, GenericIdxHeelLExpIG, GenericCostDataExpIG);

% Personal
[PersonalKinDataWeighted, PersonalGrfDataWeighted, PersonalKitDataWeighted, PersonalEmgDataWeighted, PersonalIdxHeelLWeighted, PersonalCostData] = choose_lowest_cost(...
    PersonalKinDataWeightedTrackIG, PersonalGrfDataWeightedTrackIG, PersonalKitDataWeightedTrackIG, PersonalEmgDataWeightedTrackIG, PersonalIdxHeelLTrackIG, PersonalCostDataTrackIG,...
    PersonalKinDataWeightedExpIG, PersonalGrfDataWeightedExpIG, PersonalKitDataWeightedExpIG, PersonalEmgDataWeightedExpIG, PersonalIdxHeelLExpIG, PersonalCostDataExpIG);

%% Save Generic Weighted Results
normalWalkingKneeMaxGeneric = NaN(NSUBJ, 1);
WeightedWalkingKneeMaxGeneric = NaN(NSUBJ, Nweights);

for subjID = 1:NSUBJ
    normalWalkingKneeMaxGeneric(subjID) = compute_peak_knee_flex_sim(GenericKinData, isKneeFlexion, subjID);
    WeightedWalkingKneeMaxGeneric(subjID,:) = compute_peak_knee_flex_sim(GenericKinDataWeighted, isKneeFlexion, subjID);
end

% compute average over all subjects
normalWalkingKneeMaxGenericAvg = mean(normalWalkingKneeMaxGeneric,"all","omitnan");
WeightedWalking1kgKneeMaxGenericAvg = mean(WeightedWalkingKneeMaxGeneric(:,1),"all","omitnan");
WeightedWalking2kgKneeMaxGenericAvg = mean(WeightedWalkingKneeMaxGeneric(:,2),"all","omitnan");
WeightedWalking3kgKneeMaxGenericAvg = mean(WeightedWalkingKneeMaxGeneric(:,3),"all","omitnan");
WeightedWalking4kgKneeMaxGenericAvg = mean(WeightedWalkingKneeMaxGeneric(:,4),"all","omitnan");
WeightedWalking5kgKneeMaxGenericAvg = mean(WeightedWalkingKneeMaxGeneric(:,5),"all","omitnan");

% compute STD over all subjects
normalWalkingKneeMaxGenericStd = std(normalWalkingKneeMaxGeneric,0,"all","omitnan");
WeightedWalking1kgKneeMaxGenericStd = std(WeightedWalkingKneeMaxGeneric(:,1),0,"all","omitnan");
WeightedWalking2kgKneeMaxGenericStd = std(WeightedWalkingKneeMaxGeneric(:,2),0,"all","omitnan");
WeightedWalking3kgKneeMaxGenericStd = std(WeightedWalkingKneeMaxGeneric(:,3),0,"all","omitnan");
WeightedWalking4kgKneeMaxGenericStd = std(WeightedWalkingKneeMaxGeneric(:,4),0,"all","omitnan");
WeightedWalking5kgKneeMaxGenericStd = std(WeightedWalkingKneeMaxGeneric(:,5),0,"all","omitnan");

% compute knee flexion reduction
WeightedWalking1kgKneeRedGenericAvg = mean(compute_peek_knee_flex_red(normalWalkingKneeMaxGeneric, WeightedWalkingKneeMaxGeneric(:,1)),"all","omitnan");
WeightedWalking2kgKneeRedGenericAvg = mean(compute_peek_knee_flex_red(normalWalkingKneeMaxGeneric, WeightedWalkingKneeMaxGeneric(:,2)),"all","omitnan");
WeightedWalking3kgKneeRedGenericAvg = mean(compute_peek_knee_flex_red(normalWalkingKneeMaxGeneric, WeightedWalkingKneeMaxGeneric(:,3)),"all","omitnan");
WeightedWalking4kgKneeRedGenericAvg = mean(compute_peek_knee_flex_red(normalWalkingKneeMaxGeneric, WeightedWalkingKneeMaxGeneric(:,4)),"all","omitnan");
WeightedWalking5kgKneeRedGenericAvg = mean(compute_peek_knee_flex_red(normalWalkingKneeMaxGeneric, WeightedWalkingKneeMaxGeneric(:,5)),"all","omitnan");

WeightedWalking1kgKneeRedGenericStd = std(compute_peek_knee_flex_red(normalWalkingKneeMaxGeneric, WeightedWalkingKneeMaxGeneric(:,1)),0,"all","omitnan");
WeightedWalking2kgKneeRedGenericStd = std(compute_peek_knee_flex_red(normalWalkingKneeMaxGeneric, WeightedWalkingKneeMaxGeneric(:,2)),0,"all","omitnan");
WeightedWalking3kgKneeRedGenericStd = std(compute_peek_knee_flex_red(normalWalkingKneeMaxGeneric, WeightedWalkingKneeMaxGeneric(:,3)),0,"all","omitnan");
WeightedWalking4kgKneeRedGenericStd = std(compute_peek_knee_flex_red(normalWalkingKneeMaxGeneric, WeightedWalkingKneeMaxGeneric(:,4)),0,"all","omitnan");
WeightedWalking5kgKneeRedGenericStd = std(compute_peek_knee_flex_red(normalWalkingKneeMaxGeneric, WeightedWalkingKneeMaxGeneric(:,5)),0,"all","omitnan");

%% Save Personal Weighted Results
normalWalkingKneeMaxPersonal = NaN(NSUBJ, 1);
WeightedWalkingKneeMaxPersonal = NaN(NSUBJ, Nweights);

for subjID = 1:NSUBJ
    normalWalkingKneeMaxPersonal(subjID) = compute_peak_knee_flex_sim(PersonalKinData, isKneeFlexion, subjID);
    WeightedWalkingKneeMaxPersonal(subjID,:) = compute_peak_knee_flex_sim(PersonalKinDataWeighted, isKneeFlexion, subjID);
end

% compute average over all subjects
normalWalkingKneeMaxPersonalAvg = mean(normalWalkingKneeMaxPersonal,"all","omitnan");
WeightedWalking1kgKneeMaxPersonalAvg = mean(WeightedWalkingKneeMaxPersonal(:,1),"all","omitnan");
WeightedWalking2kgKneeMaxPersonalAvg = mean(WeightedWalkingKneeMaxPersonal(:,2),"all","omitnan");
WeightedWalking3kgKneeMaxPersonalAvg = mean(WeightedWalkingKneeMaxPersonal(:,3),"all","omitnan");
WeightedWalking4kgKneeMaxPersonalAvg = mean(WeightedWalkingKneeMaxPersonal(:,4),"all","omitnan");
WeightedWalking5kgKneeMaxPersonalAvg = mean(WeightedWalkingKneeMaxPersonal(:,5),"all","omitnan");

% compute STD over all subjects
normalWalkingKneeMaxPersonalStd = std(normalWalkingKneeMaxPersonal,0,"all","omitnan");
WeightedWalking1kgKneeMaxPersonalStd = std(WeightedWalkingKneeMaxPersonal(:,1),0,"all","omitnan");
WeightedWalking2kgKneeMaxPersonalStd = std(WeightedWalkingKneeMaxPersonal(:,2),0,"all","omitnan");
WeightedWalking3kgKneeMaxPersonalStd = std(WeightedWalkingKneeMaxPersonal(:,3),0,"all","omitnan");
WeightedWalking4kgKneeMaxPersonalStd = std(WeightedWalkingKneeMaxPersonal(:,4),0,"all","omitnan");
WeightedWalking5kgKneeMaxPersonalStd = std(WeightedWalkingKneeMaxPersonal(:,5),0,"all","omitnan");

% compute knee flexion reduction
WeightedWalking1kgKneeRedPersonalAvg = mean(compute_peek_knee_flex_red(normalWalkingKneeMaxPersonal, WeightedWalkingKneeMaxPersonal(:,1)),"all","omitnan");
WeightedWalking2kgKneeRedPersonalAvg = mean(compute_peek_knee_flex_red(normalWalkingKneeMaxPersonal, WeightedWalkingKneeMaxPersonal(:,2)),"all","omitnan");
WeightedWalking3kgKneeRedPersonalAvg = mean(compute_peek_knee_flex_red(normalWalkingKneeMaxPersonal, WeightedWalkingKneeMaxPersonal(:,3)),"all","omitnan");
WeightedWalking4kgKneeRedPersonalAvg = mean(compute_peek_knee_flex_red(normalWalkingKneeMaxPersonal, WeightedWalkingKneeMaxPersonal(:,4)),"all","omitnan");
WeightedWalking5kgKneeRedPersonalAvg = mean(compute_peek_knee_flex_red(normalWalkingKneeMaxPersonal, WeightedWalkingKneeMaxPersonal(:,5)),"all","omitnan");

WeightedWalking1kgKneeRedPersonalStd = std(compute_peek_knee_flex_red(normalWalkingKneeMaxPersonal, WeightedWalkingKneeMaxPersonal(:,1)),0,"all","omitnan");
WeightedWalking2kgKneeRedPersonalStd = std(compute_peek_knee_flex_red(normalWalkingKneeMaxPersonal, WeightedWalkingKneeMaxPersonal(:,2)),0,"all","omitnan");
WeightedWalking3kgKneeRedPersonalStd = std(compute_peek_knee_flex_red(normalWalkingKneeMaxPersonal, WeightedWalkingKneeMaxPersonal(:,3)),0,"all","omitnan");
WeightedWalking4kgKneeRedPersonalStd = std(compute_peek_knee_flex_red(normalWalkingKneeMaxPersonal, WeightedWalkingKneeMaxPersonal(:,4)),0,"all","omitnan");
WeightedWalking5kgKneeRedPersonalStd = std(compute_peek_knee_flex_red(normalWalkingKneeMaxPersonal, WeightedWalkingKneeMaxPersonal(:,5)),0,"all","omitnan");

%% Evaluate Significant Generic Simulation Reductions
% paired t-test for 2 recordings of the same subjects in different conditions
% h = 1 indicates significant difference in population means
[h1gen,p1gen,CI1gen,stats1gen] = ttest(normalWalkingKneeMaxGeneric, WeightedWalkingKneeMaxGeneric(:,1),"Alpha", 0.05);
[h2gen,p2gen,CI2gen,stats2gen] = ttest(normalWalkingKneeMaxGeneric, WeightedWalkingKneeMaxGeneric(:,2),"Alpha", 0.05);
[h3gen,p3gen,CI3gen,stats3gen] = ttest(normalWalkingKneeMaxGeneric, WeightedWalkingKneeMaxGeneric(:,3),"Alpha", 0.05);
[h4gen,p4gen,CI4gen,stats4gen] = ttest(normalWalkingKneeMaxGeneric, WeightedWalkingKneeMaxGeneric(:,4),"Alpha", 0.05);
[h5gen,p5gen,CI5gen,stats5gen] = ttest(normalWalkingKneeMaxGeneric, WeightedWalkingKneeMaxGeneric(:,5),"Alpha", 0.05);

% Cohen's dz 
% represents mean change between conditions, scaled by inter-subject variability
% larger than 1 indicates large changes
dz1gen = stats1gen.tstat/sqrt(NSUBJ);
dz2gen = stats2gen.tstat/sqrt(NSUBJ);
dz3gen = stats3gen.tstat/sqrt(NSUBJ);
dz4gen = stats4gen.tstat/sqrt(NSUBJ);
dz5gen = stats5gen.tstat/sqrt(NSUBJ);

%% Evaluate Significant Personal Simulation Reductions
% paired t-test for 2 recordings of the same subjects in different conditions
% h = 1 indicates significant difference in population means
[h1per,p1per,CI1per,stats1per] = ttest(normalWalkingKneeMaxPersonal, WeightedWalkingKneeMaxPersonal(:,1),"Alpha", 0.05);
[h2per,p2per,CI2per,stats2per] = ttest(normalWalkingKneeMaxPersonal, WeightedWalkingKneeMaxPersonal(:,2),"Alpha", 0.05);
[h3per,p3per,CI3per,stats3per] = ttest(normalWalkingKneeMaxPersonal, WeightedWalkingKneeMaxPersonal(:,3),"Alpha", 0.05);
[h4per,p4per,CI4per,stats4per] = ttest(normalWalkingKneeMaxPersonal, WeightedWalkingKneeMaxPersonal(:,4),"Alpha", 0.05);
[h5per,p5per,CI5per,stats5per] = ttest(normalWalkingKneeMaxPersonal, WeightedWalkingKneeMaxPersonal(:,5),"Alpha", 0.05);

% Cohen's dz 
% represents mean change between conditions, scaled by inter-subject variability
% larger than 1 indicates large changes
dz1per = stats1per.tstat/sqrt(NSUBJ);
dz2per = stats2per.tstat/sqrt(NSUBJ);
dz3per = stats3per.tstat/sqrt(NSUBJ);
dz4per = stats4per.tstat/sqrt(NSUBJ);
dz5per = stats5per.tstat/sqrt(NSUBJ);

%% Compute Mean & STD
% kinematics
WeightedWalkingGenericKinAvg = mean(GenericKinDataWeighted,3,"omitnan");
WeightedWalkingGenericKinStd = std(GenericKinDataWeighted,0,3,"omitnan");
WeightedWalkingPersonalKinAvg = mean(PersonalKinDataWeighted,3,"omitnan");
WeightedWalkingPersonalKinStd = std(PersonalKinDataWeighted,0,3,"omitnan");

% GRF
WeightedWalkingGenericGrfAvg = mean(GenericGrfDataWeighted,3,"omitnan");
WeightedWalkingGenericGrfStd = std(GenericGrfDataWeighted,0,3,"omitnan");
WeightedWalkingPersonalGrfAvg = mean(PersonalGrfDataWeighted,3,"omitnan");
WeightedWalkingPersonalGrfStd = std(PersonalGrfDataWeighted,0,3,"omitnan");

% kinetics
WeightedWalkingGenericKitAvg = mean(GenericKitDataWeighted,3,"omitnan");
WeightedWalkingGenericKitStd = std(GenericKitDataWeighted,0,3,"omitnan");
WeightedWalkingPersonalKitAvg = mean(PersonalKitDataWeighted,3,"omitnan");
WeightedWalkingPersonalKitStd = std(PersonalKitDataWeighted,0,3,"omitnan");

% EMG
WeightedWalkingGenericEmgAvg = mean(GenericEmgDataWeighted(:,isLimEMG>0,:,:),3,"omitnan");
WeightedWalkingGenericEmgStd = std(GenericEmgDataWeighted(:,isLimEMG>0,:,:),0,3,"omitnan");
WeightedWalkingPersonalEmgAvg = mean(PersonalEmgDataWeighted(:,isLimEMG>0,:,:),3,"omitnan");
WeightedWalkingPersonalEmgStd = std(PersonalEmgDataWeighted(:,isLimEMG>0,:,:),0,3,"omitnan");

%% Save Dhondt2024_3seg Weighted Results
isKneeFlexion = contains(Dhondt2024_3segkinColHeaders,"knee_angle");
dhondt2024_3segSubFolders = repmat("Dhondt2024_3seg",1,NSUBJ) + "/" + ["SUBJ04_Dhondt2024_3seg_17062026", "SUBJ06_Dhondt2024_3seg_17062026", "SUBJ07_Dhondt2024_3seg_17062026", "SUBJ09_Dhondt2024_3seg_17062026", "SUBJ10_Dhondt2024_3seg_17062026", "SUBJ11_Dhondt2024_3seg_17062026"];
dhondt2024_3segSubFolders = dhondt2024_3segSubFolders + "/weightedWalking";
[Dhondt2024_3segKinDataWeighted, Dhondt2024_3segGrfDataWeighted, Dhondt2024_3segKitDataWeighted, Dhondt2024_3segEmgDataWeighted, ~, ~, ~, Dhondt2024_3segIdxHeelLWeighted, ~, ~, ~] = average_results(resampTime, 29, Ngrfcol, 92, resultsDIR, ResultsFolders, dhondt2024_3segSubFolders, weightedKeyWords, Nweights);

% store data for each subject
normalWalkingKneeMaxDhondt2024_3seg = NaN(NSUBJ, 1);
WeightedWalkingKneeMaxDhondt2024_3seg = NaN(NSUBJ, Nweights);
for subjID = 1:NSUBJ
    normalWalkingKneeMaxDhondt2024_3seg(subjID) = compute_peak_knee_flex_sim(Dhondt2024_3segKinData, isKneeFlexion, subjID);
    WeightedWalkingKneeMaxDhondt2024_3seg(subjID,:) = compute_peak_knee_flex_sim(Dhondt2024_3segKinDataWeighted, isKneeFlexion, subjID);
end

% compute average over all subjects
normalWalkingKneeMaxDhondt2024_3segAvg = mean(normalWalkingKneeMaxDhondt2024_3seg,"all","omitnan");
WeightedWalking1kgKneeMaxDhondt2024_3segAvg = mean(WeightedWalkingKneeMaxDhondt2024_3seg(:,1),"all","omitnan");
WeightedWalking2kgKneeMaxDhondt2024_3segAvg = mean(WeightedWalkingKneeMaxDhondt2024_3seg(:,2),"all","omitnan");
WeightedWalking3kgKneeMaxDhondt2024_3segAvg = mean(WeightedWalkingKneeMaxDhondt2024_3seg(:,3),"all","omitnan");
WeightedWalking4kgKneeMaxDhondt2024_3segAvg = mean(WeightedWalkingKneeMaxDhondt2024_3seg(:,4),"all","omitnan");
WeightedWalking5kgKneeMaxDhondt2024_3segAvg = mean(WeightedWalkingKneeMaxDhondt2024_3seg(:,5),"all","omitnan");

% compute STD over all subjects
normalWalkingKneeMaxDhondt2024_3segStd = std(normalWalkingKneeMaxDhondt2024_3seg,0,"all","omitnan");
WeightedWalking1kgKneeMaxDhondt2024_3segStd = std(WeightedWalkingKneeMaxDhondt2024_3seg(:,1),0,"all","omitnan");
WeightedWalking2kgKneeMaxDhondt2024_3segStd = std(WeightedWalkingKneeMaxDhondt2024_3seg(:,2),0,"all","omitnan");
WeightedWalking3kgKneeMaxDhondt2024_3segStd = std(WeightedWalkingKneeMaxDhondt2024_3seg(:,3),0,"all","omitnan");
WeightedWalking4kgKneeMaxDhondt2024_3segStd = std(WeightedWalkingKneeMaxDhondt2024_3seg(:,4),0,"all","omitnan");
WeightedWalking5kgKneeMaxDhondt2024_3segStd = std(WeightedWalkingKneeMaxDhondt2024_3seg(:,5),0,"all","omitnan");

% compute knee flex reduction
WeightedWalking1kgKneeRedDhondt2024_3segAvg = mean(compute_peek_knee_flex_red(normalWalkingKneeMaxDhondt2024_3seg, WeightedWalkingKneeMaxDhondt2024_3seg(:,1)),"all","omitnan");
WeightedWalking2kgKneeRedDhondt2024_3segAvg = mean(compute_peek_knee_flex_red(normalWalkingKneeMaxDhondt2024_3seg, WeightedWalkingKneeMaxDhondt2024_3seg(:,2)),"all","omitnan");
WeightedWalking3kgKneeRedDhondt2024_3segAvg = mean(compute_peek_knee_flex_red(normalWalkingKneeMaxDhondt2024_3seg, WeightedWalkingKneeMaxDhondt2024_3seg(:,3)),"all","omitnan");
WeightedWalking4kgKneeRedDhondt2024_3segAvg = mean(compute_peek_knee_flex_red(normalWalkingKneeMaxDhondt2024_3seg, WeightedWalkingKneeMaxDhondt2024_3seg(:,4)),"all","omitnan");
WeightedWalking5kgKneeRedDhondt2024_3segAvg = mean(compute_peek_knee_flex_red(normalWalkingKneeMaxDhondt2024_3seg, WeightedWalkingKneeMaxDhondt2024_3seg(:,5)),"all","omitnan");

WeightedWalking1kgKneeRedDhondt2024_3segStd = std(compute_peek_knee_flex_red(normalWalkingKneeMaxDhondt2024_3seg, WeightedWalkingKneeMaxDhondt2024_3seg(:,1)),0,"all","omitnan");
WeightedWalking2kgKneeRedDhondt2024_3segStd = std(compute_peek_knee_flex_red(normalWalkingKneeMaxDhondt2024_3seg, WeightedWalkingKneeMaxDhondt2024_3seg(:,2)),0,"all","omitnan");
WeightedWalking3kgKneeRedDhondt2024_3segStd = std(compute_peek_knee_flex_red(normalWalkingKneeMaxDhondt2024_3seg, WeightedWalkingKneeMaxDhondt2024_3seg(:,3)),0,"all","omitnan");
WeightedWalking4kgKneeRedDhondt2024_3segStd = std(compute_peek_knee_flex_red(normalWalkingKneeMaxDhondt2024_3seg, WeightedWalkingKneeMaxDhondt2024_3seg(:,4)),0,"all","omitnan");
WeightedWalking5kgKneeRedDhondt2024_3segStd = std(compute_peek_knee_flex_red(normalWalkingKneeMaxDhondt2024_3seg, WeightedWalkingKneeMaxDhondt2024_3seg(:,5)),0,"all","omitnan");

%% Evaluate Significant Dhondt2024_3seg Simulation Reductions
% paired t-test for 2 recordings of the same subjects in different conditions
% h = 1 indicates significant difference in population means
[h1fal,p1fal,CI1fal,stats1fal] = ttest(normalWalkingKneeMaxDhondt2024_3seg, WeightedWalkingKneeMaxDhondt2024_3seg(:,1),"Alpha", 0.05);
[h2fal,p2fal,CI2fal,stats2fal] = ttest(normalWalkingKneeMaxDhondt2024_3seg, WeightedWalkingKneeMaxDhondt2024_3seg(:,2),"Alpha", 0.05);
[h3fal,p3fal,CI3fal,stats3fal] = ttest(normalWalkingKneeMaxDhondt2024_3seg, WeightedWalkingKneeMaxDhondt2024_3seg(:,3),"Alpha", 0.05);
[h4fal,p4fal,CI4fal,stats4fal] = ttest(normalWalkingKneeMaxDhondt2024_3seg, WeightedWalkingKneeMaxDhondt2024_3seg(:,4),"Alpha", 0.05);
[h5fal,p5fal,CI5fal,stats5fal] = ttest(normalWalkingKneeMaxDhondt2024_3seg, WeightedWalkingKneeMaxDhondt2024_3seg(:,5),"Alpha", 0.05);

% Cohen's dz 
% represents mean change between conditions, scaled by inter-subject variability
% larger than 1 indicates large changes
dz1fal = stats1fal.tstat/sqrt(NSUBJ);
dz2fal = stats2fal.tstat/sqrt(NSUBJ);
dz3fal = stats3fal.tstat/sqrt(NSUBJ);
dz4fal = stats4fal.tstat/sqrt(NSUBJ);
dz5fal = stats5fal.tstat/sqrt(NSUBJ);

%% Compute Mean & STD
% kinematics
WeightedWalkingDhondt2024_3segKinAvg = mean(Dhondt2024_3segKinDataWeighted(:,Dhondt2024_3seg_isLimKin>0,:,:),3,"omitnan");
WeightedWalkingDhondt2024_3segKinStd = std(Dhondt2024_3segKinDataWeighted(:,Dhondt2024_3seg_isLimKin>0,:,:),0,3,"omitnan");

% GRF
WeightedWalkingDhondt2024_3segGrfAvg = mean(Dhondt2024_3segGrfDataWeighted,3,"omitnan");
WeightedWalkingDhondt2024_3segGrfStd = std(Dhondt2024_3segGrfDataWeighted,0,3,"omitnan");

% kinetics
WeightedWalkingDhondt2024_3segKitAvg = mean(Dhondt2024_3segKitDataWeighted,3,"omitnan");
WeightedWalkingDhondt2024_3segKitStd = std(Dhondt2024_3segKitDataWeighted,0,3,"omitnan");

% EMG
WeightedWalkingDhondt2024_3segEmgAvg = mean(Dhondt2024_3segEmgDataWeighted(:,Dhondt2024_3seg_isLimEmg>0,:,:),3,"omitnan");
WeightedWalkingDhondt2024_3segEmgStd = std(Dhondt2024_3segEmgDataWeighted(:,Dhondt2024_3seg_isLimEmg>0,:,:),0,3,"omitnan");

%% Extract Sagittal Plane Data
isSagittalPlaneKinematics = contains(kinColHeaders,"knee_angle") | contains(kinColHeaders,"hip_flexion") | contains(kinColHeaders,"ankle_angle");
sagittalPlaneCols = 1:Nkincol; sagittalPlaneCols = sagittalPlaneCols(isSagittalPlaneKinematics);

Dhondt2024_3segkinColHeadersLimKin = Dhondt2024_3segkinColHeaders(Dhondt2024_3seg_isLimKin);
isSagittalPlaneKinematicsDhondt2024_3seg = contains(Dhondt2024_3segkinColHeadersLimKin,"knee_angle") | contains(Dhondt2024_3segkinColHeadersLimKin,"hip_flexion") | contains(Dhondt2024_3segkinColHeadersLimKin,"ankle_angle");
sagittalPlaneColsDhondt2024_3seg = 1:Nkincol; sagittalPlaneColsDhondt2024_3seg = sagittalPlaneColsDhondt2024_3seg(isSagittalPlaneKinematicsDhondt2024_3seg);

%% Plot Experimental & Simulation Peak Knee Flexion Reduction
barColors = [[0.7,0.7,0.7]; [0,51,153]/255; [255,102,0]/255; [51,155,155]/255];

% Combine data experimental
KneeMaxReductionExpAvg = [WeightedWalking1kgKneeRedExpAvg, WeightedWalking2kgKneeRedExpAvg, WeightedWalking3kgKneeRedExpAvg, WeightedWalking4kgKneeRedExpAvg, WeightedWalking5kgKneeRedExpAvg];
KneeMaxReductionExpStd = [WeightedWalking1kgKneeRedExpStd, WeightedWalking2kgKneeRedExpStd, WeightedWalking3kgKneeRedExpStd, WeightedWalking4kgKneeRedExpStd, WeightedWalking5kgKneeRedExpStd];

% Combine data generic
KneeMaxReductionGenericAvg = [WeightedWalking1kgKneeRedGenericAvg, WeightedWalking2kgKneeRedGenericAvg, WeightedWalking3kgKneeRedGenericAvg, WeightedWalking4kgKneeRedGenericAvg, WeightedWalking5kgKneeRedGenericAvg];
KneeMaxReductionGenericStd = [WeightedWalking1kgKneeRedGenericStd, WeightedWalking2kgKneeRedGenericStd, WeightedWalking3kgKneeRedGenericStd, WeightedWalking4kgKneeRedGenericStd, WeightedWalking5kgKneeRedGenericStd];

% Combine data personal
KneeMaxReductionPersonalAvg = [WeightedWalking1kgKneeRedPersonalAvg, WeightedWalking2kgKneeRedPersonalAvg, WeightedWalking3kgKneeRedPersonalAvg, WeightedWalking4kgKneeRedPersonalAvg, WeightedWalking5kgKneeRedPersonalAvg];
KneeMaxReductionPersonalStd = [WeightedWalking1kgKneeRedPersonalStd, WeightedWalking2kgKneeRedPersonalStd, WeightedWalking3kgKneeRedPersonalStd, WeightedWalking4kgKneeRedPersonalStd, WeightedWalking5kgKneeRedPersonalStd];

% Combine data Dhondt2024_3seg
KneeMaxReductionDhondt2024_3segAvg = [WeightedWalking1kgKneeRedDhondt2024_3segAvg, WeightedWalking2kgKneeRedDhondt2024_3segAvg, WeightedWalking3kgKneeRedDhondt2024_3segAvg, WeightedWalking4kgKneeRedDhondt2024_3segAvg, WeightedWalking5kgKneeRedDhondt2024_3segAvg];
KneeMaxReductionDhondt2024_3segStd = [WeightedWalking1kgKneeRedDhondt2024_3segStd, WeightedWalking2kgKneeRedDhondt2024_3segStd, WeightedWalking3kgKneeRedDhondt2024_3segStd, WeightedWalking4kgKneeRedDhondt2024_3segStd, WeightedWalking5kgKneeRedDhondt2024_3segStd];

% Create figure
fig = figure;
set(gcf,"Units","centimeters")                                              % cm units for position
set(gcf,"Position",[0 0 fig_width fig_height/1.3])                          % IEEE 1-column: 8.89cm
hold on 
% grid on
b = bar(1:5,[KneeMaxReductionExpAvg; KneeMaxReductionGenericAvg; KneeMaxReductionPersonalAvg; KneeMaxReductionDhondt2024_3segAvg]);

% assign colors
for i = 1:4
    b(i).FaceColor = barColors(i,:);
end

xendpoints = [b.XEndPoints];
errorbar(xendpoints(1:Nweights), KneeMaxReductionExpAvg, KneeMaxReductionExpStd, '.', "vertical", "Color", "black")
errorbar(xendpoints(Nweights+1:2*Nweights), KneeMaxReductionGenericAvg, KneeMaxReductionGenericStd, '.', "vertical", "Color", "black")
errorbar(xendpoints(2*Nweights+1:3*Nweights), KneeMaxReductionPersonalAvg, KneeMaxReductionPersonalStd, '.', "vertical", "Color", "black")
errorbar(xendpoints(3*Nweights+1:end), KneeMaxReductionDhondt2024_3segAvg, KneeMaxReductionDhondt2024_3segStd, '.', "vertical", "Color", "black")
xticks(1:5)
xticklabels(["1 kg", "2 kg", "3 kg", "4 kg", "5 kg"])
ylabel(["Average Peak Knee Flexion"; "Angle Reduction [%]"],"FontWeight","bold")
lg = legend(["Experimental", "Generic", "Personal", "D'Hondt2024 3 seg"],"Location","best");
lg.Box = "off";

% figure settings
set(findall(fig,'-property','FontSize'),'FontSize',8)                       % font size
set(0,"DefaultFigureColor","w")                                             % white background
set(0,"defaulttextinterpreter","tex")                                       % tex style font
set(0,"DefaultAxesFontName","SansSerif")                                    % times new roman font
set(gca,"Units","centimeters")                                              % cm units for position
set(gca,"Position",[1.4 0.45 fig_width-1.5 fig_height-2.75])                % axes position (x, y, w, h)
hold off
axis tight

if(export)
    figName = "WeightedPeakKneeFlexionReduction_personal_dhondt2024_3seg_gait1422" + figFileType;
    exportgraphics(fig,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
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

%% Compute Experimental AVG & STD Across Subjects
normalWalkingExpKinAvg = mean(normalWalkingKinExpAvgLim,3,"omitnan");
normalWalkingExpKinStd = std(normalWalkingKinExpAvgLim,0,3,"omitnan");

weightedWalkingExpKinAvg = mean(weightedWalkingKinExpAvgLim,3,"omitnan");
weightedWalkingExpKinStd = std(weightedWalkingKinExpAvgLim,0,3,"omitnan");

%% Shift Left Simulation Data
% shift kinematics
isLeftKin = contains(kinColHeaders,"_l") & ~contains(kinColHeaders,"pelvis");
[GenericKinDataShifted, PersonalKinDataShifted, Dhondt2024_3segKinDataShifted] = shift_sim_data(isLeftKin, GenericKinData, PersonalKinData, Dhondt2024_3segKinData(:,Dhondt2024_3seg_isLimKin>0,:,:), GenericIdxHeelL, PersonalIdxHeelL, Dhondt2024_3segIdxHeelL);
[GenericKinDataWeightedShifted, PersonalKinDataWeightedShifted, Dhondt2024_3segKinDataWeightedShifted] = shift_sim_data(isLeftKin, GenericKinDataWeighted, PersonalKinDataWeighted, Dhondt2024_3segKinDataWeighted(:,Dhondt2024_3seg_isLimKin>0,:,:), GenericIdxHeelLWeighted, PersonalIdxHeelLWeighted, Dhondt2024_3segIdxHeelLWeighted);

% shift ground reaction forces
isLeftGrf = contains(GRFColHeaders,"Left");
[GenericGrfDataWeightedShifted, PersonalGrfDataWeightedShifted, Dhondt2024_3segGrfDataWeightedShifted] = shift_sim_data(isLeftGrf, GenericGrfDataWeighted, PersonalGrfDataWeighted, Dhondt2024_3segGrfDataWeighted, GenericIdxHeelLWeighted, PersonalIdxHeelLWeighted, Dhondt2024_3segIdxHeelLWeighted);

% shift EMG
isLeftEmg = NemgcolLim/2+1:NemgcolLim;
Dhondt2024_3segEmgDataWeightedLim = Dhondt2024_3segEmgDataWeighted(:,Dhondt2024_3seg_isLimEmg>0,:,:);
[GenericEmgDataWeightedShifted, PersonalEmgDataWeightedShifted, Dhondt2024_3segEmgDataWeightedShifted] = shift_sim_data(isLeftEmg, GenericEmgDataWeighted(:,isLimEMG>0,:,:), PersonalEmgDataWeighted(:,isLimEMG>0,:,:), Dhondt2024_3segEmgDataWeightedLim, GenericIdxHeelLWeighted, PersonalIdxHeelLWeighted, Dhondt2024_3segIdxHeelLWeighted);

%% Shift Pelvis Tz To Start at Zero
isPelvisTz = contains(kinColHeaders, "pelvis_tz");
for i = 1:NSUBJ
    GenericKinDataShifted(:,isPelvisTz,i) = GenericKinDataShifted(:,isPelvisTz,i) - GenericKinDataShifted(1,isPelvisTz,i);
    PersonalKinDataShifted(:,isPelvisTz,i) = PersonalKinDataShifted(:,isPelvisTz,i) - PersonalKinDataShifted(1,isPelvisTz,i);
    Dhondt2024_3segKinDataShifted(:,isPelvisTz,i) = Dhondt2024_3segKinDataShifted(:,isPelvisTz,i) - Dhondt2024_3segKinDataShifted(1,isPelvisTz,i);
end

for i = 1:NSUBJ
    GenericKinDataWeightedShifted(:,isPelvisTz,i,:) = GenericKinDataWeightedShifted(:,isPelvisTz,i,:) - GenericKinDataWeightedShifted(1,isPelvisTz,i,:);
    PersonalKinDataWeightedShifted(:,isPelvisTz,i,:) = PersonalKinDataWeightedShifted(:,isPelvisTz,i,:) - PersonalKinDataWeightedShifted(1,isPelvisTz,i,:);
    Dhondt2024_3segKinDataWeightedShifted(:,isPelvisTz,i,:) = Dhondt2024_3segKinDataWeightedShifted(:,isPelvisTz,i,:) - Dhondt2024_3segKinDataWeightedShifted(1,isPelvisTz,i,:);
end

%% Shift Pelvis Ty To Have Mean at Zero
isPelvisTy = contains(kinColHeaders, "pelvis_ty");
for i = 1:NSUBJ
    GenericKinDataShifted(:,isPelvisTy,i) = GenericKinDataShifted(:,isPelvisTy,i) - mean(GenericKinDataShifted(:,isPelvisTy,i));
    PersonalKinDataShifted(:,isPelvisTy,i) = PersonalKinDataShifted(:,isPelvisTy,i) - mean(PersonalKinDataShifted(:,isPelvisTy,i));
    Dhondt2024_3segKinDataShifted(:,isPelvisTy,i) = Dhondt2024_3segKinDataShifted(:,isPelvisTy,i) - mean(Dhondt2024_3segKinDataShifted(:,isPelvisTy,i));

    GenericKinDataWeightedShifted(:,isPelvisTy,i,:) = GenericKinDataWeightedShifted(:,isPelvisTy,i,:) - mean(GenericKinDataWeightedShifted(:,isPelvisTy,i,:));
    PersonalKinDataWeightedShifted(:,isPelvisTy,i,:) = PersonalKinDataWeightedShifted(:,isPelvisTy,i,:) - mean(PersonalKinDataWeightedShifted(:,isPelvisTy,i,:));
    Dhondt2024_3segKinDataWeightedShifted(:,isPelvisTy,i,:) = Dhondt2024_3segKinDataWeightedShifted(:,isPelvisTy,i,:) - mean(Dhondt2024_3segKinDataWeightedShifted(:,isPelvisTy,i,:));

    weightedWalkingKinExpAvgLim(:,isPelvisTy,i,:) = weightedWalkingKinExpAvgLim(:,isPelvisTy,i,:) - mean(weightedWalkingKinExpAvgLim(:,isPelvisTy,i,:));
end

%% Compute Metrics
% Generic
R_list_kin_generic = NaN(NSUBJ, Nweights, Nkincol);
rmse_list_kin_generic = NaN(NSUBJ, Nweights, Nkincol);
exp_match_kin_list_generic = NaN(NSUBJ, Nweights, Nkincol);
R_list_grf_generic = NaN(NSUBJ, Nweights, Ngrfcol);
rmse_list_grf_generic = NaN(NSUBJ, Nweights, Ngrfcol);
R_list_emg_generic = NaN(NSUBJ, Nweights, NemgcolLim);

% Personal
R_list_kin_personal = NaN(NSUBJ, Nweights, Nkincol);
rmse_list_kin_personal = NaN(NSUBJ, Nweights, Nkincol);
exp_match_kin_list_personal = NaN(NSUBJ, Nweights, Nkincol);
R_list_grf_personal = NaN(NSUBJ, Nweights, Ngrfcol);
rmse_list_grf_personal = NaN(NSUBJ, Nweights, Ngrfcol);
R_list_emg_personal = NaN(NSUBJ, Nweights, NemgcolLim);

% Dhondt2024_3seg
R_list_kin_dhondt2024_3seg = NaN(NSUBJ, Nweights, Nkincol);
rmse_list_kin_dhondt2024_3seg = NaN(NSUBJ, Nweights, Nkincol);
exp_match_list_kin_dhondt2024_3seg = NaN(NSUBJ, Nweights, Nkincol);
R_list_grf_dhondt2024_3seg = NaN(NSUBJ, Nweights, Ngrfcol);
rmse_list_grf_dhondt2024_3seg = NaN(NSUBJ, Nweights, Ngrfcol);
R_list_emg_dhondt2024_3seg = NaN(NSUBJ, Nweights, NemgcolLim);

for i = 1:NSUBJ
    for j = 1:Nweights
        % generic
        [R_list_kin_generic(i,j,:), rmse_list_kin_generic(i,j,:), exp_match_kin_list_generic(i,j,:)] = ...
            compute_metrics(weightedWalkingKinExpAvgLim(:,:,i,j), ...
            GenericKinDataWeightedShifted(:,:,i,j), ...
            weightedWalkingKinExpStdLim(:,:,i,j));
        [R_list_grf_generic(i,j,:), rmse_list_grf_generic(i,j,:), ~] = ...
            compute_metrics(weightedWalkingGrfExpAvgLim(:,:,i,j)/SUBJmass(i), ...
            GenericGrfDataWeightedShifted(:,:,i,j)/SUBJmass(i), NaN);
        [R_list_emg_generic(i,j,:), ~, ~] = ...
            compute_metrics(weightedWalkingEMGexpLim(:,:,i,j), ...
            GenericEmgDataWeightedShifted(:,:,i,j), NaN);

        % personal
        [R_list_kin_personal(i,j,:), rmse_list_kin_personal(i,j,:), exp_match_kin_list_personal(i,j,:)] = ...
            compute_metrics(weightedWalkingKinExpAvgLim(:,:,i,j), ...
            PersonalKinDataWeightedShifted(:,:,i,j), ...
            weightedWalkingKinExpStdLim(:,:,i,j));
        [R_list_grf_personal(i,j,:), rmse_list_grf_personal(i,j,:), ~] = ...
            compute_metrics(weightedWalkingGrfExpAvgLim(:,:,i,j)/SUBJmass(i), ...
            PersonalGrfDataWeightedShifted(:,:,i,j)/SUBJmass(i), NaN);
        [R_list_emg_personal(i,j,:), ~, ~] = ...
            compute_metrics(weightedWalkingEMGexpLim(:,:,i,j), ...
            PersonalEmgDataWeightedShifted(:,:,i,j), NaN);

        % dhondt2024_3seg
        [R_list_kin_dhondt2024_3seg(i,j,:), rmse_list_kin_dhondt2024_3seg(i,j,:), exp_match_list_kin_dhondt2024_3seg(i,j,:)] = ...
            compute_metrics(weightedWalkingKinExpAvgLim(:,:,i,j), ...
            Dhondt2024_3segKinDataWeightedShifted(:,:,i,j), ...
            weightedWalkingKinExpStdLim(:,:,i,j));
        [R_list_grf_dhondt2024_3seg(i,j,:), rmse_list_grf_dhondt2024_3seg(i,j,:), ~] = ...
            compute_metrics(weightedWalkingGrfExpAvgLim(:,:,i,j)/SUBJmass(i), ...
            Dhondt2024_3segGrfDataWeightedShifted(:,:,i,j)/SUBJmass(i), ...
            weightedWalkingGrfExpStdLim(:,:,i,j)/SUBJmass(i));
        [R_list_emg_dhondt2024_3seg(i,j,:), ~, ~] = ...
            compute_metrics(weightedWalkingEMGexpLim(:,:,i,j), ...
            Dhondt2024_3segEmgDataWeightedShifted(:,:,i,j), NaN);
    end
end

% generic
R_list_generic_kin_sagg = R_list_kin_generic(:,:,isSagittalPlaneKinematics);
rmse_list_generic_kin_sagg = rmse_list_kin_generic(:,:,isSagittalPlaneKinematics);
exp_match_list_generic_kin_sagg = exp_match_kin_list_generic(:,:,isSagittalPlaneKinematics);

% personal
R_list_personal_kin_sagg = R_list_kin_personal(:,:,isSagittalPlaneKinematics);
rmse_list_personal_kin_sagg = rmse_list_kin_personal(:,:,isSagittalPlaneKinematics);
exp_match_list_personal_kin_sagg = exp_match_kin_list_personal(:,:,isSagittalPlaneKinematics);

% Dhondt2024 3seg
R_list_dhondt2024_3seg_kin_sagg = R_list_kin_dhondt2024_3seg(:,:,isSagittalPlaneKinematics);
rmse_list_dhondt2024_3seg_kin_sagg = rmse_list_kin_dhondt2024_3seg(:,:,isSagittalPlaneKinematics);
exp_match_list_dhondt2024_3seg_kin_sagg = exp_match_list_kin_dhondt2024_3seg(:,:,isSagittalPlaneKinematics);

%% Plot Metrics

% Combine metrics generic
R_list_generic_kin_sagg_avg = mean(R_list_generic_kin_sagg,1,"omitnan");
R_list_generic_kin_sagg_std = std(R_list_generic_kin_sagg,0,1,"omitnan");
rmse_list_generic_kin_sagg_avg = mean(rmse_list_generic_kin_sagg,1,"omitnan");
rmse_list_generic_kin_sagg_std = std(rmse_list_generic_kin_sagg,0,1,"omitnan");
exp_match_list_generic_kin_sagg_avg = mean(exp_match_list_generic_kin_sagg,1,"omitnan");
exp_match_list_generic_kin_sagg_std = std(exp_match_list_generic_kin_sagg,0,1,"omitnan");

% Combine metrics personal
R_list_personal_kin_sagg_avg = mean(R_list_personal_kin_sagg,1,"omitnan");
R_list_personal_kin_sagg_std = std(R_list_personal_kin_sagg,0,1,"omitnan");
rmse_list_personal_kin_sagg_avg = mean(rmse_list_personal_kin_sagg,1,"omitnan");
rmse_list_personal_kin_sagg_std = std(rmse_list_personal_kin_sagg,0,1,"omitnan");
exp_match_list_personal_kin_sagg_avg = mean(exp_match_list_personal_kin_sagg,1,"omitnan");
exp_match_list_personal_kin_sagg_std = std(exp_match_list_personal_kin_sagg,0,1,"omitnan");

% Combine metrics Dhondt2024_3seg
R_list_dhondt2024_3seg_kin_sagg_avg = mean(R_list_dhondt2024_3seg_kin_sagg,1,"omitnan");
R_list_dhondt2024_3seg_kin_sagg_std = std(R_list_dhondt2024_3seg_kin_sagg,0,1,"omitnan");
rmse_list_dhondt2024_3seg_kin_sagg_avg = mean(rmse_list_dhondt2024_3seg_kin_sagg,1,"omitnan");
rmse_list_dhondt2024_3seg_kin_sagg_std = std(rmse_list_dhondt2024_3seg_kin_sagg,0,1,"omitnan");
exp_match_list_dhondt2024_3seg_kin_sagg_avg = mean(exp_match_list_dhondt2024_3seg_kin_sagg,1,"omitnan");
exp_match_list_dhondt2024_3seg_kin_sagg_std = std(exp_match_list_dhondt2024_3seg_kin_sagg,0,1,"omitnan");

%% Compute Average Improvements
% average R over all subjects
avg_R_list_kin_generic = mean(R_list_kin_generic,1);
avg_R_list_kin_personal = mean(R_list_kin_personal,1);
avg_R_list_kin_dhondt2024_3seg = mean(R_list_kin_dhondt2024_3seg,1);

avg_R_list_grf_generic = mean(R_list_grf_generic,1);
avg_R_list_grf_personal = mean(R_list_grf_personal,1);
avg_R_list_grf_dhondt2024_3seg = mean(R_list_grf_dhondt2024_3seg,1);

avg_R_list_emg_generic = mean(R_list_emg_generic,1,"omitnan");
avg_R_list_emg_personal = mean(R_list_emg_personal,1,"omitnan");
avg_R_list_emg_dhondt2024_3seg = mean(R_list_emg_dhondt2024_3seg,1,"omitnan");

% average RMSE over all subjects
avg_rmse_list_kin_generic = mean(rmse_list_kin_generic,1);
avg_rmse_list_kin_personal = mean(rmse_list_kin_personal,1);
avg_rmse_list_kin_dhondt2024_3seg = mean(rmse_list_kin_dhondt2024_3seg,1);

avg_rmse_list_grf_generic = mean(rmse_list_grf_generic,1);
avg_rmse_list_grf_personal = mean(rmse_list_grf_personal,1);
avg_rmse_list_grf_dhondt2024_3seg = mean(rmse_list_grf_dhondt2024_3seg,1);

% save R average improvements
avg_percent_R_kin_sagg = NaN(Nweights,1);
avg_percent_R_kin_sagg_dhondt2024_3seg = NaN(Nweights,1);
avg_percent_R_kin = NaN(Nweights,1);
avg_percent_R_kin_dhondt2024_3seg = NaN(Nweights,1);
avg_percent_R_grf = NaN(Nweights,1);
avg_percent_R_grf_dhondt2024_3seg = NaN(Nweights,1);

% save RMSE average improvements
avg_percent_rmse_kin_sagg = NaN(Nweights,1);
avg_percent_rmse_kin_sagg_dhondt2024_3seg = NaN(Nweights,1);
avg_percent_rmse_kin = NaN(Nweights,1);
avg_percent_rmse_kin_dhondt2024_3seg = NaN(Nweights,1);
avg_percent_rmse_grf = NaN(Nweights,1);
avg_percent_rmse_grf_dhondt2024_3seg = NaN(Nweights,1);

for i = 1:Nweights
    % compute average R sagittal plane improvements
    % postive means R increased
    [avg_percent_R_kin_sagg(i), avg_percent_R_grf(i)] = compute_R_average_improvement(avg_R_list_kin_personal(:,i,isSagittalPlaneKinematics), avg_R_list_kin_generic(:,i,isSagittalPlaneKinematics), avg_R_list_grf_personal(:,i,:), avg_R_list_grf_generic(:,i,:), avg_R_list_emg_personal(:,i,:), avg_R_list_emg_generic(:,i,:), ['personal model (sagittal plane) ' num2str(i) ' kg']);
    [avg_percent_R_kin_sagg_dhondt2024_3seg(i), avg_percent_R_grf_dhondt2024_3seg(i)] = compute_R_average_improvement(avg_R_list_kin_dhondt2024_3seg(:,i,isSagittalPlaneKinematics), avg_R_list_kin_generic(:,i,isSagittalPlaneKinematics), avg_R_list_grf_dhondt2024_3seg(:,i,:), avg_R_list_grf_generic(:,i,:), avg_R_list_emg_dhondt2024_3seg(:,i,:), avg_R_list_emg_generic(:,i,:), ['Dhondt2024_3seg model (sagittal plane) ' num2str(i) ' kg']);

    % compute average R improvements (including not sagittal plane)
    % positive means R increased
    [avg_percent_R_kin(i), ~] = compute_R_average_improvement(avg_R_list_kin_personal(:,i,:), avg_R_list_kin_generic(:,i,:), NaN, NaN, NaN, NaN,['personal model (all DOF) ' num2str(i) ' kg']);
    [avg_percent_R_kin_dhondt2024_3seg(i), ~] = compute_R_average_improvement(avg_R_list_kin_dhondt2024_3seg(:,i,:), avg_R_list_kin_generic(:,i,:), NaN, NaN, NaN, NaN, ['Dhondt2024_3seg model (all DOF) ' num2str(i) ' kg']);
    
    % compute average RMSE sagittal plane improvements
    % negative means RMSE error decreased
    [avg_percent_rmse_kin_sagg(i), avg_percent_rmse_grf(i)] = compute_RMSE_average_improvement(avg_rmse_list_kin_personal(:,i,isSagittalPlaneKinematics), avg_rmse_list_kin_generic(:,i,isSagittalPlaneKinematics), avg_rmse_list_grf_personal(:,i,:), avg_rmse_list_grf_generic(:,i,:), ['personal model (sagittal plane) ' num2str(i) ' kg']);
    [avg_percent_rmse_kin_sagg_dhondt2024_3seg(i), avg_percent_rmse_grf_dhondt2024_3seg(i)] = compute_RMSE_average_improvement(avg_rmse_list_kin_dhondt2024_3seg(:,i,isSagittalPlaneKinematics), avg_rmse_list_kin_generic(:,i,isSagittalPlaneKinematics), avg_rmse_list_grf_dhondt2024_3seg(:,i,:), avg_rmse_list_grf_generic(:,i,:), ['Dhondt2024_3seg model (sagittal plane) ' num2str(i) ' kg']);

    % compute average RMSE (including not sagittal plane)
    % negative means RMSE error decreased
    [avg_percent_rmse_kin(i), ~] = compute_RMSE_average_improvement(avg_rmse_list_kin_personal(:,i,:), avg_rmse_list_kin_generic(:,i,:), avg_rmse_list_grf_personal(:,i,:), avg_rmse_list_grf_generic(:,i,:), ['personal model (all DOF) ' num2str(i) ' kg']);
    [avg_percent_rmse_kin_dhondt2024_3seg(i), ~] = compute_RMSE_average_improvement(avg_rmse_list_kin_dhondt2024_3seg(:,i,:), avg_rmse_list_kin_generic(:,i,:), avg_rmse_list_grf_dhondt2024_3seg(:,i,:), avg_rmse_list_grf_generic(:,i,:), ['Dhondt2024_3seg model (all DOF) ' num2str(i) ' kg']);
end

%% Print Matrix Average Improvements
% print average R kinematics
avg_percent_R_kin_matrix = round([avg_percent_R_kin, avg_percent_R_kin_dhondt2024_3seg],2);
max_percent_R_kin_matrix = max(avg_percent_R_kin_matrix,[],2);
isBestRkin = avg_percent_R_kin_matrix == max_percent_R_kin_matrix;
print_matrix_latex(avg_percent_R_kin_matrix,[],["Personal", "Dhondt2024_3seg"], ["1 kg", "2 kg", "3 kg", "4 kg", "5 kg"], isBestRkin,[])

% print average RMSE kinematics
avg_percent_rmse_kin_matrix = round([avg_percent_rmse_kin, avg_percent_rmse_kin_dhondt2024_3seg],2);
max_percent_rmse_kin_matrix = min(avg_percent_rmse_kin_matrix,[],2);
isBestRMSEkin = avg_percent_rmse_kin_matrix == max_percent_rmse_kin_matrix;
print_matrix_latex(avg_percent_rmse_kin_matrix,[],["Personal", "Dhondt2024_3seg"], ["1 kg", "2 kg", "3 kg", "4 kg", "5 kg"], isBestRMSEkin,[])

% print average R GRF
avg_percent_R_grf_matrix = round([avg_percent_R_grf, avg_percent_R_grf_dhondt2024_3seg],2);
max_percent_R_grf_matrix = max(avg_percent_R_grf_matrix,[],2);
isBestRgrf = avg_percent_R_grf_matrix == max_percent_R_grf_matrix;
print_matrix_latex(avg_percent_R_grf_matrix,[],["Personal", "Dhondt2024_3seg"], ["1 kg", "2 kg", "3 kg", "4 kg", "5 kg"], isBestRgrf,[])

% print average RMSE GRF
avg_percent_rmse_grf_matrix = round([avg_percent_rmse_grf, avg_percent_rmse_grf_dhondt2024_3seg],2);
max_percent_rmse_grf_matrix = min(avg_percent_rmse_grf_matrix,[],2);
isBestRMSEgrf = avg_percent_rmse_grf_matrix == max_percent_rmse_grf_matrix;
print_matrix_latex(avg_percent_rmse_grf_matrix,[],["Personal", "Dhondt2024_3seg"], ["1 kg", "2 kg", "3 kg", "4 kg", "5 kg"], isBestRMSEgrf,[])

%% Save Metrics
% % open metrics file
% load("metrics.mat");
% 
% % kinematics, R
% metrics.kinematics.weighted.R.personal = R_list_kin_personal;
% metrics.kinematics.weighted.R.generic = R_list_kin_generic;
% metrics.kinematics.weighted.R.dhondt2024_3seg = R_list_kin_dhondt2024_3seg;
% 
% % kinematics, RMSE
% metrics.kinematics.weighted.RMSE.personal = rmse_list_kin_personal;
% metrics.kinematics.weighted.RMSE.generic = rmse_list_kin_generic;
% metrics.kinematics.weighted.RMSE.dhondt2024_3seg = rmse_list_kin_dhondt2024_3seg;
% 
% % GRFs, R
% metrics.ground_reaction.weighted.R.personal = R_list_grf_personal;
% metrics.ground_reaction.weighted.R.generic = R_list_grf_generic;
% metrics.ground_reaction.weighted.R.dhondt2024_3seg = R_list_grf_dhondt2024_3seg;
% 
% % GRFs, RMSE
% metrics.ground_reaction.weighted.RMSE.personal = rmse_list_grf_personal;
% metrics.ground_reaction.weighted.RMSE.generic = rmse_list_grf_generic;
% metrics.ground_reaction.weighted.RMSE.dhondt2024_3seg = rmse_list_grf_dhondt2024_3seg;
% 
% % EMG, R
% metrics.muscle_activations.weighted.R.personal = R_list_emg_personal;
% metrics.muscle_activations.weighted.R.generic = R_list_emg_generic;
% metrics.muscle_activations.weighted.R.dhondt2024_3seg = R_list_emg_dhondt2024_3seg;
% 
% % save metrics
% save("metrics.mat", "metrics")

%% Perform T-Tests for Sagittal Plane Peaks (Personal)
isJointAngle = contains(kinColHeaders,"ankle_angle");
[hListAnklePlantar, pListAnklePlantar, ~, ~, dzListAnklePlantar, deltaListAvgAnklePlantar, deltaListStdAnklePlantar] = perform_ttest_kin(PersonalKinDataShifted, PersonalKinDataWeightedShifted, isJointAngle, -1, 50:Ndata, NSUBJ);
[hListAnkleDorsi, pListAnkleDorsi, ~, ~, dzListAnkleDorsi, deltaListAvgAnkleDorsi, deltaListStdAnkleDorsi] = perform_ttest_kin(PersonalKinDataShifted, PersonalKinDataWeightedShifted, isJointAngle, 1, [], NSUBJ);

includeAnklePlantar = hListAnklePlantar & dzListAnklePlantar>1;
includeAnkleDorsi = hListAnkleDorsi & dzListAnkleDorsi>1;

isJointAngle = contains(kinColHeaders,"knee_angle");
[hListKneeFlex, pListKneeFlex, ~, ~, dzListKneeFlex, deltaListAvgKneeFlex, deltaListStdKneeFlex] = perform_ttest_kin(PersonalKinDataShifted, PersonalKinDataWeightedShifted, isJointAngle, -1, [], NSUBJ);

includeKneeFlex = hListKneeFlex & dzListKneeFlex>1;

isJointAngle = contains(kinColHeaders,"hip_flexion");
[hListHipFlex, pListHipFlex, ~, ~, dzListHipFlex, deltaListAvgHipFlex, deltaListStdHipFlex] = perform_ttest_kin(PersonalKinDataShifted, PersonalKinDataWeightedShifted, isJointAngle, 1, [], NSUBJ);
[hListHipExt, pListHipExt, ~, ~, dzListHipExt, deltaListAvgHipExt, deltaListStdHipExt] = perform_ttest_kin(PersonalKinDataShifted, PersonalKinDataWeightedShifted, isJointAngle, -1, [], NSUBJ);

includeHipFlex = hListHipFlex & dzListHipFlex>1;
includeHipExt = hListHipExt & dzListHipExt>1;

%% Perform T-Tests for Sagittal Plane Peaks (Generic)
isJointAngle = contains(kinColHeaders,"ankle_angle");
[hListAnklePlantar_generic, pListAnklePlantar_generic, ~, ~, dzListAnklePlantar_generic, deltaListAvgAnklePlantar_generic, deltaListStdAnklePlantar_generic] = perform_ttest_kin(GenericKinDataShifted, GenericKinDataWeightedShifted, isJointAngle, -1, 50:Ndata, NSUBJ);
[hListAnkleDorsi_generic, pListAnkleDorsi_generic, ~, ~, dzListAnkleDorsi_generic, deltaListAvgAnkleDorsi_generic, deltaListStdAnkleDorsi_generic] = perform_ttest_kin(GenericKinDataShifted, GenericKinDataWeightedShifted, isJointAngle, 1, [], NSUBJ);

includeAnklePlantar_generic = hListAnklePlantar_generic & dzListAnklePlantar_generic>1;
includeAnkleDorsi_generic = hListAnkleDorsi_generic & dzListAnkleDorsi_generic>1;

isJointAngle = contains(kinColHeaders,"knee_angle");
[hListKneeFlex_generic, pListKneeFlex_generic, ~, ~, dzListKneeFlex_generic, deltaListAvgKneeFlex_generic, deltaListStdKneeFlex_generic] = perform_ttest_kin(GenericKinDataShifted, GenericKinDataWeightedShifted, isJointAngle, -1, [], NSUBJ);

includeKneeFlex_generic = hListKneeFlex_generic & dzListKneeFlex_generic>1;

isJointAngle = contains(kinColHeaders,"hip_flexion");
[hListHipFlex_generic, pListHipFlex_generic, ~, ~, dzListHipFlex_generic, deltaListAvgHipFlex_generic, deltaListStdHipFlex_generic] = perform_ttest_kin(GenericKinDataShifted, GenericKinDataWeightedShifted, isJointAngle, 1, [], NSUBJ);
[hListHipExt_generic, pListHipExt_generic, ~, ~, dzListHipExt_generic, deltaListAvgHipExt_generic, deltaListStdHipExt_generic] = perform_ttest_kin(GenericKinDataShifted, GenericKinDataWeightedShifted, isJointAngle, -1, [], NSUBJ);

includeHipFlex_generic = hListHipFlex_generic & dzListHipFlex_generic>1;
includeHipExt_generic = hListHipExt_generic & dzListHipExt_generic>1;

%% Perform T-Test for Lumbar Bending
isJointAngle = contains(kinColHeaders,"lumbar_bending"); 
[hListLumbarBendPos, pListLumbarBendPos, ~, ~, dzListLumbarBendPos, deltaListAvgLumbarBendPos, deltaListStdLumbarBendPos] = perform_ttest_kin(PersonalKinDataShifted, PersonalKinDataWeightedShifted, isJointAngle, 1, 1:50, NSUBJ);
[hListLumbarBendNeg, pListLumbarBendNeg, ~, ~, dzListLumbarBendNeg, deltaListAvgLumbarBendNeg, deltaListStdLumbarBendNeg] = perform_ttest_kin(PersonalKinDataShifted, PersonalKinDataWeightedShifted, isJointAngle, -1, 50:Ndata, NSUBJ);

%% Save TTest Results for Kinematics
% sagittal plane 
statsSummaryKin.version = datetime("now","Format","d-MM-y");
statsSummaryKin = save_stats(statsSummaryKin, "ankle_peak_plantar", pListAnklePlantar, dzListAnklePlantar, deltaListAvgAnklePlantar, deltaListStdAnklePlantar);
statsSummaryKin = save_stats(statsSummaryKin, "ankle_peak_dorsi", pListAnkleDorsi, dzListAnkleDorsi, deltaListAvgAnkleDorsi, deltaListStdAnkleDorsi);
statsSummaryKin = save_stats(statsSummaryKin, "knee_peak_flexion", pListKneeFlex, dzListKneeFlex, deltaListAvgKneeFlex, deltaListStdKneeFlex);
statsSummaryKin = save_stats(statsSummaryKin, "hip_peak_flexion", pListHipFlex, dzListHipFlex, deltaListAvgHipFlex, deltaListStdHipFlex);
statsSummaryKin = save_stats(statsSummaryKin, "hip_peak_extension", pListHipExt, dzListHipExt, deltaListAvgHipExt, deltaListStdHipExt);
statsSummaryKin = save_stats(statsSummaryKin, "lumbar_peak_bending_pos", pListLumbarBendPos, dzListLumbarBendPos, deltaListAvgLumbarBendPos, deltaListStdLumbarBendPos);
statsSummaryKin = save_stats(statsSummaryKin, "lumbar_peak_bending_neg", pListLumbarBendNeg, dzListLumbarBendNeg, deltaListAvgLumbarBendNeg, deltaListStdLumbarBendNeg);

%% Perform TTest EMG
statsSummaryEMG.version = datetime("now","Format","d-MM-y");

for i = 1:Nemgcol/2
    isEMG = contains(EMGColHeaders,strrep(EMGColHeaders(i),"_r",""));
    [hList, pList, ~, ~, dzList, deltaListAvg, deltaListStd] = perform_ttest_kin(PersonalEmgData, PersonalEmgDataWeighted, isEMG, 1, [], NSUBJ);
    statsSummaryEMG = save_stats(statsSummaryEMG, strrep(EMGColHeaders(i),"_r","") + "_peak", pList, dzList, deltaListAvg, deltaListStd);
end

%% Print Statistics Results
% print_struct_latex(statsSummaryKin, "version", "p", [], ["1 kg", "2 kg", "3 kg", "4 kg", "5 kg"], 0.05, -1, '%.4f')
% print_struct_latex(statsSummaryKin, "version", "dz", [], ["1 kg", "2 kg", "3 kg", "4 kg", "5 kg"], 1, 1, '%.4f')
% print_struct_latex(statsSummaryEMG, "version", "p", [], ["1 kg", "2 kg", "3 kg", "4 kg", "5 kg"], 0.05, -1, '%.4f')
% print_struct_latex(statsSummaryEMG, "version", "dz", [], ["1 kg", "2 kg", "3 kg", "4 kg", "5 kg"], 1, 1, '%.4f')

% print_struct_latex(statsSummaryKin, "version", "delta", "std", ["1 kg", "2 kg", "3 kg", "4 kg", "5 kg"], 100, 1, [])
print_struct_latex(statsSummaryEMG, "version", "delta", "std", ["1 kg", "2 kg", "3 kg", "4 kg", "5 kg"], 100, 1, [])

%% Split Labels
isTrans = contains(kinColHeaders,"pelvis_tx") | contains(kinColHeaders,"pelvis_ty") | contains(kinColHeaders,"pelvis_tz");
kinLabels = repmat("[°]",Nkincol,1); kinLabels(isTrans) = "[m]";
grfLabels = repmat("Force [N]", Ngrfcol, 1);
kitLabels = repmat("Joint Moment [Nm]", Nkincol, 1); kitLabels(isTrans) = "Joint Force [N]";
emgLabels = repmat("Activation [-]", Nemgcol, 1);

jointNames = extractBefore(kinColHeaders,"_"); jointNames = strcat(upper(extractBefore(jointNames,2)), extractAfter(jointNames,1));
kitLabels = jointNames + " " + kitLabels;

muscleNames = extractBefore(EMGColHeaders,"_"); muscleNames = strcat(upper(extractBefore(muscleNames,2)), extractAfter(muscleNames,1));
emgLabelsLim = emgLabels(isLimEMG>0);

%% Add Labels Directions
kinLabelsExt = strings(Nkincol,2); kinLabelsExt(:,1) = kinLabels;
emgLabelsExt = strings(NemgcolLim,2); emgLabelsExt(:,1) = emgLabelsLim;

leftArrow = "(-)";
rightArrow = "(+)";

% ankle
isAnkle = contains(kinColHeaders,"ankle_angle");
kinLabelsExt(isAnkle,:) = [kinLabelsExt(isAnkle,1), repmat("plantar flexion (-) / dorsiflexion (+)",2,1)]; 

% knee
isKnee = contains(kinColHeaders,"knee_angle");
kinLabelsExt(isKnee,:) = [kinLabelsExt(isKnee,1), repmat("flexion (-) / extension (+)",2,1)]; 

% hip
isHip = contains(kinColHeaders,"hip_flexion");
kinLabelsExt(isHip,:) = [kinLabelsExt(isHip,1), repmat("extension (-) / flexion (+)",2,1)]; 

%% Plot Kinematics Results (Personal)
% find max anke plantar/dorsi
isAnkleR = contains(kinColHeaders,"ankle_angle_r");
maxAnkleDorsi = NaN(Nweights+1,1); maxAnkleDorsiIdx = NaN(Nweights+1);
maxAnklePlantar = NaN(Nweights+1,1); maxAnklePlantarIdx = NaN(Nweights+1);
[maxAnkleDorsi(1),maxAnkleDorsiIdx(1)] = max(PersonalKinDataAvg(:,isAnkleR));
[maxAnklePlantar(1),maxAnklePlantarIdx(1)] = max(PersonalKinDataAvg(:,isAnkleR)*-1);

% find max knee flexion
isKneeR = contains(kinColHeaders,"knee_angle_r");
maxKneeFlex = NaN(Nweights+1,1); maxKneeFlexIdx = NaN(Nweights+1);
[maxKneeFlex(1),maxKneeFlexIdx(1)] = max(PersonalKinDataAvg(:,isKneeR)*-1);

% find max hip flexion
isHipR = contains(kinColHeaders,"hip_flexion_r");
maxHipFlex = NaN(Nweights+1,1); maxHipFlexIdx = NaN(Nweights+1);
maxHipExt = NaN(Nweights+1,1); maxHipExtIdx = NaN(Nweights+1);
[maxHipFlex(1),maxHipFlexIdx(1)] = max(PersonalKinDataAvg(:,isHipR));
[maxHipExt(1),maxHipExtIdx(1)] = max(PersonalKinDataAvg(:,isHipR)*-1);

for i = 1:Nweights
    [maxKneeFlex(i+1),maxKneeFlexIdx(i+1)] = max(WeightedWalkingPersonalKinAvg(:,isKneeR,:,i)*-1);
    [maxHipFlex(i+1),maxHipFlexIdx(i+1)] = max(WeightedWalkingPersonalKinAvg(:,isHipR,:,i));
    [maxHipExt(i+1),maxHipExtIdx(i+1)] = max(WeightedWalkingPersonalKinAvg(:,isHipR,:,i)*-1);
    [maxAnkleDorsi(i+1),maxAnkleDorsiIdx(i+1)] = max(WeightedWalkingPersonalKinAvg(:,isAnkleR,:,i));
    [maxAnklePlantar(i+1),maxAnklePlantarIdx(i+1)] = max(WeightedWalkingPersonalKinAvg(:,isAnkleR,:,i)*-1);
end

% define legend text
legendtxt = strings(2*(Nweights+1),1);
legendtxt(2) = "normal";
legendtxt(4:2:end) = string(1:Nweights) + " kg";
color = makeGroupColors(24/360,Nweights+1,1,0.3,0.95)';

% create tiled layout
t = tiledlayout(1,3,"TileSpacing","tight","Padding","tight");
t.InnerPosition = [0.08 0.15 0.75 0.75];
set(gcf,"Units","centimeters")                                              % cm units for position
set(gcf,"Position",[0 0 fig_width*2 fig_height/1.4])                        % IEEE 1-column: 8.89cm

for i = sagittalPlaneCols(1:3)
    nexttile
    hold on
    XaxisLine = plot([0 1],[0 0],"Color","black","LineWidth",0.5);
    plot_mean_std(resampTime,PersonalKinDataAvg(:,i),PersonalKinDataSTD(:,i),color(:,1)', linewidth, "-")
    for j = 1:Nweights
        plot_mean_std(resampTime,WeightedWalkingPersonalKinAvg(:,i,:,j),WeightedWalkingPersonalKinStd(:,i,:,j),color(:,j+1)', linewidth,"-")
    end

    if(isHip(i))
        % draw arrows
        draw_weight_arrow(includeHipExt, Nweights, maxHipExt, deltaListAvgHipExt, -1, color, 0.70, 0.22, 0, 3, 1, 0.02, zeros(Nweights,1))
        draw_weight_arrow(includeHipFlex, Nweights, maxHipFlex, deltaListAvgHipFlex, 1, color, 0.72, 0.15, -0.12, 1, 1, 0.02, zeros(Nweights,1))
        
    elseif(isKnee(i))
        % draw arrows
        draw_weight_arrow(includeKneeFlex, Nweights, maxKneeFlex, deltaListAvgKneeFlex, -1, color, 0.32, 0.2, 0, 4, 1.2, 0.02, zeros(Nweights,1))

    elseif(isAnkle(i))
        % draw arrows
        draw_weight_arrow(includeAnkleDorsi, Nweights, maxAnkleDorsi, deltaListAvgAnkleDorsi, 1, color, 0.15, 0.20, 0, 1, 0.5, 0.02, [0 0 1 0 0;0 0 1 0 0]')
        draw_weight_arrow(includeAnklePlantar, Nweights, maxAnklePlantar, deltaListAvgAnklePlantar, -1, color, 0.15, 0.20, 0, -1, 0.5, 0.02, [0 0 1 0 0;0 0 1 0 0]')
    end

    xlabel("Gait Cycle [-]","FontWeight","bold")
    ylabel(kinLabelsExt(i,:),"FontWeight","bold")
    title(jointNames(i) + " Joint Angle")

    % figure settings
    set(0,"DefaultFigureColor","w")                                         % white background
    set(0,"defaulttextinterpreter","tex")                                   % tex style font
    set(0,"DefaultAxesFontName","SansSerif")                                % times new roman font
    hold off
    axis tight
end

lg = legend([""; legendtxt],"Location","bestoutside");
lg.Layout.Tile = 'East';
lg.Box = "off";

set(findall(t,'-property','FontSize'),'FontSize',8)                         % font size

if(export)
    figName = "personal_gait2128_kin_weightedWalking" + figFileType;
    exportgraphics(t,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
end

%% Plot Kinematics Results (Generic)
% find max anke plantar/dorsi
isAnkleR = contains(kinColHeaders,"ankle_angle_r");
maxAnkleDorsi = NaN(Nweights+1,1); maxAnkleDorsiIdx = NaN(Nweights+1);
maxAnklePlantar = NaN(Nweights+1,1); maxAnklePlantarIdx = NaN(Nweights+1);
[maxAnkleDorsi(1),maxAnkleDorsiIdx(1)] = max(GenericKinDataAvg(:,isAnkleR));
[maxAnklePlantar(1),maxAnklePlantarIdx(1)] = max(GenericKinDataAvg(:,isAnkleR)*-1);

% find max knee flexion
isKneeR = contains(kinColHeaders,"knee_angle_r");
maxKneeFlex = NaN(Nweights+1,1); maxKneeFlexIdx = NaN(Nweights+1);
[maxKneeFlex(1),maxKneeFlexIdx(1)] = max(GenericKinDataAvg(:,isKneeR)*-1);

% find max hip flexion
isHipR = contains(kinColHeaders,"hip_flexion_r");
maxHipFlex = NaN(Nweights+1,1); maxHipFlexIdx = NaN(Nweights+1);
maxHipExt = NaN(Nweights+1,1); maxHipExtIdx = NaN(Nweights+1);
[maxHipFlex(1),maxHipFlexIdx(1)] = max(GenericKinDataAvg(:,isHipR));
[maxHipExt(1),maxHipExtIdx(1)] = max(GenericKinDataAvg(:,isHipR)*-1);

for i = 1:Nweights
    [maxKneeFlex(i+1),maxKneeFlexIdx(i+1)] = max(WeightedWalkingGenericKinAvg(:,isKneeR,:,i)*-1);
    [maxHipFlex(i+1),maxHipFlexIdx(i+1)] = max(WeightedWalkingGenericKinAvg(:,isHipR,:,i));
    [maxHipExt(i+1),maxHipExtIdx(i+1)] = max(WeightedWalkingGenericKinAvg(:,isHipR,:,i)*-1);
    [maxAnkleDorsi(i+1),maxAnkleDorsiIdx(i+1)] = max(WeightedWalkingGenericKinAvg(:,isAnkleR,:,i));
    [maxAnklePlantar(i+1),maxAnklePlantarIdx(i+1)] = max(WeightedWalkingGenericKinAvg(:,isAnkleR,:,i)*-1);
end

% define legend text
legendtxt = strings(2*(Nweights+1),1);
legendtxt(2) = "normal";
legendtxt(4:2:end) = string(1:Nweights) + " kg";
color = makeGroupColors(220/360,Nweights+1,1,0.3,0.9)';

% create tiled layout
t = tiledlayout(1,3,"TileSpacing","tight","Padding","tight");
t.InnerPosition = [0.08 0.15 0.75 0.75];
set(gcf,"Units","centimeters")                                                % cm units for position
set(gcf,"Position",[0 0 fig_width*2 fig_height/1.4])                          % IEEE 1-column: 8.89cm

% for i = 1:Nkincol
for i = sagittalPlaneCols(1:3)
    nexttile
    hold on
    XaxisLine = plot([0 1],[0 0],"Color","black","LineWidth",0.5);
    plot_mean_std(resampTime, GenericKinDataAvg(:,i), GenericKinDataSTD(:,i),color(:,1)', linewidth, "-")
    for j = 1:Nweights
        plot_mean_std(resampTime,WeightedWalkingGenericKinAvg(:,i,:,j),WeightedWalkingGenericKinStd(:,i,:,j),color(:,j+1)', linewidth,"-")
    end

    if(isHip(i))
        % draw arrows
        draw_weight_arrow(includeHipExt_generic, Nweights, maxHipExt, deltaListAvgHipExt_generic, -1, color, 0.70, 0.20, 0, 3, 1, 0.02, zeros(Nweights,1))
        draw_weight_arrow(includeHipFlex_generic, Nweights, maxHipFlex, deltaListAvgHipFlex_generic, 1, color, 0.3, 0.15, -0.1, 1, 1, 0.02, zeros(Nweights,1))
        
    elseif(isKnee(i))
        % draw arrows
        draw_weight_arrow(includeKneeFlex_generic, Nweights, maxKneeFlex, deltaListAvgKneeFlex_generic, -1, color, 0.11, 0.21, 0, 4, 1.2, 0.02, zeros(Nweights,1))

    elseif(isAnkle(i))
        % draw arrows
        draw_weight_arrow(includeAnkleDorsi_generic, Nweights, maxAnkleDorsi, deltaListAvgAnkleDorsi_generic, 1, color, 0.4, 0.2, 0, 1, 0.5, 0.02,zeros(Nweights,1))
        draw_weight_arrow(includeAnklePlantar_generic, Nweights, maxAnklePlantar, deltaListAvgAnklePlantar_generic, -1, color, 0.3, 0.08, 0, -1, 0.5, 0.02, zeros(Nweights,1))
    end

    xlabel("Gait Cycle [-]","FontWeight","bold")
    ylabel(kinLabelsExt(i,:),"FontWeight","bold")
    title(jointNames(i) + " Joint Angle")

    % figure settings
    set(0,"DefaultFigureColor","w")                                         % white background
    set(0,"defaulttextinterpreter","tex")                                   % tex style font
    set(0,"DefaultAxesFontName","SansSerif")                                % times new roman font
    hold off
    axis tight
end

lg = legend([""; legendtxt],"Location","bestoutside");
lg.Layout.Tile = 'East';
lg.Box = "off";

set(findall(t,'-property','FontSize'),'FontSize',8)                         % font size

if(export)
    figName = "generic_gait2128_kin_weightedWalking" + figFileType;
    exportgraphics(t,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
end

%% Plot GRF Results
for i = 1:Ngrfcol
    fig = figure;
    set(gcf,"Units","centimeters")                                          % cm units for position
    set(gcf,"Position",[0 0 fig_width fig_height])                          % IEEE 1-column: 8.89cm
    grid on
    hold on
    plot_mean_std(resampTime,PersonalGRFDataAvg(:,i),PersonalGRFDataSTD(:,i),color(:,1)', 1, "-")
    for j = 1:Nweights
        plot_mean_std(resampTime,WeightedWalkingPersonalGrfAvg(:,i,:,j),WeightedWalkingPersonalGrfStd(:,i,:,j),color(:,j)', 1, "-")
    end
    legend(legendtxt,"Location","bestoutside")
    xlabel("Gait Cycle [-]")
    ylabel(grfLabels(i))

    % figure settings
    set(findall(fig,'-property','FontSize'),'FontSize',8)                   % font size
    set(0,"DefaultFigureColor","w")                                         % white background
    set(0,"defaulttextinterpreter","tex")                                   % tex style font
    set(0,"DefaultAxesFontName","Helvetica")                                % times new roman font
    set(gca,"Units","centimeters")                                          % cm units for position
    set(gca,"Position",[1 0.8 fig_width-3.5 fig_height-1.5])                % axes position (x, y, w, h)
    hold off
    axis tight

    if(export)
        figName = "personal_gait1422_grf_weightedWalking_" + GRFColHeaders(i) + figFileType;
        exportgraphics(fig,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
    end
end

%% Plot Kinetics Results
for i = sagittalPlaneCols
    fig = figure;
    set(gcf,"Units","centimeters")                                          % cm units for position
    set(gcf,"Position",[0 0 fig_width fig_height])                          % IEEE 1-column: 8.89cm
    grid on
    hold on
    plot_mean_std(resampTime,PersonalKitDataAvg(:,i),PersonalKitDataSTD(:,i),color(:,1)', 1,"-")
    for j = 1:Nweights
        plot_mean_std(resampTime,WeightedWalkingPersonalKitAvg(:,i,:,j),WeightedWalkingPersonalKitStd(:,i,:,j),color(:,j)', 1, "-")
    end
    legend(legendtxt,"Location","bestoutside")
    xlabel("Gait Cycle [-]")
    ylabel(kitLabels(i))

    % figure settings
    set(findall(fig,'-property','FontSize'),'FontSize',8)                   % font size
    set(0,"DefaultFigureColor","w")                                         % white background
    set(0,"defaulttextinterpreter","tex")                                   % tex style font
    set(0,"DefaultAxesFontName","Helvetica")                                % times new roman font
    set(gca,"Units","centimeters")                                          % cm units for position
    set(gca,"Position",[1 0.8 fig_width-3.5 fig_height-1.5])                % axes position (x, y, w, h)
    hold off
    axis tight

    if(export)
        figName = "personal_gait1422_kit_weightedWalking_" + kinColHeaders(i) + "_moment" + figFileType;
        exportgraphics(fig,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
    end
end

%% Plot EMG Results
% color
color = makeGroupColors(24/360,Nweights+1,1,0.3,0.95)';

% labels
muscleNamesPlot = ["", "", "", "Vasti", "Gastrocnemius", "Soleus"];

t = tiledlayout(1,3,"TileSpacing","tight","Padding","tight");
t.InnerPosition = [0.08 0.15 0.75 0.75];
set(gcf,"Units","centimeters")                                          % cm units for position
set(gcf,"Position",[0 0 fig_width*2 fig_height/1.7])                          % IEEE 1-column: 8.89cm

for i = 4:6
    legendtxt = [];
    nexttile
    hold on
    emgLeg1 = plot_emg_active(resampTime, normalWalkingEMGavgLim(:,i), 0.15, color(:,1)', 0.98, 1);
    plot_mean_std(resampTime,PersonalEmgDataAvg(:,i),PersonalEmgDataSTD(:,i),color(:,1)', linewidth, "-")

    % update legend
    legendtxt = [legendtxt strings(1,length(emgLeg1)) "" "normal"];
    for j = 1:Nweights
        emgLeg2 = plot_emg_active(resampTime, weightedWalkingEMGavgLim(:,i,j), 0.15, color(:,j+1)', 0.98-0.02*j, 1-0.02*j);
        plot_mean_std(resampTime,WeightedWalkingPersonalEmgAvg(:,i,:,j),WeightedWalkingPersonalEmgStd(:,i,:,j),color(:,j+1)', linewidth, "-")
        legendtxt = [legendtxt strings(1,length(emgLeg2)) "" num2str(j) + " kg"];
    end
    xlabel("Gait Cycle [-]","FontWeight","bold")
    ylabel(emgLabelsExt(i,:),"FontWeight","bold")
    title(muscleNamesPlot(i),"FontWeight","bold")
    ylim([0 1])

    % figure settings
    set(0,"DefaultFigureColor","w")                                         % white background
    set(0,"defaulttextinterpreter","tex")                                   % tex style font
    set(0,"DefaultAxesFontName","SansSerif")                                % times new roman font
    hold off
end

lg = legend(legendtxt,"Location","bestoutside");
lg.Layout.Tile = 'East';
lg.Box = "off"; 
set(findall(t,'-property','FontSize'),'FontSize',8)                         % font size

if(export)
    figName = "personal_gait2128_emg_weightedWalking" + figFileType;
    exportgraphics(t,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
end

%% Plot EMG Results
% color
color = makeGroupColors(24/360,Nweights+1,1,0.3,0.95)';

% labels
muscleNamesPlot = ["Hamstrings", "Biceps Femoris", "Rectus Femoris", "", "", ""];

t = tiledlayout(1,3,"TileSpacing","tight","Padding","tight");
t.InnerPosition = [0.08 0.15 0.75 0.75];
set(gcf,"Units","centimeters")                                          % cm units for position
set(gcf,"Position",[0 0 fig_width*2 fig_height/1.7])                          % IEEE 1-column: 8.89cm

for i = 1:3
    legendtxt = [];
    nexttile
    hold on
    emgLeg1 = plot_emg_active(resampTime, normalWalkingEMGavgLim(:,i), 0.05, color(:,1)', 0.98, 1);
    plot_mean_std(resampTime,PersonalEmgDataAvg(:,i),PersonalEmgDataSTD(:,i),color(:,1)', linewidth, "-")

    % update legend
    legendtxt = [legendtxt strings(1,length(emgLeg1)) "" "normal"];
    for j = 1:Nweights
        emgLeg2 = plot_emg_active(resampTime, weightedWalkingEMGavgLim(:,i,j), 0.05, color(:,j+1)', 0.98-0.02*j, 1-0.02*j);
        plot_mean_std(resampTime,WeightedWalkingPersonalEmgAvg(:,i,:,j),WeightedWalkingPersonalEmgStd(:,i,:,j),color(:,j+1)', linewidth, "-")
        legendtxt = [legendtxt strings(1,length(emgLeg2)) "" num2str(j) + " kg"];
    end
    xlabel("Gait Cycle [-]","FontWeight","bold")
    ylabel(emgLabelsExt(i,:),"FontWeight","bold")
    title(muscleNamesPlot(i),"FontWeight","bold")
    ylim([0 1])

    % figure settings
    set(0,"DefaultFigureColor","w")                                         % white background
    set(0,"defaulttextinterpreter","tex")                                   % tex style font
    set(0,"DefaultAxesFontName","SansSerif")                                % times new roman font
    hold off
end

lg = legend(legendtxt,"Location","bestoutside");
lg.Layout.Tile = 'East';
lg.Box = "off"; 
set(findall(t,'-property','FontSize'),'FontSize',8)                         % font size

if(export)
    figName = "personal_gait2128_emg_weightedWalking_2" + figFileType;
    exportgraphics(t,figName,"ContentType","vector","Resolution",300,"BackgroundColor","none")
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


function WalkingKneeMaxAvg = compute_peak_knee_flex_exp(expData, SUBJID, isKneeFlexion, weight, Ntrials, sign)
% returns peak knee flexion angle, averaged over left/right

    WalkingKneeMaxAvg = NaN(1,Ntrials);
    if(weight == "Normal")
        % normal walking peak knee flexion
        normalWalkingKin = expData.data.("SUBJ" + SUBJID).kinematics.IkdataNormal;
        normalWalkingKneeKin = normalWalkingKin(:,isKneeFlexion,:)*sign;
        WalkingKneeMaxLR = max(normalWalkingKneeKin);
        NtrialsSUBJ = size(WalkingKneeMaxLR,3);
        WalkingKneeMaxAvg(1:NtrialsSUBJ) = mean(WalkingKneeMaxLR,2);
    else
        % normal walking peak knee flexion
        weightedWalkingKin = expData.data.("SUBJ" + SUBJID).kinematics.("IkdataWeighted" + weight);
        weightedWalkingKneeKin = weightedWalkingKin(:,isKneeFlexion,:)*sign;
        WalkingKneeMaxLR = max(weightedWalkingKneeKin);
        NtrialsSUBJ = size(WalkingKneeMaxLR,3);
        WalkingKneeMaxAvg(1:NtrialsSUBJ) = mean(WalkingKneeMaxLR,2);
    end

    WalkingKneeMaxAvg = WalkingKneeMaxAvg(1:Ntrials);

end

function WalkingKneeMax = compute_peak_knee_flex_sim(KinData, isKneeFlexion, subjID)
% returns peak knee flexion angle, averaged over left/right

    Nworkers = size(KinData,4);
    WalkingKneeMax = NaN(1,Nworkers);

    for i = 1:Nworkers
        if(~isnan(KinData(:,:,subjID,i)))
            WalkingKneeKin = KinData(:,isKneeFlexion,subjID,i);
            WalkingKneeMax(i) = mean(max(WalkingKneeKin*-1));
        end
    end

end

function WalkingKneeRed = compute_peek_knee_flex_red(normalData, weightedData)

    WalkingKneeRed = (normalData-weightedData)./normalData*100;

end

function [KinData, GrfData, KitData, EmgData, IdxHeelL, CostData] = choose_lowest_cost(...
    KinDataTrackIG, GrfDataTrackIG, KitDataTrackIG, EmgDataTrackIG, IdxHeelLTrackIG, CostDataTrackIG,...
    KinDataExpIG, GrfDataExpIG, KitDataExpIG, EmgDataExpIG, IdxHeelLExpIG, CostDataExpIG)

    % Choose solution with lowest cost function value
    isExpIGlower = CostDataExpIG < CostDataTrackIG;
    
    KinData = KinDataTrackIG;
    GrfData = GrfDataTrackIG;
    KitData = KitDataTrackIG;
    EmgData = EmgDataTrackIG;
    IdxHeelL = IdxHeelLTrackIG;
    CostData = CostDataTrackIG;

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
                CostData(i,j) = CostDataExpIG(i,j);
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
            Dhondt2024_3segDataWeightedShifted(:,conditionBool,i,j) = circshift(Dhondt2024_3segDataWeightedShifted(:,conditionBool,i,j),-Dhondt2024_3segIdxHeelLWeighted(i,j),1);
        end
    end
end

function [hList, pList, ciList, statsList, dzList, deltaListAvg, deltaListStd] = perform_ttest_kin(normalData, weightedData, isJointAngle, sign, IdxRange, NSUBJ)
    %% Define variables

    %% Store data
    normalWalkingJoint = normalData(:,isJointAngle,:);
    WeightedWalking1kgJoint = weightedData(:,isJointAngle,:,1);
    WeightedWalking2kgJoint = weightedData(:,isJointAngle,:,2);
    WeightedWalking3kgJoint = weightedData(:,isJointAngle,:,3);
    WeightedWalking4kgJoint = weightedData(:,isJointAngle,:,4);
    WeightedWalking5kgJoint = weightedData(:,isJointAngle,:,5);

    %% Compute Max
    normalWalkingJointMax = compute_peak_joint(normalWalkingJoint, sign, IdxRange);
    WeightedWalking1kgJointMax = compute_peak_joint(WeightedWalking1kgJoint, sign, IdxRange);
    WeightedWalking2kgJointMax = compute_peak_joint(WeightedWalking2kgJoint, sign, IdxRange);
    WeightedWalking3kgJointMax = compute_peak_joint(WeightedWalking3kgJoint, sign, IdxRange);
    WeightedWalking4kgJointMax = compute_peak_joint(WeightedWalking4kgJoint, sign, IdxRange);
    WeightedWalking5kgJointMax = compute_peak_joint(WeightedWalking5kgJoint, sign, IdxRange);

    %% Compute Mean Over Trials Per Subject
    normalWalkingJointMaxPerSUBJ = mean(normalWalkingJointMax,2,"omitnan");
    WeightedWalking1kgJointMaxPerSUBJ = mean(WeightedWalking1kgJointMax,2,"omitnan");
    WeightedWalking2kgJointMaxPerSUBJ = mean(WeightedWalking2kgJointMax,2,"omitnan");
    WeightedWalking3kgJointMaxPerSUBJ = mean(WeightedWalking3kgJointMax,2,"omitnan");
    WeightedWalking4kgJointMaxPerSUBJ = mean(WeightedWalking4kgJointMax,2,"omitnan");
    WeightedWalking5kgJointMaxPerSUBJ = mean(WeightedWalking5kgJointMax,2,"omitnan");

    %% Perform TTest
    [h1, p1, CI1, stats1, dz1, delta1kgAvg, delta1kgStd] = perform_ttest(normalWalkingJointMaxPerSUBJ, WeightedWalking1kgJointMaxPerSUBJ, NSUBJ);
    [h2, p2, CI2, stats2, dz2, delta2kgAvg, delta2kgStd] = perform_ttest(normalWalkingJointMaxPerSUBJ, WeightedWalking2kgJointMaxPerSUBJ, NSUBJ);
    [h3, p3, CI3, stats3, dz3, delta3kgAvg, delta3kgStd] = perform_ttest(normalWalkingJointMaxPerSUBJ, WeightedWalking3kgJointMaxPerSUBJ, NSUBJ);
    [h4, p4, CI4, stats4, dz4, delta4kgAvg, delta4kgStd] = perform_ttest(normalWalkingJointMaxPerSUBJ, WeightedWalking4kgJointMaxPerSUBJ, NSUBJ);
    [h5, p5, CI5, stats5, dz5, delta5kgAvg, delta5kgStd] = perform_ttest(normalWalkingJointMaxPerSUBJ, WeightedWalking5kgJointMaxPerSUBJ, NSUBJ);

    %% Combine Delta
    % average
    deltaListAvg = [delta1kgAvg, delta2kgAvg, delta3kgAvg, delta4kgAvg, delta5kgAvg];
    deltaListStd = [delta1kgStd, delta2kgStd, delta3kgStd, delta4kgStd, delta5kgStd];
    
    %% Combine Statistics
    hList = [h1, h2, h3, h4, h5];
    pList = [p1, p2, p3, p4, p5];
    ciList = [CI1, CI2, CI3, CI4, CI5];
    statsList = [stats1, stats2, stats3, stats4, stats5];
    dzList = abs([dz1, dz2, dz3, dz4, dz5]);

end

function WalkingMaxAvg = compute_peak_joint(data, sign, IdxRange)
% returns peak knee flexion angle, averaged over left/right
    
    if(isempty(IdxRange))
        IdxRange = 1:size(data,1);
    end
    
    % compute max over trials
    WalkingKneeMaxLR = max(data(IdxRange,:,:,:)*sign,[],1);
    WalkingMaxAvg = squeeze(mean(WalkingKneeMaxLR,2));

end

function [h, p, ci, stats, dz, deltaAvg, deltaStd] = perform_ttest(data1, data2, NSUBJ)
    %% Compute Delta
    % average
    deltaAvg = mean(data2-data1,"omitnan");

    % std
    deltaStd = std(data2-data1,"omitnan");
    
    %% Evaluate Significant Personal Simulation Reductions
    % paired t-test for 2 recordings of the same subjects in different conditions
    % h = 1 indicates significant difference in population means
    [h,p,ci,stats] = ttest(data1, data2,"Alpha", 0.05);

    % Cohen's dz 
    % represents mean change between conditions, scaled by inter-subject variability
    % larger than 1 indicates large changes
    dz = stats.tstat/sqrt(NSUBJ);
end

function draw_weight_arrow(includeBool, Nweights, peakVal, deltaList, sign, color, xstart, xstep, xcorr, ycorr, alpha, beta, spaceVec)
    % draw arrows
    % plot([0.1 resampTime(maxKneeFlexIdx(1))],[maxKneeFlex(1)*-1 maxKneeFlex(1)*-1],'k--','LineWidth',0.5)

    inclCnt = 0;

    for j = 1:Nweights
        if(includeBool(j))
        % plot([0.1+0.15*(j-2) resampTime(maxKneeFlexIdx(j+1))],[maxKneeFlex(j+1)*-1 maxKneeFlex(j+1)*-1],'k--','LineWidth',0.5)
        
        draw_arrow(xstart+xstep*inclCnt, xstart+xstep*inclCnt,peakVal(1)*sign, peakVal(j+1)*sign, alpha, beta, color(:,j+1)')
        text(xstart+xstep*inclCnt+xcorr,peakVal(j+1)*sign+ycorr,num2str(round(deltaList(j),2))+"°",...
            "HorizontalAlignment","center","Color",color(:,j+1)')

        inclCnt = inclCnt + 1;
        end

        if(spaceVec(j,1))
           inclCnt = inclCnt + spaceVec(j,2);
        end
    end

end

