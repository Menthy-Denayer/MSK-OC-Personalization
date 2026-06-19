function print_matrix_latex(matrix, std_matrix, colheaders, rownames, dataMask, notation)
    % print matrix in Latex format
    Nrow = size(matrix,1);
    Ncol = size(matrix,2);

    if(isempty(notation))
        notation = '%.2f';
    end

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
                fprintf(token)
            elseif(i == 1 && j > 1)
                fprintf('\\textbf{' + string(colheaders(j-1)) + '} ' + token)
            elseif(i > 1 && j == 1)
                fprintf('\\textbf{' + string(rownames(i-1)) + '} ' + token)
            elseif(matrix(i-1,j-1) == i || dataMask(i-1,j-1) == 1 && ~isempty(std_matrix))
                fprintf(['\\textbf{' notation '$\\pm$ ' notation '} ' token], matrix(i-1,j-1), std_matrix(i-1,j-1))
            elseif(matrix(i-1,j-1) == i || dataMask(i-1,j-1) == 1)
                fprintf(['\\textbf{' notation '} ' token], matrix(i-1,j-1))
            elseif(~isempty(std_matrix))
                fprintf([notation '$\\pm$ ' notation ' ' token], matrix(i-1,j-1), std_matrix(i-1,j-1))
            else
                fprintf([notation ' ' token], matrix(i-1,j-1))
            end
        end
        fprintf('\n')
    end

end