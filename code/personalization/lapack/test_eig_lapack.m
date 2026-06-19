% test_eig_lapack.m
% Simple test for eig_lapack mex function

%% Add path to linear algebra
% addpath("/data/brussel/112/vsc11236/PredSim/LinearAlgebra")

% Create a random symmetric matrix
n = 5;  % size of the matrix
A = randn(n);
C = (A + A')/2;  % make symmetric

% Compute eigen decomposition using MATLAB
[V_matlab, D_matlab] = eig(C);

% Compute eigen decomposition using our lapack mex
[B,D] = eig_lapack(C);

% Compare results
fprintf('MATLAB eigenvalues:\n');
disp(diag(D_matlab)');

fprintf('eig_lapack eigenvalues:\n');
disp(diag(D)');

fprintf('Difference in eigenvectors (Frobenius norm): %g\n', norm(B - V_matlab, 'fro'));

% Check if eigen decomposition reconstructs the original matrix
C_reconstructed = B * D * B';
fprintf('Reconstruction error (Frobenius norm): %g\n', norm(C - C_reconstructed, 'fro'));
