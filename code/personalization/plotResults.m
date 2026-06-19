clear all
clc
close all

%% Add Path
addpath("C:\Users\menth\Documents\Programmas\PredSim\VariousFunctions")

%% Choose Kinematics Data
[kinFileName, kinFolder] = uigetfile(".mot", "Choose kinematics reference file");

%% Choose GRF Data
[grfFileName, grfFolder] = uigetfile(".sto", "Choose grf reference file");

%% Choose Tracking Results File
[resTrackFileName, resTrackFolder] = uigetfile(".mat", "Choose tracking results file");

%% Choose Tracking Results File
[resPredFileName, resPredFolder] = uigetfile(".mat", "Choose prediction results file");

%% Choose Coordinate Limits
[limFileName, limFolder] = uigetfile(".csv", "Choose coordinate limits file");

%% Load Limits
limData = importdata(fullfile(limFolder,limFileName));
limNames = string(limData.textdata(2:end,1));
limBounds = limData.data(:,1:2);

%% Plot Tracking & Prediction Results
resTrack = load(fullfile(resTrackFolder, resTrackFileName));
resPred = load(fullfile(resPredFolder, resPredFileName));

Qref_tot = getIK(fullfile(kinFolder,kinFileName),resTrack.model_info);           % load .mot file with tracking data
Qref_time = Qref_tot.time;                                                  % extract tracking data time
Nmeshes = resTrack.R.S.solver.N_meshes;                                          % define number of meshes

% check joints to track
if(strcmp(resTrack.R.S.subject.TrackingJoints,'all'))                      
    desir_coo_names = string(fieldnames(resTrack.model_info.ExtFunIO.coordi));   % if tracking all joints, 
else
    desir_coo_names = string(resTrack.R.S.subject.TrackingJoints);               % if tracking only selected joints
end

% create reference data
NtrackJoints = length(desir_coo_names);                                     % number of joints to track
Ndata = length(Qref_time);                                                  % size of the experimental data
Qref = zeros(Ndata,NtrackJoints);                                           % matrix to store tracking data  
for jointIdx = 1:NtrackJoints
    Qref(:,jointIdx) = Qref_tot.(desir_coo_names(jointIdx));                % fill matrix with data
end

isLinearCoo = contains(desir_coo_names,'tx') | contains(desir_coo_names,'ty') | contains(desir_coo_names,'tz');
Qref(:,~isLinearCoo) = Qref(:,~isLinearCoo)*180/pi;

% Find limits
[~,idxs] = ismember(limNames, desir_coo_names);
limBoundsOrdered = limBounds(idxs>0,:);
limBoundsOrdered(~isLinearCoo,:) = limBoundsOrdered(~isLinearCoo,:)*180/pi;

% resample to be ( Nmeshes ) x ( number of joints to track )
Qrefsync = interp1(linspace(1,Nmeshes,Ndata),Qref,linspace(1,Nmeshes,Nmeshes),'spline','extrap');

Qpred = resTrack.R.kinematics.Qs;
Qpredpred = resPred.R.kinematics.Qs;
isLinearCoo = contains(desir_coo_names,'tx');
Qrefsync(:,~isLinearCoo) = circshift(Qrefsync(:,~isLinearCoo),-resTrack.R.ground_reaction.idx_GC(end));

for i = 1:NtrackJoints
    figure
    hold on
    plot(linspace(1,Nmeshes,Nmeshes), Qrefsync(:,i), 'k--')
    plot(linspace(1,Nmeshes,Nmeshes), Qpred(:,i), 'r')
    plot(linspace(1,Nmeshes,Nmeshes), Qpredpred(:,i),'b')
    yline(limBoundsOrdered(i,1),"r--")
    yline(limBoundsOrdered(i,2),"r--")
    title(desir_coo_names(i))
    hold off
end
% 
%% Plot Tracking Results
GRFref_tot = getGRF(fullfile(grfFolder, grfFileName),resTrack.R.S.subject.TrackingGRFs);    % load .mot/.sto file with tracking data
GRFref_time = GRFref_tot.time;                                              % extract tracking data time
Nmeshes = resTrack.R.S.solver.N_meshes;                                          % define number of meshes

% create reference data
NGRF = length(resTrack.R.S.subject.TrackingGRFs);                                % number of joints to track
Ndata = length(GRFref_time);                                                % size of the experimental data
GRFref = zeros(Ndata,NGRF);                                                 % matrix to store tracking data  
for grfIdx = 1:NGRF
    GRFref(:,grfIdx) = GRFref_tot.(resTrack.R.S.subject.TrackingGRFs{grfIdx});   % fill matrix with data
end

% resample to be ( Nmeshes + 1 ) x ( number of joints to track )
GRFrefsync = interp1(linspace(1,Nmeshes,Ndata),GRFref,linspace(1,Nmeshes,Nmeshes),'spline','extrap');

GRFpred = [resTrack.R.ground_reaction.GRF_r resTrack.R.ground_reaction.GRF_l];
GRFpredpred = [resPred.R.ground_reaction.GRF_r resPred.R.ground_reaction.GRF_l];
GRFrefsync = circshift(GRFrefsync,-resTrack.R.ground_reaction.idx_GC(end));

for i = 1:NGRF
    figure
    hold on
    plot(linspace(1,Nmeshes,Nmeshes), GRFrefsync(:,i), 'k--')
    plot(linspace(1,Nmeshes,Nmeshes), GRFpred(:,i), 'r')
    plot(linspace(1,Nmeshes,Nmeshes), GRFpredpred(:,i), 'b')
    title(resTrack.R.S.subject.TrackingGRFs{i})
    hold off
end