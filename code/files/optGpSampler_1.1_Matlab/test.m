for i = 1:length(model.rxns)
    if model.rev(i)
        
        model.S(:,end+1) = -model.S(:,i);
        model.lb(end+1) = 0;
        model.ub(end+1) = -model.lb(i);
        model.c(end+1) = 0;
        
        model.lb(i) = 0;
    end
end