% s_L3AlignImages
%
%   Check and align Nikon D200 and D600 camera raw and rendered rgb images
%
% HJ, VISTA TEAM, 2016

%% Init ISET session 
ieInit

%% Check and process images from Nikon D200
base = 'http://scarlet.stanford.edu/validation/SCIEN/L3/nikond200/';
s = lsScarlet([base 'JPG/garden/'], '.jpg');

% Set initial guess for the offset
offset = [13 16; 13 14]; % offset for horizontal and vertical images

% for the vertical images, the cfa is [b g; g r]
% for the horizontal images, the cfa is [r g; g b]
% To make them under same CFA, we need to crop one group one line at the
% beginning and one line at the end

% after cropping, the CFA is [g r; b g]

% Load and process
for ii = 1 : length(s)
    img_name = s(ii).name(1:end-4);
    fprintf('Processing image: %s\n', img_name);
    
    % load raw and rendered images
    rgb = im2double(imread([base 'JPG/garden/' img_name '.jpg']));
    raw = im2double(imread([base 'PGM/garden/' img_name '.pgm']));
    
    for jj = 1 : size(offset, 1)
        aligned = checkImageAlignment(raw, rgb, offset(jj, :));
        if aligned
            fprintf('Offset Found: (%d, %d)...Done\n\n', ...
                offset(jj, 1), offset(jj, 2));
            
            % process image
            rawCropped = imcrop(raw, [offset(jj, 2) offset(jj, 1) ...
                size(rgb, 2)-1 size(rgb, 1)-1]);
            
            % write out to file
            if jj == 2
                rgb = rgb(2:end-1, 2:end-1, :);
                rawCropped = rawCropped(2:end-1, 2:end-1, :);
            end
            imwrite(rgb, [img_name '.jpg']);
            imwrite(rawCropped, [img_name '.pgm'], 'MaxValue', 65535);
            break;
        end
    end
    
    if ~aligned, warning('No alignment found, try using alignImages.'); end
end

%% Check and process images from Nikon D600
% Init remote data toolbox
rd = RdtClient('scien');
rd.crp('/L3/Cardinal/D600');
s = rd.searchArtifacts('_dxo_nodist');

for ii = 1 : length(s)
    fprintf('Processing image: %s\n', s(ii).artifactId);
    
    % load image
    rgb = im2double(rd.readArtifact(s(ii).artifactId, 'type', 'tif'));
    if isodd(size(rgb, 1)), rgb = rgb(1:end-1, :, :); end
    if isodd(size(rgb, 2)), rgb = rgb(:, 1:end-1, :); end
    
    img_name = s(ii).artifactId(1:end-11);
    rawArtifact = rd.searchArtifacts(img_name, 'type', 'pgm');
    raw = rd.readArtifact(rawArtifact(1).artifactId, 'type', 'pgm');
    raw = im2double(raw);
    
    % 
    if size(rgb, 1) > size(rgb, 2)
        offset = [57 7];
        % cfa is [g b; r g]
    else
        offset = [7 10];
        % cfa is [r g; g b]
    end
    
    aligned = checkImageAlignment(raw, rgb, offset);
    if aligned
        fprintf('Offset Checking passed: (%d, %d)...Done\n\n', ...
                offset(1), offset(2));
        rawCropped = imcrop(raw, [offset(2) offset(1) ...
                size(rgb, 2)-1 size(rgb, 1)-1]);
        if size(rgb, 1) > size(rgb, 2)
            rawCropped = rawCropped(2:end-1, :);
            rgb = rgb(2:end-1, :, :);
        end
        imwrite(rgb, [s(ii).artifactId '.jpg']);
        imwrite(rawCropped, [s(ii).artifactId '.pgm'], 'MaxValue', 65535);
    else
        warning('Alignment not correct');
    end
end