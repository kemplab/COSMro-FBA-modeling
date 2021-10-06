clear; clc; close all
format long
addpath(genpath('files'))

tic

%% READ INPUTS - GENERAL

% load data
[~,~,raw] = xlsread('start.xlsx','General');

% type of analysis
for row = 2:5
    value = raw(row,1);
    value = value{1};
    
    if ~isnan(value)
        if isstr(value)
            if strcmp(upper(value),'X')
                if exist('type_of_analysis')
                    error('ERROR - General - Type of analysis - Can only choose one type of analysis')
                else
                    type_of_analysis = row - 1;
                end
            else
                error('ERROR - General - Type of analysis - Values must either be X or blank')
            end
        else
            error('ERROR - General - Type of analysis - Values must either be X or blank')
        end
    end
end
if ~exist('type_of_analysis')
    error('ERROR - General - Must select one type of analysis')
end
    
% pfba fractions
if type_of_analysis == 2

    pfba_fractions = [];
    for col = 1:10
        value = raw(10,col);
        value = value{1};

        if ~isnan(value)
            if isfloat(value)
                if (value > 0) && (value <= 1)
                    pfba_fractions(end+1) = value;
                else
                    error('ERROR - General - pFBA fractions - Values must be >0 and <= 1')
                end
            else
                error('ERROR - General - pFBA fractions - Values must be numbers')
            end
        end
    end
    if isempty(pfba_fractions)
        error('ERROR - General - pFBA fractions - Must enter at least one value')
    end
    if sum(sort(pfba_fractions,'descend')==pfba_fractions) ~= length(pfba_fractions)
        error('ERROR - General - pFBA fractions - Values must be in descending order')
    end
    for i = 1:length(pfba_fractions)
        for j = i+1:length(pfba_fractions)
            if pfba_fractions(i) == pfba_fractions(j)
                error('ERROR - General - pFBA fractions - Cannot have duplicate values')
            end
        end
    end
end

% fva variables
if type_of_analysis == 3
    
    fva_variables = {};
    for row = 14:21
        value = raw(row,1);
        value = value{1};
    
        if ~isnan(value)
            if isstr(value)
                if strcmp(upper(value),'X')
                    switch row
                        case 14, fva_variables{end+1} = 'flux_obj';
                        case 15, fva_variables{end+1} = 'flux_nonobj';
                        case 16, fva_variables{end+1} = 'state_obj';
                        case 17, fva_variables{end+1} = 'state_nonobj';
                        case 18, fva_variables{end+1} = 'deltag_obj';
                        case 19, fva_variables{end+1} = 'deltag_nonobj';
                        case 20, fva_variables{end+1} = 'concentration_obj';
                        case 21, fva_variables{end+1} = 'concentration_nonobj';
                    end         
                else
                    error('ERROR - General - FVA variables - Values must either be X or blank')
                end
            else
                error('ERROR - General - FVA variables - Values must either be X or blank')
            end
        end
    end
    if isempty(fva_variables)
        error('ERROR - General - FVA variables - Must select at least one option')
    end
end

% fva fraction
if type_of_analysis == 3
    value = raw(25,1);
    value = value{1};
    
    if ~isnan(value)
        if isfloat(value)
            if (value >= 0) && (value <= 1)
                fva_fraction = value;
            else
                error('ERROR - General - FVA fraction - Values must be >=0 and <= 1')
            end
        else
            error('ERROR - General - FVA fraction - Value must be a number')
        end
    end
    if ~exist('fva_fraction')
        error('ERROR - General - FVA fraction - Must enter value')
    end
end

% random sampling minvalid
if type_of_analysis == 4
    value = raw(28,1);
    value = value{1};

    if ~isnan(value)
        if isfloat(value)
            if mod(value,1) == 0
                if value >= 1
                    random_sampling_minvalid = value;
                else
                    error('ERROR - General - Random Sampling MinValid - Value must be >=1')
                end
            else
                error('ERROR - General - Random Sampling MinValid - Value must be an integer')
            end
        else
            error('ERROR - General - Random Sampling MinValid - Value must be a number')
        end
    end
    if ~exist('random_sampling_minvalid')
        error('ERROR - General - Random Sampling MinValid - Must enter value')
    end
end

%% READ INPUTS - OBJECTIVE FUNCTION

% load data
[~,~,raw] = xlsread('start.xlsx','Objective Function');

% objective function
for row = 2:15
    value = raw(row,1);
    value = value{1};

    if ~isnan(value)
        if isstr(value)
            if strcmp(upper(value),'X')
                if exist('objective_function')
                    error('ERROR - Objective Function - Can only choose one objective function')
                else
                    objective_function = row - 1;
                end
            else
                error('ERROR - Objective Function - Values must either be X or blank')
            end
        else
            error('ERROR - Objective Function - Values must either be X or blank')
        end
    end
end
if ~exist('objective_function')
    error('ERROR - Objective Function - Must choose an objective function')
end

%% READ INPUTS - SAMPLES

% load data
[~,~,raw] = xlsread('start.xlsx','Samples');
samples = {};

% samples - first column
for row = [3:14,16:20,22:24,26:38,40:51,53:56]
    value = raw(row,1);
    value = value{1};

    if ~isnan(value)
        if isstr(value)
            if strcmp(upper(value),'X')
                switch row
                    case 3, samples{end+1} = 'monocyte';
                    case 4, samples{end+1} = 'neutrophil';
                    case 5, samples{end+1} = 'b-lymphocyte';
                    case 6, samples{end+1} = 't-lymphocyte';
                    case 7, samples{end+1} = 'cd4-t-cells';
                    case 8, samples{end+1} = 'cd8-t-cells';
                    case 9, samples{end+1} = 'nk-cells';
                    case 10, samples{end+1} = 'periph-blood-mononuclear-cells';
                    case 11, samples{end+1} = 'lymph-node';
                    case 12, samples{end+1} = 'tonsil';
                    case 13, samples{end+1} = 'bone-marrow-stromal-cell';
                    case 14, samples{end+1} = 'bone-marrow-mesench-stem-cell';
                    case 16, samples{end+1} = 'brain';
                    case 17, samples{end+1} = 'frontal-cortex';
                    case 18, samples{end+1} = 'cerebral-cortex';
                    case 19, samples{end+1} = 'spinal-cord';
                    case 20, samples{end+1} = 'retina';
                    case 22, samples{end+1} = 'heart';
                    case 23, samples{end+1} = 'bone';
                    case 24, samples{end+1} = 'colon-muscle';
                    case 26, samples{end+1} = 'oral-epithelium';
                    case 27, samples{end+1} = 'nasopharynx';
                    case 28, samples{end+1} = 'nasal-respiratory-epithelium';
                    case 29, samples{end+1} = 'esophagus';
                    case 30, samples{end+1} = 'stomach';
                    case 31, samples{end+1} = 'cardia';
                    case 32, samples{end+1} = 'colon';
                    case 33, samples{end+1} = 'rectum';
                    case 34, samples{end+1} = 'liver';
                    case 35, samples{end+1} = 'kidney';
                    case 36, samples{end+1} = 'spleen';
                    case 37, samples{end+1} = 'lung';
                    case 38, samples{end+1} = 'adipocyte';
                    case 40, samples{end+1} = 'salivary-gland';
                    case 41, samples{end+1} = 'thyroid';
                    case 42, samples{end+1} = 'adrenal';
                    case 43, samples{end+1} = 'breast';
                    case 44, samples{end+1} = 'pancreas';
                    case 45, samples{end+1} = 'islet-of-langerhans';
                    case 46, samples{end+1} = 'gallbladder';
                    case 47, samples{end+1} = 'prostate';
                    case 48, samples{end+1} = 'urinary-bladder';
                    case 49, samples{end+1} = 'skin';
                    case 50, samples{end+1} = 'hair-follicle';
                    case 51, samples{end+1} = 'placenta';
                    case 53, samples{end+1} = 'uterus';
                    case 54, samples{end+1} = 'cervix';
                    case 55, samples{end+1} = 'ovary';
                    case 56, samples{end+1} = 'testis';
                end
            else
                error('ERROR - Samples - Values must either be X or blank')
            end
        else
            error('ERROR - Samples - Values must either be X or blank')
        end
    end
end

% samples - second column
for row = [3:5,7:8,10,12:19,21:23,25:29]
    value = raw(row,6);
    value = value{1};

    if ~isnan(value)
        if isstr(value)
            if strcmp(upper(value),'X')
                switch row
                    case 3, samples{end+1} = 't-cell-leukemia-jurkat';
                    case 4, samples{end+1} = 'myeloid-leukemia-k562';
                    case 5, samples{end+1} = 'lymphoblastic-leukemia-ccrf-cem';
                    case 7, samples{end+1} = 'brain-cancer-u251';
                    case 8, samples{end+1} = 'brain-cancer-gamg';
                    case 10, samples{end+1} = 'bone-cancer-u2os';
                    case 12, samples{end+1} = 'kidney-hek293';
                    case 13, samples{end+1} = 'liver-cancer-huh-7';
                    case 14, samples{end+1} = 'liver-cancer-hepg22';
                    case 15, samples{end+1} = 'nsc-lung-cancer-nci-h460';
                    case 16, samples{end+1} = 'lung-cancer-a549';
                    case 17, samples{end+1} = 'kidney-cancer-rxf393';
                    case 18, samples{end+1} = 'colon-cancer-rko';
                    case 19, samples{end+1} = 'colon-cancer-colo205';
                    case 21, samples{end+1} = 'melanoma-m14';
                    case 22, samples{end+1} = 'breast-cancer-lcc2';
                    case 23, samples{end+1} = 'breast-cancer-mcf7';
                    case 25, samples{end+1} = 'ovarian-cancer-skov3';
                    case 26, samples{end+1} = 'prostate-cancer-lncap';
                    case 27, samples{end+1} = 'prostate-cancer-pc3';
                    case 28, samples{end+1} = 'cervical-cancer-hela-S3';
                    case 29, samples{end+1} = 'cervical-cancer-hela';
                end
            else
                error('ERROR - Samples - Values must either be X or blank')
            end
        else
            error('ERROR - Samples - Values must either be X or blank')
        end
    end
end  

% samples - third column
for row = [3,5:8]
    value = raw(row,11);
    value = value{1};

    if ~isnan(value)
        if isstr(value)
            if strcmp(upper(value),'X')
                switch row
                    case 3, samples{end+1} = 'cal-27';
                    case 5, samples{end+1} = 'scc-61-nomims';
                    case 6, samples{end+1} = 'scc-61';
                    case 7, samples{end+1} = 'rscc-61-nomims';
                    case 8, samples{end+1} = 'rscc-61';
                end
            else
                error('ERROR - Samples - Values must either be X or blank')
            end
        else
            error('ERROR - Samples - Values must either be X or blank')
        end
    end
end
if isempty(samples)
    error('ERROR - Samples - Must choose at least one sample')
end

%% READ INPUTS - MEDIA

% load data
[~,~,raw] = xlsread('start.xlsx','Media');

% media
for row = 2:2
    value = raw(row,1);
    value = value{1};

    if ~isnan(value)
        if isstr(value)
            if strcmp(upper(value),'X')
                if exist('media_choice')
                    error('ERROR - Media - Can only choose one media')
                else
                    switch row
                        case 2, media_choice = 'dmem-f12';
                    end
                end
            else
                error('ERROR - Media - Values must either be X or blank')
            end
        else
            error('ERROR - Media - Values must either be X or blank')
        end
    end
end
if ~exist('media_choice')
    error('ERROR - Media - Must choose a media')
end

%% READ INPUTS - PROTEOMICS

% load data
[~,~,raw] = xlsread('start.xlsx','Proteomics');

% conversion - average mass of amino acid, in daltons
value = raw(3,1);
value = value{1};

if ~isnan(value)
    if isfloat(value)
        if value > 0
            proteomics_conversion_mass = value;
        else
            error('ERROR - Proteomics - Conversion - Average mass of amino acid, in Daltons - Value must be >0')
        end
    else
        error('ERROR - Proteomics - Conversion - Average mass of amino acid, in Daltons - Value must be a number')
    end
end
if ~exist('proteomics_conversion_mass')
    error('ERROR - Proteomics - Conversion - Average mass of amino acid, in Daltons - Must enter value')
end

% conversion - average number of amino acids per protein
value = raw(4,1);
value = value{1};

if ~isnan(value)
    if isfloat(value)
        if value >= 1
            proteomics_conversion_number = value;
        else
            error('ERROR - Proteomics - Conversion - Average number of amino acids per protein - Value must be >=1')
        end
    else
        error('ERROR - Proteomics - Conversion - Average number of amino acids per protein - Value must be a number')
    end
end
if ~exist('proteomics_conversion_number')
    error('ERROR - Proteomics - Conversion - Average number of amino acids per protein - Must enter value')
end

% conversion - fraction of cell dry weight that is protein
value = raw(5,1);
value = value{1};

if ~isnan(value)
    if isfloat(value)
        if (value > 0) && (value < 1)
            proteomics_conversion_dryweight = value;
        else
            error('ERROR - Proteomics - Conversion - Fraction of cell dry weight that is protein - Value must be >0 and <1')
        end
    else
        error('ERROR - Proteomics - Conversion - Fraction of cell dry weight that is protein - Value must be a number')
    end
end
if ~exist('proteomics_conversion_dryweight')
    error('ERROR - Proteomics - Conversion - Fraction of cell dry weight that is protein - Must enter value')
end

% knn - k-value
value = raw(9,1);
value = value{1};

if ~isnan(value)
    if isfloat(value)
        if mod(value,1) == 0
            if value >= 1
                proteomics_knn_k = value;
            else
                error('ERROR - Proteomics - k-Nearest Neighbors - k-value - Value must be >=1')
            end
        else
            error('ERROR - Proteomics - k-Nearest Neighbors - k-value - Value must be an integer')
        end
    else
        error('ERROR - Proteomics - k-Nearest Neighbors - k-value - Value must be a number')
    end
end
if ~exist('proteomics_knn_k')
    error('ERROR - Proteomics - k-Nearest Neighbors - k-value - Must enter value')
end

% knn - minsamples
value = raw(10,1);
value = value{1};

if ~isnan(value)
    if isfloat(value)
        if mod(value,1) == 0
            if value >= 1
                proteomics_knn_minsamples = value;
            else
                error('ERROR - Proteomics - k-Nearest Neighbors - minsamples - Value must be >=1')
            end
        else
            error('ERROR - Proteomics - k-Nearest Neighbors - minsamples - Value must be an integer')
        end
    else
        error('ERROR - Proteomics - k-Nearest Neighbors - minsamples - Value must be a number')
    end
end
if ~exist('proteomics_knn_minsamples')
    error('ERROR - Proteomics - k-Nearest Neighbors - minsamples - Must enter value')
end

% knn - alpha
value = raw(11,1);
value = value{1};

if ~isnan(value)
    if isfloat(value)
        if value >= 1
            proteomics_knn_alpha = value;
        else
            error('ERROR - Proteomics - k-Nearest Neighbors - alpha - Value must be >=1')
        end
    else
        error('ERROR - Proteomics - k-Nearest Neighbors - alpha - Value must be a number')
    end
end
if ~exist('proteomics_knn_alpha')
    error('ERROR - Proteomics - k-Nearest Neighbors - alpha - Must enter value')
end

