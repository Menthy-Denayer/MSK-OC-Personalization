% --------------------------------------------------------------------------
% compareMeshSensitivity
%   Compare all solutions at N = 50 and N = 100 mesh points
%
% Original author: Menthy Denayer
% Original date: 21/Oct/2026
%
% Last edit by: Menthy Denayer
% Last edit date: 25/Oct/2026
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
resampTime = 0:0.01:1;

Nweights = 5; 
N50_subFolder = "50Meshes";
N100_subFolder = "100Meshes";

personalKeyWords = "opt3D";
genericKeyWords = "mtu3D";
weightedKeyWords = "worker";
dhondt2024_3segKeyWords = "Dhondt2024_3seg";

personal_resultsSubFolder = ["SUBJ04opt3D", "SUBJ06opt3D", "SUBJ07opt3D", "SUBJ09opt3D", "SUBJ10opt3D", "SUBJ11opt3D"];
generic_resultsSubFolder = ["SUBJ04mtu3D", "SUBJ06mtu3D", "SUBJ07mtu3D", "SUBJ09mtu3D", "SUBJ10mtu3D", "SUBJ11mtu3D"];
dhondt2024_3segSubFolders = ["SUBJ04_Dhondt2024_3seg", "SUBJ06_Dhondt2024_3seg", "SUBJ07_Dhondt2024_3seg", "SUBJ09_Dhondt2024_3seg", "SUBJ10_Dhondt2024_3seg", "SUBJ11_Dhondt2024_3seg"];

simIGsubFolderPersonal_N50 = personal_resultsSubFolder + "/" + N50_subFolder + "/weighted-simIG";
expIGsubFolderPersonal_N50 = personal_resultsSubFolder + "/" + N50_subFolder + "/weighted-expIG";
simIGsubFolderGeneric_N50 = generic_resultsSubFolder + "/" + N50_subFolder + "/weighted-simIG";
expIGsubFolderGeneric_N50 = generic_resultsSubFolder + "/" + N50_subFolder + "/weighted-expIG";
simIGsubFolderDhondt2024_3seg_N50 = dhondt2024_3segSubFolders + "/" + N50_subFolder + "/weighted-simIG";
expIGsubFolderDhondt2024_3seg_N50 = dhondt2024_3segSubFolders + "/" + N50_subFolder + "/weighted-expIG";

simIGsubFolderPersonal_N100 = personal_resultsSubFolder + "/" + N100_subFolder + "/weighted-simIG-N100";
expIGsubFolderPersonal_N100 = personal_resultsSubFolder + "/" + N100_subFolder + "/weighted-expIG-N100";
simIGsubFolderGeneric_N100 = generic_resultsSubFolder + "/" + N100_subFolder + "/weighted-simIG-N100";
expIGsubFolderGeneric_N100 = generic_resultsSubFolder + "/" + N100_subFolder + "/weighted-expIG-N100";
simIGsubFolderDhondt2024_3seg_N100 = dhondt2024_3segSubFolders + "/" + N100_subFolder + "/weighted-simIG-N100";
expIGsubFolderDhondt2024_3seg_N100 = dhondt2024_3segSubFolders + "/" + N100_subFolder + "/weighted-expIG-N100";

%% Define Figure Settings
fig_height = 8.89;  % cm
fig_width = 8.89;   % cm
export = false;
figFileType = ".jpg";
linewidth = 1.5;
colors = [[0,0,0]; [0,51,153]/255; [255,102,0]/255; [51,155,155]/255];

%% General Variables
Ndata = length(resampTime);
Nkincol = 19;
Ngrfcol = 6;
Nemgcol = 28;

%% Load Results
resultsDIR = uigetdir("..\..\..\results\","Choose solution directory");

%% Choose Desired Tracking Folders
ResultsFolders = find_desired_folders(resultsDIR, SUBJID);

%% Load Normal Walking Results
% Load coarse mesh results (N = 50)
[PersonalKinData, PersonalGrfData, PersonalKitData, PersonalEmgData,~, bodyMass,PersonalCostData,~, kinColHeaders, grfColHeaders, emgColHeaders] = average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, resultsDIR, ResultsFolders, personal_resultsSubFolder + "/" + N50_subFolder, personalKeyWords, 1);
[GenericKinData, GenericGrfData, GenericKitData, GenericEmgData,~, ~,GenericCostData,~, ~, ~, ~] = average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, resultsDIR, ResultsFolders, generic_resultsSubFolder + "/" + N50_subFolder, genericKeyWords, 1);
[Dhondt2024_3segKinData, Dhondt2024_3segGrfData, Dhondt2024_3segKitData, Dhondt2024_3segEmgData,~,~,Dhondt2024_3segCostData,~,Dhondt2024_3segkinColHeaders,~,Dhondt2024_3segEmgColHeaders] = average_results(resampTime, 29, Ngrfcol, 92, resultsDIR, ResultsFolders, dhondt2024_3segSubFolders + "/" + N50_subFolder, dhondt2024_3segKeyWords, 1);

