function folders = find_desired_folders(DIR, SUBJID)
%% draw_arrow 
% Function to retrieve the desired folders from a directory for the given 
% subject IDs
%
%------------------------------------------------------------- INPUTS -------------------------------------------------------------
% DIR                           | String                                    | Path to the directory containing all subject results
% SUBJID                        | Double                                    | Subject ID
%
%------------------------------------------------------------- OUTPUTS ------------------------------------------------------------
% folders                       | Nsubj x 1 String Array                    | List of subject folders
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
dirInfo = dir(DIR);
folderNames = string({dirInfo.name});
isSUBJ = contains(folderNames,"SUBJ") & cell2mat({dirInfo.isdir});
SUBJidxs = double(strrep(folderNames(isSUBJ),"SUBJ",""));

if(~isempty(SUBJID))
    Nsubj = length(SUBJID);
    trailingZero = strings(1,Nsubj); isSmallerTen = SUBJID<10; trailingZero(isSmallerTen) = "0";
    folders = "SUBJ" + trailingZero + SUBJID;
else
    Nsubj = length(SUBJidxs);
    trailingZero = strings(1,Nsubj); isSmallerTen = SUBJidxs<10; trailingZero(isSmallerTen) = "0";
    folders = "SUBJ" + trailingZero + SUBJidxs;
end

end