clear all; clc; close all;

% List of fonts that will be used to generate images:
font1 = 'Comic Sans MS Bold Italic';
font2 = 'Calibri Bold Italic';
font3 = 'Cambria Bold Italic'  ;
font4 = 'Consolas Bold Italic'  ; 
font5 = 'Constantia Bold Italic' ;
font6 = 'Courier New Bold Italic' ;  
font7 = 'Georgia Bold Italic' ;
font8 = 'Arial Bold Italic' ;

% constants for random number generations:
% font:
fontmin = 1;
fontmax = 8;

% positions of text on image:
pos1 = 0;
pos2 = 42;

% coordinates of lines (noise):
xmin = 0;
xmax = 250;

ymin = 0;
ymax = 80;

% generated images target values:
targetvals = [];

for i = 1:10
    % generating a string with random 4 digits from 0 to 9 and adding spaces:
    str = char(randsample(['0':'9'], 4, true)); 
    str = replace(str, '', ' ');
    
    % generating gray background line with gradient from 170 to 255, width 200:
    img = uint8(linspace(170, 255, 200));
    % repeating this gradient line and stretching the image to 50px:
    img = repmat(img, [50, 1]);

    r = (pos2-pos1).*rand(1) + pos1; % calculating position of the text
    fontnum = round((fontmax-fontmin).*rand(1) + fontmin); % random font number
    
    % inserting the generated string with specific font:
    switch fontnum
        case 1
            I = insertText(img, [r 0], str, 'FontSize', 30, 'Font', font1, 'BoxOpacity', 0);
        case 2
            I = insertText(img, [r 0], str, 'FontSize', 30, 'Font', font2, 'BoxOpacity', 0);
        case 3
            I = insertText(img, [r 0], str, 'FontSize', 30, 'Font', font3, 'BoxOpacity', 0);
        case 4
            I = insertText(img, [r 0], str, 'FontSize', 30, 'Font', font4, 'BoxOpacity', 0);
        case 5
            I = insertText(img, [r 0], str, 'FontSize', 30, 'Font', font5, 'BoxOpacity', 0);
        case 6
            I = insertText(img, [r 0], str, 'FontSize', 30, 'Font', font6, 'BoxOpacity', 0);
        case 7
            I = insertText(img, [r 0], str, 'FontSize', 30, 'Font', font7, 'BoxOpacity', 0);
        case 8
            I = insertText(img, [r 0], str, 'FontSize', 30, 'Font', font8, 'BoxOpacity', 0);
    end

    % applying gaussian and salt&pepper noise:
    I = imnoise(I, 'gaussian');
    I = imnoise(I, 'salt & pepper');
    
    % applying lines:     
    for k = 1:fix(3*rand(1)+1)
        x = (xmax-xmin).*rand(2,1) + xmin;
        y = (ymax-ymin).*rand(2,1) + ymin;
        I = insertShape(I, 'Line', [x, y], 'Color', [47,79,79], 'LineWidth', floor(1+2*rand(1)));
    end
    
    % showing the final image:
    imshow(I);
    
    % recording the target values:
    targetvals = [targetvals; str2num(str)]
    % saving the image:
    imwrite(I, strcat('newgeneradteddigits/',string(i),'.jpg'));

end

