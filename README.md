# Repository For Personalizing Predicitve MSK Simulations
This repository contains the processing code used for the paper on predictive MSK model personalization (see below). The repository is divided into different folders, containing the code, MSK models, experimental data etc. Final results can be found in the "vFinal" subfolder.

# Code
The "code" folder contains the code used for post-processing and personalization, built on top of the PredSim framework. We used [version 1.2.0 of PredSim](https://github.com/KULeuvenNeuromechanics/PredSim/releases/tag/v1.2.0) to run the final simulations, with minor changes to allow the personalization framework to work. The PredSim code can be found at: [PredSim-v1.2.0-Personalization](https://github.com/Menthy-Denayer/PredSim/tree/PredSim-v1.2.0-Personalization).

The post-processing code should be ready to run on your own device, to recreate the figures inside the manuscript, and the reported metrics. The code will ask you to select the results directory ("results" folder) and the experimental data (inside the "data" folder).

The "subject_settings" folder contains the settings structure for each subject used during the simulations.

_Note: the code has been designed to run on a high-performance super computer (VUB-HPC). Minor tweaks to the slurm scripts and file directories might be required to run the code on your own device, or your institution's high-performance computing platform._

# Data
The "data" folder contains the data used for validation ("MAT_normalizedIKData-gait2128-vOct2026.mat") and a summary of the metrics. The complete dataset can be found on FigShare (see below). Code used to process the raw data can be found at: [https://github.com/Menthy-Denayer/Data-Processing-Public.git](https://github.com/Menthy-Denayer/Data-Processing-Public.git).

# Musculoskeletal Models
The "models" folder contains all of the MSK models used to run the simulations.
- models containing 'mtu3D' are the generic models,
- models containing 'opt3D' are the personalized models,
- models containing 'Dhondt2024' are the extended models.

# Results
The "results" folder contains all of the simulation results. For each subject, we provide:
- the results for the extended model reported inside the manuscript (Dhondt2024_3seg),
- the results for personalization (calibration),
- the results for the generic (mtu3D) and personal (opt3D) models. The weighted results can also be found in these subfolders.

Additionally, each simulation is provided for N = 50 and N = 100 meshes. The difference can be studied using the [mesh sensitivity script](https://github.com/Menthy-Denayer/MSK-OC-Personalization/blob/main/code/post_processing/vFinal/compareMeshSensitivity.m).

# Citation
A paper describing the personalization framework is currenlty under submission.

The dataset can be found at:

> Denayer, M. (Creator), Turcksin, T. (Researcher), De Pauw, K. (Supervisor), Verstraten, T. (Supervisor) (2026). A Full-body Motion Capture Dataset for Bilateral Weighted Shank Walking. figshare Academic Research System. 10.6084/m9.figshare.30316372

> Denayer, M., Turcksin, T., De Pauw, K., & Verstraten, T. (2026). A Full-body Motion Capture Dataset for Bilateral Weighted Shank Walking. Scientific Data. https://doi.org/10.1038/s41597-026-08393-8
