function write_tex_latex(matrix, std_matrix, colheaders, rownames, dataMask, outputFile, notation)
%% write_tex_latex 
% Writes the data in Latex table format
%
%------------------------------------------------------------- INPUTS -------------------------------------------------------------
% matrix                        | Nrow x Ncol Double Array      | Data matrix
% std_matrix                    | Nrow x Ncol Double Array      | Optional: standard deviation matrix
% colheaders                    | Ncol x 1 String Array         | Names of the columns
% rownames                      | Nrow x 1 String Array         | Names of the rows
% dataMask                      | Nrow x Ncol Double Array      | Optional: mask to make values bold (should be 1/0)
% outputFile                    | String                        | Name of the output file
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

%% Define Variables
Nrow = size(matrix,1);
Ncol = size(matrix,2);

if(isempty(notation))
    notation = '%.2f';
end

if(isempty(dataMask))
    dataMask = zeros(Nrow, Ncol);
end

fileID = fopen(outputFile,'w');

%% Print Data
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