function [lMtildeSync, lTtildeSync, FMtildeSync, FMpasstildeSync, muscleColHeaders] = get_muscle_data(NmuscleCol, resampTime, desDIR, desFolders, desSubFolder, keywords)
%% draw_arrow 
% Function to read the desired data for the desired subjects
%
%------------------------------------------------------------- INPUTS -------------------------------------------------------------
% DIR                           | String                                    | Path to the directory containing all subject results
% SUBJID                        | Double                                    | Subject ID
% NmuscleCol                    | Double                                    | Number of muscle columns
% resampTime                    | Ndata x 1 Double Array                    | Time vector to resample to
% desDIR                        | String                                    | Path to the directory containing all the results
% desFolders                    | Nsubj x 1 String Array                    | List of folders containing results
% desSubFolder                  | Nsubj x 1 String Array                    | List of subfolders containing results
% keywords                      | String                                    | Keyword to identify correct results files
%
%------------------------------------------------------------- OUTPUTS ------------------------------------------------------------
% lMtildeSync                   | Ndata x Nemg x Nsubj Double Array         | Syncrhonized fibre lengths
% lTtildeSync                   | Ndata x Nemg x Nsubj Double Array         | Synchronized tendon slack lengths
% FMtildeSync                   | Ndata x Nemg x Nsubj Double Array         | Synchronized muscle forces
% FMpasstildeSync               | Ndata x Nemg x Nsubj Double Array         | Synchronized passive muscle forces
% muscleColHeaders              | Nemg x 1 String Array                     | EMG column headers
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
Nsubj = length(desFolders);
Ndata = length(resampTime);

lMtildeSync = NaN(Ndata, NmuscleCol, Nsubj);
lTtildeSync = NaN(Ndata, NmuscleCol, Nsubj); 
FMtildeSync = NaN(Ndata, NmuscleCol, Nsubj);
FMpasstildeSync = NaN(Ndata, NmuscleCol, Nsubj);

%% Loop Over Subjects
for subj = 1:Nsubj
    currentDIR = desDIR+"/"+desFolders(subj);
    if(~isempty(desSubFolder))
        currentDIR = currentDIR + "/" + desSubFolder(subj);
    end
    dirInfo = dir(currentDIR);
    Files = string({dirInfo.name});
    dataFiles = Files(contains(Files,keywords) & endsWith(Files,".mat"));
    Nfiles = length(dataFiles);
    if(~isempty(dataFiles))
        for fileIdx = 1:Nfiles
            data = load(fullfile(currentDIR,dataFiles(fileIdx)));

            lMtilde = data.R.muscles.lMtilde;
            Tslk = [data.model_info.muscle_info.parameters.lTs];
            lTtilde = data.R.muscles.lT./Tslk;
            FMopt = [data.model_info.muscle_info.parameters.FMo];
            FMtilde = data.R.muscles.Fce./FMopt;
            FMpasstilde = data.R.muscles.Fpass./FMopt;
            timeData = data.R.time.mesh_GC(1:end-1);

            lMtildeSync(:,:,subj, fileIdx) = synchronizeData(resampTime, timeData, lMtilde);
            lTtildeSync(:,:,subj, fileIdx) = synchronizeData(resampTime, timeData, lTtilde);
            FMtildeSync(:,:,subj, fileIdx) = synchronizeData(resampTime, timeData, FMtilde);
            FMpasstildeSync(:,:,subj, fileIdx) = synchronizeData(resampTime, timeData, FMpasstilde);
        end
    end
end

if(~isempty(dataFiles))
    muscleColHeaders = string(data.R.colheaders.muscles);
else
    muscleColHeaders = NaN;
end

end
