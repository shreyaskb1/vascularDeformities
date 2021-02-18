function disp_and_save_imgs(imgArray,baseStr,refImg,labels, thresh, transp, cmap, maxint, save_scale, rotImgs)
%disp_and_save_imgs Display and save the input images with optional colover
%   This function provides a way to display the images and save them to
%   disk in matlab format (.fig) as well as png format. The directories
%   matlab_figs and matlab_pngs are created if they dont exist.
%   Labels can be passed in which case they are used for the names of the
%   files as well as display. If an optional refImg is passed, then colover
%   is used to display it.
%   The first dimension of the imgArray is assumed to be indx for images

% Author: Keshav Datta
% Created on: 08Aug2020
% Last Modified: 08Aug2020

% create directories for storing figures
MATLAB_FIG_DIR = 'matlab_figs';
MATLAB_PNG_DIR = 'matlab_pngs';
intp_fac = 4;

[SUCCESS,MESSAGE,MESSAGEID] = mkdir(MATLAB_FIG_DIR);
[SUCCESS,MESSAGE,MESSAGEID] = mkdir(MATLAB_PNG_DIR);

szs = size(imgArray);

if length(szs) == 2
    numImgs = 1;
    imgArrayNew(1,:,:) = imgArray;
    imgArray = imgArrayNew;
else
    numImgs = szs(1);
end

if ~exist('baseStr','var') || isempty(baseStr)
    baseStr = "Auto";
end

% make subdirectories to organize the images
figDir = sprintf('%s/%s',MATLAB_FIG_DIR,baseStr);
pngDir = sprintf('%s/%s',MATLAB_PNG_DIR,baseStr);

[SUCCESS,MESSAGE,MESSAGEID] = mkdir(figDir);
[SUCCESS,MESSAGE,MESSAGEID] = mkdir(pngDir);

if ~exist('labels','var') || isempty(labels)
    autolabel = 1;
else
    autolabel = 0;
end

if ~exist('refImg','var') || isempty(refImg)
    tocolover = 0;
    refImg = zeros(256,256);
else
    tocolover = 1;
end

if ~exist('thresh','var') || isempty(thresh)
    thresh = 0.2;
end

if ~exist('transp','var') || isempty(transp)
    transp = 0.5;
end

if ~exist('cmap','var') || isempty(baseStr)
    cmap = "jet";
end

if ~exist('save_scale','var') || isempty(save_scale)
    save_scale = 4;
end

if ~exist('rotImgs','var') || isempty(rotImgs)
    rotImgs = 0;
end

if ~exist('maxint','var') || isempty(maxint)
    maxint = [];
end

if rotImgs ~= 0
    for indx =1:numImgs
        imgArray(indx,:,:) = rot90(squeeze(imgArray(indx,:,:)),rotImgs);
    end
    refImg = rot90(refImg,rotImgs);
end

% input is an an array of images, iterate over them.
for indx = 1:numImgs
    img = squeeze(imgArray(indx,:,:));
    img = imresize(img,intp_fac);
    
    if autolabel ==1
        label = sprintf("%s_%d",baseStr, indx);
    else
        label = sprintf("%s_%s", baseStr, labels(indx));
    end
    
    if tocolover == 1
        figh = colover(refImg, img, thresh, transp,[],[],[],maxint,cmap);
    else
        figh = figure; colormap(cmap);
        imagesc(img); colorbar;
    end
    title(label);
    
    % for now keep the filename same as the label
    fname = sprintf('%s',label);
    saveas(figh, sprintf('./%s/%s.fig',figDir, fname), 'fig');
    
    save_img(figh, save_scale*size(img), sprintf('./%s/%s.png',pngDir, fname));
    
end

% Print all of them in one giant figure. this is good for comparing
% relative intensities since the whole image is normalized to max across
% all the images. If you want each of them individually displayed to their
% max, normalize each fig.
% display as square as possible/
numCols = ceil(sqrt(numImgs));
numRows = ceil(numImgs/numCols); % simple for now, can improve later

largeRefImg = repmat(refImg,numRows, numCols);
largeRecImg = repmat(zeros(size(img)), numRows, numCols);

[rr,cc]=size(img);

imgIndx = 1;
for rindx = 1:numRows
    for cindx = 1:numCols
        if imgIndx > numImgs
            break;
        end
        largeRecImg((rindx-1)*rr+1:(rindx-1)*rr+rr, (cindx-1)*cc+1:(cindx-1)*cc+cc) = imresize(squeeze(imgArray(imgIndx,:,:)), intp_fac);
        imgIndx = imgIndx+1;
    end
end

if tocolover == 1
    figh = colover(largeRefImg, largeRecImg, thresh, transp,[],[],[],maxint,cmap);
else
    figh = figure; colormap(cmap);
    imagesc(largeRecImg); colorbar;
end

title(baseStr)

fname = sprintf("%s_large", baseStr);
saveas(figh, sprintf('./%s/%s.fig',figDir, fname), 'fig');

save_img(figh, size(largeRecImg), sprintf('./%s/%s.png',pngDir, fname));

% The following saves the entire figure
%saveas(figh, sprintf('./%s/%s.png',pngDir, fname), 'png');

return

% Use the following functions to save images. Each has a specific purpose
% saveas, print, imwrite, truesize, axis
% h = getframe(gcf);% saves the whole fig
% imwrite(h.cdata, 'myfilename.png') 
% h = getframe(gca); % saves only what is in the figure, not the
% surroundings
% imwrite(h.cdata, 'myfilename.png')

function save_img(figh,save_scale,fileName)

MAX_SAVE_SCALE = 512;
axis off
% set the correct axis. scale it as necessary
if save_scale(1) > MAX_SAVE_SCALE,
    save_scale = MAX_SAVE_SCALE*save_scale/max(save_scale(:));
end

% truesize(figh, save_scale); % the size is in pixels

% The following is for imwrite, but does not include colorbar.
% % This saves only the contents of the figure, not axis etc.
% iptsetpref('ImshowBorder','tight');
% hh = getframe(gcf);
% %imwrite(hh.cdata, fileName);

% This saves the whole figure
% ax = gca;
% outerpos = ax.OuterPosition;
% ti = ax.TightInset;
% left = outerpos(1) + ti(1);
% bottom = outerpos(2) + ti(2);
% ax_width = outerpos(3) - ti(1) - ti(3);
% ax_height = outerpos(4) - ti(2) - ti(4);
% % the 0.92 factor allows for the colorbar to be displayed correctly
% ax.Position = [left bottom ax_width*0.9 ax_height*1];

% figh = gcf;
% figh.PaperPositionMode = 'auto'
% fig_pos = figh.PaperPosition;
% figh.PaperSize = [fig_pos(3) fig_pos(4)];

% none of the above seem to be working well for all cases, so gave up and
% use the following for now (I wanted to save only the imae area of the
% figure and also wanted the image to show in correct aspect ratio of the
% number of pixels. Also the colorbar has to be displayed correctly). This
% should work for both colover and imagesc
axis image
saveas(figh, fileName, 'png');
%print(figh,'-dpng',sprintf('%s_print.png',fileName));
% print(fig,'testing5','-dpng');
% saveas(fig, 'testing6.png', 'png');

return

