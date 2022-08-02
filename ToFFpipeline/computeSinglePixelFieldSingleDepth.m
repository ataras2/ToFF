function [error, dataGrid, theoreticalGrid, indexSubset] = computeSinglePixelFieldSingleDepth (dLFinterp, LFargs, pixel, Pz, nvargs)
    arguments
        dLFinterp % a gridded interp object
        LFargs
        pixel (2,1) double % in form [k;l]
        Pz double

        nvargs.occlusionMethod = 'none'
        nvargs.contour = 'edge'
    end

    % extract data
    grid = getOtherViewIndexes (pixel, LFargs, Pz);
    dataGrid = dLFinterp(grid{2}(:), grid{1}(:), grid{4}(:), grid{3}(:));
    dataGrid = reshape(dataGrid, [LFargs.N, LFargs.N]);

    % compute the theoretical surface
    theoreticalGrid = getTheoreticalSurface (pixel, Pz, LFargs);

    % get anti saturation mask
    [indexSubsetSat] = rejectInvalidDataPts (dataGrid);
    indexSubsetSat = reshape(indexSubsetSat, [LFargs.N, LFargs.N]);

    if min(dataGrid - theoreticalGrid,[],'all') < -0.1
        [indexSubsetOcc] = rejectOcclusionOutliers (dataGrid - theoreticalGrid,...
                                'method', nvargs.occlusionMethod);
    else
        [indexSubsetOcc] = rejectOcclusionOutliers (dataGrid - theoreticalGrid,...
                                'method', 'none');
    end
    indexSubset = and(indexSubsetSat, indexSubsetOcc);

    % get Goodness of Fit
    error = evaluateGoF(dataGrid, theoreticalGrid, indexSubset);
end