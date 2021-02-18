function [center, final_faz] = segmentFazOCTA(fileName, fileFolder)
% this function uses segmentation and image processing operations
% to segment and isolate the foveal autovascular zone in a fundus image

% constants defined below
DISK_DIAMETER_CLOSURE = 8;
DISK_DIAMETER_TOPHAT = 12;
DISK_DIAMETER_OPENING = 12;
DELTA = 0.1;

% read the image from the file path and file name
retinaImg = imread(fullfile(fileFolder, fileName));
retinaImg_resized = imresize(retinaImg, [584 565]);

% segment the blood vessels out using edge detection 
% segmentedRetina = CoyeFilter(fileName);
segmentedRetina = retinaImg_resized;
figure, imshow(segmentedRetina);
segmentedRetina = rgb2gray(segmentedRetina);
segmentedRetina = adapthisteq(segmentedRetina);
segmentedRetina = histeq(segmentedRetina);
segmentedRetina = imadjust(segmentedRetina);
figure, imshow(segmentedRetina);

% save cropped image of central area
h_old = size(segmentedRetina, 1);
w_old = size(segmentedRetina, 2);

centerCropped = imcrop(segmentedRetina, [w_old/4 h_old/4 w_old/2 h_old/2]);
centerCroppedBW = im2bw(centerCropped);

% method taken from Diaz, et. al. (2015) 
% Step 1 - Image processing: apply white top hat operator for intensity
% profile

SE = strel('disk', DISK_DIAMETER_TOPHAT);
whiteTopHat = imtophat(centerCroppedBW, SE);
figure, imshow(whiteTopHat);

% Step 2 - apply Canny edge detection 
edgeDetection = edge(whiteTopHat, 'Canny');
figure, imshow(edgeDetection);

% Step 3 - Morphological closure, inversion, and opening
se_close = strel('disk', DISK_DIAMETER_CLOSURE);
se_open = strel('disk', DISK_DIAMETER_OPENING);
closure = imclose(edgeDetection, se_close);
closure = imcomplement(closure);
closure = imopen(closure, se_open);
h = size(closure, 1);
w = size(closure, 2);
figure, imshow(closure);

% Step 4 - select the largest connected component 
largest_objects_filtered = bwareafilt(closure, 5);
largest_objects = bwconncomp(largest_objects_filtered);

% remove the small components and choose the one closest to the
% geometric center of the image
labeled = labelmatrix(largest_objects);
RGB_label = label2rgb(labeled,@copper,'c','shuffle');

center_coords = regionprops(largest_objects, 'Centroid');
areas = regionprops(largest_objects, 'Area');
min_dist = 1000;
center_area = areas(1).Area;
index_faz = 1;

for size_idx=1:size(center_coords)
    curr_center = center_coords(size_idx);
    dist = sqrt((curr_center.Centroid(1) - w/2)^2 + (curr_center.Centroid(2) - h/2)^2);
    if(min_dist > dist)
        min_dist = dist;
        center_area = areas(size_idx).Area;
        index_faz = size_idx;
    end
end

% filter and display the foveal autovascular zone
disp(center_area);
area = center_area;
faz = bwareafilt(largest_objects_filtered, [center_area - DELTA, center_area + DELTA]);
figure, imshow(faz);
faz = uint8(faz);

H = size(retinaImg_resized, 1);
W = size(retinaImg_resized, 2);

h = size(faz, 1);
w = size(faz, 2);

% mistake somewhere below
origFaz = zeros(H,W);
origFaz(H/2-h/2:H/2+h/2-1,W/2-w/2:W/2+w/2-1) = faz;

final_img = colover(double(rgb2gray(retinaImg_resized)), double(origFaz), 0.5, 0.4);
axis image
F = getframe(final_img);
[X, Map] = frame2im(F);
final_faz = X;
final_faz = imresize(final_faz, [584 565]);

center_x = w_old/4 + center_coords(index_faz).Centroid(1);
center_y = h_old/4 + center_coords(index_faz).Centroid(2);
center = [center_x center_y];

end