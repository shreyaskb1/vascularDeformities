function computeVascularDeformities3(beforeImg,afterImg, folder)

% improvement on previous algorithm to track the movement of retinal 
% vessels. This method changes the tiling method to ensure more arrows can
% be plotted without compromising the resolution of vessels tracked

    TILE_SIZE = 7;
    TILE_SIZE_SQ = TILE_SIZE*TILE_SIZE;
    retinaImg_before = imread(fullfile(folder, beforeImg));
    retinaImg_before = imresize(retinaImg_before, [584 565]);
    retinaImg_after = imresize(imread(fullfile(folder, afterImg)), [584 565]);
    figure, imshow(retinaImg_before);
    roi = drawpoint;
    center1 = roi.Position;
    if center1(1) < 1 || center1(2) < 1
        center1 = [-1, -1];
    end
    
    figure, imshow(retinaImg_after);
    roi = drawpoint;
    center2 = roi.Position;
    if center2(1) < 1 || center2(2) < 1
        center2 = [-1, -1];
    end
    
    retinaImg_before = imtranslate(retinaImg_before, center2-center1);
    maskedImg = uint8(imcomplement(retinaImg_before == 0));
    retinaImg_after = cutOutBlackBorders(times(maskedImg, retinaImg_after));
    retinaImg_before = cutOutBlackBorders(retinaImg_before);
    
    
    segmentedI1 = CoyeFilter(retinaImg_before);
    segmentedI2 = CoyeFilter(retinaImg_after);
    
    segmentedI1_gray = rgb2gray(segmentedI1);
    segmentedI2_gray = rgb2gray(segmentedI2);
    I1 = imbinarize(segmentedI1_gray);
    I2 = imbinarize(segmentedI2_gray);
    s = strel('disk', 3);
    I1 = imclose(I1, s);
    I2 = imclose(I2, s);
    
    figure, imshow(I1);
    figure, imshow(I2);
    
    H = size(segmentedI1, 1);
    W = size(segmentedI2, 2);
    
    w_tiles = 2*W/(TILE_SIZE+1);
    h_tiles = 2*H/(TILE_SIZE+1);
    
    x_c = 0;
    y_c = 0;
    
    x1_all = zeros(TILE_SIZE_SQ); y1_all = zeros(TILE_SIZE_SQ); 
    xv_all = zeros(TILE_SIZE_SQ); yv_all = zeros(TILE_SIZE_SQ);   
    close all;
    counter = 1;
    for i=1:TILE_SIZE
        for j=1:TILE_SIZE
            tile_ib = imcrop(I1, [x_c, y_c, w_tiles, h_tiles]);
            tile_ia = imcrop(I2, [x_c, y_c, w_tiles, h_tiles]);
            
            if j == TILE_SIZE
                tile_ib = imcrop(I1, [x_c, y_c, w_tiles, H-y_c]);
                tile_ia = imcrop(I2, [x_c, y_c, w_tiles, H-y_c]);
            end
            
            if i == TILE_SIZE
                tile_ib = imcrop(I1, [x_c, y_c, W - x_c, h_tiles]);
                tile_ia = imcrop(I2, [x_c, y_c, W - x_c, h_tiles]);
            end
            
            if i == TILE_SIZE && j == TILE_SIZE
                tile_ib = imcrop(I1, [x_c, y_c, W - x_c, H - y_c]);
                tile_ia = imcrop(I2, [x_c, y_c, W - x_c, H - y_c]);                
            end
            
            tile_ib = imfill(fillVeins(tile_ib), 'holes');
            tile_ia = imfill(fillVeins(tile_ia), 'holes');
            
            filtered_before = bwareafilt(tile_ib, 1);
            filtered_after = bwareafilt(tile_ia, 1);
            
            
            centroids_before = regionprops(filtered_before, 'Centroid');
            centroids_after = regionprops(filtered_after, 'Centroid');
            
