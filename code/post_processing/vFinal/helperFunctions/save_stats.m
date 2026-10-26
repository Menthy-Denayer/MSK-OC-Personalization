function struct = save_stats(struct, name, pList, dzList, deltaList, stdList)
%% save_stats 
% Saves the statistical results in a structure
%
%------------------------------------------------------------- INPUTS -------------------------------------------------------------
% struct                        | Matlab Structure                          | Structure containing the data
% name                          | String                                    | Fieldname
% pList                         | Ndata x 1 Double Array                    | List of p-values
% dzList                        | Ndata x 1 Double Array                    | List of dz-values
% deltaList                     | Ndata x 1 Double Array                    | List of deltas 
% stdList                       | Ndata x 1 Double Array                    | List of standard deviations 
%
%------------------------------------------------------------- OUTPUTS ------------------------------------------------------------
% struct                        | Matlab Structure                          | Structure containing the data
%
%----------------------------------------------------------- REQUIREMENTS ---------------------------------------------------------
% 
%
%----------------------------------------------------------------------------------------------------------------------------------

% Original Author: Menthy Denayer
% Date: 09/July/2026

% Last Update: Menthy Denayer
% Date: 09/July/2026

%% Save Data
name = strrep(name," ", "_");
struct.(name).p = pList;
struct.(name).dz = dzList;
struct.(name).delta = deltaList;
struct.(name).std = stdList;
end