function [ROI, xi, yi] = select_roi_poly(img_in)

select_roi = 'y';
while (select_roi == 'y')
    fig_handle = figure;
    imagesc(img_in); axis image;colormap(gray(256));
    % First select the ROI using mouse clicks to select the polygon.
    % see 'help roipoly' for mouse controls needed to select the ROI
    disp(' Please select the desired ROI (Left click to add points, Double click when done)');
    [ROI,xi, yi] = roipoly;
    
    % Display the ROI 
    
    imagesc(img_in); axis image;colormap(gray(256));
    hold on;
    plot(xi,yi,'b','LineWidth', 2);
            
    select_roi = input('Continue with ROI selection (y/n)? ', 's');
  
    if ishandle(fig_handle)
        close(fig_handle);
    end

end


return
