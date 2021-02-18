function fig = colover(igray, icol, thresh, trans, scale, fig, slice, maxint, cmap)
%
%	colover(igray, icol, thresh, trans, scale, slice, maxint, cmap)
%
%	displays color image ICOL over grayscale image IGRAY
%
%       with threshhold level THRESH [0.25] and transparency TRANS [0.75]
%       SCALE [1] is a scaling factor of the output image
%       SLICE [3] is the slice dimension for display
%       MAXINT [max(ICOL)] is the maximum value for the intensity scale
%       maskimg is the image for masking background
%
%	Dirk Mayer, 10/23/2007, rev. 2/23/2010
%   Jae Mo Park, rev. 4/7/2011 : maskimg option is added
%   Jae Mo Park, rev. 7/15/2011: window level is optimized for mask option
%   Keshav Datta rev. 05/27/2017: Added option to return the fig handle
%   Keshav Datta rev. 11Aug2020: Added new option for choosing colormap

icol=double(squeeze(icol));
igray=double(squeeze(igray));
%thresh=0.01;

if ~exist('cmap','var') || isempty(cmap)
    cmap = 'jet';
end

if ~exist('maxint','var') || isempty(maxint)
    maxint = 0;
end

dummy_icol = 0; % Sometimes, the icol is a dummy image with NaNs.
if isnan(sum(icol(:))),
    dummy_icol = 1;
end

% keshav 01feb19. The following lines to display colorbar properly
if dummy_icol == 0,
    igray = normaliz(igray);
    maxicol = max(icol(:)); minicol = min(icol(:));
    if exist('maxint','var') && maxint > maxicol,
        maxicol = maxint;
    end
    igray = igray*(maxicol-minicol) + minicol; % Now igray is scaled to the same scale as icol
end

if (size(igray,3) == 2*size(icol,3))
    maskimg=igray(:,:,size(icol,3)+1:end);
    igray=igray(:,:,1:size(icol,3));
else if (size(igray,3) == 2 && size(icol,3) ~= 2)
    maskimg=igray(:,:,end);
    igray=igray(:,:,1:end-1);        
    else        
        maskimg=ones(size(igray,1), size(igray,2), size(igray,3));
    end
end

if (size(igray,3)==1 && size(icol,3)>1)
    igray=repmat(igray,[1 1 size(icol,3)]);
end

if (nargin < 8)
  maxint = max(icol(:));
end
if nargin >= 7
  if slice == 1 
    igray = permute(igray,[2 3 1]);
    icol = permute(icol,[2 3 1]);
  elseif slice == 2
    igray = permute(igray,[1 3 2]);
    icol = permute(icol,[1 3 2]);
  end
end
if (nargin < 6)
    fig = [];
end
if (nargin < 5) || ~exist('scale','var') || isempty(scale)
  scale = 1;
end
if (nargin < 4)|| ~exist('trans','var') || isempty(trans)
  trans = .75;
end
if (nargin < 3) || ~exist('thresh','var') || isempty(thresh)
  thresh = .25;
end

if (size(igray,3) > size(icol,3))
    igray=igray(:,:,1:size(igray,3)/size(icol,3):end);
end

nsize=size(igray);
nratio=size(igray,2)/size(icol,2);
icol=imresize_old(icol,[nsize(1) nsize(2)]);
% round(max(icol(:)))
if maxint > max(icol(:)),
    icol=icol/maxint*255;
else
    icol=icol/max(icol(:))*255;
end

barwdth=2*ceil(nratio);   % width for colorbar
% barwdth=1;

if size(icol,3)==1
    icol(:,1:end-barwdth)=icol(:,1:end-barwdth).*maskimg(:,1:end-barwdth);
else
    icol(:,1:end-barwdth,1)=icol(:,1:end-barwdth,1).*maskimg(:,1:end-barwdth,1);
    for m=2:size(icol,3)
        if size(maskimg,3)>1
            icol(:,:,m)=icol(:,:,m).*maskimg(:,:,m);
        else
            icol(:,:,m)=icol(:,:,m).*maskimg(:,:);
        end
    end
end