% knn - samples - first column
proteomics_knn_samples = {};
for row = [16:27,29:33,35:37,39:51,53:64,66:69]
    value = raw(row,1);
    value = value{1};

    if ~isnan(value)
        if isstr(value)
            if strcmp(upper(value),'X')
                switch row
                    case 16, proteomics_knn_samples{end+1} = 'monocyte';
                    case 17, proteomics_knn_samples{end+1} = 'neutrophil';
                    case 18, proteomics_knn_samples{end+1} = 'b-lymphocyte';
                    case 19, proteomics_knn_samples{end+1} = 't-lymphocyte';
                    case 20, proteomics_knn_samples{end+1} = 'cd4-t-cells';
                    case 21, proteomics_knn_samples{end+1} = 'cd8-t-cells';
                    case 22, proteomics_knn_samples{end+1} = 'nk-cells';
                    case 23, proteomics_knn_samples{end+1} = 'periph-blood-mononuclear-cells';
                    case 24, proteomics_knn_samples{end+1} = 'lymph-node';
                    case 25, proteomics_knn_samples{end+1} = 'tonsil';
                    case 26, proteomics_knn_samples{end+1} = 'bone-marrow-stromal-cell';
                    case 27, proteomics_knn_samples{end+1} = 'bone-marrow-mesench-stem-cell';
                    case 29, proteomics_knn_samples{end+1} = 'brain';
                    case 30, proteomics_knn_samples{end+1} = 'frontal-cortex';
                    case 31, proteomics_knn_samples{end+1} = 'cerebral-cortex';
                    case 32, proteomics_knn_samples{end+1} = 'spinal-cord';
                    case 33, proteomics_knn_samples{end+1} = 'retina';
                    case 35, proteomics_knn_samples{end+1} = 'heart';
                    case 36, proteomics_knn_samples{end+1} = 'bone';
                    case 37, proteomics_knn_samples{end+1} = 'colon-muscle';
                    case 39, proteomics_knn_samples{end+1} = 'oral-epithelium';
                    case 40, proteomics_knn_samples{end+1} = 'nasopharynx';
                    case 41, proteomics_knn_samples{end+1} = 'nasal-respiratory-epithelium';
                    case 42, proteomics_knn_samples{end+1} = 'esophagus';
                    case 43, proteomics_knn_samples{end+1} = 'stomach';
                    case 44, proteomics_knn_samples{end+1} = 'cardia';
                    case 45, proteomics_knn_samples{end+1} = 'colon';
                    case 46, proteomics_knn_samples{end+1} = 'rectum';
                    case 47, proteomics_knn_samples{end+1} = 'liver';
                    case 48, proteomics_knn_samples{end+1} = 'kidney';
                    case 49, proteomics_knn_samples{end+1} = 'spleen';
                    case 50, proteomics_knn_samples{end+1} = 'lung';
                    case 51, proteomics_knn_samples{end+1} = 'adipocyte';
                    case 53, proteomics_knn_samples{end+1} = 'salivary-gland';
                    case 54, proteomics_knn_samples{end+1} = 'thyroid';
                    case 55, proteomics_knn_samples{end+1} = 'adrenal';
                    case 56, proteomics_knn_samples{end+1} = 'breast';
                    case 57, proteomics_knn_samples{end+1} = 'pancreas';
                    case 58, proteomics_knn_samples{end+1} = 'islet-of-langerhans';
                    case 59, proteomics_knn_samples{end+1} = 'gallbladder';
                    case 60, proteomics_knn_samples{end+1} = 'prostate';
                    case 61, proteomics_knn_samples{end+1} = 'urinary-bladder';
                    case 62, proteomics_knn_samples{end+1} = 'skin';
                    case 63, proteomics_knn_samples{end+1} = 'hair-follicle';
                    case 64, proteomics_knn_samples{end+1} = 'placenta';
                    case 66, proteomics_knn_samples{end+1} = 'uterus';
                    case 67, proteomics_knn_samples{end+1} = 'cervix';
                    case 68, proteomics_knn_samples{end+1} = 'ovary';
                    case 69, proteomics_knn_samples{end+1} = 'testis';
                end
            else
                error('ERROR - Proteomics - k-Nearest Neighbors - Samples - Values must either be X or blank')
            end
        else
            error('ERROR - Proteomics - k-Nearest Neighbors - Samples - Values must either be X or blank')
        end
    end
end
    
% knn - samples - second column
for row = [16:18,20:21,23,25:32,34:36,38:42]
    value = raw(row,6);
    value = value{1};

    if ~isnan(value)
        if isstr(value)
            if strcmp(upper(value),'X')
                switch row
                    case 16, proteomics_knn_samples{end+1} = 't-cell-leukemia-jurkat';
                    case 17, proteomics_knn_samples{end+1} = 'myeloid-leukemia-k562';
                    case 18, proteomics_knn_samples{end+1} = 'lymphoblastic-leukemia-ccrf-cem';
                    case 20, proteomics_knn_samples{end+1} = 'brain-cancer-u251';
                    case 21, proteomics_knn_samples{end+1} = 'brain-cancer-gamg';
                    case 23, proteomics_knn_samples{end+1} = 'bone-cancer-u2os';
                    case 25, proteomics_knn_samples{end+1} = 'kidney-hek293';
                    case 26, proteomics_knn_samples{end+1} = 'liver-cancer-huh-7';
                    case 27, proteomics_knn_samples{end+1} = 'liver-cancer-hepg2';
                    case 28, proteomics_knn_samples{end+1} = 'nsc-lung-cancer-nci-h460';
                    case 29, proteomics_knn_samples{end+1} = 'lung-cancer-a549';
                    case 30, proteomics_knn_samples{end+1} = 'kidney-cancer-rxf393';
                    case 31, proteomics_knn_samples{end+1} = 'colon-cancer-rko';
                    case 32, proteomics_knn_samples{end+1} = 'colon-cancer-colo205';
                    case 34, proteomics_knn_samples{end+1} = 'melanoma-m14';
                    case 35, proteomics_knn_samples{end+1} = 'breast-cancer-lcc2';
                    case 36, proteomics_knn_samples{end+1} = 'breast-cancer-mcf7';
                    case 38, proteomics_knn_samples{end+1} = 'ovarian-cancer-skov3';
                    case 39, proteomics_knn_samples{end+1} = 'prostate-cancer-lncap';
                    case 40, proteomics_knn_samples{end+1} = 'prostate-cancer-pc3';
                    case 41, proteomics_knn_samples{end+1} = 'cervical-cancer-hela-s3';
                    case 42, proteomics_knn_samples{end+1} = 'cervical-cancer-hela';
                end
            else
                error('ERROR - Proteomics - k-Nearest Neighbors - Samples - Values must either be X or blank')
            end
        else
            error('ERROR - Proteomics - k-Nearest Neighbors - Samples - Values must either be X or blank')
        end
    end
end
    
% knn - samples - third column
for row = [16,18:21]
    value = raw(row,11);
    value = value{1};

    if ~isnan(value)
        if isstr(value)
            if strcmp(upper(value),'X')
                switch row
                    case 16, proteomics_knn_samples{end+1} = 'cal-27';
                    case 18, proteomics_knn_samples{end+1} = 'scc-61-nomims';
                    case 19, proteomics_knn_samples{end+1} = 'scc-61';
                    case 20, proteomics_knn_samples{end+1} = 'rscc-61-nomims';
                    case 21, proteomics_knn_samples{end+1} = 'rscc-61';
                end
            else
                error('ERROR - Proteomics - k-Nearest Neighbors - Samples - Values must either be X or blank')
            end
        else
            error('ERROR - Proteomics - k-Nearest Neighbors - Samples - Values must either be X or blank')
        end
    end
end
if isempty(proteomics_knn_samples)
    error('ERROR - Proteomics - k-Nearest Neighbors - Samples - Must choose at least one sample')
end
for i = 1:length(samples)
    if ~any(strcmp(proteomics_knn_samples,samples{i}))
        error('ERROR - Proteomics - k-Nearest Neighbors - Samples - Must include all samples selected for analysis')
    end
end     
        
%% READ INPUTS - KINETICS

% load data
[~,~,raw] = xlsread('start.xlsx','Kinetics');

% kinetics source
for row = 3:3
    value = raw(row,1);
    value = value{1};

    if ~isnan(value)
        if isstr(value)
            if strcmp(upper(value),'X')
                if exist('kinetics_source')
                    error('ERROR - Kinetics - Can only choose one kinetics source')
                else
                    switch row
                        case 3, kinetics_source = 'brenda-pipeline';
                    end
                end
            else
                error('ERROR - Kinetics - Values must either be X or blank')
            end
        else
            error('ERROR - Kinetics - Values must either be X or blank')
        end
    end
end
if ~exist('kinetics_source')
    error('ERROR - Kinetics - Must choose a kinetics source')
end

%% READ INPUTS - DELTAG

% load data
[~,~,raw] = xlsread('start.xlsx','DeltaG');

% deltag source
for row = 3:3
    value = raw(row,1);
    value = value{1};

    if ~isnan(value)
        if isstr(value)
            if strcmp(upper(value),'X')
                if exist('deltag_source')
                    error('ERROR - DeltaG - Can only choose one deltag source')
                else
                    switch row
                        case 3, deltag_source = 'vmh';
                    end
                end
            else
                error('ERROR - DeltaG - Values must either be X or blank')
            end
        else
            error('ERROR - DeltaG - Values must either be X or blank')
        end
    end
end
if ~exist('deltag_source')
    error('ERROR - DeltaG - Must choose a deltag source')
end

%% READ INPUTS - CONCENTRATIONS

% load data
[~,~,raw] = xlsread('start.xlsx','Concentrations');

% h2o concentration
concentration_h2o = [];
for row = 5:12
    value = raw(row,1);
    value = value{1};

    if ~isnan(value)
        if isfloat(value)
            if value > 0
                concentration_h2o(end+1) = value;
            else
                error('ERROR - Concentrations - Set Values - h2o Concentration - Values must be >0')
            end
        else
            error('ERROR - Concentrations - Set Values - h2o Concentration - Values must be numbers')
        end
    else
        error('ERROR - Concentrations - Set Values - h2o Concentration - Must enter value for every compartment')
    end
end

% o2 concentration
concentration_o2 = [];
for row = 5:12
    value = raw(row,5);
    value = value{1};

    if ~isnan(value)
        if isfloat(value)
            if value > 0
                concentration_o2(end+1) = value;
            else
                error('ERROR - Concentrations - Set Values - o2 Concentration - Values must be >0')
            end
        else
            error('ERROR - Concentrations - Set Values - o2 Concentration - Values must be numbers')
        end
    else
        error('ERROR - Concentrations - Set Values - o2 Concentration - Must enter value for every compartment')
    end
end

% pH
concentration_pH = [];
for row = 5:12
    value = raw(row,9);
    value = value{1};

    if ~isnan(value)
        if isfloat(value)
            if (value >= 0) && (value <= 14)
                concentration_pH(end+1) = value;
            else
                error('ERROR - Concentrations - Set Values - pH - Values must be >=0 and <=14')
            end
        else
            error('ERROR - Concentrations - Set Values - pH - Values must be numbers')
        end
    else
        error('ERROR - Concentrations - Set Values - pH - Must enter value for every compartment')
    end
end

% na+ concentration
concentration_na = [];
for row = 15:21
    value = raw(row,1);
    value = value{1};

    if ~isnan(value)
        if isfloat(value)
            if value > 0
                concentration_na(end+1) = value;
            else
                error('ERROR - Concentrations - Set Values - na+ Concentration - Values must be >0')
            end
        else
            error('ERROR - Concentrations - Set Values - na+ Concentration - Values must be numbers')
        end
    else
        error('ERROR - Concentrations - Set Values - na+ Concentration - Must enter value for every compartment')
    end
end

% k+ concentration
concentration_k = [];
for row = 15:21
    value = raw(row,5);
    value = value{1};

    if ~isnan(value)
        if isfloat(value)
            if value > 0
                concentration_k(end+1) = value;
            else
                error('ERROR - Concentrations - Set Values - k+ Concentration - Values must be >0')
            end
        else
            error('ERROR - Concentrations - Set Values - k+ Concentration - Values must be numbers')
        end
    else
        error('ERROR - Concentrations - Set Values - k+ Concentration - Must enter value for every compartment')
    end
end

% cl- concentration
concentration_cl = [];
for row = 15:21
    value = raw(row,9);
    value = value{1};

    if ~isnan(value)
        if isfloat(value)
            if value > 0
                concentration_cl(end+1) = value;
            else
                error('ERROR - Concentrations - Set Values - cl- Concentration - Values must be >0')
            end
        else
            error('ERROR - Concentrations - Set Values - cl- Concentration - Values must be numbers')
        end
    else
        error('ERROR - Concentrations - Set Values - cl- Concentration - Must enter value for every compartment')
    end
end

% concentration ranges - sources
concentration_ranges_sources_rank = repmat(NaN,1,28-27+1);
for row = 27:28
    value = raw(row,1);
    value = value{1};
    
    if ~isnan(value)
        if isfloat(value)
            if mod(value,1) == 0
                if value >= 1
                    concentration_ranges_sources_rank(row-27+1) = value;
                else
                    error('ERROR - Concentration - Ranges - Sources - Values must be >=1')
                end
            else
                error('ERROR - Concentration - Ranges - Sources - Values must be integers')
            end
        else
            error('ERROR - Concentration - Ranges - Sources - Values must be numbers')
        end     
    else
        concentration_ranges_sources_rank(end+1) = value;
    end
end
for i = 1:length(concentration_ranges_sources_rank)
    if ~isnan(concentration_ranges_sources_rank(i))
        for value = 1:(concentration_ranges_sources_rank(i)-1)
            if ~any(concentration_ranges_sources_rank==value)
                error('ERROR - Concentration - Ranges - Sources - Values must be consecutive integers, starting at 1 (1,2,...). Blank entries are allowed')
            end
        end
    end
end
concentration_ranges_sources = {};
if ~isnan(max(concentration_ranges_sources_rank))
    for i = 1:max(concentration_ranges_sources_rank)
        index = find(concentration_ranges_sources_rank==i);
        switch index
            case 1, concentration_ranges_sources{end+1} = 'bennett';
            case 2, concentration_ranges_sources{end+1} = 'park';
        end
    end
end

%% READ INPUTS - GENE KNOCKDOWN

% load data
[~,~,raw] = xlsread('start.xlsx','Gene Knockdown','A1:B346');

% perform knockdown
for row = 3:4
    value = raw(row,1);
    value = value{1};

    if ~isnan(value)
        if isstr(value)
            if strcmp(upper(value),'X')
                if exist('knockdown_perform')
                    error('ERROR - Gene Knockdown - Perform Knockdown - Can only choose one value')
                else
                    switch row
                        case 3, knockdown_perform = 1;
                        case 4, knockdown_perform = 0;
                    end
                end
            else 
                error('ERROR - Gene Knockdown - Perform Knockdown - Values must either be X or blank')
            end
        else
            error('ERROR - Gene Knockdown - Perform Knockdown - Values must either be X or blank')
        end
    end
end
if ~exist('knockdown_perform')
    error('ERROR - Gene Knockdown - Perform Knockdown - Must choose one value')
end

% genes to knockdown
if knockdown_perform == 1
    knockdown_genes = {};
    knockdown_values = [];
    
    for row = 9:length(raw(:,1))
        
        % gene id
        value = raw(row,1);
        value = value{1};
        
        if ~isnan(value)
            if isfloat(value)
                if mod(value,1) == 0
                    knockdown_genes{end+1} = num2str(value);
                else
                    error('ERROR - Gene Knockdown - Genes to knockdown - Gene id''s must be in NCBI format, without isoform number, only including digits')
                end
            else
                error('ERROR - Gene Knockdown - Genes to knockdown - Gene id''s must be in NCBI format, without isoform number, only including digits')
            end
        else
            value = raw(row,2);
            value = value{1};
            if ~isnan(value)
                error('ERROR - Gene Knockdown - Genes to knockdown - Knockdown value without gene id detected')
            end
        end

        % gene value
        value = raw(row,2);
        value = value{1};
        
        if ~isnan(value)
            if isfloat(value)
                if (value >=0) && (value < 1)
                    knockdown_values(end+1) = value;
                else
                    error('ERROR - Gene Knockdown - Genes to knockdown - Knockdown values must be >=0 and <1')
                end
            else
                error('ERROR - Gene Knockdown - Genes to knockdown - Knockdown values must be numbers')
            end
        else
            value = raw(row,1);
            value = value{1};
            if ~isnan(value)
                error('ERROR - Gene Knockdown - Genes to knockdown - Gene id without knockdown value detected')
            end
        end
    end
    
    if isempty(knockdown_genes) || isempty(knockdown_values)
        error('ERROR - Gene Knockdown - Genes to knockdown - Must include at least one gene to knockdown')
    elseif length(knockdown_genes) ~= length(knockdown_values)
        error('ERROR - Gene Knockdown - Genes to knockdown - Differing numbers of gene id''s and knockdown values')
    end
    
%     % check for duplicate values
%     for i = 1:length(knockdown_genes)
%         if sum(strcmp(knockdown_genes,knockdown_genes{i})) > 1            
%             for j = find(strcmp(knockdown_genes,knockdown_genes{i}));
%                 if j ~= i
%                     if knockdown_values(j) ~= knockdown_values(i)
%                         error(sprintf('ERROR - Gene Knockdown - Genes to knockdown - Detected duplicate gene id entries with different knockdown values: Gene ID %s, Values %f and %f',knockdown_genes{i},knockdown_values(i),knockdown_values(j)))
%                     end
%                 end
%             end
%         end
%     end
end

%% READ INPUTS - OTHER

% load data
[~,~,raw] = xlsread('start.xlsx','Other');

% membrane permeability - na+
value = raw(4,1);
value = value{1};

if ~isnan(value)
    if isfloat(value)
        if value > 0
            membrane_permeability_na = value;
        else
            error('ERROR - Other - Membrane Permeability - Na+ - Value must be >0')
        end
    else
        error('ERROR - Other - Membrane Permeability - Na+ - Value must be a number')
    end
end
if ~exist('membrane_permeability_na')
    error('ERROR - Other - Membrane Permeability - Na+ - Must enter value')
end

% membrane permeability - k+
value = raw(5,1);
value = value{1};

if ~isnan(value)
    if isfloat(value)
        if value > 0
            membrane_permeability_k = value;
        else
            error('ERROR - Other - Membrane Permeability - K+ - Value must be >0')
        end
    else
        error('ERROR - Other - Membrane Permeability - K+ - Value must be a number')
    end
end
if ~exist('membrane_permeability_k')
    error('ERROR - Other - Membrane Permeability - K+ - Must enter value')
end

% membrane permeability - cl-
value = raw(6,1);
value = value{1};

if ~isnan(value)
    if isfloat(value)
        if value > 0
            membrane_permeability_cl = value;
        else
            error('ERROR - Other - Membrane Permeability - Cl- - Value must be >0')
        end
    else
        error('ERROR - Other - Membrane Permeability - Cl- - Value must be a number')
    end
end
if ~exist('membrane_permeability_cl')
    error('ERROR - Other - Membrane Permeability - Cl- - Must enter value')
end

%% SEE IF RESULTS HAVE ALREADY BEEN COMPUTED

