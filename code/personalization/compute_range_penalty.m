function p = compute_range_penalty(data, min_allow, max_allow)
%% compute_range_penalty 
% - Computes a penalty when data exceeds the allowed range
%
%------------------------------------------------------------- INPUTS -------------------------------------------------------------
% data                          | Ndata x Ncol Double Array     | Data matrix
% min_allow                     | struct                        | Lower boundary
% max_allow                     | struct                        | Upper boundary
%
%------------------------------------------------------------- OUTPUTS ------------------------------------------------------------
% p                             | Double                        | Total computed fitness value
%
%----------------------------------------------------------- REQUIREMENTS ---------------------------------------------------------
% 
%
%----------------------------------------------------------------------------------------------------------------------------------

% Original Author: Menthy Denayer
% Date: 29/November/2025

% Last Update: Menthy Denayer
% Date: 29/November/2025
    
%% Define Variables
Ndata = size(data,1);
Ncol = size(data,2);

p = 0;
% Loop over all the columns
for i = 1:Ncol
    pcol = 0;
    % Loop over all the data
    for j = 1:Ndata
        p_max = max([0, data(j,i) - max_allow]);                            % If data > max, add penalty
        p_min = max([0, min_allow - data(j,i)]);                            % If data < min, add penalty
        pcol = pcol + p_min + p_max;
    end
    % Add average over all the data
    p = p + pcol/Ndata;
end

end