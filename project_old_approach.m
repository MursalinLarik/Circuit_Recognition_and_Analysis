%% Training Data
clc; close all; clear all;
im = imread('symbols.jpeg');
im = rgb2gray(im);

%binarizing
lvl = graythresh(im);
imbw = im2bw(im, lvl);
imbw = ~imbw;
% figure, imshow(imbw);

%Image closing to fill gaps
se = strel('disk', 2);
closed = imclose(imbw, se);
% figure, imshow(closed);

% %Line removal (B/c sign were being touched with source ring)
% se = strel('disk', 7);
% open = imopen(closed, se);
% % figure, imshow(open);

% %line erosion - components gets thinner but no connecting wires remain
% se2 = strel('line', 6, 0);
% noline = imerode(open, se2);
% % figure, imshow(noline)

% se3 = strel('line', 6, 90);
% noline = imerode(noline, se3);
% % figure, imshow(noline);

% %smoothing out plus sign in source
% se4 = strel('square', 5);
% defined_image = imerode(noline, se4);
% % figure, imshow(defined_image);

%feature extraction of components

%Labeling the objects in image
oblabel = bwlabel(closed,8);

%Object extraction
im_array = [];
a = oblabel;
total_pixels = numel(oblabel)
for total_objects = 1:max(max(oblabel))
    total_objects
    for i = 1:total_pixels
        if oblabel(i) == total_objects
            a(i) = 1;
        else
            a(i) = 0;
        end
    end
    im_array = cat(3,im_array,a);
end

y = ceil(total_objects/2);
figure,
for i = 1:total_objects;
    subplot(y,y,i)
    ab = im_array(:,:,i);
    imshow(ab)
    hold on
end

sig_array = {};
y = ceil(total_objects/2)
figure,
for i = 1:total_objects
    % signature drawing
    im_res = imfill(imfill(im_array(:,:,i)));
    % im_res = fill1;
    % im_res = bwskel(im2bw(im_res));
    %     figure, imshow(im_res);
    bound = boundaries(im_res,4);
    b = bound{1};
%     [X,Y] = size(im_res);
    %     FinalImage = bound2im(b,X,Y,min(b(:,1)),min(b(:,2)));
    %     figure, imshow(FinalImage);
    [st, angle]=signature(b);
    sig = [angle, st];
    sig_resized=imresize(sig,[360,2]);
    sig_array{end+1} = sig_resized
    subplot(y,y,i)
    plot(sig_resized(:,1), sig_resized(:,2)); xlabel('');
end

[circ, minus, plus, res] = sig_array{:};
save('circle.mat', 'circ');
save('minus.mat', 'minus');
save('plus.mat', 'plus');
save('resistor.mat', 'res');

%% Test Data

clc; close all; clear all;
im = imread('ckt.jpg');
im = rgb2gray(im);

%binarizing
lvl = graythresh(im);
imbw = imbinarize(im, lvl);
imbw = ~imbw;
% figure, imshow(imbw);

%Image closing to fill gaps
se = strel('disk', 2);
closed = imclose(imbw, se);
% figure, imshow(closed);

%Line removal (B/c sign were being touched with source ring) 
se = strel('disk', 7);
open = imopen(closed, se);
% figure, imshow(open);

%line erosion - components gets thinner but no connecting wires remain
se2 = strel('line', 6, 0);
noline = imerode(open, se2);
% figure, imshow(noline)

se3 = strel('line', 6, 90);
noline = imerode(noline, se3);
% figure, imshow(noline);

%smoothing out plus sign in source
se4 = strel('square', 5);
defined_image = imerode(noline, se4);
% figure, imshow(defined_image);

%feature extraction of components

%Labeling the objects in image
oblabel = bwlabel(defined_image,8);

%Object extraction
im_array = [];
a = oblabel;
total_pixels = numel(oblabel)
for total_objects = 1:max(max(oblabel))
        total_objects
    for i = 1:total_pixels
        if oblabel(i) == total_objects
            a(i) = 1;
        else
            a(i) = 0;
        end
    end
    im_array = cat(3,im_array,a);
end

y = ceil(total_objects/2);
% figure,
for i = 1:total_objects;
%     subplot(y,y,i)
    ab = im_array(:,:,i);
%     imshow(ab)
%     hold on
end

% figure;
y = ceil(total_objects/2);
% signature drawing
sigs = {};
% array of boundary signatures (1-cricle, 2-minus, 3-
for i=1:total_objects
    bound = boundaries(im_array(:,:,i));
    b = bound{1};
    [st, angle] = signature(b);
    sig = [angle, st];
    sig_resized = imresize(sig,[360,2]);
    sigs{end+1} = sig_resized
%     subplot(y,y,i)
%     plot(sig_resized(:,1), sig_resized(:,2)); xlabel('angle'); xlim([0 360]); ylim([0 100]);
end

circ = load('circle.mat');
min = load('minus.mat');
plus = load('plus.mat');
resistor = load('resistor.mat');

for i = 1
    a = sigs{i};
    yval = a(:,2);
    c = circ.circ(:,2);
    m = min.minus(:,2);
    p = plus.plus(:,2);
    r = resistor.res(:,2);
    c1 = crosscorr(yval, c)
    m1 = crosscorr(yval, m)
    p1 = crosscorr(yval, p)
    r1 = crosscorr(yval, r)
end
figure,
x = 1:41;
x = transpose(x);
plot(x, c1)
hold on
plot(x, m1)
hold on
plot(x, p1)
hold on
plot(x, r1)

legend('circle','minus','plus','resistor', 'Location' , 'best')
    
    