function print_matrix_latex(matrix, std_matrix, colheaders, rownames, dataMask, notation)
%% print_matrix_latex 
% Prints the data in the command window in Latex table format
%
%------------------------------------------------------------- INPUTS -------------------------------------------------------------
% matrix                        | Nrow x Ncol Double Array      | Data matrix
% std_matrix                    | Nrow x Ncol Double Array      | Optional: standard deviation matrix
% colheaders                    | Ncol x 1 String Array         | Names of the columns
% rownames                      | Nrow x 1 String Array         | Names of the rows
% dataMask                      | Nrow x Ncol Double Array      | Optional: mask to make values bold (should be 1/0)
% notation                      | String                        | Optional: notation of the numbers (default: %.2f)
%
%------------------------------------------------------------- OUTPUTS ------------------------------------------------------------
%
%
%----------------------------------------------------------- REQUIREMENTS ---------------------------------------------------------
% 
%
%----------------------------------------------------------------------------------------------------------------------------------

% Original Author: Menthy Denayer
% Date: 09/July/2026

% Last Update: Menthy Denayer
% Date: 09/July/2026

%% Print Matrix in Latex Format
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