%             [x1_center, y1_center] = findClosestVesselCoordinates(filtered_before, centroids_before.Centroid);
%             [x2_center, y2_center] = findClosestVesselCoordinates(filtered_after, centroids_after.Centroid);
            
            if sum(filtered_before(:)) == 0
                x1_center = w_tiles/2;
                y1_center = h_tiles/2;
            elseif sum(filtered_after(:)) == 0
                x2_center = w_tiles/2;
                y2_center = h_tiles/2;
            else 
                x1_center = centroids_before.Centroid(1); y1_center = centroids_before.Centroid(2);
                x2_center = centroids_after.Centroid(1); y2_center = centroids_after.Centroid(2);
            end
            x1_x = w_tiles/2;
            x2_x = w_tiles/2;
            y1_x = findClosestYCoord(filtered_before, w_tiles/2);
            y2_x = findClosestYCoord(filtered_after, w_tiles/2);
            
            x1_y = findClosestXCoord(filtered_before, h_tiles/2);
            x2_y = findClosestXCoord(filtered_before, h_tiles/2);
            y1_y = h_tiles/2;
            y2_y = h_tiles/2;
                  
            before_total = [(x1_x + x1_y + x1_center)/3, (y1_x + y1_y + y1_center)/3];
            after_total = [(x2_x + x2_y + x2_center)/3, (y2_x + y2_y + y2_center)/3];
            
            [x1_total, y1_total] = findClosestVesselCoordinates(filtered_before, before_total);
            [x2_total, y2_total] = findClosestVesselCoordinates(filtered_after, after_total);
            
            x1 = x_c + x1_total;
            y1 = y_c + y1_total;
            x2 = x_c + x2_total;
            y2 = y_c + y2_total;
            
            x1_all(counter) = x1;
            y1_all(counter) = y1;
            xv_all(counter) = x1-x2;
            yv_all(counter) = y1-y2;
            counter = counter + 1;
            y_c = y_c + h_tiles/2 + 1;
        end
        x_c = x_c + w_tiles/2 + 1;
        y_c = 0;
    end
    
    % figure, imshowpair(retinaImg_before, retinaImg_after);
    actual_before_img = imread(fullfile(folder, beforeImg));
    h_actual_before = size(actual_before_img, 1);
    w_actual_before = size(actual_before_img, 1);
    figure, imshow(actual_before_img);
    hold on;
    h1 = quiver(x1_all*w_actual_before/W, y1_all*h_actual_before/H, xv_all*w_actual_before/W, yv_all*h_actual_before/H,'lineWidth',2);
    set(h1,'AutoScale','on', 'AutoScaleFactor', 2);
    
    % figure, imshow(retinaImg_before);
    figure, imshow(retinaImg_after);
    
end
 

function filledVeinsImg = fillVeins(img)
    SE_RADIUS = 2;
    img = imcomplement(img);
    SE = strel('disk', SE_RADIUS, 8);
    img = imerode(img, SE);
    img = imdilate(img, SE);
    filledVeinsImg = imcomplement(img);
end

function [x, y] = findClosestVesselCoordinates(img, pt)
    x_dim = size(img, 2);
    y_dim = size(img, 1);
    minDist = 1000000000;
    x = 0;
    y = 0;
    for i=1:y_dim
        for j=1:x_dim
            if img(i,j) == 1
                dist = (pt(1) - i).^2 + (pt(2) - j).^2;
                if dist < minDist
                    minDist = dist;
                    x = j;
                    y = i;
                end
            end
        end
    end
%     if x == 0 && y == 0
%         x = x_dim/2;
%         y = y_dim/2;
%     end
end

function img = cutOutBlackBorders(inputImg)

i1 = imbinarize(rgb2gray(inputImg));
[r, c] = find(i1);
row1 = min(r);
row2 = max(r);
col1 = min(c);
col2 = max(c);
img = inputImg(row1:row2, col1:col2, :);

end

function y = findClosestYCoord(img, xCoord)
    min_dist = 10000;
    h_img = size(img, 1);
    y = h_img/2;
    for i=1:h_img
       if img(i, floor(xCoord)) == 1 && abs(i - h_img/2) < min_dist
           y = i;
           min_dist = abs(i - h_img/2);
       end
    end
end

function x = findClosestXCoord(img, yCoord)
    min_dist = 10000;
    w_img = size(img, 2);
    x = w_img/2;
    for i = 1:w_img
        if img(floor(yCoord), i) == 1 && abs(i - w_img/2) < min_dist
            x = i;
            min_dist = abs(i - w_img/2);
        end
    end
end