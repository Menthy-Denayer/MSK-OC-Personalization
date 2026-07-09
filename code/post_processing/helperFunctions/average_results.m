function [kinDataAvg, grfDataAvg, kitDataAvg, emgDataAvg, velData, massData, costData, idx_stanceL, kinColHeaders, grfColHeaders, emgColHeaders] = average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, desDIR, desFolders, desSubFolder, keywords, Nworkers)
%% average_results 
% Function to read the desired data for the desired subjects
%
%------------------------------------------------------------- INPUTS -------------------------------------------------------------
% resampTime                    | Ndata x 1 Double Array                        | Desired time to resample to
% Nkincol                       | Double                                        | Number of kinematics columns
% Ngrfcol                       | Double                                        | Number of GRF columns
% Nemgcol                       | Double                                        | Number of EMG columns
% desDIR                        | String                                        | Path to the directory containing result files
% desFolders                    | Nsubj x 1 String Array                        | List of folder names containing results for each subject 
% desSubFolder                  | Nsubj x 1 String Array                        | List of subfolders containing the results for each subject
% keywords                      | String                                        | Keyword used to identify the desired results file
% Nworkers                      | Double                                        | Number of results iterations (e.g. when loading weighted results)
%
%------------------------------------------------------------- OUTPUTS ------------------------------------------------------------
% kinDataAvg                    | Ndata x Nsubj x Nkin x Nworkers Double Array  | Synchronized kinematics for each condition
% grfDataAvg                    | Ndata x Nsubj x Ngrf x Nworkers Double Array  | Synchronized GRFs for each condition
% kitDataAvg                    | Ndata x Nsubj x Nkit x Nworkers Double Array  | Synchronized kinetics for each condition
% emgDataAvg                    | Ndata x Nsubj x Nemg x Nworkers Double Array  | Synchronized EMGs for each condition
% velData                       | Nsubj x Nworkers Double Array                 | Average forward velocities for each condition
% massData                      | Nsubj x Nworkers Double Array                 | Body mass for each condition
% costData                      | Nsubj x Nworkers Double Array                 | Absolute cost function value for each condition
% idx_stanceL                   | Nsubj x Nworkers Double Array                 | Left stance starts index for each condition
% kinColHeaders                 | Nkin x 1 String Array                         | Names of the kinematics columns
% grfColHeaders                 | Ngrf x 1 String Array                         | Names of the GRF columns
% emgColHeaders                 | Nemg x 1 String Array                         | Names of the EMG columns
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

kinDataAvg = NaN(Ndata, Nkincol, Nsubj, Nworkers);
grfDataAvg = NaN(Ndata, Ngrfcol, Nsubj, Nworkers); 
kitDataAvg = NaN(Ndata, Nkincol, Nsubj, Nworkers); 
emgDataAvg = NaN(Ndata, Nemgcol, Nsubj, Nworkers);
velData = NaN(Nsubj,Nworkers);
massData = NaN(Nsubj,Nworkers);
idx_stanceL = NaN(Nsubj,Nworkers);
costData = NaN(Nsubj,Nworkers);

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

            % disp(dataFiles(fileIdx))
            if(~strcmp(data.stats.return_status,"Solve_Succeeded"))
                disp("error, return status is incorrect")
            end

            if(~strcmp(data.stats.unified_return_status,"SOLVER_RET_SUCCESS"))
                disp("error, the unified return status is incorrect")
            end

            if(~data.stats.success)
                disp("error, no success")
            end
            
            if(data.stats.iter_count > 2e3)
                disp("iteration count > 2e3")
            end

            % remove MTP joint from data (passive joint)
            isMTP = contains(data.R.colheaders.coordinates,"mtp");

            kinData = data.R.kinematics.Qs(:,~isMTP);
            grfData = [data.R.ground_reaction.GRF_r data.R.ground_reaction.GRF_l];
            kitData = data.R.kinetics.T_ID(:,~isMTP);
            emgData = data.R.muscles.a;
            velData(subj, fileIdx) = data.R.S.misc.forward_velocity;
            massData(subj, fileIdx) = data.model_info.mass;
            timeData = data.R.time.mesh_GC(1:end-1);
            costData(subj, fileIdx) = sum(data.R.objective.absoluteValues);

            % find left heel strike
            l_stance_idx = find(data.R.ground_reaction.idx_stance_l(2:end)-data.R.ground_reaction.idx_stance_l(1:end-1) > 1) + 1;
            idx_stanceL(subj, fileIdx) = data.R.ground_reaction.idx_stance_l(l_stance_idx(1));

            kinDataAvg(:,:,subj, fileIdx) = synchronizeData(resampTime, timeData, kinData);
            grfDataAvg(:,:,subj, fileIdx) = synchronizeData(resampTime, timeData, grfData);
            kitDataAvg(:,:,subj, fileIdx) = synchronizeData(resampTime, timeData, kitData);
            emgDataAvg(:,:,subj, fileIdx) = synchronizeData(resampTime, timeData, emgData);
        end
    end
end

%% Return Colheaders
grfColHeaders = "GRF" + ["Right x" "Right y" "Right z" "Left x" "Left y" "Left z"];

if(~isempty(dataFiles))
    kinColHeaders = string(data.R.colheaders.coordinates(~isMTP));
    emgColHeaders = string(data.R.colheaders.muscles);
else
    kinColHeaders = NaN;
    emgColHeaders = NaN;
end

end
