clc
for i = 1:length(model1.rxns)
    if (model1.lb(i) ~= model2.lb(i)) || (model1.ub(i) ~= model2.ub(i))
        if ~(model1.Exchange(i) || model1.Demand(i) || model1.Sink(i))
            if ~(model1.ub(i)==999999999 && model2.ub(i)==0)
                disp(model1.rxns{i})
                disp(i)
                disp(model1.ub(i))
                disp(model2.ub(i))
            end
        end
    end
end

for i = 1:length(model1.rxns)
    if (model1.lb(i) ~= model2.lb(i)) || (model1.ub(i) ~= model2.ub(i))
        if ~(model1.Exchange(i) || model1.Demand(i) || model1.Sink(i))
            model1.lb(i) = model2.lb(i);
            model1.ub(i) = model2.ub(i);
        end
    end
end