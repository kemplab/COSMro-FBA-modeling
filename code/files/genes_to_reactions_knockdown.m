function protein = genes_to_reactions_knockdown(data,knockdown_genes,knockdown_values,rules,genes,genemat)

% initialize results
protein = {};
for i = 1:length(knockdown_genes)+1
    protein{i} = repmat(NaN,length(rules),length(data(1,:)));
end

% iterate thru every reaction rule
for i = 1:length(rules)
    
    % only reactions with rule
    if ~isempty(rules{i})
    
        % split rule
        rule = strsplit(rules{i},' ');
        
        % remove empty space
        rule(strcmp(rule,'')) = [];
          
        % check if long stretch of and's
        if ~any(strcmp(rule,'(')) && ~any(strcmp(rule,')')) &&  ~any(strcmp(rule,'or')) && any(strcmp(rule,'and'))
            rule_build = {'min','(','['};
            for j = find(~strcmp(rule,'and'))
                if length(rule_build) > 3
                    rule_build{end+1} = ',';
                    rule_build{end+1} = rule{j};
                else
                    rule_build{end+1} = rule{j};
                end
            end
            rule_build{end+1} = ']';
            rule_build{end+1} = ')';
            rule = rule_build;
            
        % otherwise
        else
        
            % replace or's
            rule(strcmp(rule,'or')) = {'+'};

            % replace and's
            j = 1;
            while j <= length(rule)
                if strcmp(rule{j},'and')

                    % no parentheses on either side
                    if ~strcmp(rule{j-1},')') && ~strcmp(rule{j+1},'(')
                        rule = [rule(1:j-2),{'(','min','(',rule{j-1},',',rule{j+1},')',')'},rule(j+2:end)];
                        j = j+6;

                    % parenthesis only on left side
                    elseif strcmp(rule{j-1},')') && ~strcmp(rule{j+1},'(')

                        % find left quantity
                        count = 1;
                        k = j-1;
                        while count > 0
                            k = k-1;
                            if strcmp(rule{k},'(')
                                count = count-1;
                            elseif strcmp(rule{k},')')
                                count = count+1;
                            end      
                        end

                        rule = [rule(1:k-1),{'(','min','('},rule(k:j-1),{',',rule{j+1},')',')'},rule(j+2:end)];
                        j = j+6;

                    % parenthesis only on right side
                    elseif ~strcmp(rule{j-1},')') && strcmp(rule{j+1},'(')

                        % find right quantity
                        count = 1;
                        k = j+1;
                        while count > 0
                            k = k+1;
                            if strcmp(rule{k},'(')
                                count = count+1;
                            elseif strcmp(rule{k},')')
                                count = count-1;
                            end      
                        end

                        rule = [rule(1:j-2),{'(','min','(',rule{j-1},','},rule(j+1:k),{')',')'},rule(k+1:end)];
                        j = j+3;

                    % parenthesis on both sides
                    else

                        % find left quantity
                        count = 1;
                        k = j-1;
                        while count > 0
                            k = k-1;
                            if strcmp(rule{k},'(')
                                count = count-1;
                            elseif strcmp(rule{k},')')
                                count = count+1;
                            end      
                        end

                        % find right quantity
                        count = 1;
                        l = j+1;
                        while count > 0
                            l = l+1;
                            if strcmp(rule{l},'(')
                                count = count+1;
                            elseif strcmp(rule{l},')')
                                count = count-1;
                            end      
                        end

                        rule = [rule(1:k-1),{'(','min','('},rule(k:j-1),{','},rule(j+1:l),{')',')'},rule(l+1:end)];
                        j = j+3;   

                    end
                end
                j = j+1;
            end
        end
        
        % make copy
        rule_ = rule;
        
        % wt data
        for j = 1:length(data(1,:))
            rule = rule_;
            
            % replace every gene in rule
            for k = find(~strcmp(rule,'(') & ~strcmp(rule,')') & ~strcmp(rule,'[') & ~strcmp(rule,']') & ~strcmp(rule,',') & ~strcmp(rule,'min') & ~strcmp(rule,'+'))
                rule{k} = num2str(data(strcmp(genes,rule{k}),j));
            end
            
            % evaluate rule
            protein{1}(i,j) = eval(strjoin(rule,''));
        end
        
        % check if any knockdown genes are in rule
        genes_in_rule = genes(find(genemat(i,:)))';
        for m = 1:length(knockdown_genes)
            if any(strcmp(genes_in_rule,knockdown_genes{m}))
                
                % knockdown gene
                data_knockdown = data;
                data_knockdown(strcmp(genes,knockdown_genes{m}),:) = knockdown_values(m) * data_knockdown(strcmp(genes,knockdown_genes{m}),:);
                
                % fill in data values for every sample
                for j = 1:length(data_knockdown(1,:))
                    rule = rule_;

                    % replace every gene in rule
                    for k = find(~strcmp(rule,'(') & ~strcmp(rule,')') & ~strcmp(rule,'[') & ~strcmp(rule,']') & ~strcmp(rule,',') & ~strcmp(rule,'min') & ~strcmp(rule,'+'))
                        rule{k} = num2str(data_knockdown(strcmp(genes,rule{k}),j));
                    end

                    % evaluate rule
                    protein{m+1}(i,j) = eval(strjoin(rule,''));
                end
                
            else
                protein{m+1}(i,:) = protein{1}(i,:);
            end
        end  
    end
end