%% Learn Parameters for L3 Classification
%
%  The algorithm goes as below (a simple clusterwise linear regression):
%    1) Heuristic initialization K class by pixel type and mean response
%    2) Iteratively determine the data for K class
%       2.1 - Fit linear model according to current assignment
%       2.2 - assign each patch to class with minimum residual
%    3) Learn classification tree (CART) with the extended input data
%    (padded by some useful statistics, e.g mean response level, etc.)
%
%  Potential Problems
%    Scalability - When input data explode, the method could take very long
%                  time to compute
%    
%    Optimality  - Like K-means algorithms, step 2 can only achieve
%                  sub-optimal solutions. Multiple restart could help
%
%  (HJ) VISTA TEAM, 2015

%% Init Param
ieInit; % init a new session
nClass = 40;   % number of class to be learned
max_iter = 50; % max number of iteration
tol = 0.02;    % relative tolerance, if improvement/ssw < tol, stop

%% Get data
% Init Nikon camera parameters
cfa = [2 1; 3 4]; % Bayer pattern, 2 and 4 are both for green
patch_sz = [5 5];
pad_sz   = (patch_sz - 1) / 2;

% load training data
[I_raw_tr{1}, I_jpg_tr{1}] = loadScarletNikon('DSC_0767', true, pad_sz);

% load raw and jpg test data
[I_raw_te, I_jpg_te] = loadScarletNikon('DSC_0769', true, pad_sz);

%% Build l3Data class instance
% generate data class
l3d = l3DataCamera(I_raw_tr(1), I_jpg_tr(1), cfa);

% get data pairs
[inImg, outImg, pType] = l3d.dataGet();

% we will only use one image in this example
inImg = inImg{1}; outImg = outImg{1};

%% Heuristic Initialization
%  Convert patches in inImg to rows
inImgRow = im2col(inImg, patch_sz, 'sliding')';
[outImg, r, c] = RGB2XWFormat(outImg);

%  Compute patch mean response
p_mean = mean(inImgRow, 2);

%  Compute quantile of mean response
pr = linspace(0, 1, nClass + 1);
lum_thresh = quantile(p_mean, pr(2:end-1));

%  Compute luminance levels for each patch as initial class assignment
[~, labels] = max(bsxfun(@le, p_mean, [lum_thresh inf]), [], 2);

%% Iteratively learn the assignment for each class
% allocate space for parameters
beta  = zeros(prod(patch_sz)+1, size(outImg, 2), nClass);
ressq = zeros(size(outImg, 1), nClass);
ssw   = zeros(max_iter, 1);

% pad ones into inImgRow for constant
inImgRow = padarray(inImgRow, [0 1], 1, 'pre');

% compute constant parameters
row_indx = 1:size(ressq, 1);
row_indx = row_indx(:);

% start iteration
for iter = 1 : max_iter
    % print progress
    cprintf('*Keywords', 'Iteration: %d/%d\n', iter, max_iter);
    
    % fit linear model and compute residue for each class
    fprintf('\tComputing for class: ');
    for ii = 1 : nClass
        str = sprintf('%d/%d', ii, nClass);
        fprintf(str);
        
        % fit linear model
        indx = (labels == ii);
        beta(:, :, ii) = lscov(inImgRow(indx, :), outImg(indx, :));
        
        % compute residue
        ressq(:,ii) = sum((outImg - inImgRow * beta(:,:,ii)).^2, 2);
        
        fprintf(repmat('\b', 1, length(str)));
    end
    
    % Re-assign each patch
    [~, labels] = min(ressq, [], 2);
    ssw(iter) = sum(ressq(sub2ind(size(ressq), row_indx, labels)));
    fprintf('Done...\n\tTotal Residue Within: %.2f\n', ssw(iter));
    
    % check convergence
    if iter > 1 && ssw(iter)/ssw(iter-1) > 1-tol, break; end
end
ssw(iter+1:max_iter) = [];

%% Learn classification tree (CART)
%  Theoretically, we should be able to fit a decision tree here
%  But Matlab's implementation (fitctree) is too slow for to work on the
%  whole data set
%  Here, we do some down-sampling to make it feasible
%  (HJ)

% Downsample
n_samples = 1e3 * nClass;
[data, indx] = datasample(inImgRow, n_samples, 1, 'Replace', false);
indx = indx(:);

% Appending some statistics
l3c = l3ClassifyTree(l3d);
data_full = [data l3c.p_mean{1}(indx)];
data_full = [data_full l3c.p_cont{1}(indx)];
data_full = [data_full l3c.p_type{1}(indx)];

% Fitting a decision tree
fprintf('Fitting classification tree...');
ctree = fitctree(data_full, labels(indx));
fprintf('Done\n');

%% Render based on the classification tree
%  render the training image
fprintf('Predicting labels for patches...');
pred_labels = predict(ctree, [inImgRow, l3c.p_mean{1}(:), ...
                l3c.p_cont{1}(:), l3c.p_type{1}(:)]);
            
renImg = zeros(size(inImgRow, 1), 3);
for ii = 1: nClass
    indx = (pred_labels == ii);
    renImg(indx, :) = inImgRow(indx, :) * beta(:, :, ii);
end

renImg = reshape(renImg, [size(l3c.p_mean{1}), 3]);
vcNewGraphWin([], 'wide'); 
subplot(1,2,1); imshow(I_jpg_tr{1});
subplot(1,2,2); imshow(renImg);