% Load fine mesh results (N = 100)
[PersonalKinData_N100, PersonalGrfData_N100, PersonalKitData_N100, PersonalEmgData_N100,~,~,PersonalCostData_N100,~,~,~,~] = average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, resultsDIR, ResultsFolders, personal_resultsSubFolder + "/" + N100_subFolder, personalKeyWords, 1);
[GenericKinData_N100, GenericGrfData_N100, GenericKitData_N100, GenericEmgData_N100,~, ~,GenericCostData_N100,~, ~, ~, ~] = average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, resultsDIR, ResultsFolders, generic_resultsSubFolder + "/" + N100_subFolder, genericKeyWords, 1);
[Dhondt2024_3segKinData_N100, Dhondt2024_3segGrfData_N100, Dhondt2024_3segKitData_N100, Dhondt2024_3segEmgData_N100,~,~, Dhondt2024_3segCostData_N100,~,~,~,~] = average_results(resampTime, 29, Ngrfcol, 92, resultsDIR, ResultsFolders, dhondt2024_3segSubFolders + "/" + N100_subFolder, dhondt2024_3segKeyWords, 1);

%% Load Weighted Walking Results (Exp IG)
% Load coarse mesh results (N = 50)
[PersonalKinDataWeightedExpIG, PersonalGrfDataWeightedExpIG, PersonalKitDataWeightedExpIG, PersonalEmgDataWeightedExpIG,~, ~,PersonalCostDataWeightedExpIG,~, ~, ~, ~] = average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, resultsDIR, ResultsFolders, expIGsubFolderPersonal_N50, weightedKeyWords, Nweights);
[GenericKinDataWeightedExpIG, GenericGrfDataWeightedExpIG, GenericKitDataWeightedExpIG, GenericEmgDataWeightedExpIG,~, ~,GenericCostDataWeightedExpIG,~, ~, ~, ~] = average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, resultsDIR, ResultsFolders, expIGsubFolderGeneric_N50, weightedKeyWords, Nweights);
[Dhondt2024_3segKinDataWeighted, Dhondt2024_3segGrfDataWeighted, Dhondt2024_3segKitDataWeighted, Dhondt2024_3segEmgDataWeighted,~,~,Dhondt2024_3segCostDataWeighted,~,~,~,~] = average_results(resampTime, 29, Ngrfcol, 92, resultsDIR, ResultsFolders, expIGsubFolderDhondt2024_3seg_N50, weightedKeyWords, Nweights);

% Load fine mesh results (N = 100)
[PersonalKinDataWeightedExpIG_N100, PersonalGrfDataWeightedExpIG_N100, PersonalKitDataWeightedExpIG_N100, PersonalEmgDataWeightedExpIG_N100,~,~,PersonalCostDataWeightedExpIG_N100,~,~,~,~] = average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, resultsDIR, ResultsFolders, expIGsubFolderPersonal_N100, weightedKeyWords, Nweights);
[GenericKinDataWeightedExpIG_N100, GenericGrfDataWeightedExpIG_N100, GenericKitDataWeightedExpIG_N100, GenericEmgDataWeightedExpIG_N100,~, ~,GenericCostDataWeightedExpIG_N100,~, ~, ~, ~] = average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, resultsDIR, ResultsFolders, expIGsubFolderGeneric_N100, weightedKeyWords, Nweights);
[Dhondt2024_3segKinDataWeightedExpIG_N100, Dhondt2024_3segGrfDataWeightedExpIG_N100, Dhondt2024_3segKitDataWeightedExpIG_N100, Dhondt2024_3segEmgDataWeightedExpIG_N100,~,~,Dhondt2024_3segCostDataWeightedExpIG_N100,~,~,~,~] = average_results(resampTime, 29, Ngrfcol, 92, resultsDIR, ResultsFolders, expIGsubFolderDhondt2024_3seg_N100, weightedKeyWords, Nweights);

