function n_lvls = computeLvlNumbers(cutPoints, nc)
    %%
    n_satClass = 2^nc; %how many sub classes we need 
    n_signalLvl = (cutPoints{1} + 1) * n_satClass;
    % n_lvls = nc * prod(cellfun(@(x) length(x), cutPoints) + 1);
    n_lvls = nc * n_signalLvl * prod(cellfun(@(x) length(x), {cutPoints{2:end}}) + 1);
end