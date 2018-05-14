function psf = PSF_kernel(sizex,sizey)
    first = 3.8317;
    x = -first:2*first/(sizex-1):first;
    y = -first:2*first/(sizey-1):first;
    [x_grid,y_grid] = meshgrid(x,y);
    radius_map = sqrt(x_grid.^2+y_grid.^2);
    radius_map(radius_map==0)=1;
    amp = (2*besselj(1,radius_map))./radius_map;
    psf = amp.^2;
    %{    
    range = pi/4;
    x = -range:.01:range;
    y = -range:.01:range;
    [x_grid,y_grid] = meshgrid(x,y);
    psf = sinc((x_grid.^2 + y_grid.^2).^(1/2)).^2;
    psf_resize = imresize(psf,[sizex,sizey]);
    psf_resize = psf_resize ./ sum(psf_resize(:));
    %}
end