if (ndims(igray) > 2)
    coltab=zeros(nsize(1),nsize(2),3,nsize(3));
    for i1=1:nsize(3)
        switch lower(cmap)
            case 'parula'
                coltab(:,:,:,i1) = ind2rgb(uint8(icol(:,:,i1)),parula(256));
            case 'hot'
                coltab(:,:,:,i1) = ind2rgb(uint8(icol(:,:,i1)),hot(256));
            case 'cool'
                coltab(:,:,:,i1) = ind2rgb(uint8(icol(:,:,i1)),cool(256));
            case 'hsv'
                coltab(:,:,:,i1) = ind2rgb(uint8(icol(:,:,i1)),hsv(256));
            case 'jet'
                coltab(:,:,:,i1) = ind2rgb(uint8(icol(:,:,i1)),jet(256));
            case 'pink'
                coltab(:,:,:,i1) = ind2rgb(uint8(icol(:,:,i1)),pink(256));
            case 'copper'
                coltab(:,:,:,i1) = ind2rgb(uint8(icol(:,:,i1)),copper(256));
            case 'gray'
                coltab(:,:,:,i1) = ind2rgb(uint8(icol(:,:,i1)),gray(256));
            otherwise
                coltab(:,:,:,i1) = ind2rgb(uint8(icol(:,:,i1)),jet(256));
        end
    end
    nz = size(igray,3);
    lx = ceil(sqrt(nz));
    ly = ceil(nz/lx);
    if (mod(lx+1 - mod(nz,lx+1),lx+1) < mod(lx - mod(nz,lx),lx))
        lx=lx+1;
        ly=ceil(nz/lx);
    end
    if (mod(lx+1 - mod(nz,lx+1),lx+1) < mod(lx - mod(nz,lx),lx))
        lx=lx+1;
        ly=ceil(nz/lx);
    end
else
    switch lower(cmap)
        case 'parula'
            coltab = ind2rgb(uint8(icol),parula(256));
        case 'hot'
            coltab = ind2rgb(uint8(icol),hot(256));
        case 'cool'
            coltab = ind2rgb(uint8(icol),cool(256));
        case 'hsv'
            coltab = ind2rgb(uint8(icol),hsv(256));
        case 'jet'
            coltab = ind2rgb(uint8(icol),jet(256));
        case 'pink'
            coltab = ind2rgb(uint8(icol),pink(256));
        case 'copper'
            coltab = ind2rgb(uint8(icol),copper(256));
        case 'gray'
            coltab = ind2rgb(uint8(icol),gray(256));
        otherwise
            coltab = ind2rgb(uint8(icol),jet(256));
    end
    
    lx = 1; ly = 1; nz =1;
end

% lx=5;
% ly=1;

sizex = lx*size(igray,2);
sizey = ly*size(igray,1);

minim=min(igray(:));
maxim=max(igray(:));

if ~exist('fig','var') || isempty(fig),
    fig=figure('Units','pixels','Position',[100 100 sizex*scale sizey*scale]);
else
    figure(fig);
end

set(0,'DefaultFigureColorMap', hot);
for iz=1:nz
    subplot('Position',[mod(iz-1,lx)/lx 1-(1+floor((iz-1)/lx))/ly 1/lx 1/ly])
%     imagesc(igray(:,:,iz),[minim maxim])
    imshow(igray(:,:,iz), [minim maxim]);
    colormap('gray')
    axis('off')
    hold on
%     imh = imagesc(coltab(:,:,:,iz));
    imh = imshow(coltab(:,:,:,iz));
    %   imh = imagesc(coltab(:,:,3));
    icoltmp=icol(:,:,iz);
    imAlphaData = icoltmp*0;
    % cbar=icol(:,end-barwdth+1:end,1);
    imAlphaData(icoltmp(:) >= (thresh*256)) = trans;
    %     if iz==1                                                  % jae mo park
    %         imAlphaData(:,end-barwdth+1:end) = trans;
    %     end
    set(imh,'AlphaData',imAlphaData);
    % cbh = colorbar;    
%     switch lower(cmap)
%         case 'parula'
%             colormap(cbh,parula);
%         case 'hot'
%             colormap(cbh,hot);
%         case 'cool'
%             colormap(cbh,cool);
%         case 'hsv'
%             colormap(cbh,hsv);
%         case 'jet'
%             colormap(cbh,jet);
%         case 'pink'
%             colormap(cbh,pink);
%         case 'copper'
%             colormap(cbh,copper);
%         case 'gray'
%             colormap(cbh, gray);
%         otherwise
%             colormap(cbh,jet);
%     end    
    hold off
end
set(fig,'PaperPositionMode','auto');
end


