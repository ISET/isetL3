function L3 = L3ClearIndicesData(L3)

% Clear flat and saturation indices from L3 structure
%
% L3 = L3ClearIndicesData(L3)
%
% Deletes flat and saturation indices that are temporarily stored in L3
% structure.
%
% These indices point to which patches are flat or have the right
% saturation index during training.  Since the indices are frequently
% needed, they are stored the first time they are calculated by L3Get.
% Previously they were recalculated every time they were needed.
% There is no L3Set for these indices to prevent any errors being stored.
%
% These indices need to be cleared during training whenever the patch type,
% luminance type, or saturation type are changed.  This prevents old
% indices for a different type from being used in the wrong setting.
%
% Note texture indices is not stored in this manner.  It is just the
% negation of flat indices.

if isfield(L3.training, 'flatindices')
    L3.training.flatindices = [];
end
if isfield(L3.training, 'saturationindices')
    L3.training.saturationindices = [];
end