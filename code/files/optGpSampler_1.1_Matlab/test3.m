for i = 1:length(model_old.rxns)
    if model_old.rev(i)
        model_old.S(:,end+1) = -model_old.S(:,i);
        model_old.lb(end+1) = 0;
        model_old.ub(end+1) = -model_old.lb(i);
        model_old.c(end+1) = 0;
        model_old.rxns{end+1} = model_old.rxns{i};
        
        model_old.lb(i) = 0;
    end
end