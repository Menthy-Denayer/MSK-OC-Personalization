% --------------------------------------------------------------------------
% Settings for gait14dof22musc that deviate from the PredSim defaults
%
% Original author: Lars D'Hondt
% Original date: 11/December/2023
% --------------------------------------------------------------------------

S.subject.name = 'SUBJ04mtu3D';

S.bounds.activation_all_muscles.lower = 0.01;                               % reduced lower muscle activation bound due to strong plantarflexors

% passive mtp joint 
S.subject.mtp_type = '2022paper';                                           % passive mtp joint
S.subject.set_stiffness_coefficient_selected_dofs = {'mtp_angle',25};
S.subject.set_damping_coefficient_selected_dofs = {'mtp_angle',2};

S.misc.forward_velocity = 0.94;
S.subject.base_joints_arms = [];                                            % no arms
S.subject.adapt_IG_pelvis_y = 1;                                            % adapt vertical pelvis position

% Achilles tendon stiffness
S.subject.tendon_stiff_scale = {{'soleus','gastroc'},0.5};                  % done for 2D model

% S.bounds.Qs = {'pelvis_rotation',-7.5,7.5,'lumbar_extension',2,4};
% S.bounds.Qs = {{'hip_rotation_r','hip_rotation_l'},[],4};

% to prevent body segments from clipping into eachother
S.bounds.distanceConstraints(1).point1 = 'calcn_r';
S.bounds.distanceConstraints(1).point2 = 'calcn_l';
S.bounds.distanceConstraints(1).direction = 'xz';
S.bounds.distanceConstraints(1).lower_bound = 0.09;
S.bounds.distanceConstraints(1).upper_bound = 2;

S.bounds.distanceConstraints(2).point1 = 'tibia_r';
S.bounds.distanceConstraints(2).point2 = 'tibia_l';
S.bounds.distanceConstraints(2).direction = 'xz';
S.bounds.distanceConstraints(2).lower_bound = 0.11;
S.bounds.distanceConstraints(2).upper_bound = 2;

S.bounds.distanceConstraints(3).point1 = 'toes_r';
S.bounds.distanceConstraints(3).point2 = 'toes_l';
S.bounds.distanceConstraints(3).direction = 'xz';
S.bounds.distanceConstraints(3).lower_bound = 0.1;
S.bounds.distanceConstraints(3).upper_bound = 2;


