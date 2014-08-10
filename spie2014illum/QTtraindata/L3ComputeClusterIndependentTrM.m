function trM = L3ComputeClusterIndependentTrM(desiredIm)

allImg = [];
for ii = 1 : length(desiredIm)
    thisImg = desiredIm{ii};
    [row, col, N] = size(thisImg);
    thisImg = reshape(thisImg, [row * col, 1, N]);
    thisImg = squeeze(thisImg);
    allImg = [allImg; thisImg]; 
end

allImg = allImg';
renderImg = allImg(1 : 3, :); % XYZ under rendering illuminant: D65 default
D65Img = allImg(4 : 6, :); % XYZ under training illuminant, say Tungsten

trM = D65Img / renderImg; % least square solution
end

