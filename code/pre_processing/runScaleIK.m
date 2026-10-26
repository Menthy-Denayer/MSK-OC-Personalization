% --------------------------------------------------------------------------
% runScaleIK
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
addpath("C:\Users\medenaye\Documents\programs\GitHub\OpenSim-Processing\opensim-tools");
addpath("C:\Users\medenaye\Documents\programs\GitHub\OpenSim-Processing\opensim-tools\utilities\");

%% Load OpenSim Model
% Load model file
[osim_file_name, osim_data_loc] = uigetfile("*.osim","Select .osim model file.");

%% Choose Subject
SUBJID = 7;

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

%% Choose TRC Motion File
[trcIKfile, trcIKDir] = uigetfile(".trc","Choose IK .trc file");   
% trcIKfile = trcSCALEfile;
% trcIKDir = trcSCALEDir;

%% Load PredSim Limits
dataFile = "C:\Users\medenaye\Documents\programs\PredSim\OCP\Default_Coordinate_Bounds.csv";
data = importdata(dataFile);

kinHeaders = string(data.textdata(2:end,1));
kinLimits = data.data(:,1:2);

isTrans = contains(kinHeaders,"_tx") | contains(kinHeaders,"_ty") | contains(kinHeaders,"_tz");
kinLimits(~isTrans,:) = kinLimits(~isTrans,:)*180/pi;

%% Select Data Files
% Load scale settings file
[SCALExml_file_name, SCALExml_data_loc] = uigetfile("*.xml","Select SCALE .xml settings file.");

% Load IK settings file
[IKxml_file_name, IKxml_data_loc] = uigetfile("*.xml","Select IK .xml settings file.");

%% Copy Marker File to Results Directory
mkdir(fullfile(pwd,"MODEL"))
copyfile(fullfile(trcSCALEDir,trcSCALEfile),fullfile(pwd,"MODEL",trcSCALEfile))

%% Define SCALE Settings
SCALEsettings.results_dir = pwd;
SCALEsettings.model_dir = fullfile(pwd, "MODEL");
SCALEsettings.model_name = "SUBJ" + SUBJID;
SCALEsettings.trc_scaling = trcSCALEfile;
SCALEsettings.unscaled_model_path = fullfile(new_osim_data_loc, new_osim_file_name);
SCALEsettings.xml_scaling_file = fullfile(SCALExml_data_loc, SCALExml_file_name);

%% Define IK Settings
% IKsettings.scaled_model_path = fullfile(pwd, osim_file_name);
IKsettings.trc_file = fullfile(trcIKDir, trcIKfile);
IKsettings.xml_ik_file = fullfile(IKxml_data_loc, IKxml_file_name);
IKsettings.ik_mot_dir = fullfile(pwd,"IK");
% IKsettings.output_file_name = SCALEsettings.model_name + ".mot";
% IKsettings.reportMarkerLocations = false;
IKsettings.reportMarkerErrors = true;
IKsettings.printSettings = true;

%% Run Scale
SCALEsettings = runScale(SCALEsettings);

%% Run IK
IKsettings.scaled_model_path = SCALEsettings.scaled_model_path;
runIK(IKsettings)

%% Plot IK
outputFile = strrep(trcIKfile,".trc","_ik.mot");
IKres = importdata(fullfile("IK",outputFile));

desColumns = string(IKres.colheaders(2:end));
[isDes,colOrder] = ismember(IKres.colheaders,desColumns); colOrder = colOrder(colOrder>0);
desData = IKres.data(:,isDes);
Ncol = size(desData,2);
desColumns = desColumns(colOrder);

for i = 1:Ncol
    isLimit = contains(kinHeaders, desColumns(i));
    limits = kinLimits(isLimit,:);

    figure
    hold on
    plot(IKres.data(:,1), desData(:,i))
    yline(limits(1),"Color","red")
    yline(limits(2),"Color","red")
    title(strrep(desColumns(i),"_"," "))
    hold off
end
hold off

%% Plot IK errors
outputFile = strrep(trcIKfile,".trc", "_ik_marker_errors.sto");
IKerr = importdata(fullfile("IK",outputFile));

errCols = IKerr.colheaders(2:end);
errData = IKerr.data;
Ncol = size(errData,2)-1;

figure
hold on
for i = 1:Ncol
    plot(IKerr.data(:,1), errData(:,i+1))
end
legend(strrep(errCols,"_"," "))
hold off
