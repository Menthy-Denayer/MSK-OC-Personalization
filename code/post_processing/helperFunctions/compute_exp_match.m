function exp_match = compute_exp_match(exp_mean, exp_std, pred_mean)
%% compute_pearson_corr_coeff 
% Computes percentage of gait cylce for which pred_mean lies within 
% exp_mean +- exp_std
%
%------------------------------------------------------------- INPUTS -------------------------------------------------------------
% exp_mean                      | Ndata x 1 Double Array        | Experimental average
% exp_std                       | Ndata x 1 Double Array        | Experimental standard deviation
% pred_mean                     | Ndata x 1 Double Array        | Prediction average
%
%------------------------------------------------------------- OUTPUTS ------------------------------------------------------------
% exp_match                     | 1 x 1 Double                  | Computed experimental match
%
%----------------------------------------------------------- REQUIREMENTS ---------------------------------------------------------
% 
%
%----------------------------------------------------------------------------------------------------------------------------------

% Original Author: Menthy Denayer
% Date: 08/July/2026

% Last Update: Menthy Denayer
% Date: 08/July/2026

%% Compute Experimental Match

if(all(isnan(exp_std)))
    exp_match = NaN;
else
    
    Ndata = size(pred_mean,1);

    low_bound = exp_mean - exp_std;
    upp_bound = exp_mean + exp_std;

    withinBounds = (pred_mean >= low_bound) & (pred_mean <= upp_bound);
    exp_match = sum(withinBounds)/Ndata*100;
end
end