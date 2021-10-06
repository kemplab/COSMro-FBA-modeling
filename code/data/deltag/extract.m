clear, clc, close all

fn_model = 'recon204.mat';
fn_vmh = 'vmh_no_reversible.csv';

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

% load vmh
[reaction,value,uncertainty] = textread(fn_vmh,'%s%f%f','delimiter',',','headerlines',0);

f = fopen('vmh.csv','w');
for i = 1:length(model.rxns)
    if length(model.rxns{i}) > 4
        if strcmp(model.rxns{i}(end-3:end),'_for') || strcmp(model.rxns{i}(end-3:end),'_rev')
            index = find(strcmp(reaction,model.rxns{i}(1:end-4)));
            if isempty(index)
                fprintf(f,'%s,%f,%f\n',model.rxns{i},-999999,0);
            else
                if strcmp(model.rxns{i}(end-3:end),'_for')
                    fprintf(f,'%s,%f,%f\n',model.rxns{i},value(index),uncertainty(index));
                else
                    if value(index) == -999999
                        fprintf(f,'%s,%f,%f\n',model.rxns{i},value(index),uncertainty(index));
                    else
                        fprintf(f,'%s,%f,%f\n',model.rxns{i},-value(index),uncertainty(index));
                    end
                end
            end
        else
            index = find(strcmp(reaction,model.rxns{i}));
            if isempty(index)
                fprintf(f,'%s,%f,%f\n',model.rxns{i},-999999,0);
            else
                fprintf(f,'%s,%f,%f\n',model.rxns{i},value(index),uncertainty(index));
            end
        end
    else
        index = find(strcmp(reaction,model.rxns{i}));
        if isempty(index)
            fprintf(f,'%s,%f,%f\n',model.rxns{i},-999999,0);
        else
            fprintf(f,'%s,%f,%f\n',model.rxns{i},value(index),uncertainty(index));
        end
    end
    
end
fclose(f);