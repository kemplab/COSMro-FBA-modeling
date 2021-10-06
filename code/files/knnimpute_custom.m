function data = knnimpute_custom(data,k,minsamples,alpha)

% NOTE: DOESN'T TAKE INTO ACCOUNT TIES FOR kTH DISTANCE VALUE

%% CHECK INPUTS

% k
if ~isfloat(k)
    error('ERROR - k must be a number')
elseif mod(k,1) ~= 0
    error('ERROR - k must be an integer')
elseif k < 1
    error('ERROR - k must be >=1')
end

% minsamples
if ~isfloat(minsamples)
    error('ERROR - minsamples must be a number')
elseif mod(minsamples,1) ~= 0
    error('ERROR - minsamples must be an integer')
elseif minsamples < 1
    error('ERROR - minsamples must be >=1')
end

% alpha
if ~isfloat(alpha)
    error('ERROR - alpha must be a number')
elseif alpha < 1
    error('ERROR - alpha must be >=1')
end

%% RUN KNN

% calculate original column means
column_means = [];
for col = 1:length(data(1,:))
    column_means(end+1) = mean(data(~isnan(data(:,col)),col));
end

% keep iterating until no new NaN values filled
new_nan = 1;
while new_nan == 1
    new_nan = 0;
    
    % old number of NaN's
    nan_old = isnan(data);
    nan_old = sum(nan_old(:));
    
    % calculate pairwise distances between rows and number of values used
    [distances,nums] = pdist_custom(data);
    
    % implement minsamples
    distances(nums<minsamples) = Inf;
    
    % calculate normalized distance metric
    distances = squareform(distances./(nums.^alpha));
    distances(logical(eye(size(distances)))) = NaN;

    % get indices of NaN values in data
    indices = find(isnan(data));
    [rows,cols] = find(isnan(data));
    
    % availability of column values in different rows
    cols_availability = double(~isnan(data(:,cols)));
    cols_availability(cols_availability==0) = NaN;
    
    % distance metric * column availability
    distances_availability = distances(:,rows).*cols_availability;
    
    % sort available distances, get top k values
    [sorted_values,sorted_indices] = sort(distances_availability,'ascend');
    sorted_values = sorted_values(1:k,:);
    sorted_indices = sorted_indices(1:k,:);
    
    % get indices and values of smallest available distances
    sorted_indices = sub2ind(size(data),sorted_indices,repmat(cols',length(sorted_values(:,1)),1));
    values = data(sorted_indices);
    
    % calculate weights from distances
    weights = 1./sorted_values;
    weights(weights==Inf) = realmax/k;
    weights = weights./repmat(nansum(weights,1),length(weights(:,1)),1);
    
    % fill in missing values
    data(indices) = sum((weights.*values),1)';
        
    % new number of NaN's
    nan_new = isnan(data);
    nan_new = sum(nan_new(:));
    
    % if filled in NaN's and still some left, continue
    if (nan_new < nan_old) && (nan_new > 0)
        new_nan = 1;
    end
    
end

% fill in remaining NaN's with original column means
for col = 1:length(data(1,:))
    data(isnan(data(:,col)),col) = column_means(col);
end
