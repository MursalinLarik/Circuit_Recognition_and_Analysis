clc; close all; clear all;
im = imread('ckt.jpg');
im = rgb2gray(im);

im_num = imread('numbered.jpeg');
imshow(im_num);

figure, imshow(im); xlabel('Original Image');

%binarizing
lvl = graythresh(im);
imbw = imbinarize(im, lvl);
imbw = ~imbw;
figure, imshow(imbw); xlabel('Binarized Image');

%Image closing to fill gaps
se = strel('disk', 2);
closed = imclose(imbw, se);
figure, imshow(closed); xlabel('Closed image to fill gaps');

%Line removal (B/c sign were being touched with source ring) 
se = strel('disk', 7);
open = imopen(closed, se);
figure, imshow(open); xlabel('Opened image to break bridges');

%line erosion - components gets thinner but no connecting wires remain
se2 = strel('line', 6, 0);
noline = imerode(open, se2);
figure, imshow(noline); xlabel('Connecting Wire Erosion');

se3 = strel('line', 6, 90);
noline = imerode(noline, se3);
figure, imshow(noline); xlabel('Connecting Wire Erosion');

%smoothing out plus sign in source
se4 = strel('square', 5);
defined_image = imerode(noline, se4);
figure, imshow(defined_image); xlabel('Evening out plus sign');

%feature extraction of components

%Labeling the objects in image
oblabel = bwlabel(defined_image,8);

%Object extraction
im_array = [];
a = oblabel;
total_pixels = numel(oblabel);
for total_objects = 1:max(max(oblabel))
    for i = 1:total_pixels
        if oblabel(i) == total_objects
            a(i) = 1;
        else
            a(i) = 0;
        end
    end
    im_array = cat(3,im_array,a);
end

template_holes = load('holes.mat');

% Finding Holes in test data
figure;
holes = [];
for i = 1:size(im_array, 3)
    A = im_array(:,:,i);
    A = im2bw(A);
    [a,b] = size(A);
    ch = bwconvhull(A);
    B = zeros(a,b);
    B(ch) = 1;
    B(A) = 0;
    BW = bwareaopen(B,2);
    se = strel('disk', 1);
    bwopen = imopen(BW, se);
    subplot (4,2,i*2-1), imshow(A); xlabel('Original Image');
    subplot (4,2,i*2), imshow(bwopen); xlabel('Convex Hull Superimposed on Original Image');
    openedlabel = bwlabel(bwopen);
    maxholes = max(max(openedlabel));
    holes = [holes maxholes];
end
label_array = ["Circle", "Minus", "Plus", "Resistor"];

identified_objects = [];

test_label = [];
for i=1:length(holes)
    a = find(template_holes.holes == holes(i));
    identified_objects = [identified_objects label_array(a)];
end
% finding centroids
position = [];
stat = regionprops(defined_image,'centroid');
figure, imshow(defined_image); hold on;
for ii = 1: numel(stat)
    plot(stat(ii).Centroid(1),stat(ii).Centroid(2),'ro');
    position = [position; stat(ii).Centroid(1) stat(ii).Centroid(2)];
end
title('Centroids');

% Determining polarity
if stat(3).Centroid(1) > stat(1).Centroid(1)
    polarity = 'clockwise'
else
    polarity = 'anticlockwise'
end

position = [position; stat(3).Centroid(1) + 30,stat(3).Centroid(2) - 30]
box_color = {'green','green','green','green', 'red'};
labels = {'Source', '', '', 'Resistor', polarity};

RGB = insertText(im,position,labels,'FontSize',18,'BoxColor',...
    box_color,'BoxOpacity',0.4,'TextColor','white');
figure, imshow(RGB)