%% Load Weighted Walking Results (Sim IG)
% Load coarse mesh results (N = 50)
[PersonalKinDataWeightedSimIG, PersonalGrfDataWeightedSimIG, PersonalKitDataWeightedSimIG, PersonalEmgDataWeightedSimIG,~, ~,PersonalCostDataWeightedSimIG,~, ~, ~, ~] = average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, resultsDIR, ResultsFolders, simIGsubFolderPersonal_N50, weightedKeyWords, Nweights);
[GenericKinDataWeightedSimIG, GenericGrfDataWeightedSimIG, GenericKitDataWeightedSimIG, GenericEmgDataWeightedSimIG,~, ~,GenericCostDataWeightedSimIG,~, ~, ~, ~] = average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, resultsDIR, ResultsFolders, simIGsubFolderGeneric_N50, weightedKeyWords, Nweights);

% Load fine mesh results (N = 100)
[PersonalKinDataWeightedSimIG_N100, PersonalGrfDataWeightedSimIG_N100, PersonalKitDataWeightedSimIG_N100, PersonalEmgDataWeightedSimIG_N100,~,~,PersonalCostDataWeightedSimIG_N100,~,~,~,~] = average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, resultsDIR, ResultsFolders, simIGsubFolderPersonal_N100, weightedKeyWords, Nweights);
[GenericKinDataWeightedSimIG_N100, GenericGrfDataWeightedSimIG_N100, GenericKitDataWeightedSimIG_N100, GenericEmgDataWeightedSimIG_N100,~, ~,GenericCostDataWeightedSimIG_N100,~, ~, ~, ~] = average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, resultsDIR, ResultsFolders, simIGsubFolderGeneric_N100, weightedKeyWords, Nweights);
[Dhondt2024_3segKinDataWeightedSimIG_N100, Dhondt2024_3segGrfDataWeightedSimIG_N100, Dhondt2024_3segKitDataWeightedSimIG_N100, Dhondt2024_3segEmgDataWeightedSimIG_N100,~,~,Dhondt2024_3segCostDataWeightedSimIG_N100,~,~,~,~] = average_results(resampTime, 29, Ngrfcol, 92, resultsDIR, ResultsFolders, simIGsubFolderDhondt2024_3seg_N100, weightedKeyWords, Nweights);

%% Choose Lowest Cost
% Coarse mesh results (N = 50)
[PersonalKinDataWeighted, PersonalGrfDataWeighted, PersonalKitDataWeighted, PersonalEmgDataWeighted, PersonalCostDataWeighted] = choose_lowest_cost(PersonalKinDataWeightedSimIG, PersonalGrfDataWeightedSimIG, PersonalKitDataWeightedSimIG, PersonalEmgDataWeightedSimIG, PersonalCostDataWeightedSimIG, PersonalKinDataWeightedExpIG, PersonalGrfDataWeightedExpIG, PersonalKitDataWeightedExpIG, PersonalEmgDataWeightedExpIG, PersonalCostDataWeightedExpIG);
[GenericKinDataWeighted, GenericGrfDataWeighted, GenericKitDataWeighted, GenericEmgDataWeighted, GenericCostDataWeighted] = choose_lowest_cost(GenericKinDataWeightedSimIG, GenericGrfDataWeightedSimIG, GenericKitDataWeightedSimIG, GenericEmgDataWeightedSimIG, GenericCostDataWeightedSimIG, GenericKinDataWeightedExpIG, GenericGrfDataWeightedExpIG, GenericKitDataWeightedExpIG, GenericEmgDataWeightedExpIG, GenericCostDataWeightedExpIG);

