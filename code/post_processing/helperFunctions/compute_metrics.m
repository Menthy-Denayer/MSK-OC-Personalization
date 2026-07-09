function [R_list, rmse_list, exp_match_list] = compute_metrics(data1, data2, std_data)
%% compute_metrics 
% Computes the following metrics:
%   - RMSE between data1 & data2
%   - Pearson correlation coefficient between data1 & data2
%   - Experimental match of data2 inside data1 +- std_data
%
% Assumes data1 & data2 represent same part of gait cycle & are synchronized!
%
%------------------------------------------------------------- INPUTS -------------------------------------------------------------
% data1                         | Ndata x Ncol Double Array     | First data matrix
% data2                         | Ndata x Ncol Double Array     | Second data matrix
% std_data                      | Ndata x Ncol Double Array     | Std data related to data1
%
%------------------------------------------------------------- OUTPUTS ------------------------------------------------------------
% R_list                        | Ncol x 1 Double Array         | List of computed Pearson correlation coefficients
% rmse_list                     | Ncol x 1 Double Array         | List of computed RMSEs
% exp_match_list                | Ncol x 1 Double Array         | List of computed experimental match values
%
%----------------------------------------------------------- REQUIREMENTS ---------------------------------------------------------
% 
%
%----------------------------------------------------------------------------------------------------------------------------------

% Original Author: Menthy Denayer
% Date: 08/July/2026

% Last Update: Menthy Denayer
% Date: 08/July/2026

%% Define Variables
Ncolumns = size(data1, 2);
R_list = zeros(Ncolumns, 1);
rmse_list = zeros(Ncolumns, 1);
exp_match_list = zeros(Ncolumns,1);

%% Loop Over Columns & Compute Metrics
for i = 1:Ncolumns
    R_list(i) = compute_pearson_corr_coeff(data1(:,i), data2(:,i));
    rmse_list(i) = compute_rmse(data1(:,i), data2(:,i));
    if(~isnan(std_data))
        exp_match_list(i) = compute_exp_match(data1(:,i), std_data(:,i), data2(:,i));
    end
end
end