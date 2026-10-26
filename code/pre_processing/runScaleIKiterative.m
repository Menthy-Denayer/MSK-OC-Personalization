% --------------------------------------------------------------------------
% runScaleIKiterative
%   runs the OpenSim scale & inverse kinematics tools for the desired
%   experimental data and settings
%
% Original author: Menthy Denayer
% Original date: 12/Oct/2026
%
% Last edit by: Menthy Denayer
% Last edit date: 25/Oct/2026
% 
% --------------------------------------------------------------------------

clear all
clc
close all

%% Add Path
dataProcessingDIR = uigetdir("", "Data processing directory");
addpath(fullfile(dataProcessingDIR,"opensim-tools"));
addpath(fullfile(dataProcessingDIR,"opensim-tools","utilities"));

%% Load OpenSim Model
% Load model file
[osim_file_name, osim_data_loc] = uigetfile("*.osim","Select .osim model file.");

%% Choose Subject
SUBJID = 11;

%% Adapt Markers
shiftMarkerBool = true;

if(shiftMarkerBool)
    % SUBJ04
    if(SUBJID == 4)
        markerNames = ["LASI", "RASI", "LPSI", "RPSI"]; 
        offsetVector = [[0,0,0.01];[0,0,-0.01]; [0,0.00,-0.03]; [0,0.00,0.03]];

    % SUBJ06
    elseif(SUBJID == 6)
        markerNames = ["LASI", "RASI", "LPSI", "RPSI", "RKNE", "LKNE"];  
        offsetVector = [[0,0,0];[0,0.01,0];[0,0,-0.01];[0,0,0.01];[0.01,0,0];[0,0,0]];

    % SUBJ07
    elseif(SUBJID == 7)
        markerNames = ["LPSI", "RPSI", "RKNE", "LKNE"]; 
        offsetVector = [[0,0.00,-0.02]; [0,0.00,0.02]; [0.01, 0, 0]; [0, 0, 0]]; 

    % SUBJ09
    elseif(SUBJID == 9)
        markerNames = ["LPSI", "RPSI"]; 
        offsetVector = [[0,0,-0.025]; [0,0,0.025]]; 

    % SUBJ10
    elseif(SUBJID == 10)
        markerNames = ["LPSI", "RPSI", "RKNE", "RKNEmed"]; 
        offsetVector = [[0,0,-0.025]; [0,0.0,0.025]; [0.005,0,0]; [0.005,0,0]];  

    % SUBJ11
    elseif(SUBJID == 11)
        % no changes
        markerNames = ["LPSI", "RPSI"]; 
        offsetVector = [[0,0,0]; [0,0.0,0]]; 
    end


    % Update markers
    new_osim_file_name = shiftMarker(osim_file_name, osim_data_loc, markerNames, offsetVector);
    new_osim_data_loc = pwd;
else
    new_osim_file_name = osim_file_name;
    new_osim_data_loc = osim_data_loc;
end

%% Choose TRC Scaling File
[trcSCALEfile, trcSCALEDir] = uigetfile(".trc","Choose scaling .trc file");

%% Choose TRC IK Directory
trcIKDir = uigetdir("..\..\data\Inverse Kinematics\","Choose processed data directory");
trcDIRinfo = struct2table(dir(trcIKDir));
[~,~,trcFileExtensions] = fileparts(trcDIRinfo.name);
trcFiles = string(trcDIRinfo.name(ismember(trcFileExtensions, ".trc")));
NtrcFiles = length(trcFiles); 

%% Select Data Files
% Load scale settings file
[SCALExml_file_name, SCALExml_data_loc] = uigetfile("*.xml","Select SCALE .xml settings file.");

% Load IK settings file
[IKxml_file_name, IKxml_data_loc] = uigetfile("*.xml","Select IK .xml settings file.");

%% Copy Marker File to Results Directory
mkdir(fullfile(pwd,"MODEL"))
copyfile(fullfile(trcSCALEDir,trcSCALEfile),fullfile(pwd,"MODEL",trcSCALEfile))

%% Define SCALE Settings
SCALEsettings.model_dir = fullfile(pwd,"MODEL");
SCALEsettings.results_dir = pwd;
SCALEsettings.model_name = "SUBJ" + SUBJID;
SCALEsettings.trc_scaling = trcSCALEfile;
SCALEsettings.unscaled_model_path = fullfile(new_osim_data_loc, new_osim_file_name);
SCALEsettings.xml_scaling_file = fullfile(SCALExml_data_loc, SCALExml_file_name);

%% Run Scale
SCALEsettings = runScale(SCALEsettings);

%% Define IK Settings
IKsettings.scaled_model_path = SCALEsettings.scaled_model_path;
IKsettings.xml_ik_file = fullfile(IKxml_data_loc, IKxml_file_name);
IKsettings.ik_mot_dir = fullfile(pwd,"IK/" + SCALEsettings.model_name);
% IKsettings.output_file_name = "";
% IKsettings.reportMarkerLocations = false;
IKsettings.reportMarkerErrors = true;
IKsettings.printSettings = true;

%% Run IK
% run IK for all trc files
for fileIdx = 1:NtrcFiles
    IKsettings.trc_file = fullfile(trcIKDir, trcFiles(fileIdx));
    runIK(IKsettings)
end
