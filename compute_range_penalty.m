function p = compute_range_penalty(data, min_allow, max_allow)
% computes a penalty based on when data exceeds the given range
    
    Ndata = size(data,1);
    Ncol = size(data,2);
    
    p = 0;
    for i = 1:Ncol
        pcol = 0;
        for j = 1:Ndata
            p_max = max([0, data(j,i) - max_allow]);
            p_min = max([0, min_allow - data(j,i)]);
            pcol = pcol + p_min + p_max;
        end
        p = p + pcol/Ndata;
    end

end