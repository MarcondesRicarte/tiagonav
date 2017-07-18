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
    subplot(1,2,1);
    imshow(img);

    %try
    %    subplot(2,2,2);
    %    imgClusters = image(uint8(predicted_labels-1)) ;
    %    title('clusters') ;
    %    colormap(cmap);
    %    imshow(imgClusters);
    %end;
    
    subplot(1,2,2);
    imgContours = uint8(predicted_labels-1);
    [counts,x] = imhist(imgContours,16);
    T = otsuthresh(counts);
    bw = imbinarize(imgContours,T);
    [bw, threshold] = edge(bw, 'sobel');
    imgContoursColor = times(imgContours,uint8(bw));
    [B,L]= bwboundaries(bw);
    imshow(img)
    hold on
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2, 'Color', 'red')
    end
    pause(1);

    
    % Object geometry data
    Ilabel = bwlabel(bw);
    geometry.centroids = regionprops(Ilabel,'centroid');
    geometry.convexHull = regionprops(Ilabel,'ConvexHull');
    
    
    
end