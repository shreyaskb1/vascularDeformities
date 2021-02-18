function trimBranches(A)
    dth=100;  % trimming threshold, all pegs closer or at 3 distance to nearest junction are trimmed
    [sz1A sz2A sz3A]=size(A);  %sz2A is x, horizontal. sz1A is y, vertical
    A1=A(:,:,1);
    hfg1=figure(1);imshow(A1)
    % hfg1.ToolBar='none';
    hfg1.MenuBar='none';hfg1.DockControls='off';hfg1.Name='start image';hfg1.Position=[500 200 2*sz2A 2*sz1A];
    B=imbinarize(A1);
    B0=B;   % reference
    figure(25);imshow(B0)
    hfg25.MenuBar='none';hfg25.Name='skeletonized image';hfg25.Position=[510 210 2*sz2A 2*sz1A];
    for s=1:1:10
    B2=bwmorph(B,'skel',Inf);             % skeletonize
    hfg2=figure(2);imshow(B2);
    hfg2.MenuBar='none';hfg2.Name='skeletonized image';hfg2.Position=[510 210 2*sz2A 2*sz1A];
    B2(1,:)=0;B2(end,:)=0;B2(:,1)=0;B2(:,end)=0; % make sure 1 pixel wide picture frame is black
    [sz1_b,sz2_b]=size(B2)        % sz2 horizontal sz1 vertical         
    [wy,wx,v]=find(B2);P=[wy wx];  % locations of white points, now contained in P
    PA={};                              % build cell container to log how many white points around each white point
    for k=1:1:length(P)             % allocating each white point location at the head of each PA line
        PA=[PA;P(k,:)];
    end
    fc=zeros(length(P),1);    % vector with counters of how many white pixels around each white pixel
    for k=1:1:length(P)
       p1=PA{k};    % read white point coordinates
       p1y=p1(1);p1x=p1(2);
         % mask 1.1 capturing straight tips
         p2=[p1y-1 p1x-1]; if B2(p2(1),p2(2)) p0=PA{k};PA{k}=[p0;p1];fc(k)=fc(k)+1; end        % top left, clock wise
         p2=[p1y-1 p1x]; if B2(p2(1),p2(2)) p0=PA{k};PA{k}=[p0;p1];fc(k)=fc(k)+1; end            % top
         p2=[p1y-1 p1x+1]; if B2(p2(1),p2(2)) p0=PA{k};PA{k}=[p0;p1];fc(k)=fc(k)+1; end       % top right
         p2=[p1y p1x+1]; if B2(p2(1),p2(2)) p0=PA{k};PA{k}=[p0;p1];fc(k)=fc(k)+1; end           % right
         p2=[p1y+1 p1x+1]; if B2(p2(1),p2(2)) p0=PA{k};PA{k}=[p0;p1];fc(k)=fc(k)+1; end       % down right
         p2=[p1y+1 p1x]; if B2(p2(1),p2(2)) p0=PA{k};PA{k}=[p0;p1];fc(k)=fc(k)+1; end           % down
         p2=[p1y+1 p1x-1]; if B2(p2(1),p2(2)) p0=PA{k};PA{k}=[p0;p1];fc(k)=fc(k)+1; end       % down left
         p2=[p1y p1x-1]; if B2(p2(1),p2(2)) p0=PA{k};PA{k}=[p0;p1];fc(k)=fc(k)+1; end            % left
    end
    PA2={};                              % build cell container for bent tip points
    for k=1:1:length(P)             
        PA2=[PA2;P(k,:)];
    end
    fc2=zeros(length(P),1);        % meter for bent tip points
    for k=1:1:length(P)
         p1=PA2{k};   
         p1y=p1(1);p1x=p1(2);
         r1=[p1y-1 p1x-1;        % top left, clock wise
              p1y-1 p1x;           % top
              p1y-1 p1x+1;     % top right
              p1y p1x+1;          % right
              p1y+1 p1x+1;        % down right
              p1y+1 p1x;      % down
              p1y+1 p1x-1;    % down left
              p1y p1x-1];          % left
         rm=zeros(1,length(r1));
         for k2=1:1:length(r1)
             rm(k2)=B2(r1(k2,1),r1(k2,2));
         end
         rm2=find(rm);
         if numel(rm2)==2 && (abs(rm2(1)-rm2(2))==1 || (abs(rm2(1)-rm2(2))==length(r1)-1))
             p0=PA2{k};PA2{k}=[p0;p1];
             fc2(k)=fc2(k)+1;
         end
    end
    figure(10);stem(fc)  % 002        % 1s are tips, 2s are sections, 3s and above are junctions
    figure(12);stem(fc2)         % fc2 marks P points that are bent tips 
    T=P(find(fc==1),:);                            % compiling straight tip points
    TL=P(find(fc2==1),:);                            % compiling bent tip points
    figure(4);imshow(B2);hold all;plot(T(:,2),T(:,1),'r*');       % check
    figure(4);plot(TL(:,2),TL(:,1),'Marker','*','Color','c','LineStyle','none');  
    % 201
    figure(25);hold all;plot(T(:,2),T(:,1),'r*');       % check
    figure(25);plot(TL(:,2),TL(:,1),'Marker','*','Color','c','LineStyle','none');  
    for k=1:1:length(T)
        B(T(k,1),T(k,2))=0;
    end
    end
    figure(26);imshow(B)
    hfg26.MenuBar='none';hfg26.Name=' ';hfg26.Position=[510 210 2*sz2A 2*sz1A];
end