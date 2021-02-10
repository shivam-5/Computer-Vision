I1 = imread('img1.png');
detector = detectHarrisFeatures(rgb2gray(I1));
pos1 = [240,240;198,198;205,205;362,362;1,1;128,321;75,164;490,267;370,23;390,190];
I2 = imread('img2.png');
pos2 = find_matches(im2double(I1), pos1, im2double(I2));
figure(1);
subplot(2,2,1); 
imagesc(I1);
hold on;
plot(pos1(:,1),pos1(:,2),'y+','LineWidth',2);

subplot(2,2,2); 
imagesc(I2);
hold on;
plot(pos2(:,1),pos2(:,2),'y+','LineWidth',2);