function write_tex_latex(matrix, std_matrix, colheaders, rownames, dataMask, outputFile, notation)
    % print matrix in Latex format
    Nrow = size(matrix,1);
    Ncol = size(matrix,2);

    if(isempty(notation))
        notation = '%.2f';
    end

    if(isempty(dataMask))
        dataMask = zeros(Nrow, Ncol);
    end

    fileID = fopen(outputFile,'w');

    % print data
    for i = 1:Nrow+1
        for j = 1:Ncol+1
            if(j < Ncol+1)
                token = '& ';
            elseif(i == 1 && j == Ncol + 1)
                token = '\\\\ \\hline';
            else
                token = '\\\\';
            end

            if(i == 1 && j == 1)
                fprintf(fileID, token);
            elseif(i == 1 && j > 1)
                fprintf(fileID, '\\textbf{' + string(colheaders(j-1)) + '} ' + token);
            elseif(i > 1 && j == 1)
                fprintf(fileID, '\\textbf{' + string(rownames(i-1)) + '} ' + token);
            elseif(matrix(i-1,j-1) == i || dataMask(i-1,j-1) == 1 && ~isempty(std_matrix))
                fprintf(fileID, ['\\textbf{' notation '$\\pm$ ' notation '} ' token], matrix(i-1,j-1), std_matrix(i-1,j-1));
            elseif(matrix(i-1,j-1) == i || dataMask(i-1,j-1) == 1)
                fprintf(fileID, ['\\textbf{' notation '} ' token], matrix(i-1,j-1));
            elseif(~isempty(std_matrix))
                fprintf(fileID, [notation '$\\pm$ ' notation ' ' token], matrix(i-1,j-1), std_matrix(i-1,j-1));
            else
                fprintf(fileID, [notation ' ' token], matrix(i-1,j-1));
            end
        end
        fprintf(fileID, '\n');
    end

    fclose(fileID);

end