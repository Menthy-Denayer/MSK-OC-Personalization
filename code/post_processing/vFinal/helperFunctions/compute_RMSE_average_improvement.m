function [avg_percent_rmse_kin, avg_percent_rmse_grf] = compute_RMSE_average_improvement(avg_rmse_list_kin_personal, avg_rmse_list_kin_generic, avg_rmse_list_grf_personal, avg_rmse_list_grf_generic, identifier)
%% compute_RMSE_average_improvement 
% Computes the average improvement for the RMSE:
% delta RMSE = (RMSE_personal - RMSE_generic) / RMSE_generic * 100
%
%------------------------------------------------------------- INPUTS -------------------------------------------------------------
% avg_rmse_list_kin_personal    | Ndof x 1 Double Array         | Average RMSE for kinematics of the personal model
% avg_rmse_list_kin_generic     | Ndof x 1 Double Array         | Average RMSE for kinematics of the generic model
% avg_rmse_list_grf_personal    | Ngrf x 1 Double Array         | Average RMSE for GRFs of the personal model
% avg_rmse_list_grf_generic     | Ngrf x 1 Double Array         | Average RMSE for GRFs of the generic model
% identifier                    | String                        | String to customize results message
%
%------------------------------------------------------------- OUTPUTS ------------------------------------------------------------
% avg_percent_rmse_kin          | 1 x 1 Double Array            | Computed average improvement for the kinematics
% avg_percent_rmse_grf          | 1 x 1 Double Array            | Computed average improvement for the GRFs
%
%----------------------------------------------------------- REQUIREMENTS ---------------------------------------------------------
% 
%
%----------------------------------------------------------------------------------------------------------------------------------

% Original Author: Menthy Denayer
% Date: 08/July/2026

% Last Update: Menthy Denayer
% Date: 08/July/2026   

%% Compute Average RMSE Improvement
percent_rmse_kin = (avg_rmse_list_kin_personal - avg_rmse_list_kin_generic)./avg_rmse_list_kin_generic*100;
percent_rmse_grf = (avg_rmse_list_grf_personal - avg_rmse_list_grf_generic)./avg_rmse_list_grf_generic*100;

avg_percent_rmse_kin = mean(percent_rmse_kin);
avg_percent_rmse_grf = mean(percent_rmse_grf);

% print results
fprintf(['\n** Printing RMSE Metrics for ' identifier ' **\n'])
if(avg_percent_rmse_kin > 0)
    fprintf('The RMSE INCREASED on average by %.2f%% for the kinematics\n', avg_percent_rmse_kin)
else
    fprintf('The RMSE DECREASED on average by %.2f%% for the kinematics\n', -avg_percent_rmse_kin)
end

if(avg_percent_rmse_grf > 0)
    fprintf('The RMSE INCREASED on average by %.2f%% for the ground reaction forces\n', avg_percent_rmse_grf)
else
    fprintf('The RMSE DECREASED on average by %.2f%% for the ground reaction forces\n', -avg_percent_rmse_grf)
end
end