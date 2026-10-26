% --------------------------------------------------------------------------
% createPredSimIG
%   creates initial guess file based on IK results
%
% Original author: Menthy Denayer
% Original date: 03/Oct/2026
%
% Last edit by: Menthy Denayer
% Last edit date: 25/Oct/2026
% 
% --------------------------------------------------------------------------

clear all
clc
close all

%% Import
import org.opensim.modeling.*

%% Add Path
addpath("C:\Users\medenaye\Documents\programs\GitHub\OpenSim-Processing\data-processing\utilities")

%% Define Variables
fileKey = "NormalWalking";
pelvis_vertical_offset = 0.035;
desired_dofs = ["pelvis_tilt", "pelvis_list", "pelvis_rotation", "pelvis_tx", "pelvis_ty", "pelvis_tz", "hip_flexion_r", "hip_adduction_r", "hip_rotation_r", "knee_angle_r", "ankle_angle_r", "mtp_angle_r", "hip_flexion_l", "hip_adduction_l", "hip_rotation_l", "knee_angle_l", "ankle_angle_l", "mtp_angle_l", "lumbar_extension", "lumbar_bending", "lumbar_rotation"];
% desired_dofs = ["pelvis_tilt","pelvis_list","pelvis_rotation","pelvis_tx","pelvis_ty","pelvis_tz","hip_flexion_r","hip_adduction_r","hip_rotation_r","knee_angle_r","ankle_angle_r","subtalar_angle_r","mtp_angle_r","hip_flexion_l","hip_adduction_l","hip_rotation_l","knee_angle_l","ankle_angle_l","subtalar_angle_l","mtp_angle_l","lumbar_extension","lumbar_bending","lumbar_rotation","arm_flex_r","arm_add_r","arm_rot_r","elbow_flex_r","arm_flex_l","arm_add_l","arm_rot_l","elbow_flex_l"];
resampTime = 0:0.01:1;
lowpassSettings.lowpassFreq = 6;                                            % default in OpenSim
lowpassSettings.lowpassFilterOrder = 2;                                     % default in OpenSim

%% Choose Directories
motDIR = uigetdir("C:\Users\medenaye\Documents\programs\GitHub\MSK-OC-Personalization\data", "Choose IK directory");
[eventsFile, eventsDIR] = uigetfile(".mat", "Choose events file");

%% Get SUBJID
[~, subjID] = fileparts(motDIR);
subjID = string(regexp(subjID, "SUBJ\d+", 'match', 'once'));

%% Get Motion Files
motDIRinfo = struct2table(dir(motDIR));
[~,~,motFileExtensions] = fileparts(motDIRinfo.name);
motFiles = string(motDIRinfo.name(ismember(motFileExtensions, ".mot")));
isFiles = contains(motFiles, fileKey) & ~contains(motFiles, "error");
motFilesFiltered = motFiles(isFiles);
NmotFiles = length(motFilesFiltered); 

%% Save Data
Ndata = length(resampTime);
Njoints = length(desired_dofs);
allKinematicsData = NaN(Ndata, Njoints, NmotFiles);
forward_speed = NaN(1,NmotFiles);