% Fine mesh results (N = 100)
[PersonalKinDataWeighted_N100, PersonalGrfDataWeighted_N100, PersonalKitDataWeighted_N100, PersonalEmgDataWeighted_N100, PersonalCostDataWeighted_N100] = choose_lowest_cost(PersonalKinDataWeightedSimIG_N100, PersonalGrfDataWeightedSimIG_N100, PersonalKitDataWeightedSimIG_N100, PersonalEmgDataWeightedSimIG_N100, PersonalCostDataWeightedSimIG_N100, PersonalKinDataWeightedExpIG_N100, PersonalGrfDataWeightedExpIG_N100, PersonalKitDataWeightedExpIG_N100, PersonalEmgDataWeightedExpIG_N100, PersonalCostDataWeightedExpIG_N100);
[GenericKinDataWeighted_N100, GenericGrfDataWeighted_N100, GenericKitDataWeighted_N100, GenericEmgDataWeighted_N100, GenericCostDataWeighted_N100] = choose_lowest_cost(GenericKinDataWeightedSimIG_N100, GenericGrfDataWeightedSimIG_N100, GenericKitDataWeightedSimIG_N100, GenericEmgDataWeightedSimIG_N100, GenericCostDataWeightedSimIG_N100, GenericKinDataWeightedExpIG_N100, GenericGrfDataWeightedExpIG_N100, GenericKitDataWeightedExpIG_N100, GenericEmgDataWeightedExpIG_N100, GenericCostDataWeightedExpIG_N100);
[Dhondt2024_3segKinDataWeighted_N100, Dhondt2024_3segGrfDataWeighted_N100, Dhondt2024_3segKitDataWeighted_N100, Dhondt2024_3segEmgDataWeighted_N100, Dhondt2024_3segCostDataWeighted_N100] = choose_lowest_cost(Dhondt2024_3segKinDataWeightedSimIG_N100, Dhondt2024_3segGrfDataWeightedSimIG_N100, Dhondt2024_3segKitDataWeightedSimIG_N100, Dhondt2024_3segEmgDataWeightedSimIG_N100, Dhondt2024_3segCostDataWeightedSimIG_N100, Dhondt2024_3segKinDataWeightedExpIG_N100, Dhondt2024_3segGrfDataWeightedExpIG_N100, Dhondt2024_3segKitDataWeightedExpIG_N100, Dhondt2024_3segEmgDataWeightedExpIG_N100, Dhondt2024_3segCostDataWeightedExpIG_N100);

%% Compute Normal Walking Errors
% personal
[KinErrPersonal, GrfErrPersonal, KitErrPersonal, EmgErrPersonal, CostErrPersonal, KinErrPersonalMax, GrfErrPersonalMax, KitErrPersonalMax, EmgErrPersonalMax] = computeAllErrors(PersonalKinData, PersonalKinData_N100, PersonalGrfData, PersonalGrfData_N100, PersonalKitData, PersonalKitData_N100, PersonalEmgData, PersonalEmgData_N100, PersonalCostData, PersonalCostData_N100);

% generic
[KinErrGeneric, GrfErrGeneric, KitErrGeneric, EmgErrGeneric, CostErrGeneric, KinErrGenericMax, GrfErrGenericMax, KitErrGenericMax, EmgErrGenericMax] = computeAllErrors(GenericKinData, GenericKinData_N100, GenericGrfData, GenericGrfData_N100, GenericKitData, GenericKitData_N100, GenericEmgData, GenericEmgData_N100, GenericCostData, GenericCostData_N100);

% dhondt 2024 3 segments
[KinErrDhondt2024_3seg, GrfErrDhondt2024_3seg, KitErrDhondt2024_3seg, EmgErrDhondt2024_3seg, CostErrDhondt2024_3seg, KinErrDhondt2024_3segMax, GrfErrDhondt2024_3segMax, KitErrDhondt2024_3segMax, EmgErrDhondt2024_3segMax] = computeAllErrors(Dhondt2024_3segKinData, Dhondt2024_3segKinData_N100, Dhondt2024_3segGrfData, Dhondt2024_3segGrfData_N100, Dhondt2024_3segKitData, Dhondt2024_3segKitData_N100, Dhondt2024_3segEmgData, Dhondt2024_3segEmgData_N100, Dhondt2024_3segCostData, Dhondt2024_3segCostData_N100);

%% Compute Weighted Walking Errors
% personal
[KinErrWeightedPersonal, GrfErrWeightedPersonal, KitErrWeightedPersonal, EmgErrWeightedPersonal, CostErrWeightedPersonal, KinErrWeightedPersonalMax, GrfErrWeightedPersonalMax, KitErrWeightedPersonalMax, EmgErrWeightedPersonalMax] = computeAllErrors(PersonalKinDataWeighted, PersonalKinDataWeighted_N100, PersonalGrfDataWeighted, PersonalGrfDataWeighted_N100, PersonalKitDataWeighted, PersonalKitDataWeighted_N100, PersonalEmgDataWeighted, PersonalEmgDataWeighted_N100, PersonalCostDataWeighted, PersonalCostDataWeighted_N100);

% generic
[KinErrWeightedGeneric, GrfErrWeightedGeneric, KitErrWeightedGeneric, EmgErrWeightedGeneric, CostErrWeightedGeneric, KinErrWeightedGenericMax, GrfErrWeightedGenericMax, KitErrWeightedGenericMax, EmgErrWeightedGenericMax] = computeAllErrors(GenericKinDataWeighted, GenericKinDataWeighted_N100, GenericGrfDataWeighted, GenericGrfDataWeighted_N100, GenericKitDataWeighted, GenericKitDataWeighted_N100, GenericEmgDataWeighted, GenericEmgDataWeighted_N100, GenericCostDataWeighted, GenericCostDataWeighted_N100);

