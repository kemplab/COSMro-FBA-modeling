clear, clc, close all

fn_model = 'recon204.mat';

fn_human = 'turnover_human.csv';
fn_all = 'turnover_all.csv';

% load model
load(fn_model)

% break down reversible reactions
for i = 1:length(model.rxns)
    if model.rev(i) == 1;
        model.rxns{i} = strcat(model.rxns{i},'_for');
        old_lower_bound = model.lb(i);
        model.lb(i) = 0;
        model.rev(i) = 0;

        model.S(:,end+1) = -model.S(:,i);
        model.rxns{end+1} = strcat(model.rxns{i}(1:end-4),'_rev');
        model.lb(end+1) = 0;
        model.ub(end+1) = -old_lower_bound;
        model.rev(end+1) = 0;
        model.c(end+1) = model.c(i);
        model.rxnGeneMat(end+1,:) = model.rxnGeneMat(i,:);
        model.rules{end+1} = model.rules{i};
        model.grRules{end+1} = model.grRules{i};
        model.subSystems{end+1} = model.subSystems{i};
        model.rxnNames{end+1} = model.rxnNames{i};
        model.rxnKeggID{end+1} = model.rxnKeggID{i};
        model.rxnConfidenceEcoIDA{end+1} = model.rxnConfidenceEcoIDA{i};
        model.rxnConfidenceScores{end+1} = model.rxnConfidenceScores{i};
        model.rxnsboTerm{end+1} = model.rxnsboTerm{i};
        model.rxnReferences{end+1} = model.rxnReferences{i};
        model.rxnECNumbers{end+1} = model.rxnECNumbers{i};
        model.rxnNotes{end+1} = model.rxnNotes{i};
        model.Exchange(end+1) = model.Exchange(i);
        model.Demand(end+1) = model.Demand(i);
        model.Sink(end+1) = model.Sink(i);
    end
end
model.rxnTurnover = repmat(NaN,1,length(model.rxns));

% remove subsystems
subsystems_to_remove = {'Miscellaneous','Unassigned'};
for i = 1:length(model.rxns)
    if any(strcmp(subsystems_to_remove,model.subSystems{i}))
        model.subSystems{i} = '';
    end
end

% load turnover rate [1/hr] - human
[ec,value,chebi,kegg,pubchem,hmdb] = textread(fn_human,'%s%f%s%s%s%s','delimiter',',','headerlines',1);

subsystem_human = {};
subsystem_value_human = {};

for i = 1:length(model.rxns)
    turnover = [];
    if ~strcmp(model.rxnECNumbers{i},'')
        ec_index = find(strcmp(ec,model.rxnECNumbers{i}));
        for j = 1:length(ec_index)
            met_index = find(model.S(:,i)<0);
            for k = 1:length(met_index)

                match = false;

                % check chebi
                if ~strcmp(chebi{ec_index(j)},'')
                    id_chebi = strsplit(chebi{ec_index(j)},';');
                    for l = 1:length(id_chebi)
                        if strcmp(id_chebi{l},model.metCHEBIID{met_index(k)})
                            if ~match
                                turnover(end+1) = value(ec_index(j));
                                match = true;
                            end
                        end
                    end
                end

                % check kegg
                if ~strcmp(kegg{ec_index(j)},'')
                    id_kegg = strsplit(kegg{ec_index(j)},';');
                    for l = 1:length(id_kegg)
                        if strcmp(id_kegg{l},model.metKeggID{met_index(k)})
                            if ~match
                                turnover(end+1) = value(ec_index(j));
                                match = true;
                            end
                        end
                    end
                end

                % check pubchem
                if ~strcmp(pubchem{ec_index(j)},'')
                    id_pubchem = strsplit(pubchem{ec_index(j)},';');
                    for l = 1:length(id_pubchem)
                        if strcmp(id_pubchem{l},model.metPubChemID{met_index(k)})
                            if ~match
                                turnover(end+1) = value(ec_index(j));
                                match = true;
                            end
                        end
                    end
                end

                % check hmdb
                if ~strcmp(hmdb{ec_index(j)},'')
                    id_hmdb = strsplit(hmdb{ec_index(j)},';');
                    for l = 1:length(id_hmdb)
                        if strcmp(id_hmdb{l},model.metHMDB{met_index(k)})
                            if ~match
                                turnover(end+1) = value(ec_index(j));
                                match = true;
                            end
                        end
                    end
                end

            end
        end
    end
    
    if length(turnover) > 0
        model.rxnTurnover(i) = mean(turnover);
        
        if ~strcmp(model.subSystems{i},'')
            if ~any(strcmp(subsystem_human,model.subSystems{i}))
                subsystem_human{end+1} = model.subSystems{i};
                subsystem_value_human{end+1} = turnover;
            else
                subsystem_value_human{strcmp(subsystem_human,model.subSystems{i})} = horzcat(subsystem_value_human{strcmp(subsystem_human,model.subSystems{i})},turnover);
            end
        end
    end

end

% get enzyme values - human
enzyme_human = {};
enzyme_value_human = {};

for i = 1:length(ec)
    if ~any(strcmp(enzyme_human,ec{i}))
        enzyme_human{end+1} = ec{i};
        enzyme_value_human{end+1} = [value(i)];
    else
        enzyme_value_human{strcmp(enzyme_human,ec{i})}(end+1) = value(i);
    end
end

% get mean value - human
meanvalue_human = mean(value);

