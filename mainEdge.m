function [] = mainEdge(imname)
% name of the input file
%imname = 'tobolsk.jpg';
%imname = 'nativity.jpg';
%imname = 'monastery.jpg';
%imname = 'cathedral.jpg';

% read in the image
fullim = imread(imname);

% convert to double matrix (might want to do this later on to same memory)
fullim = im2double(fullim);

% compute the height of each part (just 1/3 of total)
height = floor(size(fullim,1)/3);
width = size(fullim,2);
x_min = 0.1;
x_max = 0.95;
y_min = 0.1;
y_max = 0.99;
% separate clor channels
B = fullim(1:height,:);
B = imcrop(B, [floor(width * x_min), floor(height * y_min), round(width * (x_max - x_min)), round(height * (y_max - y_min)) ]);
G = fullim(height+1:height*2,:);
G = imcrop(G, [floor(width * x_min), floor(height * y_min), round(width * (x_max - x_min)), round(height * (y_max - y_min)) ]);
R = fullim(height*2+1:height*3,:);
R = imcrop(R, [floor(width * x_min), floor(height * y_min), round(width * (x_max - x_min)), round(height * (y_max - y_min)) ]);

% Align the images
% Functions that might be useful to you for aligning the images include: 
% "circshift", "sum", and "imresize" (for multiscale)
[xShiftG, yShiftG, xShiftR, yShiftR] = align(R, G, B);

G = circshift(G, [xShiftG, yShiftG]);
R = circshift(R, [xShiftR, yShiftR]);

%G = zeros(size(G));
result = cat(3, R, G, B);
[cropped] = autoCrop(result);

fileName = imname(1:end - 4);
fileNameOriginal = strcat(fileName, 'Colored.jpg');
imwrite(result, fileNameOriginal);
fileNameCropped = strcat(fileName, 'Cropped.jpg');
imwrite(cropped, fileNameCropped);

figure(1);
imshow(result);
figure(2);
imshow(cropped);

% save result image
%imwrite(colorim,['result-' imname]);
end

%% align method
function [xShiftG, yShiftG, xShiftR, yShiftR] = align(R, G, B)
threshold = 95000;
if size(R, 1) * size(R, 2) < threshold
    searchRadius = 15;
    B_edge = edge(B, 'Canny') ./ 2;
    B_normal = reshape(B_edge, 1, []);
    currValG = 0;
    xShiftG = 0;
    yShiftG = 0;
    
    currValR = 0;
    xShiftR = 0;
    yShiftR = 0;
    for a = -searchRadius:searchRadius
        for b = -searchRadius:searchRadius
            G_shifted = circshift(G, [a, b]);
            G_edge = edge(G_shifted, 'Canny') ./ 2;
            G_shifted = reshape(G_edge, 1, []);
            G_dot = dot(B_normal, G_shifted);
            if G_dot > currValG
                currValG = G_dot;
                xShiftG = a;
                yShiftG = b;
            end
            
            R_shifted = circshift(R, [a, b]);
            R_edge = edge(R_shifted, 'Canny') ./ 2;
            R_shifted = reshape(R_edge, 1, []);
            R_dot = dot(B_normal, R_shifted);
            if R_dot > currValR
                currValR = R_dot;
                xShiftR = a;
                yShiftR = b;
            end
        end
    end
else
    scale = 0.25;
    searchRadius = 5;
    R_small = imresize(R, scale);
    G_small = imresize(G, scale);
    B_small = imresize(B, scale);
    [OldxShiftG, OldyShiftG, OldxShiftR, OldyShiftR] = align(R_small, G_small, B_small);
    OldxShiftG = OldxShiftG / scale;
    OldyShiftG = OldyShiftG / scale;
    OldxShiftR = OldxShiftR / scale;
    OldyShiftR = OldyShiftR / scale;
    B_edge = edge(B, 'Canny') ./ 2;
    B_normal = reshape(B_edge, 1, []);
    currValG = 0;
    xShiftG = 0;
    yShiftG = 0;
    
    currValR = 0;
    xShiftR = 0;
    yShiftR = 0;
    for a = -searchRadius:searchRadius
        for b = -searchRadius:searchRadius
            G_shifted = circshift(G, [OldxShiftG + a, OldyShiftG + b]);
            G_edge = edge(G_shifted, 'Canny') ./ 2;
            G_shifted = reshape(G_edge, 1, []);
            G_dot = dot(B_normal, G_shifted);
            if G_dot > currValG
                currValG = G_dot;
                xShiftG = OldxShiftG + a;
                yShiftG = OldyShiftG + b;
            end
            
            R_shifted = circshift(R, [OldxShiftR + a, OldyShiftR + b]);
            R_edge = edge(R_shifted, 'Canny') ./ 2;
            R_shifted = reshape(R_edge, 1, []);
            R_dot = dot(B_normal, R_shifted);
            if R_dot > currValR
                currValR = R_dot;
                xShiftR = OldxShiftR + a;
                yShiftR = OldyShiftR + b;
            end
        end
    end
end
end

%% Autocrop method
function [cropped] = autoCrop(input)
resultGray = rgb2gray(input);
scale = 1/8;
edgeMinPercentage = 0.5;
if size(resultGray, 1) * size(resultGray, 2) > 950000
    resultGray = imresize(resultGray, scale);
end
resultGray = edge(resultGray, 'Canny');
% figure(2);
% imshow(resultGray);
% dlmwrite('edge.txt', resultGray);
xmin = 1;
for a = 2:floor(size(resultGray, 2) * 0.1)
    count = 0;
    for b = 1:size(resultGray, 1)
        if resultGray(b, a) == 1 || resultGray(b, a - 1) == 1 || resultGray(b, a + 1) == 1
            count = count + 1;
        end
    end
    if count > size(resultGray, 1) * edgeMinPercentage
        xmin = a;
    end
end

xmax = size(resultGray, 2);
for a = size(resultGray, 2) - 1:-1:floor(size(resultGray, 2) * 0.95);
    count = 0;
    for b = 1:size(resultGray, 1)
        if resultGray(b, a) == 1 || resultGray(b, a - 1) == 1 || resultGray(b, a + 1) == 1
            count = count + 1;
        end
    end
    if count > size(resultGray, 1) * edgeMinPercentage
        xmax = a;
    end
end

ymin = 1;
for a = 2:floor(size(resultGray, 1) * 0.05)
    count = 0;
    for b = 1:size(resultGray, 2)
        if resultGray(a, b) == 1 || resultGray(a - 1, b) == 1 || resultGray(a + 1, b) == 1
            count = count + 1;
        end
    end
    if count > size(resultGray, 2) * edgeMinPercentage
        ymin = a;
    end
end


ymax = size(resultGray, 1);
for a = size(resultGray, 1) - 1:-1:floor(size(resultGray, 1) * 0.95);
    count = 0;
    for b = 1:size(resultGray, 2)
        if resultGray(a, b) == 1 || resultGray(a - 1, b) == 1 || resultGray(a + 1, b) == 1
            count = count + 1;
        end
    end
    if count > size(resultGray, 2) * edgeMinPercentage
        ymax = a;
    end
end
if size(input, 1) * size(input, 2) > 950000
    xmin = xmin / scale;
    xmax = xmax / scale;
    ymin = ymin / scale;
    ymax = ymax / scale;
end
cropped = imcrop(input, [xmin, ymin, xmax - xmin, ymax - ymin]);
end