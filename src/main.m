% config
clear all;

connect = 'tiago';      % ['turtle','tiago'] 
source = 'file';        % ['file', 'simulator']
sourceDir = 'videos\amb1low.mp4';  % ['videos\amb1low.mp4', 'videos\amb2low.mp4', 'videos\amb1high.mp4', 'videos\amb1high.mp4']
NETWORK_PATH = 'matconvnet-1.0-beta24\models'; 
NET_NAME = 'pascal-fcn8s-dag.mat'; % ['pascal-fcn8s-dag.mat', 'pascal-fcn16s-dag.mat', 'pascal-fcn32s-dag.mat', 'pascal-fcn8s-tvg-dag.mat']
DATA_DIR = fullfile('data', 'images');
RESULT_DIR = fullfile('data', 'unaries');


imsub = 0;
depthsub = 0;
pointsub = 0;
if strcmp(source,'simulator')
    if strcmp(connect,'tiago') 
        % Connect  TIAGo robot
        setenv('ROS_MASTER_URI','http://192.168.3.129:11311')
        setenv('ROS_IP','192.168.254.1')
        rosinit
    elseif strcmp(connect,'turtle')
        %Tutllebot
        ipaddress = '192.168.3.133';
        rosinit(ipaddress);
    end;

    % Get image
    imsub = 0;
    if ismember('/xtion/rgb/image_raw', rostopic('list'))
        imsub = rossubscriber('/xtion/rgb/image_raw');
    end;

    % Get depth image
    depthsub = 0;
    if ismember('/xtion/depth_registered/image_raw', rostopic('list'))
        depthsub = rossubscriber('/xtion/depth_registered/image_raw');
    end;

    % Get cloud point
    pointsub = 0;
    if ismember('/xtion/depth_registered/points', rostopic('list'))
        pointsub = rossubscriber('/xtion/depth_registered/points');
    end;
end;


[net,normalize_fn] = initializeCNN(NETWORK_PATH, NET_NAME);
for i=0:10 % zero time
    video = VideoReader(sourceDir);
    video.CurrentTime = i;
    image = readFrame(video);
    
    scores = executeCNN(image,net,normalize_fn);
    imshowCNN(image, scores);    
end;



for i=1:50
    load ([sourceDir, num2str(i), '.mat']);
    
    % plot image
    if imsub ~= 0
        image = receive(imsub);
        figure
        imshow(readImage(image));
    end;


    % plot depth image
    if depthsub ~= 0
        depthImage = receive(depthsub);
        figure
        imshow(readImage(depthImage));
    end;


    % plot cloud points
    if pointsub ~= 0
        ptcloud = receive(pointsub);
        xyz = readXYZ(ptcloud);
        xyzvalid = xyz(~isnan(xyz(:,1)),:);
        xyzselected = xyz(xyz(:,3)< 2,:);
        %rgb = readRGB(ptcloud);
        scatter3(ptcloud);

        %scatter(xyzselected(:,1),xyzselected(:,2))
        pcobj = pointCloud(readXYZ(ptcloud),'Color',uint8(255*readRGB(ptcloud)));


        % parser cordinates
        minX = min(xyz(:,1));
        maxX = max(xyz(:,1));
        minY = min(xyz(:,2));
        maxY = max(xyz(:,2));
        minZ = min(xyz(:,3));
        maxZ = max(xyz(:,3));

        sizeX = - minX + maxX;
        sizeY = - minY + maxY;
        sizeZ = minZ + maxZ;

        pcshow(pcobj)
        roi = [0,inf;0,inf;0,2.5];
        indices = findPointsInROI(pcobj, roi);
        obj = select(pcobj,indices);

        pcshow(pcobj.Location,'r');
        hold on;
        pcshow(obj.Location,'g');
        hold off;

    end;
    
    imwrite(readImage(image),['image',int2str(i),'.png']);
    Segmentation(readImage(image),['imageContour',int2str(i),'.png']);
    close(gcf);
    scatter3(ptcloud);
    f = getframe(gca);
    im = frame2im(f);
    imwrite(im,['ptcloud',int2str(i),'.png']);
    
end;



% Segmentation
seg = readImage(depthImage);
seg(isnan(readImage(depthImage))) = 255; % white
clearImage = seg;
imshow(seg);
seg = edge(seg,'canny');
[H,theta,rho] = hough(seg);
P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
lines = houghlines(seg,theta,rho,P,'FillGap',5,'MinLength',7);

% Plot Lines
figure, imshow(readImage(image)), hold on
max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',5,'Color','red');
   
   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end
% highlight the longest line segment
plot(xy_long(:,1),xy_long(:,2),'LineWidth',5,'Color','red');



rosshutdown