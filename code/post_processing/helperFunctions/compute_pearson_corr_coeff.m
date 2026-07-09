function r = compute_pearson_corr_coeff(data1, data2)

%% compute_pearson_corr_coeff 
% Computes the Pearson correlation coefficient between data1 & data2
%
% Assumes data1 & data2 represent same part of gait cycle & are synchronized!
%
%------------------------------------------------------------- INPUTS -------------------------------------------------------------
% data1                         | Ndata x Ncol Double Array     | First data matrix
% data2                         | Ndata x Ncol Double Array     | Second data matrix
%
%------------------------------------------------------------- OUTPUTS ------------------------------------------------------------
% r                             | 1 x 1 Double                  | Computed correlation coefficient
%
%----------------------------------------------------------- REQUIREMENTS ---------------------------------------------------------
% 
%
%----------------------------------------------------------------------------------------------------------------------------------

% Original Author: Menthy Denayer
% Date: 08/July/2026

% Last Update: Menthy Denayer
% Date: 08/July/2026

%% Compute Pearson Correlation Coefficient    
n = length(data1);                                  % length of data array

sumx = sum(data1);                                  % sum of data elements list 1
sumx2 = sum(data1.^2);                              % data elements squared list 1
sumy = sum(data2);                                  % sum of data elements list 2
sumy2 = sum(data2.^2);                              % data elements squared list 2
sumxy = sum(data1.*data2);                          % dot product list 1 & list 2

num = n*sumxy - sumx*sumy;                          % numerator
den2 = (n*sumx2 - (sumx)^2)*(n*sumy2 - (sumy)^2);   % denumerator squared

r = num/sqrt(den2);                                 % Pearson correlation coefficient 

end