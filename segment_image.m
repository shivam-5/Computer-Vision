%{
   The idea is to identify edges in blurred initial image followed by
   repeated dilations and erosions with constant blurring to remove noises
   and keep relvant features and detecting the edges of relevant content.

    Step 1: Blurring the image with gaussian filter
    Step 2: Convert to grayscale
    Step 3: Detect edges using Laplacian of Gaussian method
    Step 4: Repeat next 3 steps 4 times
    Step 5: Blur with gaussian filter
    Step 6: Dilate the image with three line based structuring elements
        with 0,45,90 degree angles
    Step 7: Erode the image with three line based structuring elements
        with 0,45,90 degree angles
    Step 8: Detect edges using Canny edge detector

References: 
    1. The implementation of LOG is picked from my a part of my own 
        implementation as per instructions in Question3 of Coursework 4
    2. The idea of dilation and erosion with multi line was picked from:
        https://uk.mathworks.com/help/images/detecting-a-cell-using-image-segmentation.html
        However extra 45 degree line element and the 4 time loop has been
        added as per current requirement.
%}

function [seg] = segment_image(I)
    blur = imgaussfilt(I,2);
    I = rgb2gray(blur);
    logedge = edge_recognition_log(I);
    
    se0 = strel("line",2,0);
    se90 = strel("line",2,90);
    se45 = strel("line",2,45);
    for i = 1:4
        blur = imgaussfilt(logedge,4);
        dilate = imdilate(blur,[se0 se45 se90]);
        erode = imerode(dilate,[se0 se45 se90]);
        logedge = erode;
    end
    
    final = edge(logedge,'canny');
    seg = final;
end

function edge = edge_recognition_log(I)
    HGauss = fspecial('gaussian',[50,50],7);
    IConv = conv2(I, HGauss, 'same');
    edge = I -IConv;
end