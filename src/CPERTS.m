clear;

%% Parameter of experiment
fdir = '../dataset/iso/';
lens_x = 10; % number of lenslet
lens_y = 10;
start_dep = 150;
end_dep = 150;
step_dep = 1;
pitch = 2;   % pitch of lenslet
sx = 36;     % sensor size of horizontal axis
focal_length = 50;  % focal length of main lens
filter = 2; % 1:average, 2:psf, 3:gaussian, 4:log

%% import elemental image
infile=[fdir 'merged_image.png'];    outfile=[fdir, 'CPERTS/'];
mkdir(outfile);
ei=uint8(imread(infile));  [v h d]=size(ei);
eny = v/lens_y; enx = h/lens_x; 
% Calculate real focal length
f_ratio=36/sx;          % focal length ratio compared with Full frame camera
sy = sx * (v/h);
F=focal_length*f_ratio;       % Effective focal length

%% perts
time=[];
mspace=[];

% Reconstruction
for dep=start_dep:step_dep:end_dep
    display(['----- Processing is started at ', num2str(dep), 'mm display plane. -----']);
    tic;
    min_space = 0;
    x=dep*sx/F;   % projection area for each elemental image
    y=dep*sy/F;
    xe=x/enx;   % projection area for each pixel
    ye=y/eny;
    % x and y directional matrix
    x_v=1:h;    y_v=1:v;
    % marginal floating point for convenience of computation
    fp_x=1/(2^((lens_x-1)/2));    
    fp_y=1/(2^((lens_y-1)/2));
    % calculate the position value in the x and y directions
    px=(xe.*((x_v-enx.*floor(x_v./(enx+fp_x)))-0.5)) + (pitch.*floor(x_v./(enx+fp_x)));    
    py=(ye.*((y_v-eny.*floor(y_v./(eny+fp_y)))-0.5)) + (pitch.*floor(y_v./(eny+fp_y)));
    % Sorting the position of projected pixel on reconstruction plane in x and y directions
    [sort_x, sort_xi]=sort(px);    
    [sort_y, sort_yi]=sort(py);
    % Calculation : Minimum space (Minimum space will be 1px distance in reconstructed image)
    dx = diff(sort_x);
    dy = diff(sort_y);
    min_space = min([dx dy])
    
    % pixel rearrangement
    temp=ei(:,sort_xi,:);
    img=temp(sort_yi,:,:);  %img is sort image
    
    dx = [dx 0];
    dy = [dy 0];
    % Calculation : Pixel Size on the Projection Plane
    pixel_x = round(xe/min_space);
    pixel_y = round(ye/min_space);
    % Estimation : Projection plane's size [px]
    Ix = round(sum(dx./min_space))+pixel_x;
    Iy = round(sum(dy./min_space))+pixel_y;
    % Padding size
    Padx = round((Ix-h)/2);
    Pady = round((Iy-v)/2);
    temp = padarray(ei,[Pady,Padx]); %padding elemental image
    [Iy,Ix,c] = size(temp);
    % Calculation : pixel's position on projection plane
    sort_outx = uint16(ones(1,Ix));
    sort_outy = uint16(ones(1,Iy));
    pos_x = uint16(round(sort_x./min_space));
    pos_y = uint16(round(sort_y./min_space));
    for x=1:h
        sort_outx(pos_x(x)) = sort_xi(x) + Padx ;
    end
    for y=1:v
        sort_outy(pos_y(y)) = sort_yi(y) + Pady ;
    end
    temp = temp(:,sort_outx,:);
    temp = temp(sort_outy,:,:);     % Now temp is Projection Plane's Image

    % Convolution PSF or other filter
    div = 1;
    switch filter
        case 1 
            fname = 'avg';
            f = fspecial('average', [pixel_y,pixel_x]);
            f_div = fspecial('average', [round(pixel_y/div),round(pixel_x/div)]);
        case 2 
            fname = 'psf';
            f = PSF_kernel(round(pixel_y),round(pixel_x));
            f_div = PSF_kernel(round(pixel_y/div),round(pixel_x/div));
        case 3 
            fname = 'gause';
            f = fspecial('gaussian', [pixel_y,pixel_x],sqrt(mean([pixel_y pixel_x])));
            f_div = fspecial('gaussian', [round(pixel_y/div),round(pixel_x/div)],sqrt(mean([pixel_y pixel_x])));
        case 4
            fname = 'log';
            f = fspecial('log', [pixel_y,pixel_x]);
            f_div = fspecial('log', [round(pixel_y/div),round(pixel_x/div)]);
    end
    %intensity = single(ones(Iy+round(pixel_y/div)-1,Ix+round(pixel_x/div)-1).*(round(pixel_y/div)*round(pixel_x/div)));
    intensity = conv2(single(rgb2gray(temp)>0),f);
    intensity(intensity==0)=1;
    %temp = imresize(temp,1/div);
    temp = im2single(temp);
    temp2(:,:,1) = conv2(temp(:,:,1),f_div);
    temp2(:,:,2) = conv2(temp(:,:,2),f_div);
    temp2(:,:,3) = conv2(temp(:,:,3),f_div);

    [a, b] = size(temp2(:,:,1));
    %intensity = imresize(intensity,[a b]);
    temp2 = temp2./repmat(intensity,1,1,3);
    %}

    elapse=toc
    time=[time elapse];
    mspace =[mspace min_space];
    Shx = round((enx*lens_x*pitch*F)/(sx*dep));
    Shy = round((eny*lens_y*pitch*F)/(sy*dep));
    CIIR_x = enx*lens_x+(lens_x-1)*Shx;
    CIIR_y = eny*lens_y+(lens_y-1)*Shy;

    imwrite(imresize(temp2,[CIIR_y CIIR_x]), [outfile, num2str(dep), 'mm_div_', num2str(round(div)), '_', fname, '.png']);
    display(['----- Processing is completed ----']);
    clear temp
    clear intensity
    clear temp2
end
csvwrite([outfile 'time.csv'],time);
csvwrite([outfile 'min.csv'],mspace);
