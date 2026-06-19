function print_struct_latex(struct, excludeFields, subFieldName, subFieldName2, colheaders, threshold, sign, notation)
    fieldNames = string(fieldnames(struct));
    fieldNames = fieldNames(~contains(fieldNames, excludeFields));
    Nfields = length(fieldNames);

    Ncases = length(struct.(fieldNames(1)).(subFieldName));
    matrix = zeros(Nfields, Ncases);
    if(~isempty(subFieldName2))
        matrix2 = zeros(Nfields, Ncases);
    else
        matrix2 = [];
    end

    for i = 1:Nfields
        matrix(i,:) = struct.(fieldNames(i)).(subFieldName);
        if(~isempty(subFieldName2)) 
            matrix2(i,:) = struct.(fieldNames(i)).(subFieldName2);
        end
    end

    if(sign > 0)
        dataMask = matrix > threshold;
    else
        dataMask = matrix < threshold;
    end

    print_matrix_latex(matrix, abs(matrix2), colheaders, strrep(fieldNames,"_"," "), dataMask, notation)
end