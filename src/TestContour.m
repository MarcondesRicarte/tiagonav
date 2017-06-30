% Test contour
I = imread('toyobjects.png');
imshow(I)
hold on
title('Original Image');

mask = false(size(I));
mask(230:480,1:600) = true;

visboundaries(mask,'Color','b');

bw = activecontour(I, mask, 100, 'edge');

visboundaries(bw,'Color','r'); 
title('Initial contour (blue) and final contour (red)');
