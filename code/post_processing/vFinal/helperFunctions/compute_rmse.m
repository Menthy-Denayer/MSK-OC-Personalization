function rmse_res = compute_rmse(data1, data2)

%% compute_rmse 
% Computes the RMSE between data1 & data2
%
% Assumes data1 & data2 represent same part of gait cycle & are synchronized!
%
%------------------------------------------------------------- INPUTS -------------------------------------------------------------
% data1                         | Ndata x Ncol Double Array     | First data matrix
% data2                         | Ndata x Ncol Double Array     | Second data matrix
%
%------------------------------------------------------------- OUTPUTS ------------------------------------------------------------
% rmse_res                      | 1 x 1 Double                  | Computed RMSE
%
%----------------------------------------------------------- REQUIREMENTS ---------------------------------------------------------
% 
%
%----------------------------------------------------------------------------------------------------------------------------------

% Original Author: Menthy Denayer
% Date: 08/July/2026

% Last Update: Menthy Denayer
% Date: 08/July/2026

%% Compute RMSE
rmse_res = rmse(data1, data2);

end