function [IKdata, normTime] = loadIKdata(data_loc,excludeJoints)
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