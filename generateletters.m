clear all; clc; close all;

font1 = 'Arial Bold Italic' ;
font2 = 'Calibri Bold Italic';
font3 = 'Cambria Bold Italic'  ;
font4 = 'Constantia Bold Italic' ;
font5 = 'Segoe UI Bold Italic' ;  
font6 = 'Trebuchet MS Bold Italic' ;

fontmin = 1;
fontmax = 6;

pos1 = 0;
pos2 = 42;

xmin = 0;
xmax = 250;

ymin = 0;
ymax = 80;

targetvals = [];

for i = 1:50
    
    str = char(randsample(['A':'Z'], 4, true)); 
    str = replace(str, '', ' ');
    
    img = uint8(linspace(170, 255, 200));
    img = repmat(img, [50, 1]);

    r = (pos2-pos1).*rand(1) + pos1;
    fontnum = round((fontmax-fontmin).*rand(1) + fontmin);
    
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
    end

    I = imnoise(I, 'gaussian');
    I = imnoise(I, 'salt & pepper');
    
    for k = 1:fix(3*rand(1)+1)
        x = (xmax-xmin).*rand(2,1) + xmin;
        y = (ymax-ymin).*rand(2,1) + ymin;
        I = insertShape(I, 'Line', [x, y], 'Color', [47,79,79], 'LineWidth', floor(1+2*rand(1)));
    end
    
    imshow(I);
    
    targetvals = [targetvals; str]
    imwrite(I, strcat('newgeneratedletters/',string(i),'.jpg'));

end

