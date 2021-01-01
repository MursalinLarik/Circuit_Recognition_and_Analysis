clc; close all; 
im = imread('numbered.jpeg');
im = rgb2gray(im);
% figure, imshow(im); xlabel('Original Image');

%binarizing
lvl = graythresh(im);
imbw = imbinarize(im, lvl);
imbw = ~imbw;
% figure, imshow(imbw); xlabel('Binarized Image');

%Image closing to fill gaps
se = strel('disk', 2);
closed = imclose(imbw, se);
% figure, imshow(closed); xlabel('Closed image to fill gaps');

%Line removal (B/c sign were being touched with source ring) 
se = strel('disk', 4);
open = imopen(closed, se);
% figure, imshow(open); xlabel('Opened image to break bridges');

%line erosion - components gets thinner but no connecting wires remain
se2 = strel('line', 6, 0);
noline = imerode(open, se2);
% figure, imshow(noline); xlabel('Connecting Wire Erosion');

se3 = strel('line', 6, 90);
noline = imerode(noline, se3);
% figure, imshow(noline); xlabel('Connecting Wire Erosion');

%smoothing out plus sign in source
se4 = strel('square', 3);
defined_image = imerode(noline, se4);
% figure, imshow(defined_image); xlabel('Evening out plus sign');

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
sia = size(im_array,3);
for i = 1:sia
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
    s1 = subplot (sia,2,i*2-1), imshow(A); xlabel('Original Image');
    s2 = subplot (sia,2,i*2), imshow(bwopen); xlabel('Convex Deficiencies');
    openedlabel = bwlabel(bwopen);
    maxholes = max(max(openedlabel));
    holes = [holes maxholes];
end


label_array = ["Circle", "Minus", "Plus", "Resistor"];
identified_objects = [];

for i=1:length(holes)
    a = find(template_holes.holes == holes(i));
    identified_objects = [identified_objects label_array(a)];
end

% finding centroids and bounding boxes
stat = regionprops(defined_image,'centroid','BoundingBox');
figure, imshow(defined_image); hold on;

%images of exttacted components
extracted_comps = {};
centroids = [];
for ii = 1: numel(stat)
    centroids = [centroids; stat(ii).Centroid(1),stat(ii).Centroid(2)]
    plot(stat(ii).Centroid(1),stat(ii).Centroid(2),'ro');
    hold on
    BB = stat(ii).BoundingBox;
    rectangle('Position', [BB(1)-10,BB(2)-10,BB(3)+15,BB(4)+15],'EdgeColor','r','LineWidth',2);
    cropped = imcrop(defined_image, [BB(1)-10,BB(2)-10,BB(3)+15,BB(4)+15]);
    extracted_comps{end+1} = cropped;
end
title('Centroids');

% Determining polarity
if stat(3).Centroid(1) > stat(1).Centroid(1) %comparing plus and cicle center x positions
    polarity = 'positive'
else
    polarity = 'negative'
end

nums = [];
number_extracted = {};
for i=1:numel(stat)
    if holes(i) == 2
        nums = [nums; stat(i).Centroid(1) stat(i).Centroid(2)];
        resized = imresize(cell2mat(extracted_comps(i)), [20,20]);
        rotated  = imrotate(resized, 90);
        number_extracted{end+1} = rotated;
    end
end

% preddd = ML(cell2mat(number_extracted(1)));

% Associating numbers with objects
% extracted_comps - images of extracted objects
% defined_image - image of separate components
% centroids - matrix of component locations
% input - integer

integer = [2 6];

ckt_element_pos = [];
for j=1:numel(stat)
    if holes(j) == 2 %checking if number
        num_pos = [centroids(j,1), centroids(j,2)] %positions of centroids of numbers in the image
        norms = [];
        for k = 1:numel(stat)
            norms = [norms norm(num_pos - centroids(k,:))]
        end
        index_of_min = find(norms == min(norms))
        ckt_element_pos = [ckt_element_pos; centroids(index_of_min,:)];
    end
end

% we have the circuit element positions corresponding to the closest
% numbers
for i = 1:length(ckt_element_pos)
    for j=1:length(centroids)
        if norm(ckt_element_pos(1,:) - centroids(j,:)) == 0
            src_val = integer(1);
        end
        if norm(ckt_element_pos(2,:) - centroids(j,:)) == 0
            res_val = integer(2);
        end
    end
end

% circuit values src_val and res_val
figure;
imshow('numbered.jpeg');
str = strcat('I = ',num2str(src_val/res_val),' A')
text(400,100,str,'Color','red','FontSize',14)
