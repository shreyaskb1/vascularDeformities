function computeVascularDeformities1(beforeImg, afterImg, folder)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    retinaImg_before = imread(fullfile(folder, beforeImg));
    retinaImg_after = imread(fullfile(folder, afterImg));
    retinaImg_before = imresize(retinaImg_before, [584 565]);
    retinaImg_after = imresize(retinaImg_after, [584 565]);
    figure, imshow(retinaImg_before);
    figure, imshow(imread(fullfile(folder, afterImg)));
    TILE_SIZE = 6;
    segmentedI1 = CoyeFilter(retinaImg_before);
    segmentedI2 = CoyeFilter(retinaImg_after);
    figure, imshow(segmentedI1);
    figure, imshow(segmentedI2);
    
    segmentedI1_gray = rgb2gray(segmentedI1);
    segmentedI2_gray = rgb2gray(segmentedI2);
    I1 = imbinarize(segmentedI1_gray);
    I2 = imbinarize(segmentedI2_gray);
    figure, imshow(I1);
    figure, imshow(I2);
    
    H = size(segmentedI1, 1);
    W = size(segmentedI2, 2);
    
    x_value = 0;
    y_value = 0;
    
    tiled_before = cell(TILE_SIZE*TILE_SIZE, 1);
    tiled_after = cell(TILE_SIZE*TILE_SIZE, 1);
    offsets = cell(TILE_SIZE*TILE_SIZE, 2);
    counter = 1;
    
    for i_idx=1:TILE_SIZE
        for j_idx=1:TILE_SIZE
            tiled_image_before = imcrop(I1, [x_value, y_value, W/TILE_SIZE, H/TILE_SIZE]);
            tiled_image_after = imcrop(I2, [x_value y_value W/TILE_SIZE H/TILE_SIZE]);
            
            tiled_image_before = fillVeins(tiled_image_before);
            tiled_image_after = fillVeins(tiled_image_after);
            
            tiled_before{counter} = tiled_image_before;
            tiled_after{counter} = tiled_image_after;
            offsets{counter} = [x_value, y_value];
            
            counter = counter + 1;
            
            y_value = y_value + H/TILE_SIZE + 1;
        end
        x_value = x_value + W/TILE_SIZE + 1;
        y_value = 0;
    end
    
    vector_coords = zeros(TILE_SIZE*TILE_SIZE, 4);
    TILE_SIZE_SQ = TILE_SIZE*TILE_SIZE;
    x1_all = zeros(TILE_SIZE_SQ); y1_all = zeros(TILE_SIZE_SQ); xv_all = zeros(TILE_SIZE_SQ); yv_all = zeros(TILE_SIZE_SQ);
    for i=1:TILE_SIZE*TILE_SIZE
        curr_before = tiled_before{i};
        curr_after = tiled_after{i};
        
        filtered_before = bwareafilt(curr_before, 1);
        filtered_after = bwareafilt(curr_after, 1);
        
        centroids_before = regionprops(filtered_before, 'Centroid');
        centroids_after = regionprops(filtered_after, 'Centroid');
        
        if size(centroids_before, 1) == 0 || size(centroids_after, 1) == 0
            continue;
        end
        x1 = centroids_before.Centroid(1);
        x1 = x1 + offsets{i}(1);
        x2 = centroids_after.Centroid(1);
        x2 = x2 + offsets{i}(1);
        y1 = centroids_before.Centroid(2);
        y1 = y1 + offsets{i}(2);
        y2 = centroids_after.Centroid(2);
        y2 = y2 + offsets{i}(2);
        
        vector_coords(i,:) = [x1, y1, x1-x2, y1-y2];
        x1_all(i) = x1;
        y1_all(i) = y1;
        xv_all(i) = x2-x1;
        yv_all(i) = y2-y1;
    end
    close all;
    
    figure, imshowpair(retinaImg_before, retinaImg_after);
    hold on;
    quiver(x1_all, y1_all, xv_all, yv_all,'lineWidth',3);
    
    
end

function filledVeinsImg = fillVeins(img)
    SE_RADIUS = 2;
    img = imcomplement(img);
    SE = strel('disk', SE_RADIUS, 8);
    img = imerode(img, SE);
    img = imdilate(img, SE);
    filledVeinsImg = imcomplement(img);
end