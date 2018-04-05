%% s_lwpr
%
% This script tests the performance and projection results of locally
% weighted projection regression algorithm
%
% (HJ) VISTA TEAM, 2015

%% Init
ieInit;

%% Load Data
% Init Nikon camera parameters
cfa = [2 1; 3 4]; % Bayer pattern, 2 and 4 are both for green
patch_sz = [5 5];
pad_sz   = (patch_sz - 1) / 2;

% load training image
[I_raw, I_jpg] = loadScarletNikon('DSC_0767', true, pad_sz);
[I_raw_tr, I_jpg_tr] = cutImages(I_raw, I_jpg, [648 968]);
% [I_raw_tr{2}, I_jpg_tr{2}] = loadScarletNikon('DSC_0768', true, pad_sz);

% load raw and jpg test data - Cross validation test
% [I_raw_te, I_jpg_te] = loadScarletNikon('DSC_0767', true, pad_sz);

l3d = l3DataCamera(I_raw_tr, I_jpg_tr, cfa);


%% Train lwpr model
%  Init model
d = prod(patch_sz);
model = lwpr_init(d, 3, 'name', 'lwpr_l3');
model = lwpr_set(model, 'init_D', eye(d)*0.25);    
model = lwpr_set(model, 'init_alpha', ones(d)*250);
model = lwpr_set(model, 'diag_only', 0);
model = lwpr_set(model, 'w_gen', 0.2);
model = lwpr_set(model, 'w_prune', 0.7);   
model = lwpr_set(model, 'meta', 1);
model = lwpr_set(model, 'meta_rate', 250);
model = lwpr_set(model, 'update_D', 1);
model = lwpr_set(model, 'kernel', 'Gaussian');

%  Store model as mex C pointer
model = lwpr_storage('Store',model);

%  Training
[raw, jpg, pType] = l3d.dataGet();
tic;
for ii = 1 : length(raw)
    [p_data, ~] = im2patch(raw{ii}, patch_sz, pType);
    Y = RGB2XWFormat(jpg{ii});
    for jj = 1 : size(p_data, 2)
        [model,~,~] = lwpr_update(model,p_data(:, jj), Y(jj, :)');
        
        if mod(jj, 1e5) == 0
            fprintf('#Data: %d\t Time:%.2f\n', jj, toc);
        end
    end
end

%  Make predictions on the training image
l3d = l3DataCamera({I_raw}, {I_jpg}, cfa);
[raw, jpg, pType] = l3d.dataGet();
[p_data, ~] = im2patch(raw{1}, patch_sz, pType);
yp = lwpr_predict(model, p_data);

%  Show the image
yp = reshape(yp', size(jpg));
vcNewGraphWin; imshow(yp);

%  Get model back to matlab
model = lwpr_storage('GetFree',model);