% dhondt 2024 3 segments
[KinErrWeightedDhondt2024_3seg, GrfErrWeightedDhondt2024_3seg, KitErrWeightedDhondt2024_3seg, EmgErrWeightedDhondt2024_3seg, CostErrWeightedDhondt2024_3seg, KinErrWeightedDhondt2024_3segMax, GrfErrWeightedDhondt2024_3segMax, KitErrWeightedDhondt2024_3segMax, EmgErrWeightedDhondt2024_3segMax] = computeAllErrors(Dhondt2024_3segKinDataWeighted, Dhondt2024_3segKinDataWeighted_N100, Dhondt2024_3segGrfDataWeighted, Dhondt2024_3segGrfDataWeighted_N100, Dhondt2024_3segKitDataWeighted, Dhondt2024_3segKitDataWeighted_N100, Dhondt2024_3segEmgDataWeighted, Dhondt2024_3segEmgDataWeighted_N100, Dhondt2024_3segCostDataWeighted, Dhondt2024_3segCostDataWeighted_N100);

%% Print Manuscript Errors
fprintf('Kinematic error, personal model: %.2f %s %.2f°\n', mean(KinErrPersonal), char(177), std(KinErrPersonal))
fprintf('EMG error, personal model: %.2f %s %.2f\n', mean(EmgErrPersonal), char(177), std(EmgErrPersonal))
fprintf('GRF error, personal model: %.2f %s %.2f N\n', mean(GrfErrPersonal), char(177), std(GrfErrPersonal))
fprintf('Cost error, personal model: %.2f %s %.2f %%\n', CostErrPersonal, char(177), std((PersonalCostData-PersonalCostData_N100)./PersonalCostData*100))

%% Print All Errors
% personal
fprintf('*** PERSONAL ***\n')
printErrors(KinErrPersonal, GrfErrPersonal, KitErrPersonal, EmgErrPersonal, CostErrPersonal, kinColHeaders, grfColHeaders, emgColHeaders)
printErrors(KinErrWeightedPersonal, GrfErrWeightedPersonal, KitErrWeightedPersonal, EmgErrWeightedPersonal, CostErrWeightedPersonal,  kinColHeaders, grfColHeaders, emgColHeaders)

% generic
fprintf('*** GENERIC ***\n')
printErrors(KinErrGeneric, GrfErrGeneric, KitErrGeneric, EmgErrGeneric, CostErrGeneric, kinColHeaders, grfColHeaders, emgColHeaders)
printErrors(KinErrWeightedGeneric, GrfErrWeightedGeneric, KitErrWeightedGeneric, EmgErrWeightedGeneric, CostErrWeightedGeneric,  kinColHeaders, grfColHeaders, emgColHeaders)

% dhondt
fprintf('*** EXTENDED ***\n')
printErrors(KinErrDhondt2024_3seg, GrfErrDhondt2024_3seg, KitErrDhondt2024_3seg, EmgErrDhondt2024_3seg, CostErrDhondt2024_3seg, Dhondt2024_3segkinColHeaders, grfColHeaders, Dhondt2024_3segEmgColHeaders)
printErrors(KinErrWeightedDhondt2024_3seg, GrfErrWeightedDhondt2024_3seg, KitErrWeightedDhondt2024_3seg, EmgErrWeightedDhondt2024_3seg, CostErrWeightedDhondt2024_3seg,  Dhondt2024_3segkinColHeaders, grfColHeaders, Dhondt2024_3segEmgColHeaders)