% get previous results folders
folderstruct = dir('results');
folderstruct = folderstruct(3:end);
folders = {};
for i = 1:length(folderstruct)
    folders{end+1} = folderstruct(i).name;
end

% check for perfect match
for i = 1:length(folders)
    info = load(sprintf('results/%s/info.mat',folders{i}));
    
    match_perfect = 1;
    if ~isequal(type_of_analysis,info.type_of_analysis) || ~isequal(objective_function,info.objective_function) || ~isequal(samples,info.samples) || ~isequal(media_choice,info.media_choice) || ~isequal(proteomics_conversion_mass,info.proteomics_conversion_mass) || ~isequal(proteomics_conversion_number,info.proteomics_conversion_number) || ~isequal(proteomics_conversion_dryweight,info.proteomics_conversion_dryweight) || ~isequal(proteomics_knn_k,info.proteomics_knn_k) || ~isequal(proteomics_knn_minsamples,info.proteomics_knn_minsamples) || ~isequal(proteomics_knn_alpha,info.proteomics_knn_alpha) || ~isequal(proteomics_knn_samples,info.proteomics_knn_samples) || ~isequal(kinetics_source,info.kinetics_source) || ~isequal(deltag_source,info.deltag_source) || ~isequal(concentration_h2o,info.concentration_h2o) || ~isequal(concentration_o2,info.concentration_o2) || ~isequal(concentration_pH,info.concentration_pH) || ~isequal(concentration_na,info.concentration_na) || ~isequal(concentration_k,info.concentration_k) || ~isequal(concentration_cl,info.concentration_cl) || ~isequal(concentration_ranges_sources,info.concentration_ranges_sources) || ~isequal(knockdown_perform,info.knockdown_perform) || ~isequal(membrane_permeability_na,info.membrane_permeability_na) || ~isequal(membrane_permeability_k,info.membrane_permeability_k) || ~isequal(membrane_permeability_cl,info.membrane_permeability_cl) || info.done_all==0
        match_perfect = 0;
    else
        if type_of_analysis == 2
            if ~isequal(pfba_fractions,info.pfba_fractions)
                match_perfect = 0;
            end
        elseif type_of_analysis == 3
            if ~isequal(fva_variables,info.fva_variables) || ~isequal(fva_fraction,info.fva_fraction)
                match_perfect = 0;
            end
        elseif type_of_analysis == 4
            if ~isequal(random_sampling_minvalid,info.random_sampling_minvalid)
                match_perfect = 0;
            end
        end
        if knockdown_perform == 1
            if ~isequal(knockdown_genes,info.knockdown_genes) || ~isequal(knockdown_values,info.knockdown_values)
                match_perfect = 0;
            end
        end
    end
    if match_perfect == 1
        error(sprintf('Results with same exact parameters have already been computed. Located within results folder %s',folders{i}))
    end
end

%% INITIALIZE RESULTS FOLDER

% create results folder
results_folder = strrep(datestr(datetime('now')),':','-');
mkdir(sprintf('results/%s',results_folder))
fprintf('RESULTS FOLDER: %s\n',results_folder);

%% WRITE TO INFO FILE - GENERAL

% create info file
f_info = fopen(sprintf('results/%s/info.txt',results_folder),'w');
fprintf(f_info,'GENERAL\n-------\n');

% type of analysis
save(sprintf('results/%s/info.mat',results_folder),'type_of_analysis')
switch type_of_analysis
    case 1, fprintf(f_info,'Type of Analysis: Objective Value\n');
    case 2, fprintf(f_info,'Type of Analysis: pFBA\n');
    case 3, fprintf(f_info,'Type of Analysis: FVA\n');
    case 4, fprintf(f_info,'Type of Analysis: Random Sampling\n');
end

% pfba fractions
if type_of_analysis == 2
    save(sprintf('results/%s/info.mat',results_folder),'pfba_fractions','-append')
    fprintf(f_info,'pFBA fractions: %s\n',strjoin(strsplit(num2str(pfba_fractions),'  '),', '));
end

% fva variables
if type_of_analysis == 3
    save(sprintf('results/%s/info.mat',results_folder),'fva_variables','-append')
    fprintf(f_info,'FVA variables: %s\n',strjoin(fva_variables,', '));
end

% fva fraction
if type_of_analysis == 3
    save(sprintf('results/%s/info.mat',results_folder),'fva_fraction','-append')
    fprintf(f_info,'FVA fraction: %f\n',fva_fraction);
end

% random sampling minvalid
if type_of_analysis == 4
    save(sprintf('results/%s/info.mat',results_folder),'random_sampling_minvalid','-append')
    fprintf(f_info,'Random Sampling MinValid: %f\n',random_sampling_minvalid);
end

%% WRITE TO INFO FILE - OBJECTIVE FUNCTION

fprintf(f_info,'\nOBJECTIVE FUNCTION\n------------------\n');

% objective function
save(sprintf('results/%s/info.mat',results_folder),'objective_function','-append')
switch objective_function
    case 1, fprintf(f_info,'Objective Function: nadh[c] --> nad[c] + h[c]\n');
    case 2, fprintf(f_info,'Objective Function: nadh[m] --> nad[m] + h[m]\n');
    case 3, fprintf(f_info,'Objective Function: nadh[c] + nadh[m] --> nad[c] + nad[m] + h[c] + h[m]\n');
    case 4, fprintf(f_info,'Objective Function: nadph[c] --> nadp[c] + h[c]\n');
    case 5, fprintf(f_info,'Objective Function: nadph[m] --> nadp[m] + h[m]\n');
    case 6, fprintf(f_info,'Objective Function: nadph[c] + nadph[m] --> nadp[c] + nadp[m] + h[c] + h[m]\n');
    case 7, fprintf(f_info,'Objective Function: nadh[c] + nadh[m] + nadph[c] + nadph[m] --> nad[c] + nad[m] + nadp[c] + nadp[m] + 2 h[c] + 2 h[m]\n');
    case 8, fprintf(f_info,'Objective Function: atp[c] + h2o[c] --> adp[c] + pi[c] + h[c]\n');
    case 9, fprintf(f_info,'Objective Function: atp[m] + h2o[m] --> adp[m] + pi[m] + h[m]\n');
    case 10, fprintf(f_info,'Objective Function: atp[c] + atp[m] + h2o[c] + h2o[m] --> adp[c] + adp[m] + pi[c] + pi[m] + h[c] + h[m]\n');
    case 11, fprintf(f_info,'Objective Function: biomass\n');
    case 12, fprintf(f_info,'Objective Function: nadp[c] + nadp[m] + h[c] + h[m] --> nadph[c] + nadph[m]\n');
    case 13, fprintf(f_info,'Objective Function: nadph[c] + nadph[m] --> nadp[c] + nadp[m]\n');
    case 14, fprintf(f_info,'Objective Function: nadp[c] + nadp[m] --> nadph[c] + nadph[m]\n');
end

%% WRITE TO INFO FILE - SAMPLES

fprintf(f_info,'\nSAMPLES\n-------\n');

% samples
save(sprintf('results/%s/info.mat',results_folder),'samples','-append')
fprintf(f_info,'Samples: %s\n',strjoin(samples,', '));

%% WRITE TO INFO FILE - MEDIA

fprintf(f_info,'\nMEDIA\n-----\n');

% media
save(sprintf('results/%s/info.mat',results_folder),'media_choice','-append')
fprintf(f_info,'Media: %s\n',media_choice);

%% WRITE TO INFO FILE - PROTEOMICS

fprintf(f_info,'\nPROTEOMICS\n----------\n');

% conversion
save(sprintf('results/%s/info.mat',results_folder),'proteomics_conversion_mass','-append')
save(sprintf('results/%s/info.mat',results_folder),'proteomics_conversion_number','-append')
save(sprintf('results/%s/info.mat',results_folder),'proteomics_conversion_dryweight','-append')
fprintf(f_info,'Conversion - Average mass of amino acid, in Daltons: %f\n',proteomics_conversion_mass);
fprintf(f_info,'Conversion - Average number of amino acids per protein: %f\n',proteomics_conversion_number);
fprintf(f_info,'Conversion - Fraction of cell dry weight that is protein: %f\n',proteomics_conversion_dryweight);

% k-nearest neighbors
save(sprintf('results/%s/info.mat',results_folder),'proteomics_knn_k','-append')
save(sprintf('results/%s/info.mat',results_folder),'proteomics_knn_minsamples','-append')
save(sprintf('results/%s/info.mat',results_folder),'proteomics_knn_alpha','-append')
save(sprintf('results/%s/info.mat',results_folder),'proteomics_knn_samples','-append')
fprintf(f_info,'k-Nearest Neighbors - k-value: %d\n',proteomics_knn_k);
fprintf(f_info,'k-Nearest Neighbors - minsamples: %d\n',proteomics_knn_minsamples);
fprintf(f_info,'k-Nearest Neighbors - alpha: %f\n',proteomics_knn_alpha);
fprintf(f_info,'k-Nearest Neighbors - Samples: %s\n',strjoin(proteomics_knn_samples,', '));

%% WRITE TO INFO FILE - KINETICS

fprintf(f_info,'\nKINETICS\n--------\n');

% source
save(sprintf('results/%s/info.mat',results_folder),'kinetics_source','-append')
fprintf(f_info,'Source: %s\n',kinetics_source);

%% WRITE TO INFO FILE - DELTAG

fprintf(f_info,'\nDELTAG\n------\n');

% source
save(sprintf('results/%s/info.mat',results_folder),'deltag_source','-append')
fprintf(f_info,'Source: %s\n',deltag_source);

%% WRITE TO INFO FILE - CONCENTRATIONS

fprintf(f_info,'\nCONCENTRATIONS\n--------\n');

% set values
save(sprintf('results/%s/info.mat',results_folder),'concentration_h2o','-append')
save(sprintf('results/%s/info.mat',results_folder),'concentration_o2','-append')
save(sprintf('results/%s/info.mat',results_folder),'concentration_pH','-append')
save(sprintf('results/%s/info.mat',results_folder),'concentration_na','-append')
save(sprintf('results/%s/info.mat',results_folder),'concentration_k','-append')
save(sprintf('results/%s/info.mat',results_folder),'concentration_cl','-append')
fprintf(f_info,'Set Values - h2o [M]: e=%f, c=%f, g=%f, l=%f, m=%f, n=%f, r=%f, p=%f\n',concentration_h2o(1),concentration_h2o(2),concentration_h2o(3),concentration_h2o(4),concentration_h2o(5),concentration_h2o(6),concentration_h2o(7),concentration_h2o(8));
fprintf(f_info,'Set Values - o2 [M]: e=%f, c=%f, g=%f, l=%f, m=%f, n=%f, r=%f, p=%f\n',concentration_o2(1),concentration_o2(2),concentration_o2(3),concentration_o2(4),concentration_o2(5),concentration_o2(6),concentration_o2(7),concentration_o2(8));
fprintf(f_info,'Set Values - pH: e=%f, c=%f, g=%f, l=%f, m=%f, n=%f, r=%f, p=%f\n',concentration_pH(1),concentration_pH(2),concentration_pH(3),concentration_pH(4),concentration_pH(5),concentration_pH(6),concentration_pH(7),concentration_pH(8));
fprintf(f_info,'Set Values - na+ [M]: c=%f, g=%f, l=%f, m=%f, n=%f, r=%f, p=%f\n',concentration_na(1),concentration_na(2),concentration_na(3),concentration_na(4),concentration_na(5),concentration_na(6),concentration_na(7));
fprintf(f_info,'Set Values - k+ [M]: c=%f, g=%f, l=%f, m=%f, n=%f, r=%f, p=%f\n',concentration_k(1),concentration_k(2),concentration_k(3),concentration_k(4),concentration_k(5),concentration_k(6),concentration_k(7));
fprintf(f_info,'Set Values - cl- [M]: c=%f, g=%f, l=%f, m=%f, n=%f, r=%f, p=%f\n',concentration_cl(1),concentration_cl(2),concentration_cl(3),concentration_cl(4),concentration_cl(5),concentration_cl(6),concentration_cl(7));

% ranges - sources
save(sprintf('results/%s/info.mat',results_folder),'concentration_ranges_sources','-append')
if isempty(concentration_ranges_sources)
    fprintf(f_info,'Ranges - Sources: none\n');
else
    fprintf(f_info,'Ranges - Sources: ');
    for i = 1:length(concentration_ranges_sources)
        if i~=1
            fprintf(f_info,', ');
        end
        fprintf(f_info,concentration_ranges_sources{i});
    end
    fprintf(f_info,'\n');
end

%% WRITE TO INFO FILE - GENE KNOCKDOWN

fprintf(f_info,'\nGENE KNOCKDOWN\n--------------\n');

% perform knockdown
save(sprintf('results/%s/info.mat',results_folder),'knockdown_perform','-append')
if knockdown_perform == 0
    fprintf(f_info,'Perform knockdown?: No\n');
else
    fprintf(f_info,'Perform knockdown?: Yes\n');
end

% genes to knockdown
if knockdown_perform == 1
    save(sprintf('results/%s/info.mat',results_folder),'knockdown_genes','-append')
    save(sprintf('results/%s/info.mat',results_folder),'knockdown_values','-append')
    fprintf(f_info,'Genes to knockdown (ID,VALUE): ');
    for i = 1:length(knockdown_genes)
        if i ~= 1
            fprintf(f_info,', ');
        end
        fprintf(f_info,'(%s,%f)',knockdown_genes{i},knockdown_values(i));
    end
    fprintf(f_info,'\n');
end

%% WRITE TO INFO FILE - OTHER

fprintf(f_info,'\nOTHER\n--------------\n');

% membrane permeability - na+
save(sprintf('results/%s/info.mat',results_folder),'membrane_permeability_na','-append')
fprintf(f_info,'Relative Na+ Membrane Permeability: %f\n',membrane_permeability_na);

% membrane permeability - k+
save(sprintf('results/%s/info.mat',results_folder),'membrane_permeability_k','-append')
fprintf(f_info,'Relative K+ Membrane Permeability: %f\n',membrane_permeability_k);

% membrane permeability - cl-
save(sprintf('results/%s/info.mat',results_folder),'membrane_permeability_cl','-append')
fprintf(f_info,'Relative Cl- Membrane Permeability: %f\n',membrane_permeability_cl);

% close info file
fclose(f_info);

%% INITIALIZE COMPLETION STATUS

% overall
done_all = 0;
save(sprintf('results/%s/info.mat',results_folder),'done_all','-append')

%% ENSURE ALL SAMPLES ARE FOUND

% get available samples
available_samples = {};
folderstruct = dir('samples/protein');
folderstruct = folderstruct(3:end);
for i = 1:length(folderstruct);
    name = strsplit(folderstruct(i).name,'.');
    available_samples{end+1} = name{1};
end

for i = 1:length(proteomics_knn_samples)
    if ~any(strcmp(available_samples,proteomics_knn_samples{i}))
        if any(strcmp(samples,proteomics_knn_samples{i}))
            found_index = find(strcmp(samples,proteomics_knn_samples{i}));
            error(sprintf('ERROR - Samples - Could not find sample ''%s''',samples{found_index}))
        else
            error(sprintf('ERROR - Proteomics - k-Nearest Neighbors - Samples - Could not find sample ''%s''',proteomics_knn_samples{i}))
        end
    end
end

%% ENSURE MEDIA FILE IS FOUND

% get available media
available_media = {};
folderstruct = dir('media');
folderstruct = folderstruct(3:end);
for i = 1:length(folderstruct);
    name = strsplit(folderstruct(i).name,'.');
    available_media{end+1} = name{1};
end

% check if chosen media is avialable
if ~any(strcmp(available_media,media_choice));
    error(strcmp('ERROR - Media - Could not find media ''%s''',media_choice));
end

%% ENSURE KINETICS FILE IS FOUND

% get available kinetics sources
available_kinetics = {};
folderstruct = dir('kinetics');
folderstruct = folderstruct(3:end);
for i = 1:length(folderstruct);
    name = strsplit(folderstruct(i).name,'.');
    available_kinetics{end+1} = name{1};
end

% check if chosen kinetics source is available
if ~any(strcmp(available_kinetics,kinetics_source));
    error(strcmp('ERROR - Kinetics - Could not find kinetics source ''%s''',kinetics_source));
end

%% ENSURE DELTAG FILE IS FOUND

% get available deltag sources
available_deltag = {};
folderstruct = dir('deltag');
folderstruct = folderstruct(3:end);
for i = 1:length(folderstruct);
    name = strsplit(folderstruct(i).name,'.');
    available_deltag{end+1} = name{1};
end

% check if chosen deltag source is available
if ~any(strcmp(available_deltag,deltag_source));
    error(strcmp('ERROR - DeltaG - Could not find deltag source ''%s''',deltag_source));
end

%% ENSURE CONCENTRATIONS FILES ARE FOUND

% get available concentrations sources
available_concentrations = {};
folderstruct = dir('concentrations');
folderstruct = folderstruct(3:end);
for i = 1:length(folderstruct);
    name = strsplit(folderstruct(i).name,'.');
    available_concentrations{end+1} = name{1};
end

