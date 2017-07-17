function [image] = imshowCNN(img, scores)

    %% Visualize the result
    % Copied from https://github.com/vlfeat/matconvnet-fcn/blob/master/fcnTest.m#L220 
    % First create the colour map for it
    N=21;
    cmap = zeros(N,3);
    for i=1:N
      id = i-1; r=0;g=0;b=0;
      for j=0:7
        r = bitor(r, bitshift(bitget(id,1),7 - j));
        g = bitor(g, bitshift(bitget(id,2),7 - j));
        b = bitor(b, bitshift(bitget(id,3),7 - j));
        id = bitshift(id,-3);
      end
      cmap(i,1)=r; cmap(i,2)=g; cmap(i,3)=b;
    end
    cmap = cmap / 255;

    % Display the image and it's segmentation side by side
    [~, predicted_labels] = max(scores, [], 3);
    figure(234);
    subplot(2,2,1);
    imshow(img);

    subplot(2,2,2);
    imgClusters = image(uint8(predicted_labels-1)) ;
    title('clusters') ;
    colormap(cmap) ;
    imshow(im);
    
    
    subplot(2,2,3);
    imgContours = uint8(predicted_labels-1);
    [counts,x] = imhist(imgContours,16);
    T = otsuthresh(counts);
    bw = imbinarize(imgContours,T);
    [bw, threshold] = edge(bw, 'sobel');
    imgContoursColor = mtimes(imgContours, bw);
    imshow(imgContours);
    pause(1);

end