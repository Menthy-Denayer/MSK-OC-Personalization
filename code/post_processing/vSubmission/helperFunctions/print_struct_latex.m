function print_struct_latex(struct, excludeFields, subFieldName, subFieldName2, colheaders, threshold, sign, notation)
%% print_struct_latex 
% Prints the data in the command window in Latex table format
%
%------------------------------------------------------------- INPUTS -------------------------------------------------------------
% struct                        | Matlab Structure                          | Structure containing the data
% excludeFields                 | String                                    | Name of the fields to exclude when printing
% subFieldName                  | String                                    | Name of the field in the structure to print
% subFieldName2                 | String                                    | Name of the subfield in the structure to print
% colheaders                    | Ncol x 1 String Array                     | List of the column names
% threshold                     | Double                                    | Threshold to bold text
% sign                          | Double                                    | Whether the data should be > than threshold (+) to be bold or < (-)
% notation                      | String                                    | Notation for printing numbers (default: %.2f)
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
fieldNames = string(fieldnames(struct));
fieldNames = fieldNames(~contains(fieldNames, excludeFields));
Nfields = length(fieldNames);

%% Generate Matrix
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

%% Print Matrix
print_matrix_latex(matrix, abs(matrix2), colheaders, strrep(fieldNames,"_"," "), dataMask, notation)
end