function blockpattern = L3TrainBlockPattern(patchtype,blockwidth,cfapattern)
% Generate blockpattern from cfapattern
%
%  blockpattern = L3TrainBlockPattern(patchtype,blockwidth,cfapattern)
%
% Patchtype is the row and column of this particularly pixel in the
% cfaPattern.
%
% Given a cfaPattern, we ask which pixel is in the center (patchtype).
% Then we replicate the cfaPattern into the blockwidth x blockwidth matrix,
% centered on that pixel.
%
% Example:
%   patchtype = '11'; blockwidth = [5,5]; cfaPattern = [1 2; 2 3];
%   L3TrainBlockPattern(patchtype,blockwidth,cfaPattern)
%
% (c) Stanford VISTA Team

% Notation comment:         x is row, y is column

patchtypex = patchtype(1);
patchtypey = patchtype(2);

blockpattern = zeros(blockwidth(1),blockwidth(2),size(cfapattern,3));

% For each entry in the cfaPattern, create a
for cfapatternx=1:size(cfapattern,1)
    
    startx=mod(cfapatternx - patchtypex + ceil(blockwidth(1)/2),size(cfapattern,1));

    if startx==0,  startx=size(cfapattern,1); end
    
    % A comment here would be helpful.
    for cfapatterny=1:size(cfapattern,2)        
        starty = mod(cfapatterny - patchtypey + ceil(blockwidth(2)/2), size(cfapattern,2));
        if starty==0,  starty=size(cfapattern,2); end
        
        currentcolor=cfapattern(cfapatternx,cfapatterny);        
        
        blockpattern(startx:size(cfapattern,1):blockwidth(1), starty:size(cfapattern,2):blockwidth(2))=currentcolor;
    end
end

end
