function dataAugmentationOpticDisk(directory)
% this function performs several data augmentation operations on a set of
% images given as a parameter and writes them to the same folder. 

% checks if the given folder exists and prompts user to re-enter folder if
% it doesn't

if ~isfolder(directory)
    errorMessage = sprintf('Error: The following folder does not exist:\n%s\nPlease specify a new folder.', directory);
    uiwait(warndlg(errorMessage));
    myFolder = uigetdir(); % Ask for a new one.
    if myFolder == 0
         % User clicked Cancel
         return;
    end
end

% read all the files in the directory
filepattern = fullfile(directory, '*.bmp');
files = dir(filepattern);

% loop over all the files in the directory
for k = 1 : length(files)
    % read each file
    name = files(k).name;
    fullFileName = fullfile(files(k).folder, name);
    without_extension = name(1:(strfind(name, '.')-1));
    fprintf(1, 'Now reading %s\n', name);
    I = imread(fullFileName);

    % rotation operations
    rotated_img = getRotatedImg(I);    
    imwrite(rotated_img, fullfile(directory, strcat(without_extension, '_ROTATED.bmp')));
    
    % translation operations
    % translated_img = getTranslatedImg(I);
    % imwrite(translated_img, fullfile(directory, strcat(without_extension, '_TRANSLATED.bmp')));
    
    % scale operations
    % scaled_img = getScaledImg(rotated_img);
    contrast_alt = jitterColorHSV(I,'Contrast',[0.5 4]);
    imwrite(contrast_alt, fullfile(directory, strcat(without_extension, '_CONTRAST.bmp')));
    
    % reflection 
    reflected_img = getReflectedImg(I);
    brightness_alt = jitterColorHSV(reflected_img,'Brightness',[-0.5 0.5]); 
    imwrite(brightness_alt, fullfile(directory, strcat(without_extension, '_REFLECTED.bmp')));
    
    % shear operations
    % sheared_img = getShearedImg(I);
    jittered = jitterColorHSV(I,'Contrast',0.4,'Hue',0.1,'Saturation',0.2,'Brightness',0.3);
    imwrite(jittered, fullfile(directory, strcat(without_extension, '_JITTERED.bmp')));
    
    % noise induced (salt & pepper, gaussian, poisson)
    saltAndPepper = imnoise(reflected_img,'salt & pepper',0.1);
    imwrite(getRotatedImg(saltAndPepper), fullfile(directory, strcat(without_extension, '_SPNOISE.bmp')));
    
    gaussianNoise = imnoise(I, 'gaussian');
    imwrite(gaussianNoise, fullfile(directory, strcat(without_extension, '_GNOISE.bmp')));
    sigma = 1+3*rand; 
    
    poissonNoise = imnoise(contrast_alt, 'poisson');
    imwrite(poissonNoise, fullfile(directory, strcat(without_extension, '_PNOISE.bmp')));
    
    % random blurring
    blurred = imgaussfilt(jittered,sigma);
    imwrite(blurred, fullfile(directory, strcat(without_extension, '_BLUR.bmp')));
    
    saturation = jitterColorHSV(poissonNoise,'Saturation',[-0.4 -0.1]); 
    imwrite(saturation, fullfile(directory, strcat(without_extension, '_SATURATED.bmp')));
end
end

function rotatedImg = getRotatedImg(image)
    A = [90, 180, 270];
    rotatedImg = imrotate(image, A(randi(length(A), 1)));
end

function translatedImg = getTranslatedImg(image)
    tform = randomAffine2d('XTranslation',[-50 50],'YTranslation',[-100 100]);
    outputView = affineOutputView(size(image),tform);
    translatedImg = imwarp(image ,tform,'OutputView',outputView);
end

function scaledImg = getScaledImg(image)
    tform = randomAffine2d('Scale',[1,1.2]);
    outputView = affineOutputView(size(image),tform);
    scaledImg = imwarp(image,tform,'OutputView',outputView);
end

function reflectedImg = getReflectedImg(image)
    tform = randomAffine2d('XReflection',true,'YReflection',false);
    outputView = affineOutputView(size(image),tform);
    reflectedImg = imwarp(image,tform,'OutputView',outputView);
end

function shearedImg = getShearedImg(image)
    tform = randomAffine2d('XShear',[-20 20]); 
    outputView = affineOutputView(size(image),tform); 
    shearedImg = imwarp(image,tform,'OutputView',outputView);
end




