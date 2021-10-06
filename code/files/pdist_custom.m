function [distances,nums] = pdist_custom(data)

% size of input data
[n,p] = size(data);

% initialize results
distances = zeros(1,n*(n-1)./2);
nums = zeros(1,n*(n-1)./2);

% calculate results
k = 1;
for i = 1:n-1

    % initialize sum and count
    sum = zeros(n-i,1);
    count = zeros(n-i,1);
    
    % calculate sum and count
    for q = 1:p
        sum = nansum([sum,(data(i,q) - data((i+1):n,q)).^2],2);
        count = count + ~isnan((data(i,q) - data((i+1):n,q)).^2);
    end
    distances(k:(k+n-i-1)) = sqrt(sum);
	nums(k:(k+n-i-1)) = count;

    k = k + (n-i);
end