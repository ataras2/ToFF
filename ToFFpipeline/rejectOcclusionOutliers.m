function [indexSubset] = rejectOcclusionOutliers (distGrid, nvargs)
    % return a list of indices that are valid for curve fitting using segmentation on the grid data from other views
    arguments
        distGrid (:,:) double
        nvargs.method string = 'none'
    end

    middleIndex = (size(distGrid,1) + 1)/2;

    if strcmp(nvargs.method, 'none')
        indexSubset = true(size(distGrid));
    elseif strcmp(nvargs.method, 'activecontour')
        mask = zeros(size(distGrid));
        mask(2:end-2, 2:end-2) = 1;
        indexSubset = activecontour(distGrid, mask);

        if indexSubset(middleIndex,middleIndex) == false
            indexSubset  = ~indexSubset;
        end
    elseif strcmp(nvargs.method, 'lazysnapping')
        % create superpixels
        L = superpixels(distGrid, 10);

        middle = sub2ind(size(distGrid), middleIndex, middleIndex);

        % the foreground should contain the closest bit
        [~, fgIdx] = min(distGrid(:));

        indexSubset = lazysnapping(distGrid, L, middle, fgIdx);
    else
        error('Invalid occlusion mode selected %s', nvargs.method)
    end
end