% check if chosen concentration sources are available
for i = 1:length(concentration_ranges_sources)
    if ~any(strcmp(available_concentrations,concentration_ranges_sources{i}))
        error(strcmp('ERROR - Concentrations - Ranges - Sources - Could not find concentrations source ''%s''',concentration_ranges_sources{i}));
    end
end

%% INITIALIZE MODEL

% load model
load('files/recon204.mat')

% turn off biomass reaction
if objective_function == 11
    model.ub(strcmp(model.rxns,'biomass_reaction')) = 0;
end

%% PROTEOMICS W/ KNOCKDOWN

if knockdown_perform == 1
        
    % load protein data for each sample
    knn = zeros(length(model.genes_noisoforms),length(proteomics_knn_samples));
    for i = 1:length(proteomics_knn_samples)
        [genes,data] = textread(sprintf('samples/protein/%s.csv',proteomics_knn_samples{i}),'%s%f','delimiter',',','headerlines',1);

        % ensure all model genes are found
        for j = 1:length(model.genes_noisoforms)
            if ~any(strcmp(genes,model.genes_noisoforms{j}))
                error(strcmp('ERROR - Sample Data - Protein - Could not find gene ''%s'' in protein data for sample ''%s''',model.genes_noisoforms{j},proteomics_knn_samples{i}))
            end
        end

        % ensure all genes are model genes
        for j = 1:length(genes)
            if ~any(strcmp(model.genes_noisoforms,genes{j}))
                error(strcmp('ERROR - Sample Data - Protein - Gene ''%s'' in protein data for sample ''%s'' is not found in the model',genes{j},proteomics_knn_samples{i}))
            end
        end

        % order genes correctly
        [~,order] = ismember(model.genes_noisoforms,genes);
        knn(:,i) = data(order);
    end

    % perform knn
    knn = knnimpute_custom(knn,proteomics_knn_k,proteomics_knn_minsamples,proteomics_knn_alpha);

    % only keep samples to analyze
    knn = knn(:,ismember(proteomics_knn_samples,samples));

    % convert ppm to mmol/gDW
    % ppm => divide by 1,000,000
    % numerator:
    %   molecules to moles => divide by N_a
    %   moles to mmoles => multiply by 10^3
    % denominator:
    %   proteins to amino acids => multiply by "proteomics_conversion_number"
    %   amino acids to Daltons => multiply by "proteomics_conversion_mass"
    %   Daltons to grams => multiply by 1.66054e-24
    %   grams protein to grams dry weight => divide by "proteomics_conversion_dryweight"
    knn = knn / 1000000 * (1/(6.0221409e23)*1000) / (proteomics_conversion_number*proteomics_conversion_mass*(1.66054e-24)/proteomics_conversion_dryweight);

    % convert genes to reactions w/ knockdown
    protein = genes_to_reactions_knockdown(knn,knockdown_genes,knockdown_values,model.grRules_noisoforms,model.genes_noisoforms,model.rxnGeneMat_noisoforms);
    
%% PROTEOMICS W/O KNOCKDOWN

else
   
    % load protein data for each sample
    knn = zeros(length(model.genes_noisoforms),length(proteomics_knn_samples));
    for i = 1:length(proteomics_knn_samples)
        [genes,data] = textread(sprintf('samples/protein/%s.csv',proteomics_knn_samples{i}),'%s%f','delimiter',',','headerlines',1);

        % ensure all model genes are found
        for j = 1:length(model.genes_noisoforms)
            if ~any(strcmp(genes,model.genes_noisoforms{j}))
                error(strcmp('ERROR - Sample Data - Protein - Could not find gene ''%s'' in protein data for sample ''%s''',model.genes_noisoforms{j},proteomics_knn_samples{i}))
            end
        end

        % ensure all genes are model genes
        for j = 1:length(genes)
            if ~any(strcmp(model.genes_noisoforms,genes{j}))
                error(strcmp('ERROR - Sample Data - Protein - Gene ''%s'' in protein data for sample ''%s'' is not found in the model',genes{j},proteomics_knn_samples{i}))
            end
        end

        % order genes correctly
        [~,order] = ismember(model.genes_noisoforms,genes);
        knn(:,i) = data(order);
    end
    
    % perform knn
    knn = knnimpute_custom(knn,proteomics_knn_k,proteomics_knn_minsamples,proteomics_knn_alpha);

    % only keep samples to analyze
    knn = knn(:,ismember(proteomics_knn_samples,samples));

    % convert ppm to mmol/gDW
    % ppm => divide by 1,000,000
    % numerator:
    %   molecules to moles => divide by N_a
    %   moles to mmoles => multiply by 10^3
    % denominator:
    %   proteins to amino acids => multiply by "proteomics_conversion_number"
    %   amino acids to Daltons => multiply by "proteomics_conversion_mass"
    %   Daltons to grams => multiply by 1.66054e-24
    %   grams protein to grams dry weight => divide by "proteomics_conversion_dryweight"
    knn = knn / 1000000 * (1/(6.0221409e23)*1000) / (proteomics_conversion_number*proteomics_conversion_mass*(1.66054e-24)/proteomics_conversion_dryweight);
    
%     genes = model.genes_noisoforms;
%     save('data_all.mat','knn','genes');
    
    % convert genes to reactions
    protein = genes_to_reactions(knn,model.grRules_noisoforms,model.genes_noisoforms);

end
        
%% LOAD SAMPLE FLUX AND CONCENTRATION DATA

% initialize flux data
reaction_flux_value = {};
reaction_flux_lb = {};
reaction_flux_ub = {};

% load sample flux data
for i = 1:length(samples)
    
    % initialize sample data
    reaction_flux_value{end+1} = containers.Map;
    reaction_flux_lb{end+1} = containers.Map;
    reaction_flux_ub{end+1} = containers.Map;

    % if file exists
    if exist(sprintf('samples/flux/%s.csv',samples{i})) == 2
        
        % load data
        [reactions,flux,lb_flux,ub_flux] = textread(sprintf('samples/flux/%s.csv',samples{i}),'%s%f%f%f','delimiter',',','headerlines',1);
        for j = 1:length(reactions)
            
           % determine if valid reaction name
           if ~any(strcmp(model.rxns,reactions{j}))
               error(sprintf('ERROR - Sample Data - Flux - Invalid reaction name ''%s'' for sample ''%s''',reactions{j},samples{i}))
           
           % determine if duplicate reaction name
           elseif any(strcmp(reactions(1:j-1),reactions{j}))
               error(sprintf('ERROR - Sample Data - Flux - Duplicate reaction name ''%s'' in sample ''%s''',reactions{j},samples{i}))
           end
                  
           % extract data
           if ~isnan(flux(j))
               reaction_flux_value{end}(reactions{j}) = flux(j);   
           else
               if ~isnan(lb_flux(j))
                   reaction_flux_lb{end}(reactions{j}) = lb_flux(j);  
               end
               if ~isnan(ub_flux(j))
                   reaction_flux_ub{end}(reactions{j}) = ub_flux(j);  
               end
           end   
        end
    end
end
        
% initialize concentration data
metabolite_concentration_value = {};
metabolite_concentration_lb = {};
metabolite_concentration_ub = {};

% load sample metabolite data
for i = 1:length(samples)
    
    % initialize sample data
    metabolite_concentration_value{end+1} = containers.Map;
    metabolite_concentration_lb{end+1} = containers.Map;
    metabolite_concentration_ub{end+1} = containers.Map;

    % if file exists
    if exist(sprintf('samples/concentration/%s.csv',samples{i})) == 2
        
        % load data
        [metabolites,concentration,lb_concentration,ub_concentration] = textread(sprintf('samples/concentration/%s.csv',samples{i}),'%s%f%f%f','delimiter',',','headerlines',1);
        for j = 1:length(metabolites)
            
           % determine if valid metabolite name
           if ~any(strcmp(model.mets,metabolites{j}))
               error(sprintf('ERROR - Sample Data - Concentration - Invalid metabolite name ''%s'' for sample ''%s''',metabolites{j},samples{i}))
           
           % determine if duplicate metabolite name
           elseif any(strcmp(metabolites(1:j-1),metabolites{j}))
               error(sprintf('ERROR - Sample Data - Concentration - Duplicate metabolite name ''%s'' in sample ''%s''',metabolites{j},samples{i}))
           
           % determine if in extracellar compartment
           elseif strcmp(metabolites{j}(end-2:end),'[e]')
                error(sprintf('ERROR - Sample Data - Concentration - Cannot add extracellular metabolite concentration ''%s'' in sample ''%s''',metabolites{j},samples{i}))
           end
                  
           % extract data
           if ~isnan(concentration(j))
               metabolite_concentration_value{end}(metabolites{j}) = concentration(j);   
           else
               if ~isnan(lb_concentration(j))
                   metabolite_concentration_lb{end}(metabolites{j}) = lb_concentration(j);  
               end
               if ~isnan(ub_concentration(j))
                   metabolite_concentration_ub{end}(metabolites{j}) = ub_concentration(j);  
               end
           end   
        end
    end
end

%% LOAD MEDIA

% load file
[metabolites,concentration] = textread(sprintf('media/%s.csv',media_choice),'%s%f','delimiter',',','headerlines',1);

% make sure all metabolites are valid and in extracellular compartment
for i = 1:length(metabolites)
    if ~any(strcmp(model.mets,metabolites{i}))
        error(sprintf('ERROR - Media - Invalid metabolite name ''%s'' in media ''%s''',metabolites{i},media_choice))
    elseif ~strcmp(metabolites{i}(end-2:end),'[e]')
        error(sprintf('ERROR - Media - Metabolite ''%s'' in media ''%s'' must be in extracellular compartment',metabolites{i},media_choice))
    end
    
% add to sample concentrations
    for j = 1:length(samples)
        metabolite_concentration_value{j}(metabolites{i}) = concentration(i);
    end
end

%% LOAD KINETICS

% load file
[reactions,kcat] = textread(sprintf('kinetics/%s.csv',kinetics_source),'%s%f','delimiter',',','headerlines',1);

% ensure all model reactions are found
for i = 1:length(model.rxns)
    if ~any(strcmp(reactions,model.rxns{i}))
        error(sprintf('ERROR - Kinetics Data - Reaction ''%s'' is not found in kinetics source ''%s''',model.rxns{i},kinetics_source))
    end
end

% ensure all reactions are in model
for i = 1:length(reactions)
    if ~any(strcmp(model.rxns,reactions{i}))
        error(sprintf('ERROR - Kinetics Data - Reaction ''%s'' in kinetics source ''%s'' is not found in the model',reactions{i},kinetics_source))
    end
end

% order reactions correctly
[~,order] = ismember(model.rxns,reactions);
kcat = kcat(order);

%% LOAD DELTAG

% load file
[reactions,deltag,uncertainty] = textread(sprintf('deltag/%s.csv',deltag_source),'%s%f%f','delimiter',',','headerlines',1);

% ensure all model reactions are found
for i = 1:length(model.rxns)
    if ~any(strcmp(reactions,model.rxns{i}))
        error(sprintf('ERROR - DeltaG Data - Reaction ''%s'' is not found in deltag source ''%s''',model.rxns{i},deltag_source))
    end
end

% ensure all reactions are in model
for i = 1:length(reactions)
    if ~any(strcmp(model.rxns,reactions{i}))
        error(sprintf('ERROR - DeltaG Data - Reaction ''%s'' in deltag source ''%s'' is not found in the model',reactions{i},deltag_source))
    end
end

% order reactions correctly
[~,order] = ismember(model.rxns,reactions);
deltag = deltag(order);
uncertainty = uncertainty(order);

%% LOAD CONCENTRATIONS

% add set values to each sample
for i = 1:length(samples)
    compartments = {'e','c','g','l','m','n','r','x'};
    for j = 1:length(compartments)
        
        % h2o concentration
        if ~any(strcmp(keys(metabolite_concentration_value{i}),sprintf('h2o[%s]',compartments{j}))) && ~any(strcmp(keys(metabolite_concentration_lb{i}),sprintf('h2o[%s]',compartments{j}))) && ~any(strcmp(keys(metabolite_concentration_ub{i}),sprintf('h2o[%s]',compartments{j})))
            metabolite_concentration_value{i}(sprintf('h2o[%s]',compartments{j})) = concentration_h2o(j);
        end
        
        % o2 concentration
        if ~any(strcmp(keys(metabolite_concentration_value{i}),sprintf('o2[%s]',compartments{j}))) && ~any(strcmp(keys(metabolite_concentration_lb{i}),sprintf('o2[%s]',compartments{j}))) && ~any(strcmp(keys(metabolite_concentration_ub{i}),sprintf('o2[%s]',compartments{j})))
            metabolite_concentration_value{i}(sprintf('o2[%s]',compartments{j})) = concentration_o2(j);
        end
        
        % h+ concentration
        if ~any(strcmp(keys(metabolite_concentration_value{i}),sprintf('h[%s]',compartments{j}))) && ~any(strcmp(keys(metabolite_concentration_lb{i}),sprintf('h[%s]',compartments{j}))) && ~any(strcmp(keys(metabolite_concentration_ub{i}),sprintf('h[%s]',compartments{j})))
            metabolite_concentration_value{i}(sprintf('h[%s]',compartments{j})) = 10^(-concentration_pH(j));
        end
    end
    
    for j = 2:length(compartments)
        
        % na+ concentration
        if ~any(strcmp(keys(metabolite_concentration_value{i}),sprintf('na1[%s]',compartments{j}))) && ~any(strcmp(keys(metabolite_concentration_lb{i}),sprintf('na1[%s]',compartments{j}))) && ~any(strcmp(keys(metabolite_concentration_ub{i}),sprintf('na1[%s]',compartments{j})))
            metabolite_concentration_value{i}(sprintf('na1[%s]',compartments{j})) = concentration_na(j-1);
        end
        
        % k+ concentration
        if ~any(strcmp(keys(metabolite_concentration_value{i}),sprintf('k[%s]',compartments{j}))) && ~any(strcmp(keys(metabolite_concentration_lb{i}),sprintf('k[%s]',compartments{j}))) && ~any(strcmp(keys(metabolite_concentration_ub{i}),sprintf('k[%s]',compartments{j})))
            metabolite_concentration_value{i}(sprintf('k[%s]',compartments{j})) = concentration_k(j-1);
        end
        
        % cl- concentration
        if ~any(strcmp(keys(metabolite_concentration_value{i}),sprintf('cl[%s]',compartments{j}))) && ~any(strcmp(keys(metabolite_concentration_lb{i}),sprintf('cl[%s]',compartments{j}))) && ~any(strcmp(keys(metabolite_concentration_ub{i}),sprintf('cl[%s]',compartments{j})))
            metabolite_concentration_value{i}(sprintf('cl[%s]',compartments{j})) = concentration_cl(j-1);
        end
    end
end

% load ranges
for i = 1:length(concentration_ranges_sources)
    [metabolites,lower_bound,upper_bound] = textread(sprintf('concentrations/%s.csv',concentration_ranges_sources{i}),'%s%f%f','delimiter',',','headerlines',1);
  
    % iterate over all metabolits
    for j = 1:length(metabolites)
        
        % ensure metabolite is found in model
        if ~any(strcmp(model.mets,metabolites{j}))
            error(sprintf('ERROR - Concentration Data - Metabolite ''%s'' in concentration range source ''%s'' is not found in the model',metabolites{j},concentration_ranges_sources{i}))
        end
        
        % ensure no duplicates
        if any(strcmp(metabolites(1:j-1),metabolites{j}))
            error(sprintf('ERROR - Concentration Data - Metabolite ''%s'' is duplicated in concentration range source ''%s''',metabolites{j},concentration_ranges_sources{i}))
        end
    
        % add range to each sample
        for k = 1:length(samples)
            if ~any(strcmp(keys(metabolite_concentration_value{k}),metabolites{j})) && ~any(strcmp(keys(metabolite_concentration_lb{k}),metabolites{j})) && ~any(strcmp(keys(metabolite_concentration_ub{k}),metabolites{j}))
                metabolite_concentration_lb{k}(metabolites{j}) = lower_bound(j);
                metabolite_concentration_ub{k}(metabolites{j}) = upper_bound(j);
            end
        end  
    end
end

%% ADD OBJECTIVE FUNCTION

