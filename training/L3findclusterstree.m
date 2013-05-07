function L3 = L3findclusterstree(L3)
% [pcas,thresholds,clustermembers,centroids,variances]=...
%    L3findclusterstree(patches,blockwidth,treedepth,projection,contrasts)

%L3FINDCLUSTERSTREE performs hierarchical clustering on patches
%
%[pcas,thresholds,clustermembers,centroids,variances]=
%   L3findclusterstree(patches,blockwidth,treedepth,projection,contrasts)
%
%INPUTS:
%   patches:
%   blockpattern:   2 entry vector with rows, columns in patch
%   treedepth:  scalar giving the maximum depth of the tree (number of
%               leaves is 2^(treedepth-1))
%   projection: binary of whether to project to unit norm for clustering
%   contrasts:  vector giving the sum of the deviation from the predicted
%               mean for each patch, this is used only if projection=1
%
%OUTPUTS:
%   pcas:       matrix with columns giving the PCA directions for each
%               binary decision, these only exist for non-leaf nodes
%   thresholds: vector giving the threshold value for which branch to go
%               down, these only exist for non-leaf nodes
%               size(thresholds)=1 x (2^(treedepth-1)-1)
%   clustermembers:  vector giving the node number that each patch is in,
%                    only nodes that are leaves can be chosen
%                    (size(clustermembers)=1 x numclusters)
%   centroids:   (Optional) matrix with columns giving centroids for the
%                cluster at each node
%   variances:   (Optional) matrix with columns giving variances of each
%                CFA measurement for patches in cluster (same size as
%                centroids)
%
% Nodes are numbered consecutively from the top.  Number of nodes is
% 2^treedepth-1.
%
% Copyright Steven Lansel, 2010

%%

if ieNotDefined('L3'), error('L3 structure required'); end

patches    = L3Get(L3,'spatches');
pixPerBlock   = L3Get(L3,'npixels per block');
blocksize  = L3Get(L3,'block size');
treedepth  = L3Get(L3,'tree depth');


%Projection is not used currently.  The idea is that clustering might be
%improved by first normalizing each patch to have a unit energy.  It might
%be a good idea for certain applications, but in general testing it had
%little effect.
% projection = L3Get(L3,'projection');  %binary about whether to project

%% Clustering parameters

% The contribution of each pixel in the 5x5 patch towards the calculation of principal
% components is weighted.  We count the pixels in the center more than the
% pixels at the edge.
%
% Spatial weights from Gaussian, vector of weights for different pixels in
% the patches, used so pixels can have different weights

wstdv   = 8;  % Put this in the L3 structure
[x,y]   = meshgrid(-floor(blocksize(1)/2):floor(blocksize(1)/2),-floor(blocksize(2)/2):floor(blocksize(2)/2));
dist2   = x.^2 + y.^2;
weights = exp(-dist2/2/wstdv^2);
weights = weights/sum(weights(:));

%% Initalize outputs

clustermembers = double(L3Get(L3,'texture indices'));

pcas      = zeros(pixPerBlock,2^(treedepth-1)-1);
thresholds= zeros(1,2^(treedepth-1)-1);

% if nargout>=4
%     centroids=zeros(pixPerBlock,2^treedepth-1);
%     if nargout>=5
%         variances=zeros(pixPerBlock,2^treedepth-1);
%     end
% end

% if projection
%     %Apply scale normalization
%     for n=1:pixPerBlock
%         patches(n,:)=patches(n,:)./contrasts;
%     end
% end

%Apply spatial weighting
for n=1:pixPerBlock
    patches(n,:)=patches(n,:)*weights(n);
end

%% Split the clusters
for nodenum=1:(2^(treedepth-1)-1)
    
    % Which are in the current cluster
    oldclusterindices = find(clustermembers==nodenum);
    
    % First PCA of this cluster to be used for splitting
    pcas(:,nodenum) = princompeconomy(patches(:,oldclusterindices)',1);
    
    % Determine the threshold based on where the centroid is projected onto
    % the PCA
    %     if nargout<=3
    %     elseif nargout>=4
    %
    %         centroids(:,nodenum)=mean(patches(:,clustermembers==nodenum),2);
    %         thresholds(nodenum)=pcas(:,nodenum)'*centroids(:,nodenum);
    %
    %         % If variance is requested, compute it
    %         if nargout>=5
    %             variances(:,nodenum)=mean((patches(:,clustermembers==nodenum)-repmat(centroids(:,nodenum),1,sum(clustermembers==nodenum))).^2,2);
    %         end
    %     end
    
    % We are splitting the clusters according to whether the projection
    % onto the pcas exceeds the halfway point or not
    thresholds(nodenum)=pcas(:,nodenum)'*mean(patches(:,oldclusterindices),2);
    
    % These go into the other branch (below threshold branch, node 2n)
    belowthreshold=pcas(:,nodenum)'*patches(:,oldclusterindices) < thresholds(nodenum);
    
    clustermembers(oldclusterindices(belowthreshold))=2*nodenum;
    clustermembers(clustermembers==nodenum)=2*nodenum+1;

end


% Calculate variances in the clusters
% if nargout>=4
%     for nodenum=(2^(treedepth-1)):(2^treedepth-1)
%         centroids(:,nodenum)=mean(patches(:,clustermembers==nodenum),2);
%         if nargout>=5
%             variances(:,nodenum) = mean((patches(:,clustermembers==nodenum)-repmat(centroids(:,nodenum),1,sum(clustermembers==nodenum))).^2,2);
%         end
%     end
% end

%% Add spatial weights to PCA directions
pcas = diag(weights(:))*pcas;

%% Remove transformations to patches
% if projection
%     %Remove scale normalization
%     for n=1:pixPerBlock
%         patches(n,:)=patches(n,:).*contrasts;
%     end
% end

%Remove spatial weighting
for n=1:pixPerBlock
    patches(n,:)=patches(n,:)/weights(n);
%     if nargout>=4
%         centroids(n,:)=centroids(n,:)/weights(n);
%         if nargout>=5
%             variances(n,:)=variances(n,:)/weights(n)^2;
%         end
%     end
end

L3 = L3Set(L3,'cluster directions',pcas);
L3 = L3Set(L3,'cluster thresholds',thresholds);
L3 = L3Set(L3,'cluster members',clustermembers);

end


function coeff = princompeconomy(x,numcoeffs)
%PRINCOMP Principal Components Analysis.
%   coeff = princompeconomy(x,numcoeffs)
%           performs principal components analysis on the N-by-P
%   data matrix X, and returns the principal component coefficients, also
%   known as loadings.  Rows of X correspond to observations, columns to
%   variables.  COEFF is a P-by-P matrix, each column containing coefficients
%   for one principal component.  The columns are in order of decreasing
%   component variance.
%
%   numcoeffs says how many principal component vectors to return
%
%   PRINCOMP centers X by subtracting off column means, but does not
%   rescale the columns of X.  To perform PCA with standardized variables,
%   i.e., based on correlations, use PRINCOMP(ZSCORE(X)).  To perform PCA
%   directly on a covariance or correlation matrix, use PCACOV.
%
%   Edited by Lansel to calculate a desired number of coefficients (instead
%   of all) and be faster, hence why it is called economy



% Center X by subtracting off column means
x0 = x - repmat(mean(x,1),size(x,1),1);

% The principal component coefficients are the eigenvectors of
% S = X0'*X0./(n-1), but computed using SVD.
% [U,sigma,coeff] = svd(x0,0);

[U,sigma,coeff] = svds(x0,numcoeffs);

end