for i = 1:NmotFiles
    kinematics = importdata(fullfile(motDIR, motFilesFiltered(i)));
    
    taskName = extractBefore(motFilesFiltered(i),"_markers");

    KINlabels = kinematics.colheaders;
    [~,isJoint] = ismember(desired_dofs, KINlabels);

    kinematicsData = kinematics.data(:,isJoint);
    KinTime = kinematics.data(:,1);

    % Filter Kinematics
    FS = 1/(KinTime(2) - KinTime(1));
    kinematicsData_filtered = lowpassFilterWrapper(kinematicsData, FS, lowpassSettings);

    % Load Events
    load(fullfile(eventsDIR, eventsFile));
    gaitEvents = events.(taskName);
    time_range = gaitEvents.RHeelStrike;

    KINidxs = [findTimeIdx(KinTime, time_range(1)), findTimeIdx(KinTime, time_range(2))];
    
    % Correct time & extract data
    newKINtime = KinTime(KINidxs(1):KINidxs(2)); 
    duration = (newKINtime(end) - newKINtime(1));
    newKINtime = (newKINtime - newKINtime(1))/duration;
    kinematicsData_filtered = kinematicsData_filtered(KINidxs(1):KINidxs(2),:);
    kinematicsData_interp = interp1(newKINtime, kinematicsData_filtered, resampTime);

    % Fix Plevis Heading
    isPelvisTx = contains(desired_dofs,"pelvis_tx");
    shiftTx = kinematicsData_interp(1,isPelvisTx);
    kinematicsData_interp(:,isPelvisTx) = kinematicsData_interp(:,isPelvisTx)-shiftTx;

    isPelvisTz = contains(desired_dofs,"pelvis_tz");
    shiftTz = kinematicsData_interp(1,isPelvisTz);
    kinematicsData_interp(:,isPelvisTz) = kinematicsData_interp(:,isPelvisTz)-shiftTz;

    % Fix Pelvis Height
    isPelvisTy = contains(desired_dofs,"pelvis_ty");
    kinematicsData_interp(:,isPelvisTy) = kinematicsData_interp(:,isPelvisTy)+pelvis_vertical_offset;
    allKinematicsData(:,:,i) = kinematicsData_interp;

    forward_speed(i) = kinematicsData_interp(end,isPelvisTx)/duration;
end

%% Average Data
avgKinematicsData = mean(allKinematicsData,3);
deltaX = avgKinematicsData(end,isPelvisTx);
deltaT = deltaX / mean(forward_speed);
avgTime = resampTime * deltaT;

%% Debug Plot
for i = 1:Njoints
    figure
    hold on
    for j = 1:NmotFiles
        plot(avgTime, allKinematicsData(:,i,j), "black")
    end
    plot(avgTime, avgKinematicsData(:,i),"red")
    title(strrep(desired_dofs(i),"_"," "))
    hold off
end

%% Left/Right Plot
isLeft = endsWith(desired_dofs,"_l");
LeftIdx = find(isLeft);
isRight = endsWith(desired_dofs, "_r");
RightIdx = find(isRight);

for i = 1:sum(isLeft)
    figure
    plot(avgTime, avgKinematicsData(:,LeftIdx(i)), "b", avgTime, avgKinematicsData(:,RightIdx(i)), "r")
    title(strrep(desired_dofs(LeftIdx(i)), "_l", ""))
    legend("Left", "Right")
end

%% Save Data
Ndata = size(avgKinematicsData,1);

table = createTimeSeriesTable(desired_dofs, avgTime, avgKinematicsData);

table.addTableMetaDataString("nRows", string(Ndata))
table.addTableMetaDataString("nColumns", string(size(avgKinematicsData,2)+1))
table.addTableMetaDataString("inDegrees", "yes")
STOFileAdapter().write(table, subjID + "_normalWalking_average_zeroMTP.mot");

%% Helper Functions
% find index of time point closest to desired value
function idx = findTimeIdx(timeVector, timePoint)
    [dist,idx] = min(abs(timeVector-timePoint));
    if(dist > 0.5)
        warning(['Time distance is larger than 0.5 (' num2str(dist) ')!'])
        idx = 1;
    end
end

function filteredData = lowpassFilterWrapper(data, Fs, settings)
Ntrials = size(data,3);
filteredData = NaN(size(data));

for i = 1:Ntrials
    filteredData(:,:,i) = lowpassFilter(data(:,:,i), Fs, settings);
end

% debug
% for i = 1:size(data,2)
%     figure
%     hold on
%     plot(data(:,i),"black")
%     plot(filteredData(:,i),"red--")
%     hold off
% end

end