%% Functions
function [KinErr, GrfErr, KitErr, EmgErr, CostErr, KinErrMax, GrfErrMax, KitErrMax, EmgErrMax] = computeAllErrors(KinData, KinData_N100, GrfData, GrfData_N100, KitData, KitData_N100, EmgData, EmgData_N100, CostData, CostData_N100)

    Nworkers = size(KinData,4);
    KinErr = NaN([size(KinData,2), Nworkers]);
    GrfErr = NaN([size(GrfData,2), Nworkers]);
    KitErr = NaN([size(KitData,2), Nworkers]);
    EmgErr = NaN([size(EmgData,2), Nworkers]);
    CostErr = NaN(Nworkers,1);

    KinErrMax = NaN([size(KinData,2) size(KinData,3), Nworkers]);
    GrfErrMax = NaN([size(GrfData,2) size(GrfData,3), Nworkers]);
    KitErrMax = NaN([size(KitData,2) size(KitData,3), Nworkers]);
    EmgErrMax = NaN([size(EmgData,2) size(EmgData,3), Nworkers]);

    for i = 1:Nworkers
        KinErr(:,i) = squeeze(mean(rmse(KinData(:,:,:,i), KinData_N100(:,:,:,i)),3,"omitnan"));
        GrfErr(:,i) = squeeze(mean(rmse(GrfData(:,:,:,i), GrfData_N100(:,:,:,i)),3,"omitnan"));
        KitErr(:,i) = squeeze(mean(rmse(KitData(:,:,:,i), KitData_N100(:,:,:,i)),3,"omitnan"));
        EmgErr(:,i) = squeeze(mean(rmse(EmgData(:,:,:,i), EmgData_N100(:,:,:,i)),3,"omitnan"));
        CostErr(i,:) = mean((CostData(:,i) - CostData_N100(:,i))./CostData(:,i)*100,"omitnan");
        
        KinErrMax(:,:,i) = squeeze(max(abs(KinData(:,:,:,i)-KinData_N100(:,:,:,i)),[],"omitnan"));
        GrfErrMax(:,:,i) = squeeze(max(abs(GrfData(:,:,:,i)-GrfData_N100(:,:,:,i)),[],"omitnan"));
        KitErrMax(:,:,i) = squeeze(max(abs(KitData(:,:,:,i)-KitData_N100(:,:,:,i)),[],"omitnan"));
        EmgErrMax(:,:,i) = squeeze(max(abs(EmgData(:,:,:,i)-EmgData_N100(:,:,:,i)),[],"omitnan"));
    end

end

function printErrors(KinErr, GrfErr, KitErr, EmgErr, CostErr, kinColHeaders, grfColHeaders, emgColHeaders)

    KinUnit = repmat("°", length(kinColHeaders), 1); KinUnit(4:6) = "m";

    Nworkers = size(KinErr, 2);

    for j = 1:Nworkers
        fprintf(' --- Worker %i ---\n', j)
        for i = 1:length(KinErr)
            fprintf('Average RMSE for kinematics across subjects, for joint %s, is %.2f %s\n', kinColHeaders(i), KinErr(i,j), KinUnit(i))
        end
        
        for i = 1:length(GrfErr)
            fprintf('Average RMSE for GRFs across subjects, for joint %s, is %.2f N\n', grfColHeaders(i), GrfErr(i,j))
        end
        
        KitUnit = repmat("Nm", length(kinColHeaders), 1); KitUnit(4:6) = "N";
        for i = 1:length(KitErr)
            fprintf('Average RMSE for kinetics across subjects, for joint %s, is %.2f %s\n', kinColHeaders(i), KitErr(i,j), KitUnit(i))
        end
        
        for i = 1:length(EmgErr)
            fprintf('Average RMSE for EMGs across subjects, for muscle %s, is %.2f\n', emgColHeaders(i), EmgErr(i,j))
        end
        
        fprintf('Average difference for objective cost across subjects is %.2f %%\n', CostErr(j))

    end

end

function [KinData, GrfData, KitData, EmgData, CostData] = choose_lowest_cost(...
    KinDataSimIG, GrfDataSimIG, KitDataSimIG, EmgDataSimIG, CostDataSimIG,...
    KinDataExpIG, GrfDataExpIG, KitDataExpIG, EmgDataExpIG, CostDataExpIG)

    % Choose solution with lowest cost function value
    isExpIGlower = CostDataExpIG < CostDataSimIG;
    
    KinData = KinDataSimIG;
    GrfData = GrfDataSimIG;
    KitData = KitDataSimIG;
    EmgData = EmgDataSimIG;
    CostData = CostDataSimIG;
    
    NSUBJ = size(KinData,3);
    Ncol = size(KinData,4);
    
    for i = 1:NSUBJ
        for j = 1:Ncol
            if(isExpIGlower(i,j))
                KinData(:,:,i,j) = KinDataExpIG(:,:,i,j);
                GrfData(:,:,i,j) = GrfDataExpIG(:,:,i,j);
                KitData(:,:,i,j) = KitDataExpIG(:,:,i,j);
                EmgData(:,:,i,j) = EmgDataExpIG(:,:,i,j);
                CostData(i,j) = CostDataExpIG(i,j);
            end
        end
    end
end