% load turnover rate [1/hr] - all
[ec,value,chebi,kegg,pubchem,hmdb] = textread(fn_all,'%s%f%s%s%s%s','delimiter',',','headerlines',1);

subsystem_all = {};
subsystem_value_all = {};

for i = 1:length(model.rxns)
    if isnan(model.rxnTurnover(i))
        turnover = [];
        if ~strcmp(model.rxnECNumbers{i},'')
            ec_index = find(strcmp(ec,model.rxnECNumbers{i}));
            for j = 1:length(ec_index)
                met_index = find(model.S(:,i)<0);
                for k = 1:length(met_index)

                    match = false;

                    % check chebi
                    if ~strcmp(chebi{ec_index(j)},'')
                        id_chebi = strsplit(chebi{ec_index(j)},';');
                        for l = 1:length(id_chebi)
                            if strcmp(id_chebi{l},model.metCHEBIID{met_index(k)})
                                if ~match
                                    turnover(end+1) = value(ec_index(j));
                                    match = true;
                                end
                            end
                        end
                    end

                    % check kegg
                    if ~strcmp(kegg{ec_index(j)},'')
                        id_kegg = strsplit(kegg{ec_index(j)},';');
                        for l = 1:length(id_kegg)
                            if strcmp(id_kegg{l},model.metKeggID{met_index(k)})
                                if ~match
                                    turnover(end+1) = value(ec_index(j));
                                    match = true;
                                end
                            end
                        end
                    end

                    % check pubchem
                    if ~strcmp(pubchem{ec_index(j)},'')
                        id_pubchem = strsplit(pubchem{ec_index(j)},';');
                        for l = 1:length(id_pubchem)
                            if strcmp(id_pubchem{l},model.metPubChemID{met_index(k)})
                                if ~match
                                    turnover(end+1) = value(ec_index(j));
                                    match = true;
                                end
                            end
                        end
                    end

                    % check hmdb
                    if ~strcmp(hmdb{ec_index(j)},'')
                        id_hmdb = strsplit(hmdb{ec_index(j)},';');
                        for l = 1:length(id_hmdb)
                            if strcmp(id_hmdb{l},model.metHMDB{met_index(k)})
                                if ~match
                                    turnover(end+1) = value(ec_index(j));
                                    match = true;
                                end
                            end
                        end
                    end

                end
            end
        end

        if length(turnover) > 0
            model.rxnTurnover(i) = mean(turnover);
            
            if ~strcmp(model.subSystems{i},'')
                if ~any(strcmp(subsystem_all,model.subSystems{i}))
                    subsystem_all{end+1} = model.subSystems{i};
                    subsystem_value_all{end+1} = turnover;
                else
                    subsystem_value_all{strcmp(subsystem_all,model.subSystems{i})} = horzcat(subsystem_value_all{strcmp(subsystem_all,model.subSystems{i})},turnover);
                end
            end
        end
    end
end

% get enzyme values - all
enzyme_all = {};
enzyme_value_all = {};

for i = 1:length(ec)
    if ~any(strcmp(enzyme_all,ec{i}))
        enzyme_all{end+1} = ec{i};
        enzyme_value_all{end+1} = [value(i)];
    else
        enzyme_value_all{strcmp(enzyme_all,ec{i})}(end+1) = value(i);
    end
end

% impute values - enzyme - human
for i = 1:length(model.rxns)
    if (~strcmp(model.rxnECNumbers{i},'')) && (isnan(model.rxnTurnover(i)))
        if any(strcmp(enzyme_human,model.rxnECNumbers{i}))
            model.rxnTurnover(i) = mean(enzyme_value_human{strcmp(enzyme_human,model.rxnECNumbers{i})});
        end
    end
end

% impute values - enzyme - all
for i = 1:length(model.rxns)
    if (~strcmp(model.rxnECNumbers{i},'')) && (isnan(model.rxnTurnover(i)))
        if any(strcmp(enzyme_all,model.rxnECNumbers{i}))
            model.rxnTurnover(i) = mean(enzyme_value_all{strcmp(enzyme_all,model.rxnECNumbers{i})});
        end
    end
end

% impute values - subsystem - human
for i = 1:length(model.rxns)
    if (~strcmp(model.rxnECNumbers{i},'')) && (isnan(model.rxnTurnover(i)))
        if any(strcmp(subsystem_human,model.subSystems{i}))
            model.rxnTurnover(i) = mean(subsystem_value_human{strcmp(subsystem_human,model.subSystems{i})});
        end
    end
end

% impute values - subsystem - all
for i = 1:length(model.rxns)
    if (~strcmp(model.rxnECNumbers{i},'')) && (isnan(model.rxnTurnover(i)))
        if any(strcmp(subsystem_all,model.subSystems{i}))
            model.rxnTurnover(i) = mean(subsystem_value_all{strcmp(subsystem_all,model.subSystems{i})});
        end
    end
end

% impute values - mean value - human
for i = 1:length(model.rxns)
    if (~strcmp(model.rxnECNumbers{i},'')) && (isnan(model.rxnTurnover(i)))
        model.rxnTurnover(i) = meanvalue_human;
    end
end

% output
f = fopen('kinetics/brenda-pipeline.csv','w');
fprintf(f,'REACTION,KCAT [1/s]\n');
for i = 1:length(model.rxns)
    if ~isnan(model.rxnTurnover(i))
        fprintf(f,'%s,%f\n',model.rxns{i},model.rxnTurnover(i));
    else
         fprintf(f,'%s,nan\n',model.rxns{i});
    end
end
fclose(f);