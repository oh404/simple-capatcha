clc; clear all; close all; % cleaning all previous values

% loading target values;
targetvals = {'C','L','E','J';
'T','Z','O','B';
'R','R','J','W';
'Z','Z','E','W';
'E','B','I','K';
'M','L','R','R';
'B','B','R','K';
'F','Q','U','K';
'H','G','I','O';
'C','A','P','Q';
'R','L','B','K';
'A','W','N','L';
'O','I','J','A';
'A','B','B','U';
'W','F','I','D';
'U','F','Y','O';
'L','B','V','F';
'F','G','Y','Q';
'F','Z','J','F';
'F','L','I','T';
'N','R','A','U';
'H','X','Y','P';
'T','Q','U','F';
'K','V','P','B';
'J','N','M','H';
'G','G','O','X';
'Y','D','I','L';
'Z','W','H','X';
'L','C','K','I';
'G','U','O','V';
'X','E','B','A';
'A','H','A','A';
'L','A','G','R';
'H','S','J','H';
'N','L','Y','S';
'G','T','L','W';
'P','I','E','F';
'T','Y','W','P';
'R','F','O','C';
'H','G','N','A';
'G','T','P','Y';
'D','L','C','I';
'J','B','L','O';
'U','K','Z','O';
'N','T','X','E';
'F','D','A','G';
'F','L','N','U';
'M','I','L','S';
'P','E','H','F';
'O','M','D','E'};



%% TRAINING:

% loading train image:
I = imread('letters/letterstest.jpg');

% cleaning and making it BW:
BW = createMask(I);

% applying regionprops, numbering all objects with area higher than 50px:
[labels, number] = bwlabel(BW);
Istats = regionprops(labels);
Istats( [Istats.Area] < 50 ) = [];

% recording the number of objects:
num = length(Istats);

% recording 4 objects:
Ibox = floor( [Istats.BoundingBox] );
Ibox = reshape(Ibox, [4 num]);

% showing the image:
figure, imshow(BW); 
hold on
for k = 1 : num
    % for each of the object (digit) creating a subimage, and recording it
    % to separate image with 24x12 size. Drawing a boundingboxes of each
    % objects:
    rectangle('position', Ibox(:,k), 'edgecolor', 'r', 'LineWidth', 2);

    % calculating objects positions:
    col1 = Ibox(1, k);
    col2 = col1 + Ibox(3, k);
    row1 = Ibox(2, k);
    row2 = row1 + Ibox(4, k);
    
    % moving resized objects to TTraining matrix, for training on ANN:    
    subImage = BW(row1:row2, col1:col2);
    templateImageResized = imresize(subImage, [24 12]);
    
    TTraining(k,:) = templateImageResized(:)';
   
end
hold off

% TTarget, where all target values for training will be kept (A-Z):
TTarget = zeros(156,26);

for row = 1:26
    for col = 1:6
        TTarget( 6 * (row-1) + col, row ) = 1;
    end
end

% transposing to make the same-dimensioned:
TTraining = TTraining';
TTarget = TTarget';

% new ANN with 2 layers of 64-neurons each, logsig:
net = newff([zeros(288,1) ones(288,1)], [256 256 256 26], {'logsig' 'logsig' 'logsig' 'logsig'}, 'traingdx');
net = train(net, TTraining, TTarget); 


%% TRAINING

