function [patchVec,row,col] = raw2PatchVecFormat(rawData, patchSz, format, varargin)
% Crop and transfer rawData (e.g. rggb) to a vector for ML work
%
%   [patchVec,row,col] = raw2PatchVecFormat(rawData, patchSz, format, varargin)
%
% Description
%   We take input raw data that is in the form of a region of a sensor
%   image.  This function returns a vector in which the region is
%   cropped (patchSz) and each patch is converted to a vector that is
%   numel(patchSz) long.
%
%   For example, if the patchSz and rawData all us to create n patches
%   from the sensor data, The dimension of the return is
%
%           (n, prod(patchSz))
%
% Inputs
%  rawData - THese are the raw sensor data (voltages, usually) 
%  patchSz - The patch size (row,col)
%  format  - {'single','rggb'}
%
% Optional key/value pairs
%  None
%
% Returns
%  patchVec
%
% ZL/BW, VISTA TEAM, 2018
%
% See also

% Example:
%{
scene = sceneCreate; oi = oiCreate; oi = oiCompute(oi,scene);
sensor = sensorCreate; sensor = sensorCompute(sensor,oi);
rawData = sensorGet(sensor,'volts');
mlData = raw2PatchVecFormat(rawData, [5,5], 'rggb');
%}

%% Extract the parms
p = inputParser;

p.addRequired('rawData', @ismatrix);
p.addRequired('patchSz', @isvector);

format = ieParamFormat(format);
p.addRequired('format', @ischar);

p.parse(rawData, patchSz, format, varargin{:});

rawData = p.Results.rawData;
patchSz = p.Results.patchSz;
format  = p.Results.format;

% Get the dimension of the patch
rPatch = patchSz(1);
cPatch = patchSz(2);

% Get the dimension of the rawData
[rRawData, cRawData] = size(rawData);

%% Crop the rawData according to style

switch format
    case 'single'
        rowSamps = rRawData - rPatch + 1;
        colSamps = cRawData - cPatch + 1;
        patchVec = zeros(rowSamps * colSamps, rPatch * cPatch);
        
        for rr = 1 : rowSamps
            for cc = 1 : colSamps
                Crop = cropAndFlatten(rawData, rr, cc, [rPatch,cPatch]);
                patchVec((rr - 1) * colSamps + cc, :) = Crop;
            end
        end
        
    case 'rggb'
        % Calculating how many patches we expect.
        % We pull out data from each 2x2 group of RG/GB pixels
        % Each one has a neighborhood of prod(patchSz) points.  So we
        % are going to store for this super-pixel 4 * prod(patchSz)
        % points.
        % 
        % This is how many RG/GB super pixels there are in the rows
        % and columns.  We subtract a bit to account for the edges.
        boundary = ceil(rPatch/2);
        rowSamps = boundary:2:(rRawData - boundary);
        boundary = ceil(cPatch/2);
        colSamps = boundary:2:(cRawData - boundary);

        %{
        rPatchImg = round((rRawData - rPatch) / 2) + 1;
        cPatchImg = round((cRawData - cPatch) / 2) + 1;
        %}
        % Allocate enough size for the output.
        % Each row is for one patch (also called cropped window)
        % Each column is for 
        % patchVec = zeros(numel(rowSamps) * numel(colSamps), 4 * rPatch * cPatch);
        patchVec = zeros(numel(rowSamps), numel(colSamps), 4*rPatch*cPatch);
        halfSize = floor(patchSz/2);
        for rr = 1:numel(rowSamps)
            for cc = 1:numel(colSamps)
                
                rows = (rowSamps(rr):(rowSamps(rr) + rPatch - 1)) - halfSize(1);
                cols = (colSamps(cc):(colSamps(cc) + cPatch - 1)) - halfSize(2);
                
                tmp = rawData(rows, cols);     Crop = tmp(:)';
                tmp = rawData(rows+1, cols);   Crop = cat(2,Crop,tmp(:)');
                tmp = rawData(rows, cols+1);   Crop = cat(2,Crop,tmp(:)');
                tmp = rawData(rows+1, cols+1); Crop = cat(2,Crop,tmp(:)');

                %                 Crp1 = cropAndFlatten(rawData, 2 * rr - 1, 2 * cc - 1, [rPatch, cPatch]);
                %                 Crp2 = cropAndFlatten(rawData, 2 * rr - 1, 2 * cc, [rPatch, cPatch]);
                %                 Crp3 = cropAndFlatten(rawData, 2 * rr, 2 * cc - 1, [rPatch, cPatch]);
                %                 Crp4 = cropandFlatten(rawData, 2 * rr, 2 * cc, [rPatch, cPatch]);
                %
                % Crop = [Crp1 Crp2 Crp3 Crp4];
                % patchVec((rr - 1) * colSamps + cc, :) = Crop;
                patchVec(rr,cc,:) = Crop;
            end
        end
        [patchVec,row,col] = RGB2XWFormat(patchVec);
end

end


%% Helper function to create flatten crop blcoks for rggb
% function Crop = cropAndFlatten(rawData, r, c, patchSz)
% [rPatch, cPatch] = size(patchSz);
% 
% Crop = rawData(r : r + rPatch - 1, c : c + cPatch - 1);
% Crop = reshape(Crop, [1, numel(Crop)]);
% 
% end
