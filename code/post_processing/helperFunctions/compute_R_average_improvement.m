function [avg_percent_R_kin, avg_percent_R_grf] = compute_R_average_improvement(avg_R_list_kin_personal, avg_R_list_kin_generic, avg_R_list_grf_personal, avg_R_list_grf_generic, avg_R_list_emg_personal, avg_R_list_emg_generic, identifier)
%% compute_R_average_improvement 
% Computes the average improvement for the correlation coefficient:
% delta R = (R_personal - R_generic) / (1 - R_generic) * 100
%
%------------------------------------------------------------- INPUTS -------------------------------------------------------------
% avg_R_list_kin_personal       | Ndof x 1 Double Array         | Average correlation coefficients for kinematics of the personal model
% avg_R_list_kin_generic        | Ndof x 1 Double Array         | Average correlation coefficients for kinematics of the generic model
% avg_R_list_grf_personal       | Ngrf x 1 Double Array         | Average correlation coefficients for GRFs of the personal model
% avg_R_list_grf_generic        | Ngrf x 1 Double Array         | Average correlation coefficients for GRFs of the generic model
% avg_R_list_emg_personal       | Nemg x 1 Double Array         | Average correlation coefficients for EMGs of the generic model
% avg_R_list_emg_generic        | Nemg x 1 Double Array         | Average correlation coefficients for EMGs of the generic model
% identifier                    | String                        | String to customize results message
%
%------------------------------------------------------------- OUTPUTS ------------------------------------------------------------
% avg_percent_R_kin             | 1 x 1 Double Array            | Computed average improvement for the kinematics
% avg_percent_R_grf             | 1 x 1 Double Array            | Computed average improvement for the GRFs
%
%----------------------------------------------------------- REQUIREMENTS ---------------------------------------------------------
% 
%
%----------------------------------------------------------------------------------------------------------------------------------

% Original Author: Menthy Denayer
% Date: 08/July/2026

% Last Update: Menthy Denayer
% Date: 08/July/2026    

%% Compute Average R Improvements
% positive means R increased
rel_dR_kin = (avg_R_list_kin_personal - avg_R_list_kin_generic);
rel_dR_grf = (avg_R_list_grf_personal - avg_R_list_grf_generic);
rel_dR_emg = (avg_R_list_emg_personal - avg_R_list_emg_generic);

% deltaR = Rpersonal - Rgeneric
max_dR_kin = 1-avg_R_list_kin_generic;
max_dR_grf = 1-avg_R_list_grf_generic;
max_dR_emg = 1-avg_R_list_emg_generic;

% maximum possible change = 1 - Rgeneric
percent_R_kin = rel_dR_kin./max_dR_kin*100;
percent_R_grf = rel_dR_grf./max_dR_grf*100;
percent_R_emg = rel_dR_emg./max_dR_emg*100;

% maximum possible change = deltaR/maxDR 
avg_percent_R_kin = mean(percent_R_kin);
avg_percent_R_grf = mean(percent_R_grf);
avg_percent_R_emg = mean(percent_R_emg);

% print results
fprintf(['\n** Printing R Metrics for ' identifier ' **\n'])
fprintf('The pearson correlation coefficient R reached on average %.2f%% of the maximal improvement for the kinematics\n', avg_percent_R_kin)
fprintf('The pearson correlation coefficient R reached on average %.2f%% of the maximal improvement for the ground reaction forces\n', avg_percent_R_grf)
fprintf('The pearson correlation coefficient R reached on average %.2f%% of the maximal improvement for the EMG\n', avg_percent_R_emg)

end