% testing on 20 images:
for i = 1:50
    % cleaning the buffer after each iteration:
    TPattern = [];
    subImage = [];
    subImageResized = [];
    
    % reading the image:
    I = imread(strcat('letters/',string(i),'.jpg'));
    % cleaning the image    
    BW = createMasktest(I);
    BW2 = imclearborder(BW, 4);
    
    % applying regionprops to number the objects (letters) with area > 50px:
    [labels, number] = bwlabel(BW2);
    Istats = regionprops(labels); 

    Istats( [Istats.Area] < 50 ) = [];
    num = length(Istats); 

    Ibox = floor( [Istats.BoundingBox] );
    Ibox = reshape(Ibox, [4 num]);
    
    % these two lines can be commented for faster running, without showing each image:
    figure
    imshow(BW2)
    hold on
    for k = 1 : num
        % drawing bouding boxes for each of the separate objects:
        rectangle('position', Ibox(:,k), 'edgecolor', 'r', 'LineWidth', 3);

        col1 = Ibox(1, k);
        col2 = col1 + Ibox(3, k);
        row1 = Ibox(2, k);
        row2 = row1 + Ibox(4, k);
        
        % keeping subimages:
        subImage = BW(row1:row2, col1:col2);
        subImageResized = imresize(subImage, [24 12]);

        % keepping patterns of the resized 24x12 images for recognition on
        % ANN:
        TPattern(k,:) = subImageResized(:)';
    end
    
    hold off
    
    % recognizing the images:
    TPattern = TPattern';
    Y = sim(net, TPattern);
    [value index] = max(Y);
    digits = index;
    results(i,:) = digits

end 

% replacing indices with letters:
res = int2letters(results)

%% Accuracy 
% comparting target values and recognized values:
a = res == targetvals;
% calulating accuracy by % with the number of correctly recognized digits
% by the total number of digits
acc = sum(sum(a))/numel(a);

disp('Accuracy:')
disp(acc);

%% Replacing letter indeces to 1-26 to letters A-Z:
function [res] = int2letters(results)
    letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    numbers = '1':'26';
    res = string(results);
    for i = 1:numel(numbers)
        res(res == numbers(i)) = letters(i);
    end
end

%% Masks from Color Tresholder

function [BW,maskedRGBImage] = createMask(RGB)
%createMask  Threshold RGB image using auto-generated code from colorThresholder app.
%  [BW,MASKEDRGBIMAGE] = createMask(RGB) thresholds image RGB using
%  auto-generated code from the colorThresholder app. The colorspace and
%  range for each channel of the colorspace were set within the app. The
%  segmentation mask is returned in BW, and a composite of the mask and
%  original RGB images is returned in maskedRGBImage.

% Auto-generated by colorThresholder app on 29-Nov-2021
%------------------------------------------------------


% Convert RGB image to chosen color space
I = rgb2hsv(RGB);

% Define thresholds for channel 1 based on histogram settings
channel1Min = 0.004;
channel1Max = 0.000;

% Define thresholds for channel 2 based on histogram settings
channel2Min = 0.000;
channel2Max = 1.000;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 0.000;
channel3Max = 0.876;

% Create mask based on chosen histogram thresholds
sliderBW = ( (I(:,:,1) >= channel1Min) | (I(:,:,1) <= channel1Max) ) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
BW = sliderBW;

% Initialize output masked image based on input image.
maskedRGBImage = RGB;

% Set background pixels where BW is false to zero.
maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

end


%% for test

function [BW,maskedRGBImage] = createMasktest(RGB)
%createMask  Threshold RGB image using auto-generated code from colorThresholder app.
%  [BW,MASKEDRGBIMAGE] = createMask(RGB) thresholds image RGB using
%  auto-generated code from the colorThresholder app. The colorspace and
%  range for each channel of the colorspace were set within the app. The
%  segmentation mask is returned in BW, and a composite of the mask and
%  original RGB images is returned in maskedRGBImage.

% Auto-generated by colorThresholder app on 29-Nov-2021
%------------------------------------------------------


% Convert RGB image to chosen color space
I = rgb2hsv(RGB);

% Define thresholds for channel 1 based on histogram settings
channel1Min = 0.000;
channel1Max = 0.000;

% Define thresholds for channel 2 based on histogram settings
channel2Min = 0.000;
channel2Max = 1.000;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 0.000;
channel3Max = 0.322;

% Create mask based on chosen histogram thresholds
sliderBW = ( (I(:,:,1) >= channel1Min) | (I(:,:,1) <= channel1Max) ) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
BW = sliderBW;

% Initialize output masked image based on input image.
maskedRGBImage = RGB;

% Set background pixels where BW is false to zero.
maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

end
