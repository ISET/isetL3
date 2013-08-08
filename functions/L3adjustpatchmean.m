function patches=L3adjustpatchmean(patches,means,blockpattern)

% L3ADJUSTPATCHMEAN adds a constant to each measured color channel
%
%  patches=L3adjustpatchmean(patches,means,blockpattern)
%
% For each patch, values are entered for each meaured color channel.  
% For a given patch and a specific measured color channel, this value is
% added to all measurements of the patch that are of that same color.
%
% (c) Stanford VISTA Team

measuredColors = sort(unique(blockpattern(:)))';
for colornum = measuredColors
    cfaindices = find(blockpattern==colornum);
    patches(cfaindices,:)=patches(cfaindices,:)+repmat(means(colornum,:),length(cfaindices),1);
end

end
