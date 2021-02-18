function [center, opticDisk] = foveaToDiskOCTA(fileName, fileFolder, eyeSide)
% this function takes in a OCT-A image and segments out the 
% optic disk from it
STANDARD_X = 584;
STANDARD_Y = 565;
THRESHOLD_FACTOR_X = 0.2;
THRESHOLD_FACTOR_Y = 0.2;

OCTAimg = imread(fullfile(fileFolder, fileName));
OCTAimg_gray = imbinarize(rgb2gray(OCTAimg));
OCTAimg_gray = imresize(OCTAimg_gray, [STANDARD_X STANDARD_Y]);
% figure, imshow(OCTAimg_gray);

h = size(OCTAimg_gray, 1);
w = size(OCTAimg_gray, 2);

SE = strel('disk', 5);
closed = imclose(OCTAimg_gray, SE);
closed = imcomplement(closed);
% figure, imshow(closed);

[center_faz, ~] = segmentFazOCTA(fileName, fileFolder);
CC = bwconncomp(closed);
RP_CC = regionprops(CC, 'Centroid');
A_CC = regionprops(CC, 'Area');

threshold_x = THRESHOLD_FACTOR_X*w;
threshold_y = THRESHOLD_FACTOR_Y*h;

if eyeSide == 'L'
    within_x = [0, threshold_x];
elseif eyeSide == 'R'
    within_x = [w - threshold_x, w];
end

within_y = [center_faz(2) - threshold_y, center_faz(2) + threshold_y];

COM = zeros(size(RP_CC, 1), 3);
for i_idx=1:size(RP_CC, 1)
    curr_center = RP_CC(i_idx).Centroid;
    if curr_center(1) >= within_x(1) && curr_center(1) <= within_x(2)
        if curr_center(2) >= within_y(1) && curr_center(2) <= within_y(2)
            COM(i_idx, 1) = curr_center(1);
            COM(i_idx, 2) = curr_center(2);
            COM(i_idx, 3) = A_CC(i_idx).Area;
        end
    end
end

total_area = 0;
for i_idx=1:size(COM)
    total_area = total_area + COM(i_idx, 3);
end

x_COM = 0;
y_COM = 0;
for i_idx=1:size(COM)
   x_COM = x_COM + COM(i_idx, 1)*COM(i_idx, 3);
   y_COM = y_COM + COM(i_idx, 2)*COM(i_idx, 3);
end

x_COM = x_COM/total_area;
y_COM = y_COM/total_area;
center = [x_COM, y_COM];
annotated_img = insertShape(imresize(OCTAimg, [STANDARD_X STANDARD_Y]), 'FilledCircle', [x_COM, y_COM, 5], 'Color', 'green');
figure, imshow(annotated_img);
opticDisk = annotated_img;

end