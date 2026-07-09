% Function to read the desired data for the desired subjects
function [lMtildeSync, lTtildeSync, FMtildeSync, FMpasstildeSync, muscleColHeaders] = get_muscle_data(NmuscleCol, resampTime, desDIR, desFolders, desSubFolder, keywords)

    Nsubj = length(desFolders);
    Ndata = length(resampTime);

    lMtildeSync = NaN(Ndata, NmuscleCol, Nsubj);
    lTtildeSync = NaN(Ndata, NmuscleCol, Nsubj); 
    FMtildeSync = NaN(Ndata, NmuscleCol, Nsubj);
    FMpasstildeSync = NaN(Ndata, NmuscleCol, Nsubj);
    
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

                % pennAngle1 = acos((data.R.muscles.lMT-data.R.muscles.lT)./data.R.muscles.lM)*180/pi;
                % 
                % arg = real( data.R.muscles.FT./(data.R.muscles.Fpass+data.R.muscles.Fce) );
                % arg(arg>1) = 1;                                                             % acos(>1) = complex
                % pennAngle2 = acos(arg)*180/pi;
                % 
                % for i = 1:length(Tslk)/2
                %     figure
                %     hold on
                %     plot(timeData, pennAngle1(:,i),"k")
                %     plot(timeData, pennAngle2(:,i),"r--")
                %     hold off
                % end

            end
        end
    end

    if(~isempty(dataFiles))
        muscleColHeaders = string(data.R.colheaders.muscles);
    else
        muscleColHeaders = NaN;
    end

end
