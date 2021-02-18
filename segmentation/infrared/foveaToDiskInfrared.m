function foveaToDiskInfrared(fileName, fileFolder)
% this function computes the distance and displays 
% the fovea to disk distance in a retinal  infrared fundus image
% Algorithm adapted from Rust, et. al. 2017 and modified by me

% Constants defined below
LARGEST_OBJECTS = 4;
STANDARD_X = 584;
STANDARD_Y = 565;
DELTA = 0.1;

I = imread(fullfile(fileFolder, fileName));
retinaImg = imresize(I, [STANDARD_X STANDARD_Y]);

% Step 1: preprocessing the image:
% conversion of image to grayscale and median filter for noise reduction
grayRetinaImg = rgb2gray(retinaImg);
grayRetinaImg = medfilt2(grayRetinaImg);

% using Otsu's method to threshold and isolate bright and dark regions
foreground = imbinarize(grayRetinaImg, graythresh(grayRetinaImg));
% brightRegions = imbinarize(foreground, graythresh(foreground));
% figure, imshow(foreground);
% figure, imshow(brightRegions);

% use unsharp masking, dilation with 10x10 disc SE, then closing with same SE
SE = strel('disk', 5);
vesselsRemoved = imdilate(grayRetinaImg, SE);
%vesselsRemoved = grayRetinaImg
vesselsRemoved = imsharpen(vesselsRemoved);
vesselsRemoved = imclose(vesselsRemoved, SE);

segmented = imbinarize(fuzzycmeans(vesselsRemoved));
segmented = imcomplement(segmented);
largest_objects_filtered = bwareafilt(segmented, LARGEST_OBJECTS);
roundness = regionprops(largest_objects_filtered, 'Circularity');
centers = regionprops(largest_objects_filtered, 'Centroid');
areas = regionprops(largest_objects_filtered, 'Area');

h = size(largest_objects_filtered, 1);
w = size(largest_objects_filtered, 2);

disk_area = areas(1).Area;
min_dist_from_center = 1000;
disk_index = 1;

for i_idx = 1:LARGEST_OBJECTS
    object_y = centers(i_idx).Centroid(2);
    distance_from_center = abs(h/2 - object_y);
    if(distance_from_center < min_dist_from_center)
        disk_area = areas(i_idx).Area;
        min_dist_from_center = distance_from_center;
        disk_index = i_idx;
    end
end

disk = bwareafilt(largest_objects_filtered, [disk_area - DELTA, disk_area + DELTA]);
figure, imshow(disk);
centroid_of_disk = centers(disk_index);
x_disk = centroid_of_disk.Centroid(1);
y_disk = centroid_of_disk.Centroid(2);

% [center_faz, faz_annotated] = segmentFaz(fileName, fileFolder);
% figure, imshow(faz_annotated);
% faz_annotated = imresize(faz_annotated, [STANDARD_X STANDARD_Y]);
% 
% annotated_img = insertShape(faz_annotated,'Line',[x_disk y_disk center_faz(1) center_faz(2)],'LineWidth',3,'Color','green');
% annotated_img = insertShape(annotated_img, 'FilledCircle', [x_disk y_disk 5], 'Color', 'green');
% annotated_img = insertShape(annotated_img, 'FilledCircle', [center_faz(1) center_faz(2) 5], 'Color', 'blue');

% figure, imshow(annotated_img);

end