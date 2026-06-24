function [IKdata, normTime] = loadIKdata(data_loc,excludeJoints)
%% loadIKdata 
% - Loads the desired IK data for computing the RMSE during personalization
%
%------------------------------------------------------------- INPUTS -------------------------------------------------------------
% params                        | struct                        | Structure with settings
%   data_loc                    | string                        | Path to location of the data
%   excludeJoints               | string                        | List of joints to exclude from the data
%
%------------------------------------------------------------- OUTPUTS ------------------------------------------------------------
% IKdata                        | Ndata x Njoints Double Array  | IK data
% normTime                      | Ndata x 1 Double Array        | Normalized time data
%
%----------------------------------------------------------- REQUIREMENTS ---------------------------------------------------------
% 
%
%----------------------------------------------------------------------------------------------------------------------------------

% Original Author: Menthy Denayer
% Date: 15/January/2026

% Last Update: Menthy Denayer
% Date: 24/June/2026 

%% Load Data
KINdata = importdata(data_loc);

%% Normalize Time Vector
kinTime = KINdata.data(:,1); 
kinDuration = kinTime(end)-kinTime(1);
normTime = kinTime/kinDuration;

%% Choose Desired Kinematics
all_colheaders = string(KINdata.colheaders); 
desir_coo_names = all_colheaders(~contains(all_colheaders,"time"));
desir_coo_names = desir_coo_names(~contains(desir_coo_names,"activation"));

% exclude joints
if(~isempty(excludeJoints))
    excludeBool = contains(desir_coo_names,excludeJoints);
    desir_coo_names = desir_coo_names(~excludeBool);
end

[~,desir_joint_idx] = ismember(desir_coo_names,all_colheaders);             % get desired joint indices  
IKdata = KINdata.data(:,desir_joint_idx(desir_joint_idx>0));                % all joint angles

% all_colheaders(desir_joint_idx(desir_joint_idx>0))

end