switch objective_function
    case 1 % nadh[c] --> nad[c] + h[c]
        model.rxns{end+1} = 'objective';
        model.S(strcmp(model.mets,'nadh[c]'),end+1) = -1;
        model.S(strcmp(model.mets,'nad[c]'),end) = 1;
        model.S(strcmp(model.mets,'h[c]'),end) = 1;
        model.lb(end+1) = 0;
        model.ub(end+1) = 999999999;
        model.rev(end+1) = 0;
        model.c(end+1) = 1;
        model.rxnGeneMat(end+1,:) = zeros(size(model.rxnGeneMat(end,:)));
        model.rules{end+1} = '';
        model.grRules{end+1} = '';
        model.subSystems{end+1} = '';
        model.rxnNames{end+1} = '';
        model.rxnKeggID{end+1} = '';
        model.rxnConfidenceEcoIDA{end+1} = '';
        model.rxnConfidenceScores{end+1} = '';
        model.rxnsboTerm{end+1} = '';
        model.rxnReferences{end+1} = '';
        model.rxnECNumbers{end+1} = '';
        model.rxnNotes{end+1} = '';
        model.Exchange(end+1) = 0;
        model.Demand(end+1) = 1;
        model.Sink(end+1) = 0;
        model.rxnGeneMat_noisoforms(end+1,:) = zeros(size(model.rxnGeneMat_noisoforms(end,:)));
        model.Transport(end+1) = 0;
        model.TransportS(:,end+1) = zeros(length(model.mets),1);
        model.grRules_noisoforms{end+1} = '';

    case 2 % nadh[m] --> nad[m] + h[m]
        model.rxns{end+1} = 'objective';
        model.S(strcmp(model.mets,'nadh[m]'),end+1) = -1;
        model.S(strcmp(model.mets,'nad[m]'),end) = 1;
        model.S(strcmp(model.mets,'h[m]'),end) = 1;
        model.lb(end+1) = 0;
        model.ub(end+1) = 999999999;
        model.rev(end+1) = 0;
        model.c(end+1) = 1;
        model.rxnGeneMat(end+1,:) = zeros(size(model.rxnGeneMat(end,:)));
        model.rules{end+1} = '';
        model.grRules{end+1} = '';
        model.subSystems{end+1} = '';
        model.rxnNames{end+1} = '';
        model.rxnKeggID{end+1} = '';
        model.rxnConfidenceEcoIDA{end+1} = '';
        model.rxnConfidenceScores{end+1} = '';
        model.rxnsboTerm{end+1} = '';
        model.rxnReferences{end+1} = '';
        model.rxnECNumbers{end+1} = '';
        model.rxnNotes{end+1} = '';
        model.Exchange(end+1) = 0;
        model.Demand(end+1) = 1;
        model.Sink(end+1) = 0;
        model.rxnGeneMat_noisoforms(end+1,:) = zeros(size(model.rxnGeneMat_noisoforms(end,:)));
        model.Transport(end+1) = 0;
        model.TransportS(:,end+1) = zeros(length(model.mets),1);
        model.grRules_noisoforms{end+1} = '';

    case 3 % nadh[c] + nadh[m] --> nad[c] + nad[m] + h[c] + h[m]
        model.rxns{end+1} = 'objective';
        model.S(strcmp(model.mets,'nadh[c]'),end+1) = -1;
        model.S(strcmp(model.mets,'nadh[m]'),end) = -1;
        model.S(strcmp(model.mets,'nad[c]'),end) = 1;
        model.S(strcmp(model.mets,'nad[m]'),end) = 1;
        model.S(strcmp(model.mets,'h[c]'),end) = 1;
        model.S(strcmp(model.mets,'h[m]'),end) = 1;
        model.lb(end+1) = 0;
        model.ub(end+1) = 999999999;
        model.rev(end+1) = 0;
        model.c(end+1) = 1;
        model.rxnGeneMat(end+1,:) = zeros(size(model.rxnGeneMat(end,:)));
        model.rules{end+1} = '';
        model.grRules{end+1} = '';
        model.subSystems{end+1} = '';
        model.rxnNames{end+1} = '';
        model.rxnKeggID{end+1} = '';
        model.rxnConfidenceEcoIDA{end+1} = '';
        model.rxnConfidenceScores{end+1} = '';
        model.rxnsboTerm{end+1} = '';
        model.rxnReferences{end+1} = '';
        model.rxnECNumbers{end+1} = '';
        model.rxnNotes{end+1} = '';
        model.Exchange(end+1) = 0;
        model.Demand(end+1) = 1;
        model.Sink(end+1) = 0;
        model.rxnGeneMat_noisoforms(end+1,:) = zeros(size(model.rxnGeneMat_noisoforms(end,:)));
        model.Transport(end+1) = 0;
        model.TransportS(:,end+1) = zeros(length(model.mets),1);
        model.grRules_noisoforms{end+1} = '';

    case 4 % nadph[c] --> nadp[c] + h[c]
        model.rxns{end+1} = 'objective';
        model.S(strcmp(model.mets,'nadph[c]'),end+1) = -1;
        model.S(strcmp(model.mets,'nadp[c]'),end) = 1;
        model.S(strcmp(model.mets,'h[c]'),end) = 1;
        model.lb(end+1) = 0;
        model.ub(end+1) = 999999999;
        model.rev(end+1) = 0;
        model.c(end+1) = 1;
        model.rxnGeneMat(end+1,:) = zeros(size(model.rxnGeneMat(end,:)));
        model.rules{end+1} = '';
        model.grRules{end+1} = '';
        model.subSystems{end+1} = '';
        model.rxnNames{end+1} = '';
        model.rxnKeggID{end+1} = '';
        model.rxnConfidenceEcoIDA{end+1} = '';
        model.rxnConfidenceScores{end+1} = '';
        model.rxnsboTerm{end+1} = '';
        model.rxnReferences{end+1} = '';
        model.rxnECNumbers{end+1} = '';
        model.rxnNotes{end+1} = '';
        model.Exchange(end+1) = 0;
        model.Demand(end+1) = 1;
        model.Sink(end+1) = 0;
        model.rxnGeneMat_noisoforms(end+1,:) = zeros(size(model.rxnGeneMat_noisoforms(end,:)));
        model.Transport(end+1) = 0;
        model.TransportS(:,end+1) = zeros(length(model.mets),1);
        model.grRules_noisoforms{end+1} = '';

    case 5 % nadph[m] --> nadp[m] + h[m]
        model.rxns{end+1} = 'objective';
        model.S(strcmp(model.mets,'nadph[m]'),end+1) = -1;
        model.S(strcmp(model.mets,'nadp[m]'),end) = 1;
        model.S(strcmp(model.mets,'h[m]'),end) = 1;
        model.lb(end+1) = 0;
        model.ub(end+1) = 999999999;
        model.rev(end+1) = 0;
        model.c(end+1) = 1;
        model.rxnGeneMat(end+1,:) = zeros(size(model.rxnGeneMat(end,:)));
        model.rules{end+1} = '';
        model.grRules{end+1} = '';
        model.subSystems{end+1} = '';
        model.rxnNames{end+1} = '';
        model.rxnKeggID{end+1} = '';
        model.rxnConfidenceEcoIDA{end+1} = '';
        model.rxnConfidenceScores{end+1} = '';
        model.rxnsboTerm{end+1} = '';
        model.rxnReferences{end+1} = '';
        model.rxnECNumbers{end+1} = '';
        model.rxnNotes{end+1} = '';
        model.Exchange(end+1) = 0;
        model.Demand(end+1) = 1;
        model.Sink(end+1) = 0;
        model.rxnGeneMat_noisoforms(end+1,:) = zeros(size(model.rxnGeneMat_noisoforms(end,:)));
        model.Transport(end+1) = 0;
        model.TransportS(:,end+1) = zeros(length(model.mets),1);
        model.grRules_noisoforms{end+1} = '';

    case 6 % nadph[c] + nadph[m] --> nadp[c] + nadp[m] + h[c] + h[m]
        model.rxns{end+1} = 'objective';
        model.S(strcmp(model.mets,'nadph[c]'),end+1) = -1;
        model.S(strcmp(model.mets,'nadph[m]'),end) = -1;
        model.S(strcmp(model.mets,'nadp[c]'),end) = 1;
        model.S(strcmp(model.mets,'nadp[m]'),end) = 1;
        model.S(strcmp(model.mets,'h[c]'),end) = 1;
        model.S(strcmp(model.mets,'h[m]'),end) = 1;
        model.lb(end+1) = 0;
        model.ub(end+1) = 999999999;
        model.rev(end+1) = 0;
        model.c(end+1) = 1;
        model.rxnGeneMat(end+1,:) = zeros(size(model.rxnGeneMat(end,:)));
        model.rules{end+1} = '';
        model.grRules{end+1} = '';
        model.subSystems{end+1} = '';
        model.rxnNames{end+1} = '';
        model.rxnKeggID{end+1} = '';
        model.rxnConfidenceEcoIDA{end+1} = '';
        model.rxnConfidenceScores{end+1} = '';
        model.rxnsboTerm{end+1} = '';
        model.rxnReferences{end+1} = '';
        model.rxnECNumbers{end+1} = '';
        model.rxnNotes{end+1} = '';
        model.Exchange(end+1) = 0;
        model.Demand(end+1) = 1;
        model.Sink(end+1) = 0;
        model.rxnGeneMat_noisoforms(end+1,:) = zeros(size(model.rxnGeneMat_noisoforms(end,:)));
        model.Transport(end+1) = 0;
        model.TransportS(:,end+1) = zeros(length(model.mets),1);
        model.grRules_noisoforms{end+1} = '';

    case 7 % nadh[c] + nadh[m] + nadph[c] + nadph[m] --> nad[c] + nad[m] + nadp[c] + nadp[m] + 2 h[c] + 2 h[m]
        model.rxns{end+1} = 'objective';
        model.S(strcmp(model.mets,'nadh[c]'),end+1) = -1;
        model.S(strcmp(model.mets,'nadh[m]'),end) = -1;
        model.S(strcmp(model.mets,'nadph[c]'),end) = -1;
        model.S(strcmp(model.mets,'nadph[m]'),end) = -1;
        model.S(strcmp(model.mets,'nad[c]'),end) = 1;
        model.S(strcmp(model.mets,'nad[m]'),end) = 1;
        model.S(strcmp(model.mets,'nadp[c]'),end) = 1;
        model.S(strcmp(model.mets,'nadp[m]'),end) = 1;
        model.S(strcmp(model.mets,'h[c]'),end) = 2;
        model.S(strcmp(model.mets,'h[m]'),end) = 2;
        model.lb(end+1) = 0;
        model.ub(end+1) = 999999999;
        model.rev(end+1) = 0;
        model.c(end+1) = 1;
        model.rxnGeneMat(end+1,:) = zeros(size(model.rxnGeneMat(end,:)));
        model.rules{end+1} = '';
        model.grRules{end+1} = '';
        model.subSystems{end+1} = '';
        model.rxnNames{end+1} = '';
        model.rxnKeggID{end+1} = '';
        model.rxnConfidenceEcoIDA{end+1} = '';
        model.rxnConfidenceScores{end+1} = '';
        model.rxnsboTerm{end+1} = '';
        model.rxnReferences{end+1} = '';
        model.rxnECNumbers{end+1} = '';
        model.rxnNotes{end+1} = '';
        model.Exchange(end+1) = 0;
        model.Demand(end+1) = 1;
        model.Sink(end+1) = 0;
        model.rxnGeneMat_noisoforms(end+1,:) = zeros(size(model.rxnGeneMat_noisoforms(end,:)));
        model.Transport(end+1) = 0;
        model.TransportS(:,end+1) = zeros(length(model.mets),1);
        model.grRules_noisoforms{end+1} = '';

    case 8 % atp[c] + h2o[c] --> adp[c] + pi[c] + h[c]
        model.rxns{end+1} = 'objective';
        model.S(strcmp(model.mets,'atp[c]'),end+1) = -1;
        model.S(strcmp(model.mets,'h2o[c]'),end) = -1;
        model.S(strcmp(model.mets,'adp[c]'),end) = 1;
        model.S(strcmp(model.mets,'pi[c]'),end) = 1;
        model.S(strcmp(model.mets,'h[c]'),end) = 1;
        model.lb(end+1) = 0;
        model.ub(end+1) = 999999999;
        model.rev(end+1) = 0;
        model.c(end+1) = 1;
        model.rxnGeneMat(end+1,:) = zeros(size(model.rxnGeneMat(end,:)));
        model.rules{end+1} = '';
        model.grRules{end+1} = '';
        model.subSystems{end+1} = '';
        model.rxnNames{end+1} = '';
        model.rxnKeggID{end+1} = '';
        model.rxnConfidenceEcoIDA{end+1} = '';
        model.rxnConfidenceScores{end+1} = '';
        model.rxnsboTerm{end+1} = '';
        model.rxnReferences{end+1} = '';
        model.rxnECNumbers{end+1} = '';
        model.rxnNotes{end+1} = '';
        model.Exchange(end+1) = 0;
        model.Demand(end+1) = 1;
        model.Sink(end+1) = 0;
        model.rxnGeneMat_noisoforms(end+1,:) = zeros(size(model.rxnGeneMat_noisoforms(end,:)));
        model.Transport(end+1) = 0;
        model.TransportS(:,end+1) = zeros(length(model.mets),1);
        model.grRules_noisoforms{end+1} = '';

    case 9 % % atp[m] + h2o[m] --> adp[m] + pi[m] + h[m]
        model.rxns{end+1} = 'objective';
        model.S(strcmp(model.mets,'atp[m]'),end+1) = -1;
        model.S(strcmp(model.mets,'h2o[m]'),end) = -1;
        model.S(strcmp(model.mets,'adp[m]'),end) = 1;
        model.S(strcmp(model.mets,'pi[m]'),end) = 1;
        model.S(strcmp(model.mets,'h[m]'),end) = 1;
        model.lb(end+1) = 0;
        model.ub(end+1) = 999999999;
        model.rev(end+1) = 0;
        model.c(end+1) = 1;
        model.rxnGeneMat(end+1,:) = zeros(size(model.rxnGeneMat(end,:)));
        model.rules{end+1} = '';
        model.grRules{end+1} = '';
        model.subSystems{end+1} = '';
        model.rxnNames{end+1} = '';
        model.rxnKeggID{end+1} = '';
        model.rxnConfidenceEcoIDA{end+1} = '';
        model.rxnConfidenceScores{end+1} = '';
        model.rxnsboTerm{end+1} = '';
        model.rxnReferences{end+1} = '';
        model.rxnECNumbers{end+1} = '';
        model.rxnNotes{end+1} = '';
        model.Exchange(end+1) = 0;
        model.Demand(end+1) = 1;
        model.Sink(end+1) = 0;
        model.rxnGeneMat_noisoforms(end+1,:) = zeros(size(model.rxnGeneMat_noisoforms(end,:)));
        model.Transport(end+1) = 0;
        model.TransportS(:,end+1) = zeros(length(model.mets),1);
        model.grRules_noisoforms{end+1} = '';

    case 10 % atp[c] + atp[m] + h2o[c] + h2o[m] --> adp[c] + adp[m] + pi[c] + pi[m] + h[c] + h[m]
        model.rxns{end+1} = 'objective';
        model.S(strcmp(model.mets,'atp[c]'),end+1) = -1;
        model.S(strcmp(model.mets,'atp[m]'),end) = -1;
        model.S(strcmp(model.mets,'h2o[c]'),end) = -1;
        model.S(strcmp(model.mets,'h2o[m]'),end) = -1;
        model.S(strcmp(model.mets,'adp[c]'),end) = 1;
        model.S(strcmp(model.mets,'adp[m]'),end) = 1;
        model.S(strcmp(model.mets,'pi[c]'),end) = 1;
        model.S(strcmp(model.mets,'pi[m]'),end) = 1;
        model.S(strcmp(model.mets,'h[c]'),end) = 1;
        model.S(strcmp(model.mets,'h[m]'),end) = 1;
        model.lb(end+1) = 0;
        model.ub(end+1) = 999999999;
        model.rev(end+1) = 0;
        model.c(end+1) = 1;
        model.rxnGeneMat(end+1,:) = zeros(size(model.rxnGeneMat(end,:)));
        model.rules{end+1} = '';
        model.grRules{end+1} = '';
        model.subSystems{end+1} = '';
        model.rxnNames{end+1} = '';
        model.rxnKeggID{end+1} = '';
        model.rxnConfidenceEcoIDA{end+1} = '';
        model.rxnConfidenceScores{end+1} = '';
        model.rxnsboTerm{end+1} = '';
        model.rxnReferences{end+1} = '';
        model.rxnECNumbers{end+1} = '';
        model.rxnNotes{end+1} = '';
        model.Exchange(end+1) = 0;
        model.Demand(end+1) = 1;
        model.Sink(end+1) = 0;
        model.rxnGeneMat_noisoforms(end+1,:) = zeros(size(model.rxnGeneMat_noisoforms(end,:)));
        model.Transport(end+1) = 0;
        model.TransportS(:,end+1) = zeros(length(model.mets),1);
        model.grRules_noisoforms{end+1} = '';

    case 11 % biomass
        model.c(strcmp(model.rxns,'biomass_reaction')) = 1;
        
    case 12 % nadp[c] + nadp[m] + h[c] + h[m] --> nadph[c] + nadph[m]
        model.rxns{end+1} = 'objective';
        model.S(strcmp(model.mets,'nadp[c]'),end+1) = -1;
        model.S(strcmp(model.mets,'nadp[m]'),end) = -1;
        model.S(strcmp(model.mets,'h[c]'),end) = -1;
        model.S(strcmp(model.mets,'h[m]'),end) = -1;
        model.S(strcmp(model.mets,'nadph[c]'),end) = 1;
        model.S(strcmp(model.mets,'nadph[m]'),end) = 1;
        model.lb(end+1) = 0;
        model.ub(end+1) = 999999999;
        model.rev(end+1) = 0;
        model.c(end+1) = 1;
        model.rxnGeneMat(end+1,:) = zeros(size(model.rxnGeneMat(end,:)));
        model.rules{end+1} = '';
        model.grRules{end+1} = '';
        model.subSystems{end+1} = '';
        model.rxnNames{end+1} = '';
        model.rxnKeggID{end+1} = '';
        model.rxnConfidenceEcoIDA{end+1} = '';
        model.rxnConfidenceScores{end+1} = '';
        model.rxnsboTerm{end+1} = '';
        model.rxnReferences{end+1} = '';
        model.rxnECNumbers{end+1} = '';
        model.rxnNotes{end+1} = '';
        model.Exchange(end+1) = 0;
        model.Demand(end+1) = 1;
        model.Sink(end+1) = 0;
        model.rxnGeneMat_noisoforms(end+1,:) = zeros(size(model.rxnGeneMat_noisoforms(end,:)));
        model.Transport(end+1) = 0;
        model.TransportS(:,end+1) = zeros(length(model.mets),1);
        model.grRules_noisoforms{end+1} = '';
        
    case 13 % nadph[c] + nadph[m] --> nadp[c] + nadp[m]
        model.rxns{end+1} = 'objective';
        model.S(strcmp(model.mets,'nadph[c]'),end+1) = -1;
        model.S(strcmp(model.mets,'nadph[m]'),end) = -1;
        model.S(strcmp(model.mets,'nadp[c]'),end) = 1;
        model.S(strcmp(model.mets,'nadp[m]'),end) = 1;
        model.lb(end+1) = 0;
        model.ub(end+1) = 999999999;
        model.rev(end+1) = 0;
        model.c(end+1) = 1;
        model.rxnGeneMat(end+1,:) = zeros(size(model.rxnGeneMat(end,:)));
        model.rules{end+1} = '';
        model.grRules{end+1} = '';
        model.subSystems{end+1} = '';
        model.rxnNames{end+1} = '';
        model.rxnKeggID{end+1} = '';
        model.rxnConfidenceEcoIDA{end+1} = '';
        model.rxnConfidenceScores{end+1} = '';
        model.rxnsboTerm{end+1} = '';
        model.rxnReferences{end+1} = '';
        model.rxnECNumbers{end+1} = '';
        model.rxnNotes{end+1} = '';
        model.Exchange(end+1) = 0;
        model.Demand(end+1) = 1;
        model.Sink(end+1) = 0;
        model.rxnGeneMat_noisoforms(end+1,:) = zeros(size(model.rxnGeneMat_noisoforms(end,:)));
        model.Transport(end+1) = 0;
        model.TransportS(:,end+1) = zeros(length(model.mets),1);
        model.grRules_noisoforms{end+1} = '';
        
    case 14 % nadp[c] + nadp[m] --> nadph[c] + nadph[m]
        model.rxns{end+1} = 'objective';
        model.S(strcmp(model.mets,'nadp[c]'),end+1) = -1;
        model.S(strcmp(model.mets,'nadp[m]'),end) = -1;
        model.S(strcmp(model.mets,'nadph[c]'),end) = 1;
        model.S(strcmp(model.mets,'nadph[m]'),end) = 1;
        model.lb(end+1) = 0;
        model.ub(end+1) = 999999999;
        model.rev(end+1) = 0;
        model.c(end+1) = 1;
        model.rxnGeneMat(end+1,:) = zeros(size(model.rxnGeneMat(end,:)));
        model.rules{end+1} = '';
        model.grRules{end+1} = '';
        model.subSystems{end+1} = '';
        model.rxnNames{end+1} = '';
        model.rxnKeggID{end+1} = '';
        model.rxnConfidenceEcoIDA{end+1} = '';
        model.rxnConfidenceScores{end+1} = '';
        model.rxnsboTerm{end+1} = '';
        model.rxnReferences{end+1} = '';
        model.rxnECNumbers{end+1} = '';
        model.rxnNotes{end+1} = '';
        model.Exchange(end+1) = 0;
        model.Demand(end+1) = 1;
        model.Sink(end+1) = 0;
        model.rxnGeneMat_noisoforms(end+1,:) = zeros(size(model.rxnGeneMat_noisoforms(end,:)));
        model.Transport(end+1) = 0;
        model.TransportS(:,end+1) = zeros(length(model.mets),1);
        model.grRules_noisoforms{end+1} = '';
