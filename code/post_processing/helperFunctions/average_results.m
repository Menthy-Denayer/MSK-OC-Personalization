% Function to read the desired data for the desired subjects
function [kinDataAvg, grfDataAvg, kitDataAvg, emgDataAvg, velData, massData, costData, idx_stanceL, kinColHeaders, grfColHeaders, emgColHeaders] = average_results(resampTime, Nkincol, Ngrfcol, Nemgcol, desDIR, desFolders, desSubFolder, keywords, Nworkers)

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
    
    % loop over subjects
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
                    disp("error")
                end
                
                if(data.stats.iter_count > 2e3)
                    disp("iteration count > 2e3")
                end

                % remove MTP joint from data (temporary!)
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
    
    % Return colheaders
    grfColHeaders = "GRF" + ["Right x" "Right y" "Right z" "Left x" "Left y" "Left z"];

    if(~isempty(dataFiles))
        kinColHeaders = string(data.R.colheaders.coordinates(~isMTP));
        emgColHeaders = string(data.R.colheaders.muscles);
    else
        kinColHeaders = NaN;
        emgColHeaders = NaN;
    end

end
