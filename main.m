I = imread('im1.jpg');
Idouble = im2double(I);
Is = segment_image(im2double(I));
figure(2);
subplot(1,1,1); imagesc(Is); colormap('gray'); colorbar;