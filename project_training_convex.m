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

%Holes in training data
figure
holes = [];
for i = 1:size(im_array, 3)
    A = im_array(:,:,i);
    A = im2bw(A);
    [a,b] = size(A);
    ch = bwconvhull(A);
    B = zeros(a,b);
    B(ch) = 1;
    B(A) = 0;
    BW = bwareaopen(B,10);
    se = strel('disk', 3);
    bwopen = imopen(BW, se);
    subplot (4,2,i*2-1), imshow(A); xlabel('Original Image');
    subplot (4,2,i*2), imshow(bwopen); xlabel('Convex Deficiencies');
    openedlabel = bwlabel(bwopen);
    maxholes = max(max(openedlabel));
    holes = [holes maxholes];
end
label_array = ['Circle', 'Minus', 'Plus', 'Resistor'];

save('holes.mat', 'holes');
save('labels.mat', 'label_array');


