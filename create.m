function [] = create(imname)
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
% separate color channels
B = fullim(1:height,:);
B = imcrop(B, [floor(width * 0.1), floor(height * 0.2), round(width * 0.85), round(height * 0.8) ]);
G = fullim(height+1:height*2,:);
G = imcrop(G, [floor(width * 0.1), floor(height * 0.2), round(width * 0.85), round(height * 0.8) ]);
R = fullim(height*2+1:height*3,:);
R = imcrop(R, [floor(width * 0.1), floor(height * 0.2), round(width * 0.85), round(height * 0.8) ]);

% Align the images
% Functions that might be useful to you for aligning the images include: 
% "circshift", "sum", and "imresize" (for multiscale)
[xShiftG, yShiftG, xShiftR, yShiftR] = align(R, G, B);

G = circshift(G, [xShiftG, yShiftG]);
R = circshift(R, [xShiftR, yShiftR]);
%%%%%aG = align(G,B);
%%%%%aR = align(R,B);
%G = zeros(size(G));
result = cat(3, R, G, B);
figure(1);
imshow(result);

% save result image
%imwrite(colorim,['result-' imname]);
end

%% align method
function [xShiftG, yShiftG, xShiftR, yShiftR] = align(R, G, B)
threshold = 95000;
if size(R, 1) * size(R, 2) < threshold
    searchRadius = 15;
    B_normal = reshape(B, 1, []);
    B_normal = B_normal ./ norm(B_normal);
    currValG = 0;
    xShiftG = 0;
    yShiftG = 0;
    
    currValR = 0;
    xShiftR = 0;
    yShiftR = 0;
    for a = -searchRadius:searchRadius
        for b = -searchRadius:searchRadius
            G_shifted = circshift(G, [a, b]);
            G_shifted = reshape(G_shifted, 1, []);
            G_dot = dot(B_normal, G_shifted ./ norm(G_shifted));
            if G_dot > currValG
                currValG = G_dot;
                xShiftG = a;
                yShiftG = b;
            end
            
            R_shifted = circshift(R, [a, b]);
            R_shifted = reshape(R_shifted, 1, []);
            R_dot = dot(B_normal, R_shifted ./ norm(R_shifted));
            if R_dot > currValR
                currValR = R_dot;
                xShiftR = a;
                yShiftR = b;
            end
        end
    end
%     G = circshift(G, [xShiftG, yShiftG]);
%     R = circshift(R, [xShiftR, yShiftR]);
%     %%%%%aG = align(G,B);
%     %%%%%aR = align(R,B);
%     
%     result = cat(3, R, G, B);
%     figure(1);
%     imshow(result);
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
    B_normal = reshape(B, 1, []);
    B_normal = B_normal ./ norm(B_normal);
    currValG = 0;
    xShiftG = 0;
    yShiftG = 0;
    
    currValR = 0;
    xShiftR = 0;
    yShiftR = 0;
    for a = -searchRadius:searchRadius
        for b = -searchRadius:searchRadius
            G_shifted = circshift(G, [OldxShiftG + a, OldyShiftG + b]);
            G_shifted = reshape(G_shifted, 1, []);
            G_dot = dot(B_normal, G_shifted ./ norm(G_shifted));
            if G_dot > currValG
                currValG = G_dot;
                xShiftG = OldxShiftG + a;
                yShiftG = OldyShiftG + b;
            end
            
            R_shifted = circshift(R, [OldxShiftR + a, OldyShiftR + b]);
            R_shifted = reshape(R_shifted, 1, []);
            R_dot = dot(B_normal, R_shifted ./ norm(R_shifted));
            if R_dot > currValR
                currValR = R_dot;
                xShiftR = OldxShiftR + a;
                yShiftR = OldyShiftR + b;
            end
        end
    end
%     G = circshift(G, [xShiftG, yShiftG]);
%     R = circshift(R, [xShiftR, yShiftR]);
%     %%%%%aG = align(G,B);
%     %%%%%aR = align(R,B);
%     
%     result = cat(3, R, G, B);
%     figure(1);
%     imshow(result);
end
end