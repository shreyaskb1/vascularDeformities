function I = trimBranches2(I)
I = ~im2bw(I);
I = bwmorph(I,'skel','inf');

B = bwmorph(I,'branchpoints');
E = bwmorph(I,'endpoints');
[yb,xb] = find(B);                  % coordinates of branchpoints
[ye,xe] = find(E);                  % coordinates od endpoints

branch_length = 20;                 % length of branch to be removed
D = pdist2([xb yb], [xe ye]);       % combinations of distances
[De,indb] = min(D);                 % smallest distances
inde = find(De < branch_length);    % desired distances
indb = indb(inde);

[m,n] = size(I);
[X,Y] = meshgrid(1:n,1:m);          % mesh for circle mask
cla
imshow(I)
hold on
for i = 1:length(inde)
    ie = inde(i);                   % index of end point
    ib = indb(i);                   % index of branch point
    [x1,y1,x2,y2] = deal( xb(ib),yb(ib),xe(ie),ye(ie) );
    x0 = (x1 + x2)/2;
    y0 = (y1 + y2)/2;
    D = pdist2( [x1 y1], [x2 y2] ); % distance between points
        % create circle between points
    msk = (X-x0).^2 + (Y-y0).^2 <= D^2/4;
        % extract data from image into circle region
    rgn = msk & I;
        % biggest branch should be removed from region
    L = bwlabel(rgn);
    ar = regionprops(L,'Area');
    [~,ind] = max( cat(1,ar.Area) );
    rgn(L==ind) = 0;                % remove biggest branch
    msk = bwmorph(msk,'thin',1);    % reduce circle mask
    I = I & ~msk;                   % clear circle region from image
    I = I | rgn;                    % place modified region
    
    imshow(I|msk)
    plot(x2,y2,'.r')
    plot(x1,y1,'.b')
    pause(1)
end
I = bwareaopen(I,3);                % clear small areas
I = bwmorph(I,'spur',2);            % clear spur two times
imshow(I)
plot(xe,ye,'.r')
plot(xb,yb,'.b')
hold off
end

