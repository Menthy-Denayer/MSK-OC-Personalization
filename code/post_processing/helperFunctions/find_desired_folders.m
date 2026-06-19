% Function to retrieve the desired folders from a directory for the given subject IDs
function folders = find_desired_folders(DIR, SUBJID)
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