end

% save original model
model_original = model;
            
%% SETUP SAMPLES AND GENE KNOCKDOWNS

% iterate over every sample
for a = 1:length(samples)
    
    % create sample folder
    mkdir(sprintf('results/%s/%s',results_folder,samples{a}))
    
    % initialize objval results file
    f_objval = fopen(sprintf('results/%s/%s/objval.txt',results_folder,samples{a}),'w');
    if knockdown_perform == 1
        fprintf(f_objval,'GENE\tID\tFRACTION\tOBJVAL\tFRACTION\n');
    end

    % iterate over wt and every gene knockdown
    for b = 1:length(protein)
        
        % if gene knockdown, only perform if gene is in model
        if (knockdown_perform == 1) && (b ~= 1)
            if any(strcmp(model.genes_noisoforms,knockdown_genes{b-1}))
                to_run = 1;
            else
                to_run = 0;
            end
        else
            to_run = 1;
        end
        
        if to_run == 1

%% CREATE MODEL

            % load original model
            model = model_original;
                        
            % set reaction upper bounds
            for i = 1:length(kcat)
                if model.ub(i)==999999999 && ~isnan(protein{b}(i,a)*kcat(i))
                    model.ub(i) = protein{b}(i,a)*kcat(i);
                end
            end

            % restrict exchange reactions to metabolites in extracellular space
            for i = 1:length(model.rxns)
                if model.Exchange(i)
                    metabolite = find(model.S(:,i)~=0);
                    if ~any(strcmp(keys(metabolite_concentration_value{a}),model.mets{metabolite}))
                        if full(model.S(model.S(:,i)~=0,i)) < 0
                            model.lb(i) = 0;
                        else
                            model.ub(i) = 0;
                        end
                    end
                end
            end

            % set known sample flux values
            key = keys(reaction_flux_value{a});
            val = values(reaction_flux_value{a});
            for i = 1:length(key)
                model.lb(strcmp(model.rxns,key{i})) = val(i);
                model.ub(strcmp(model.rxns,key{i})) = val(i);
            end

            % set known sample flux ranges
            key = keys(reaction_flux_lb{a});
            val = values(reaction_flux_lb{a});
            for i = 1:length(key)
                model.lb(strcmp(model.rxns,key{i})) = val(i);
            end

            key = keys(reaction_flux_ub{a});
            val = values(reaction_flux_ub{a});
            for i = 1:length(key)
                model.ub(strcmp(model.rxns,key{i})) = val(i);
            end

     %% CREATE MILP PROBLEM

            % change variable names
            model.A = model.S;
            model.rhs = model.b;
            model.obj = model.c;
            model.sense = repmat('=',1,length(model.mets));
            model.vtype = repmat('C',1,length(model.rxns));

            model.varnames = {};
            for i = 1:length(model.rxns)
                model.varnames{end+1} = sprintf('flux_%s',model.rxns{i});
            end

            model = rmfield(model,{'S','b','c'});

            % vmax equation
            %
            % v <= vmax*b
            % ---->  v - vmax*b <= 0
            model.A = vertcat(model.A,zeros(length(model.rxns),length(model.rxns)));
            model.A = horzcat(model.A,zeros(length(model.mets)+length(model.rxns),length(model.rxns)));

            for i = 1:length(model.rxns)
                model.A(length(model.mets)+i,i) = 1;
                model.A(length(model.mets)+i,length(model.rxns)+i) = -model.ub(i);
            end

            model.rhs = vertcat(model.rhs,zeros(length(model.rxns),1));

            model.sense = strcat(model.sense,repmat('<',1,length(model.rxns)));

            model.lb = vertcat(model.lb,zeros(length(model.rxns),1));
            model.ub = vertcat(model.ub,ones(length(model.rxns),1));
            model.obj = vertcat(model.obj,zeros(length(model.rxns),1));
            model.vtype = strcat(model.vtype,repmat('B',1,length(model.rxns)));
            for i = 1:length(model.rxns)
                model.varnames{end+1} = sprintf('state_%s',model.rxns{i});
            end

            % deltaG equation
            %
            % dG <= K - K*b
            % ---->  dG + K*b <= K
            %
            % non-transport: dG_standard + K*b + sum(R*T*stoich*lnconc) <= K
            %
            % transport: dG_standard + K*b + sum(R*T*stoich*lnconc) + sum(stoich*charge*F*V) <= K
            % ----> dG_standard + K*b + sum(R*T*stoich*lnconc) <= K - sum(stoich*charge*R*T*lngrad)
            model.A = vertcat(model.A,zeros(length(model.rxns),length(model.rxns)*2));
            model.A = horzcat(model.A,zeros(length(model.mets)+length(model.rxns)*2,length(model.mets)+length(model.rxns)));

            K = 999999999;
            RT = 2.479;

            for i = 1:length(model.rxns)
                model.A(length(model.mets)+length(model.rxns)+i,length(model.rxns)+i) = K;
                metabolites = find(model.A(1:length(model.mets),i)~=0);
                for j = 1:length(metabolites)
                    model.A(length(model.mets)+length(model.rxns)+i,length(model.rxns)*2+metabolites(j)) = RT*full(model.A(metabolites(j),i));
                end
                model.A(length(model.mets)+length(model.rxns)+i,length(model.rxns)*2+length(model.mets)+i) = 1;
            end

            for i = 1:length(model.rxns)
                model.rhs(end+1) = K;

                if model.Transport(i)
                    reactants = find(model.TransportS(:,i) < 0);
                    products = find(model.TransportS(:,i) > 0);

                    for j = 1:length(reactants)
                        k_found = nan;
                        for k = 1:length(products)
                            if strcmp(model.mets{reactants(j)}(1:end-4),model.mets{products(k)}(1:end-4))
                                k_found = k;
                            end
                        end

                        compartment_reactant = model.mets{reactants(j)}(end-1); 
                        compartment_product = model.mets{products(k_found)}(end-1);
                        FV = RT * log( ( membrane_permeability_na*log(metabolite_concentration_value{a}(sprintf('na1[%s]',compartment_product))) + membrane_permeability_k*log(metabolite_concentration_value{a}(sprintf('k[%s]',compartment_product))) + membrane_permeability_cl*log(metabolite_concentration_value{a}(sprintf('cl[%s]',compartment_reactant))) ) / ( membrane_permeability_na*log(metabolite_concentration_value{a}(sprintf('na1[%s]',compartment_reactant))) + membrane_permeability_k*log(metabolite_concentration_value{a}(sprintf('k[%s]',compartment_reactant))) + membrane_permeability_cl*log(metabolite_concentration_value{a}(sprintf('cl[%s]',compartment_product))) ) );
                        model.rhs(end) = model.rhs(end) - abs(model.TransportS(reactants(j),i)) * model.metCharge(reactants(j)) * FV;
                    end
                end
            end

            model.sense = strcat(model.sense,repmat('<',1,length(model.rxns)));

            for i = 1:length(model.mets)
                if any(strcmp(keys(metabolite_concentration_value{a}),model.mets{i}))
                    model.lb(end+1) = log(metabolite_concentration_value{a}(model.mets{i}));
                    model.ub(end+1) = log(metabolite_concentration_value{a}(model.mets{i}));
                else
                    if any(strcmp(keys(metabolite_concentration_lb{a}),model.mets{i}))
                        model.lb(end+1) = log(metabolite_concentration_lb{a}(model.mets{i}));
                    else
                        model.lb(end+1) = -15;
                    end
                    if any(strcmp(keys(metabolite_concentration_ub{a}),model.mets{i}))
                        model.ub(end+1) = log(metabolite_concentration_ub{a}(model.mets{i}));
                    else
                        model.ub(end+1) = -2;
                    end
                end
            end
            model.obj = vertcat(model.obj,zeros(length(model.mets),1));
            model.vtype = strcat(model.vtype,repmat('C',1,length(model.mets)));
            for i = 1:length(model.mets)
                model.varnames{end+1} = sprintf('concentration_%s',model.mets{i});
            end

            for i = 1:length(deltag)
                model.lb(end+1) = deltag(i)-0.5*uncertainty(i);
                model.ub(end+1) = deltag(i)+0.5*uncertainty(i);
