

%acfDetectorRed = trainACFObjectDetector(redLabelsV2,'NegativeSamplesFactor',5,'NumStages',10,'MaxWeakLearners',3000);
%acfDetectorBlue = trainACFObjectDetector(blueLabelsV2,'NegativeSamplesFactor',5,'NumStages',10,'MaxWeakLearners',3000);

img = imread('train02.jpg');

[bbox,score] = detect(acfDetectorBlue,img);
[selectedBbox, selectedScore] = selectStrongestBbox(bbox, score, 'OverlapThreshold', 0.35);

for i = 1:length(selectedScore)
    if selectedScore(i) < 40
        continue
    end
   annotation = sprintf('Confidence = %.1f',selectedScore(i));
   img = insertObjectAnnotation(img,'rectangle',selectedBbox(i,:),annotation);
end

figure
imshow(img)