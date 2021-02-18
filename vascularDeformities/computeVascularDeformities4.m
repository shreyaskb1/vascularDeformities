function computeVascularDeformities4(beforeImg,afterImg, folder)

    % constants
    MIN_BL = 20;
    STD_H = 584;
    STD_W = 565;
    BP_MINDIST = 30;
    INTER_BP_MAXDIST = 50;
    MIN_DIST_PAIR = 75*75;
    
    retinaImg_before = imread(fullfile(folder, beforeImg));
    retinaImg_before = imresize(retinaImg_before, [STD_H STD_W]);
    retinaImg_after = imresize(imread(fullfile(folder, afterImg)), [STD_H STD_W]);
    
%     retinaImg_before = (imgEnhance(retinaImg_before));
%     retinaImg_after = (imgEnhance(retinaImg_after));
    
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
    s = strel('disk', 4);
    I1 = imclose(I1, s);
    I2 = imclose(I2, s);
        
    figure, imshow(I1);
    figure, imshow(I2);
    
    skeleton_I1 = bwskel(I1, 'MinBranchLength', MIN_BL);
    skeleton_I2 = bwskel(I2, 'MinBranchLength', MIN_BL);
    I1_skel_filtered = bwareafilt(skeleton_I1, [100, 584*565]);
    I2_skel_filtered = bwareafilt(skeleton_I2, [100, 584*565]);
    

    I1_skel_filtered = bwmorph(I1_skel_filtered, 'bridge');
    I2_skel_filtered = bwmorph(I2_skel_filtered, 'bridge');
    I1_skel_filtered = bwmorph(I1_skel_filtered, 'fill');
    I2_skel_filtered = bwmorph(I2_skel_filtered, 'fill');

    close all;
    
    I1_skel_filtered = bwmorph(I1_skel_filtered, 'thin', Inf);
    I2_skel_filtered = bwmorph(I2_skel_filtered, 'thin', Inf);
    
    bp1 = bwmorph(I1_skel_filtered,'branchpoints');
    [row, column] = find(bp1);
    branchPts = [row, column];
    branchPts = getNewBranchPoints(branchPts, BP_MINDIST);
    figure, imshow(I1_skel_filtered);
    hold on;
    plot(branchPts(:,2),branchPts(:,1), 'rx', 'MarkerSize', 20);
    
    bp2 = bwmorph(I2_skel_filtered,'branchpoints');
    [row2, column2] = find(bp2);
    branchPts2 = [row2, column2];
    branchPts2 = getNewBranchPoints(branchPts2, BP_MINDIST);
    figure, imshow(I2_skel_filtered);
    hold on;
    plot(branchPts2(:,2),branchPts2(:,1), 'rx', 'MarkerSize', 20);
   
    ctr = 1;
    for i_idx = 1:size(branchPts,1)
        curr_before = branchPts(i_idx,:);
        min_dist = size(I1_skel_filtered,1)*size(I2_skel_filtered);
        smallest_dist_idx = 1;
        for j_idx = 1:size(branchPts2, 1)
            curr_after = branchPts2(j_idx, :);
            x_diff = curr_before(1) - curr_after(1);
            y_diff = curr_before(2) - curr_after(2);
            x_diff = x_diff*x_diff;
            y_diff = y_diff*y_diff;
            dist = x_diff + y_diff;
            if(min_dist > dist)
                min_dist = dist;
                smallest_dist_idx = j_idx;
            end
        end
        
        if (min_dist < MIN_DIST_PAIR)
            matched_after_x(ctr,1) = branchPts(i_idx,1);
            matched_after_x(ctr,2) = branchPts(i_idx,2);
            matched_after_dx(ctr,1) = branchPts2(smallest_dist_idx,1) - curr_before(1);
            matched_after_dx(ctr,2) = branchPts2(smallest_dist_idx,2) - curr_before(2);
            ctr = ctr + 1;
        end
    end
    close all;
    retinaImg_before = imresize(retinaImg_before, [STD_H, STD_W]);
    retinaImg_after = imresize(retinaImg_after, [STD_H, STD_W]);
    
    figure, imshow(retinaImg_before);
    hold all;
    
    h1 = quiver(matched_after_x(:,2), matched_after_x(:, 1), matched_after_dx(:,2), matched_after_dx(:,1), 'AutoScale','off');
    plot(branchPts(:,2),branchPts(:,1), 'bx', 'MarkerSize', 20);
    hold all;
    plot(branchPts2(:,2),branchPts2(:,1), 'gx', 'MarkerSize', 20);
    
    
    figure, imshow(retinaImg_after);
    
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

function newBP = getNewBranchPoints(BP, minDist)
    len = size(BP, 1);
    counter = 1;
    flag = 1;
    minDistSq = minDist*minDist;
    for i_idx = 1:len
        curr_coord = BP(i_idx,:);
        flag = 1;
        for j_idx = 1:(i_idx-1)
            nxt_coord = BP(j_idx, :);
            dist = (curr_coord(1) - nxt_coord(1))*(curr_coord(1) - nxt_coord(1));
            dist = dist + (curr_coord(2) - nxt_coord(2))*(curr_coord(2) - nxt_coord(2));
            if dist < minDistSq
                flag = 0;
            end
        end
        if flag == 1
            newBP(counter,:) = curr_coord;
            counter = counter + 1;
        end
    end
end

function imgEnhanced = imgEnhance(img)
    shadow_lab = rgb2lab(img);
    max_luminosity = 100;
    L = shadow_lab(:,:,1)/max_luminosity;
    shadow_imadjust = shadow_lab;
    shadow_imadjust(:,:,1) = imadjust(L)*max_luminosity;
    imgEnhanced = lab2rgb(shadow_imadjust);
end