%                 model.lb(end+1) = -999999;
%                 model.ub(end+1) = -999999;
            end
            model.lb(end+1) = -999999;
            model.ub(end+1) = -999999;

            model.obj = vertcat(model.obj,zeros(length(model.rxns),1));
            model.vtype = strcat(model.vtype,repmat('C',1,length(model.rxns)));
            for i = 1:length(model.rxns)
                model.varnames{end+1} = sprintf('deltag_%s',model.rxns{i});
            end

    %% RUN FBA

            % parameters
            params.outputflag = 1;
            params.timelimit = 5*60;
            params.numericfocus = 3;
            model.modelsense = 'max';

            % run fba
            result = gurobi(model,params);
            objective_value = result.objval;
            if b == 1
                objective_value_wt = objective_value;
            end

            % output results
            if knockdown_perform == 1
                if b == 1
                    fprintf(f_objval,'WT\t\t%f\t1\n',objective_value);
                else
                    fraction_of_wt = objective_value/objective_value_wt;
                    fprintf(f_objval,'%s\t%s\t%f\t%f\t%f\n',knockdown_genes{b-1},model.geneids_noisoforms{strcmp(model.genes_noisoforms,knockdown_genes{b-1})},knockdown_values(b-1),objective_value,fraction_of_wt);
                end
            else
                fprintf(f_objval,'%f\n',objective_value);
            end

    %% RUN pFBA

            if type_of_analysis == 2

                % create pfba results file
                if knockdown_perform == 1
                    if b == 1
                        f_pfba = fopen(sprintf('results/%s/%s/pfba-WT.txt',results_folder,samples{a}),'w');
                    else
                        f_pfba = fopen(sprintf('results/%s/%s/pfba-KD-%s.txt',results_folder,samples{a},knockdown_genes{b-1}),'w');
                    end
                else
                    f_pfba = fopen(sprintf('results/%s/%s/pfba.txt',results_folder,samples{a}),'w');
                end

                % repeat with smaller pfba fractions until solution is found
                success = 0;
                c = 0;
                while (success == 0) && (c < length(pfba_fractions))
                    c = c + 1;

                    % bound objective function
                    if objective_function == 11
                        model.lb(strcmp(model.varnames,'flux_biomass_reaction')) = pfba_fractions(c)*objective_value;
                        model.ub(strcmp(model.varnames,'flux_biomass_reaction')) = objective_value;
                    else
                        model.lb(strcmp(model.varnames,'flux_objective')) = pfba_fractions(c)*objective_value;
                        model.ub(strcmp(model.varnames,'flux_objective')) = objective_value;
                    end

                    % change objective
                    model.obj = zeros(size(model.obj));
                    for i = 1:length(model.rxns)
                        model.obj(i) = 1;
                    end
                    if objective_function == 11
                        model.obj(strcmp(model.varnames,'flux_biomass_reaction')) = 0;
                    else
                        model.obj(strcmp(model.varnames,'flux_objective')) = 0;
                    end

                    % parameters
                    params.outputflag = 0;
                    params.timelimit = 5*60;
                    params.numericfocus = 3;
                    model.modelsense = 'min';

                    % run pfba
                    result = gurobi(model,params);

                    % if pfba objective found, was a success
                    if isfield(result,'objval')
                        success = 1;
                        fprintf(f_pfba,'pFBA solution found at fraction = %f\n\n',pfba_fractions(c));

                        if objective_function ~= 11

                            % get objective function reactions
                            result_index = [];
                            result_value = [];

                            for i = 1:length(model.rxns)-1
                                switch objective_function
                                    case 1 % nadh[c] --> nad[c] + h[c]
                                        if (model.A(strcmp(model.mets,'nadh[c]'),i) > 0) && (model.A(strcmp(model.mets,'nad[c]'),i) < 0)
                                            result_index(end+1) = i;
                                            result_value(end+1) = result.x(i);
                                        end

                                    case 2 % nadh[m] --> nad[m] + h[m]
                                        if (model.A(strcmp(model.mets,'nadh[m]'),i) > 0) && (model.A(strcmp(model.mets,'nad[m]'),i) < 0)
                                            result_index(end+1) = i;
                                            result_value(end+1) = result.x(i);
                                        end

                                    case 3 % nadh[c] + nadh[m] --> nad[c] + nad[m] + h[c] + h[m]
                                        if ((model.A(strcmp(model.mets,'nadh[c]'),i) > 0) && (model.A(strcmp(model.mets,'nad[c]'),i) < 0)) || ((model.A(strcmp(model.mets,'nadh[m]'),i) > 0) && (model.A(strcmp(model.mets,'nad[m]'),i) < 0))
                                            result_index(end+1) = i;
                                            result_value(end+1) = result.x(i);
                                        end

                                    case 4 % nadph[c] --> nadp[c] + h[c]
                                        if (model.A(strcmp(model.mets,'nadph[c]'),i) > 0) && (model.A(strcmp(model.mets,'nadp[c]'),i) < 0)
                                            result_index(end+1) = i;
                                            result_value(end+1) = result.x(i);
                                        end

                                    case 5 % nadph[m] --> nadp[m] + h[m]
                                        if (model.A(strcmp(model.mets,'nadph[m]'),i) > 0) && (model.A(strcmp(model.mets,'nadp[m]'),i) < 0)
                                            result_index(end+1) = i;
                                            result_value(end+1) = result.x(i);
                                        end

                                    case 6 % nadph[c] + nadph[m] --> nadp[c] + nadp[m] + h[c] + h[m]
                                        if ((model.A(strcmp(model.mets,'nadph[c]'),i) > 0) && (model.A(strcmp(model.mets,'nadp[c]'),i) < 0)) || ((model.A(strcmp(model.mets,'nadph[m]'),i) > 0) && (model.A(strcmp(model.mets,'nadp[m]'),i) < 0))
                                            result_index(end+1) = i;
                                            result_value(end+1) = result.x(i);
                                        end

                                    case 7 % nadh[c] + nadh[m] + nadph[c] + nadph[m] --> nad[c] + nad[m] + nadp[c] + nadp[m] + 2 h[c] + 2 h[m]
                                        if ((model.A(strcmp(model.mets,'nadh[c]'),i) > 0) && (model.A(strcmp(model.mets,'nad[c]'),i) < 0)) || ((model.A(strcmp(model.mets,'nadh[m]'),i) > 0) && (model.A(strcmp(model.mets,'nad[m]'),i) < 0)) || ((model.A(strcmp(model.mets,'nadph[c]'),i) > 0) && (model.A(strcmp(model.mets,'nadp[c]'),i) < 0)) || ((model.A(strcmp(model.mets,'nadph[m]'),i) > 0) && (model.A(strcmp(model.mets,'nadp[m]'),i) < 0))
                                            result_index(end+1) = i;
                                            result_value(end+1) = result.x(i);
                                        end

                                    case 8 % atp[c] + h2o[c] --> adp[c] + pi[c] + h[c]
                                        if (model.A(strcmp(model.mets,'atp[c]'),i) > 0) && (model.A(strcmp(model.mets,'adp[c]'),i) < 0)
                                            result_index(end+1) = i;
                                            result_value(end+1) = result.x(i);
                                        end

                                    case 9 % atp[m] + h2o[m] --> adp[m] + pi[m] + h[m]
                                        if (model.A(strcmp(model.mets,'atp[m]'),i) > 0) && (model.A(strcmp(model.mets,'adp[m]'),i) < 0)
                                            result_index(end+1) = i;
                                            result_value(end+1) = result.x(i);
                                        end

                                    case 10 % atp[c] + atp[m] + h2o[c] + h2o[m] --> adp[c] + adp[m] + pi[c] + pi[m] + h[c] + h[m]
                                        if ((model.A(strcmp(model.mets,'atp[c]'),i) > 0) && (model.A(strcmp(model.mets,'adp[c]'),i) < 0)) || ((model.A(strcmp(model.mets,'atp[m]'),i) > 0) && (model.A(strcmp(model.mets,'adp[m]'),i) < 0))
                                            result_index(end+1) = i;
                                            result_value(end+1) = result.x(i);
                                        end
                                        
                                    case 12 % nadp[c] + nadp[m] + h[c] + h[m] --> nadph[c] + nadph[m]
                                        if ((model.A(strcmp(model.mets,'nadp[c]'),i) > 0) && (model.A(strcmp(model.mets,'nadph[c]'),i) < 0)) || ((model.A(strcmp(model.mets,'nadp[m]'),i) > 0) && (model.A(strcmp(model.mets,'nadph[m]'),i) < 0))
                                            result_index(end+1) = i;
                                            result_value(end+1) = result.x(i);
                                        end
                                        
                                    case 13 % nadph[c] + nadph[m] --> nadp[c] + nadp[m]
                                        if ((model.A(strcmp(model.mets,'nadph[c]'),i) > 0) && (model.A(strcmp(model.mets,'nadp[c]'),i) < 0)) || ((model.A(strcmp(model.mets,'nadph[m]'),i) > 0) && (model.A(strcmp(model.mets,'nadp[m]'),i) < 0))
                                            result_index(end+1) = i;
                                            result_value(end+1) = result.x(i);
                                        end
                                        
                                    case 14 % nadp[c] + nadp[m] --> nadph[c] + nadph[m]
                                        if ((model.A(strcmp(model.mets,'nadp[c]'),i) > 0) && (model.A(strcmp(model.mets,'nadph[c]'),i) < 0)) || ((model.A(strcmp(model.mets,'nadp[m]'),i) > 0) && (model.A(strcmp(model.mets,'nadph[m]'),i) < 0))
                                            result_index(end+1) = i;
                                            result_value(end+1) = result.x(i);
                                        end
                                end
                            end

                            % sort objective function reactions
                            [result_value,sorted] = sort(result_value,'descend');
                            result_index = result_index(sorted);

                            result_percent = [];
                            for i = 1:length(result_value)
                                result_percent(end+1) = result_value(i) / sum(result_value) * 100;
                            end

                            % output objective function reactions
                            fprintf(f_pfba,'PERCENT\tFLUX\tGENES\tID\tNAME\tSUBSYSTEM\tFORMULA\n');
                            for i = 1:length(result_index)
                                fprintf(f_pfba,'%f\t%f\t%s\t%s\t%s\t%s\t%s\n',result_percent(i),result_value(i),strjoin(model.geneids_noisoforms(find(model.rxnGeneMat_noisoforms(result_index(i),:)))',','),model.rxns{result_index(i)},model.rxnNames{result_index(i)},model.subSystems{result_index(i)},model.formulas{result_index(i)});
                            end
                        end
                    end
                end

                % if no pfba objective found
                if success == 0
                    if knockdown_perform == 1
                        if b == 1
                            fprintf(f_pfba,'No pFBA solution found');
                        else
                            fprintf(f_pfba,'No pFBA solution found');
                        end
                    else
                        fprintf(f_pfba,'No pFBA solution found');
                    end
                end

                % close pfba file
                fclose(f_pfba);
            end

    %% RUN FVA

            if type_of_analysis == 3

                % create fva results file
                if knockdown_perform == 1
                    if b == 1
                        f_fva = fopen(sprintf('results/%s/%s/fva-WT.txt',results_folder,samples{a}),'w');
                    else
                        f_fva = fopen(sprintf('results/%s/%s/fva-KD-%s.txt',results_folder,samples{a},knockdown_genes{b-1}),'w');
                    end
                else
                    f_fva = fopen(sprintf('results/%s/%s/fva.txt',results_folder,samples{a}),'w');
                end

                % bound objective function
                if objective_function == 11
                    model.lb(strcmp(model.varnames,'flux_biomass_reaction')) = fva_fraction*objective_value;
                    model.ub(strcmp(model.varnames,'flux_biomass_reaction')) = objective_value;
                else
                    model.lb(strcmp(model.varnames,'flux_objective')) = fva_fraction*objective_value;
                    model.ub(strcmp(model.varnames,'flux_objective')) = objective_value;
                end

                % clear objective function
                model.obj = zeros(size(model.obj));

                % determine objective function reactions
                if objective_function == 11
                    objfunc_reactions = {'biomass_reaction'};
                else
                    objfunc_reactions = {};
                    for i = 1:length(model.rxns)-1
                        switch objective_function
                            case 1 % nadh[c] --> nad[c] + h[c]
                                if (model.A(strcmp(model.mets,'nadh[c]'),i) > 0) && (model.A(strcmp(model.mets,'nad[c]'),i) < 0)
                                    objfunc_reactions{end+1} = model.rxns{i};
                                end

                            case 2 % nadh[m] --> nad[m] + h[m]
                                if (model.A(strcmp(model.mets,'nadh[m]'),i) > 0) && (model.A(strcmp(model.mets,'nad[m]'),i) < 0)
                                    objfunc_reactions{end+1} = model.rxns{i};
                                end

                            case 3 % nadh[c] + nadh[m] --> nad[c] + nad[m] + h[c] + h[m]
                                if ((model.A(strcmp(model.mets,'nadh[c]'),i) > 0) && (model.A(strcmp(model.mets,'nad[c]'),i) < 0)) || ((model.A(strcmp(model.mets,'nadh[m]'),i) > 0) && (model.A(strcmp(model.mets,'nad[m]'),i) < 0))
                                    objfunc_reactions{end+1} = model.rxns{i};
                                end

                            case 4 % nadph[c] --> nadp[c] + h[c]
                                if (model.A(strcmp(model.mets,'nadph[c]'),i) > 0) && (model.A(strcmp(model.mets,'nadp[c]'),i) < 0)
                                    objfunc_reactions{end+1} = model.rxns{i};
                                end

                            case 5 % nadph[m] --> nadp[m] + h[m]
                                if (model.A(strcmp(model.mets,'nadph[m]'),i) > 0) && (model.A(strcmp(model.mets,'nadp[m]'),i) < 0)
                                    objfunc_reactions{end+1} = model.rxns{i};
                                end

                            case 6 % nadph[c] + nadph[m] --> nadp[c] + nadp[m] + h[c] + h[m]
                                if ((model.A(strcmp(model.mets,'nadph[c]'),i) > 0) && (model.A(strcmp(model.mets,'nadp[c]'),i) < 0)) || ((model.A(strcmp(model.mets,'nadph[m]'),i) > 0) && (model.A(strcmp(model.mets,'nadp[m]'),i) < 0))
                                    objfunc_reactions{end+1} = model.rxns{i};
                                end

                            case 7 % nadh[c] + nadh[m] + nadph[c] + nadph[m] --> nad[c] + nad[m] + nadp[c] + nadp[m] + 2 h[c] + 2 h[m]
                                if ((model.A(strcmp(model.mets,'nadh[c]'),i) > 0) && (model.A(strcmp(model.mets,'nad[c]'),i) < 0)) || ((model.A(strcmp(model.mets,'nadh[m]'),i) > 0) && (model.A(strcmp(model.mets,'nad[m]'),i) < 0)) || ((model.A(strcmp(model.mets,'nadph[c]'),i) > 0) && (model.A(strcmp(model.mets,'nadp[c]'),i) < 0)) || ((model.A(strcmp(model.mets,'nadph[m]'),i) > 0) && (model.A(strcmp(model.mets,'nadp[m]'),i) < 0))
                                    objfunc_reactions{end+1} = model.rxns{i};
                                end

                            case 8 % atp[c] + h2o[c] --> adp[c] + pi[c] + h[c]
                                if (model.A(strcmp(model.mets,'atp[c]'),i) > 0) && (model.A(strcmp(model.mets,'adp[c]'),i) < 0)
                                    objfunc_reactions{end+1} = model.rxns{i};
                                end

                            case 9 % atp[m] + h2o[m] --> adp[m] + pi[m] + h[m]
                                if (model.A(strcmp(model.mets,'atp[m]'),i) > 0) && (model.A(strcmp(model.mets,'adp[m]'),i) < 0)
                                    objfunc_reactions{end+1} = model.rxns{i};
                                end

                            case 10 % atp[c] + atp[m] + h2o[c] + h2o[m] --> adp[c] + adp[m] + pi[c] + pi[m] + h[c] + h[m]
                                if ((model.A(strcmp(model.mets,'atp[c]'),i) > 0) && (model.A(strcmp(model.mets,'adp[c]'),i) < 0)) || ((model.A(strcmp(model.mets,'atp[m]'),i) > 0) && (model.A(strcmp(model.mets,'adp[m]'),i) < 0))
                                    objfunc_reactions{end+1} = model.rxns{i};
                                end
                                
                            case 12 % nadp[c] + nadp[m] + h[c] + h[m] --> nadph[c] + nadph[m]
                                if ((model.A(strcmp(model.mets,'nadp[c]'),i) > 0) && (model.A(strcmp(model.mets,'nadph[c]'),i) < 0)) || ((model.A(strcmp(model.mets,'nadp[m]'),i) > 0) && (model.A(strcmp(model.mets,'nadph[m]'),i) < 0))
                                    objfunc_reactions{end+1} = model.rxns{i};
                                end
                                
                            case 13 % nadph[c] + nadph[m] --> nadp[c] + nadp[m]
                                if ((model.A(strcmp(model.mets,'nadph[c]'),i) > 0) && (model.A(strcmp(model.mets,'nadp[c]'),i) < 0)) || ((model.A(strcmp(model.mets,'nadph[m]'),i) > 0) && (model.A(strcmp(model.mets,'nadp[m]'),i) < 0))
                                    objfunc_reactions{end+1} = model.rxns{i};
                                end
                                
                            case 14 % nadp[c] + nadp[m] --> nadph[c] + nadph[m]
                                if ((model.A(strcmp(model.mets,'nadp[c]'),i) > 0) && (model.A(strcmp(model.mets,'nadph[c]'),i) < 0)) || ((model.A(strcmp(model.mets,'nadp[m]'),i) > 0) && (model.A(strcmp(model.mets,'nadph[m]'),i) < 0))
                                    objfunc_reactions{end+1} = model.rxns{i};
                                end
                        end
                    end
                end

                % determine objective function metabolites
                switch objective_function
                    case 1 % nadh[c] --> nad[c] + h[c]
                        objfunc_metabolites = {'nad[c]','nadh[c]'};

                    case 2 % nadh[m] --> nad[m] + h[m]
                        objfunc_metabolites = {'nad[m]','nadh[m]'};

                    case 3 % nadh[c] + nadh[m] --> nad[c] + nad[m] + h[c] + h[m]
                        objfunc_metabolites = {'nad[c]','nad[m]','nadh[c]','nadh[m]'};

                    case 4 % nadph[c] --> nadp[c] + h[c]
                        objfunc_metabolites = {'nadp[c]','nadph[c]'};

                    case 5 % nadph[m] --> nadp[m] + h[m]
                        objfunc_metabolites = {'nadp[m]','nadph[m]'};

                    case 6 % nadph[c] + nadph[m] --> nadp[c] + nadp[m] + h[c] + h[m]
                        objfunc_metabolites = {'nadp[c]','nadp[m]','nadph[c]','nadph[m]'};

                    case 7 % nadh[c] + nadh[m] + nadph[c] + nadph[m] --> nad[c] + nad[m] + nadp[c] + nadp[m] + 2 h[c] + 2 h[m]
                        objfunc_metabolites = {'nad[c]','nad[m]','nadp[c]','nadp[m]','nadh[c]','nadh[m]','nadph[c]','nadph[m]'};

                    case 8 % atp[c] + h2o[c] --> adp[c] + pi[c] + h[c]
                        objfunc_metabolites = {'adp[c]','atp[c]'};

                    case 9 % atp[m] + h2o[m] --> adp[m] + pi[m] + h[m]
                        objfunc_metabolites = {'adp[m]','atp[m]'};

                    case 10 % atp[c] + atp[m] + h2o[c] + h2o[m] --> adp[c] + adp[m] + pi[c] + pi[m] + h[c] + h[m]
                        objfunc_metabolites = {'adp[c]','adp[m]','atp[c]','atp[m]'};

                    case 11 % biomass
                        objfunc_metabolites = {};
                        
                    case 12 % nadp[c] + nadp[m] + h[c] + h[m] --> nadph[c] + nadph[m]
                        objfunc_metabolites = {'nadp[c]','nadp[m]','nadph[c]','nadph[m]'};
                        
                    case 13 % nadph[c] + nadph[m] --> nadp[c] + nadp[m]
                        objfunc_metabolites = {'nadp[c]','nadp[m]','nadph[c]','nadph[m]'};
                        
                    case 14 % nadp[c] + nadp[m] --> nadph[c] + nadph[m]
                        objfunc_metabolites = {'nadp[c]','nadp[m]','nadph[c]','nadph[m]'};
                end

                % iterate thru every variable
                done_flux = 0;
                done_state = 0;
                done_concentration = 0;
                done_deltag = 0;

                for i = 1:length(model.varnames)

                    % get variable name
                    split = strsplit(model.varnames{i},'_');
                    type = split{1};
                    name = strjoin(split(2:end),'_');

                    % flux variables
                    if strcmp(type,'flux')
                        if (any(strcmp(objfunc_reactions,name)) && any(strcmp(fva_variables,'flux_obj'))) || (~any(strcmp(objfunc_reactions,name)) && any(strcmp(fva_variables,'flux_nonobj')))

                            % find reaction id
                            rxnid = find(strcmp(model.rxns,name));

                            % set objective
                            model.obj(i) = 1;

                            % minimization parameters
                            params.outputflag = 0;
                            params.timelimit = 5*60;
                            params.numericfocus = 3;
                            model.modelsense = 'min';

                            % run minimization
                            result = gurobi(model,params);

                            % return result if success, otherwise return NaN
                            if isfield(result,'objval')
                                minval = result.objval;
                            else
                                minval = NaN;
                            end

                            % maximization parameters
                            params.outputflag = 0;
                            params.timelimit = 5*60;
                            params.numericfocus = 3;
                            model.modelsense = 'max';

                            % run maximization
                            result = gurobi(model,params);

                            % return result if success, otherwise return NaN
                            if isfield(result,'objval')
                                maxval = result.objval;
                            else
                                maxval = NaN;
                            end

                            % output results
                            if done_flux == 0
                                fprintf(f_fva,'FLUX VARIABLES\nLB\tUB\tMIN\tMAX\tGENES\tID\tNAME\tSUBSYSTEM\tFORMULA\n');
                                done_flux = 1;
                            end
                            fprintf(f_fva,'%f\t%f\t%f\t%f\t%s\t%s\t%s\t%s\t%s\n',model.lb(i),model.ub(i),minval,maxval,strjoin(model.geneids_noisoforms(find(model.rxnGeneMat_noisoforms(rxnid,:)))',','),model.rxns{rxnid},model.rxnNames{rxnid},model.subSystems{rxnid},model.formulas{rxnid});

                            % clear objective
                            model.obj = zeros(size(model.obj));  
                        end

                    % state variables
                    elseif strcmp(type,'state')
                        if (any(strcmp(objfunc_reactions,name)) && any(strcmp(fva_variables,'state_obj'))) || (~any(strcmp(objfunc_reactions,name)) && any(strcmp(fva_variables,'state_nonobj')))

                            % find reaction id
                            rxnid = find(strcmp(model.rxns,name));

                            % set objective
                            model.obj(i) = 1;

%                             % minimization parameters
%                             params.outputflag = 0;
%                             params.timelimit = 5*60;
%                             params.numericfocus = 3;
%                             model.modelsense = 'min';
% 
%                             % run minimization
%                             result = gurobi(model,params);
% 
%                             % return result if success, otherwise return NaN
%                             if isfield(result,'objval')
%                                 minval = result.objval;
%                             else
%                                 minval = NaN;
%                             end
                            minval = NaN;

                            % maximization parameters
                            params.outputflag = 0;
                            params.timelimit = 5*60;
                            params.numericfocus = 3;
                            model.modelsense = 'max';

                            % run maximization
                            result = gurobi(model,params);

                            % return result if success, otherwise return NaN
                            if isfield(result,'objval')
                                maxval = result.objval;
                            else
                                maxval = NaN;
                            end

                            % output results
                            if done_state == 0
                                fprintf(f_fva,'\nSTATE VARIABLES\nLB\tUB\tMIN\tMAX\tGENES\tID\tNAME\tSUBSYSTEM\tFORMULA\n');
                                done_state = 1;
                            end
                            fprintf(f_fva,'%f\t%f\t%f\t%f\t%s\t%s\t%s\t%s\t%s\n',model.lb(i),model.ub(i),minval,maxval,strjoin(model.geneids_noisoforms(find(model.rxnGeneMat_noisoforms(rxnid,:)))',','),model.rxns{rxnid},model.rxnNames{rxnid},model.subSystems{rxnid},model.formulas{rxnid});

                            % clear objective
                            model.obj = zeros(size(model.obj));
                        end

                    % concentration variables
                    elseif strcmp(type,'concentration')
                        if (any(strcmp(objfunc_metabolites,name)) && any(strcmp(fva_variables,'concentration_obj'))) || (~any(strcmp(objfunc_metabolites,name)) && any(strcmp(fva_variables,'concentration_nonobj')))

                            % find metabolite id
                            metid = find(strcmp(model.mets,name));

                            % set objective
                            model.obj(i) = 1;

                            % minimization parameters
                            params.outputflag = 0;
                            params.timelimit = 5*60;
                            params.numericfocus = 3;
                            model.modelsense = 'min';

                            % run minimization
                            result = gurobi(model,params);

                            % return result if success, otherwise return NaN
                            if isfield(result,'objval')
                                minval = result.objval;
                            else
                                minval = NaN;
                            end

                            % maximization parameters
                            params.outputflag = 0;
                            params.timelimit = 5*60;
                            params.numericfocus = 3;
                            model.modelsense = 'max';

                            % run maximization
                            result = gurobi(model,params);

                            % return result if success, otherwise return NaN
                            if isfield(result,'objval')
                                maxval = result.objval;
                            else
                                maxval = NaN;
                            end

                            % output results
                            if done_concentration == 0
                                fprintf(f_fva,'\nCONCENTRATION VARIABLES\nLB\tUB\tMIN\tMAX\tID\tNAME\n');
                                done_concentration = 1;
                            end
                            fprintf(f_fva,'%f\t%f\t%f\t%f\t%s\t%s\n',model.lb(i),model.ub(i),minval,maxval,model.mets{metid},model.metNames{metid});

                            % clear objective
                            model.obj = zeros(size(model.obj)); 
                        end

                    % deltag variables
                    elseif strcmp(type,'deltag')
                        if (any(strcmp(objfunc_reactions,name)) && any(strcmp(fva_variables,'deltag_obj'))) || (~any(strcmp(objfunc_reactions,name)) && any(strcmp(fva_variables,'deltag_nonobj')))

                            % find reaction id
                            rxnid = find(strcmp(model.rxns,name));

                            % set objective
                            model.obj(i) = 1;

                            % minimization parameters
                            params.outputflag = 0;
                            params.timelimit = 5*60;
                            params.numericfocus = 3;
                            model.modelsense = 'min';

                            % run minimization
                            result = gurobi(model,params);

                            % return result if success, otherwise return NaN
                            if isfield(result,'objval')
                                minval = result.objval;
                            else
                                minval = NaN;
                            end

                            % maximization parameters
                            params.outputflag = 0;
                            params.timelimit = 5*60;
                            params.numericfocus = 3;
                            model.modelsense = 'max';

                            % run maximization
                            result = gurobi(model,params);

                            % return result if success, otherwise return NaN
                            if isfield(result,'objval')
                                maxval = result.objval;
                            else
                                maxval = NaN;
                            end

                            % output results
                            if done_deltag == 0
                                fprintf(f_fva,'\nDELTAG VARIABLES\nLB\tUB\tMIN\tMAX\tGENES\tID\tNAME\tSUBSYSTEM\tFORMULA\n');
                                done_deltag = 1;
                            end
                            fprintf(f_fva,'%f\t%f\t%f\t%f\t%s\t%s\t%s\t%s\t%s\n',model.lb(i),model.ub(i),minval,maxval,strjoin(model.geneids_noisoforms(find(model.rxnGeneMat_noisoforms(rxnid,:)))',','),model.rxns{rxnid},model.rxnNames{rxnid},model.subSystems{rxnid},model.formulas{rxnid});

                            % clear objective
                            model.obj = zeros(size(model.obj));
                        end   
                    end   
                end

                % close fva file
                fclose(f_fva);
            end

    %% RANDOM SAMPLING

            if type_of_analysis == 4        
                
                if ((knockdown_perform == 1) && (b ~= 1)) || (knockdown_perform == 0)
                
                    % bound objective function
                    model.lb(strcmp(model.varnames,'flux_objective')) = 0.95*objective_value;
                    model.ub(strcmp(model.varnames,'flux_objective')) = objective_value;

    %                 % remove reactions that can't be on
    %                 maxval = textread('files/fva.txt','%f');
    %                 for i = 1:length(maxval)
    %                     if (maxval(i)==0) || (isnan(maxval(i)))
    %                         model.ub(i) = 0;
    %                     end
    %                 end     

                    % reactions of interest
                    reactions_of_interest = {'G6PDH2r_for','GND','ME2','ME2m','ICDHy','ICDHyrm_for','GLUDym_for','DHFR_rev','MTHFD_for','MTHFDm_for'};
    %                 reactions_of_interest = {'GTHOm'};

                    % remove off reactions
                    for i = 1:length(model.rxns)
                        if (result.x(length(model.rxns)+i) == 0) && (~any(strcmp(reactions_of_interest,model.rxns{i})))
                            model.ub(i) = 0;
                        end
                    end

                    % keep only stoichiometric equations
                    model.S = model.A(1:length(model.mets),1:length(model.rxns));
                    model.b = model.rhs(1:length(model.mets));
                    model.sense = model.sense(1:length(model.mets));
                    model.lb = model.lb(1:length(model.rxns));
                    model.ub = model.ub(1:length(model.rxns));
                    model.c = model.obj(1:length(model.rxns));
                    model.vtype = model.vtype(1:length(model.rxns));
                    model.varnames = model.varnames(1:length(model.rxns));

                    model = rmfield(model,{'A','rhs','obj'});

                    % reduce model
                    cd('files/optGpSampler_1.1_Matlab');
                    [reducedModel, fixedRxnIds, fixedFluxValues, removedMetIDs,removedRxnIDs] = optReduceModel(model,'gurobi');

                    % get reduced reactions, add reactions of interest
                    reactions_keep = union(reducedModel.rxns,reactions_of_interest);

                    % setup new reduced model
                    reducedModelNew = [];
                    reducedModelNew.S = model.S;
                    reducedModelNew.lb = model.lb;
                    reducedModelNew.ub = model.ub;
                    reducedModelNew.c = model.c;
                    reducedModelNew.b = model.b;
                    reducedModelNew.mets = model.mets;
                    reducedModelNew.rxns = model.rxns;

                    % remove suggested metabolites if not in any reactions
                    to_delete = [];
                    for i = 1:length(reducedModelNew.mets)
                        if ~any(strcmp(reducedModel.mets,reducedModelNew.mets{i}))

                            found = 0;
                            for j = 1:length(reactions_of_interest)
                                rxn_index = find(strcmp(reducedModelNew.rxns,reactions_of_interest{j}));
                                if reducedModelNew.S(i,j) ~= 0
                                    found = 1;
                                end
                            end

                            if found == 0
                                to_delete(end+1) = i;
                            end

                        end
                    end
                    for i = sort(to_delete,'descend')
                        reducedModelNew.S(i,:) = [];
                        reducedModelNew.b(i) = [];
                        reducedModelNew.mets(i) = [];
                    end

                    % remove suggested reactions
                    to_delete = [];
                    for i = 1:length(reducedModelNew.rxns)
                        if ~any(strcmp(reactions_keep,reducedModelNew.rxns{i}))
                            to_delete(end+1) = i;
                        end
                    end
                    for i = sort(to_delete,'descend')
                        reducedModelNew.S(:,i) = [];
                        reducedModelNew.lb(i) = [];
                        reducedModelNew.ub(i) = [];
                        reducedModelNew.c(i) = [];
                        reducedModelNew.rxns(i) = [];
                    end   

                    % get objective function reactions
                    result_index = [];

                    for i = 1:length(model.rxns)-1
                        switch objective_function
                            case 1 % nadh[c] --> nad[c] + h[c]
                                if (model.S(strcmp(model.mets,'nadh[c]'),i) > 0) && (model.S(strcmp(model.mets,'nad[c]'),i) < 0)
                                    result_index(end+1) = i;
                                end

                            case 2 % nadh[m] --> nad[m] + h[m]
                                if (model.S(strcmp(model.mets,'nadh[m]'),i) > 0) && (model.S(strcmp(model.mets,'nad[m]'),i) < 0)
                                    result_index(end+1) = i;
                                end

                            case 3 % nadh[c] + nadh[m] --> nad[c] + nad[m] + h[c] + h[m]
                                if ((model.S(strcmp(model.mets,'nadh[c]'),i) > 0) && (model.S(strcmp(model.mets,'nad[c]'),i) < 0)) || ((model.S(strcmp(model.mets,'nadh[m]'),i) > 0) && (model.S(strcmp(model.mets,'nad[m]'),i) < 0))
                                    result_index(end+1) = i;
                                end

                            case 4 % nadph[c] --> nadp[c] + h[c]
                                if (model.S(strcmp(model.mets,'nadph[c]'),i) > 0) && (model.S(strcmp(model.mets,'nadp[c]'),i) < 0)
                                    result_index(end+1) = i;
                                end

                            case 5 % nadph[m] --> nadp[m] + h[m]
                                if (model.S(strcmp(model.mets,'nadph[m]'),i) > 0) && (model.S(strcmp(model.mets,'nadp[m]'),i) < 0)
                                    result_index(end+1) = i;
                                end

                            case 6 % nadph[c] + nadph[m] --> nadp[c] + nadp[m] + h[c] + h[m]
                                if ((model.S(strcmp(model.mets,'nadph[c]'),i) > 0) && (model.S(strcmp(model.mets,'nadp[c]'),i) < 0)) || ((model.S(strcmp(model.mets,'nadph[m]'),i) > 0) && (model.S(strcmp(model.mets,'nadp[m]'),i) < 0))
                                    result_index(end+1) = i;
                                end

                            case 7 % nadh[c] + nadh[m] + nadph[c] + nadph[m] --> nad[c] + nad[m] + nadp[c] + nadp[m] + 2 h[c] + 2 h[m]
                                if ((model.S(strcmp(model.mets,'nadh[c]'),i) > 0) && (model.S(strcmp(model.mets,'nad[c]'),i) < 0)) || ((model.S(strcmp(model.mets,'nadh[m]'),i) > 0) && (model.S(strcmp(model.mets,'nad[m]'),i) < 0)) || ((model.S(strcmp(model.mets,'nadph[c]'),i) > 0) && (model.S(strcmp(model.mets,'nadp[c]'),i) < 0)) || ((model.S(strcmp(model.mets,'nadph[m]'),i) > 0) && (model.S(strcmp(model.mets,'nadp[m]'),i) < 0))
                                    result_index(end+1) = i;
                                end

                            case 8 % atp[c] + h2o[c] --> adp[c] + pi[c] + h[c]
                                if (model.S(strcmp(model.mets,'atp[c]'),i) > 0) && (model.S(strcmp(model.mets,'adp[c]'),i) < 0)
                                    result_index(end+1) = i;
                                end

                            case 9 % atp[m] + h2o[m] --> adp[m] + pi[m] + h[m]
                                if (model.S(strcmp(model.mets,'atp[m]'),i) > 0) && (model.S(strcmp(model.mets,'adp[m]'),i) < 0)
                                    result_index(end+1) = i;
                                end

                            case 10 % atp[c] + atp[m] + h2o[c] + h2o[m] --> adp[c] + adp[m] + pi[c] + pi[m] + h[c] + h[m]
                                if ((model.S(strcmp(model.mets,'atp[c]'),i) > 0) && (model.S(strcmp(model.mets,'adp[c]'),i) < 0)) || ((model.S(strcmp(model.mets,'atp[m]'),i) > 0) && (model.S(strcmp(model.mets,'adp[m]'),i) < 0))
                                    result_index(end+1) = i;
                                end

                            case 12 % nadp[c] + nadp[m] + h[c] + h[m] --> nadph[c] + nadph[m]
                                if ((model.S(strcmp(model.mets,'nadp[c]'),i) > 0) && (model.S(strcmp(model.mets,'nadph[c]'),i) < 0)) || ((model.S(strcmp(model.mets,'nadp[m]'),i) > 0) && (model.S(strcmp(model.mets,'nadph[m]'),i) < 0))
                                    result_index(end+1) = i;
                                end

                            case 13 % nadph[c] + nadph[m] --> nadp[c] + nadp[m]
                                if ((model.S(strcmp(model.mets,'nadph[c]'),i) > 0) && (model.S(strcmp(model.mets,'nadp[c]'),i) < 0)) || ((model.S(strcmp(model.mets,'nadph[m]'),i) > 0) && (model.S(strcmp(model.mets,'nadp[m]'),i) < 0))
                                    result_index(end+1) = i;
                                end

                            case 14 % nadp[c] + nadp[m] --> nadph[c] + nadph[m]
                                if ((model.S(strcmp(model.mets,'nadp[c]'),i) > 0) && (model.S(strcmp(model.mets,'nadph[c]'),i) < 0)) || ((model.S(strcmp(model.mets,'nadp[m]'),i) > 0) && (model.S(strcmp(model.mets,'nadph[m]'),i) < 0))
                                    result_index(end+1) = i;
                                end
                        end
                    end

                    % only keep reactions in reduced model
                    to_delete = [];
                    for i = 1:length(result_index)
                        if isempty(find(strcmp(reducedModelNew.rxns,model.rxns{result_index(i)})))
                            to_delete(end+1) = i;
                        end
                    end
                    for i = sort(to_delete,'descend')
                        result_index(i) = [];
                    end

                    % get random samples
                    points = zeros(length(reducedModelNew.rxns),0);
                    while length(points(1,:)) < random_sampling_minvalid
                        sModel = optGpSampler(reducedModelNew,[],1e4,100,4,'gurobi',0);

                        % make sure objective function value is valid
                        valid = ((sModel.points(end,:) >= model.lb(end)) & (sModel.points(end,:) <= model.ub(end)));
                        points = [points,sModel.points(:,find(valid))];

                        % display number of valid points
                        fprintf('Finished Random Sampling Iteration, # of Valid Points = %d\n',length(points(1,:)));
                    end

                    % ksdensity
                    data = {};
                    f = {};
                    xi = {};
                    rxn = {};
                    lb = [];
                    ub = [];
                    for i = 1:length(result_index)                     
                        i_reduced = find(strcmp(sModel.rxns,model.rxns{result_index(i)}));
                        rxn_data = points(i_reduced,:);
                        rxn_data = rxn_data(rxn_data >= model.lb(result_index(i)) & rxn_data <= model.ub(result_index(i)));

                        if mean(rxn_data) > 0
                            data{end+1} = rxn_data;
                            [f{end+1},xi{end+1}] = ksdensity(rxn_data);
                            rxn{end+1} = model.rxns{result_index(i)};
                            lb(end+1) = model.lb(result_index(i));
                            ub(end+1) = model.ub(result_index(i));
                        end
                    end

                    cd('../..');

                    if knockdown_perform == 1
                        save(sprintf('results/%s/%s/random_%s.mat',results_folder,samples{a},knockdown_genes{b-1}),'data','f','xi','rxn','lb','ub');
                    else
                        save(sprintf('results/%s/%s/random.mat',results_folder,samples{a}),'data','f','xi','rxn','lb','ub'); 
                    end
                    
                end
            end
        end
    end
    
    % close objval results
    fclose(f_objval);
end

%% FINISH UP

% completion status
done_all = 1;
save(sprintf('results/%s/info.mat',results_folder),'done_all','-append')

toc