function selectCenter(directory, txtFile)
% this function runs through images in a given directory and displays them
% for the user to select a point of interest, which are then written to 
% the file specified.
% Author: Shreyas Bharadwaj, 13th September 2020

% define standard size for all images in the directory 
ROWS = 700;
COLS = 605;

% check if folder exists and prompt for re entry if it doesn't
if ~isfolder(directory)
    errorMessage = sprintf('Error: The following folder does not exist:\n%s\nPlease specify a new folder.', directory);
    uiwait(warndlg(errorMessage));
    myFolder = uigetdir(); % Ask for a new one.
    if myFolder == 0
         % User clicked Cancel
         return;
    end
end

% get all the files in the directory that match the image format desired
filepattern = fullfile(directory, '*.bmp');
files = dir(filepattern);
% open the file to write the points to
fileID = fopen(txtFile,'w');

% loop through all the files in the directory
for k = 1 : length(files)
    fullFileName = fullfile(files(k).folder, files(k).name);
    fprintf(1, 'Now reading %s\n', files(k).name);
    % read the image and resize it to the appropriate standard dimensions
    I = imread(fullFileName);
    I = imresize(I, [ROWS COLS]); 
    imwrite(I, fullFileName);
    % use MATLAB's drawpoint function to get a user selected point from the
    % image
    figure, imshow(I);
    roi = drawpoint;
    % get the center, put it in a string, and write it to the file
    pos = roi.Position;
    if pos(1) < 1 || pos(2) < 1
        pos = [-1, -1];
    end
    str = strcat(files(k).name, {','}, string(pos(1)), {','}, string(pos(2)));
    fprintf(fileID, str);
    fprintf(fileID, '\n');
    close all;
end
end