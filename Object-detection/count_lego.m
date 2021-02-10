%{
   The idea is to train two different ACF object detectors for Blue 2x4
   bricks and Red 2x2 bricks on training data images generated
   by applying various transformations on 12 initial sample images. 
   (Translation, Rotation)

   A total of 180 images were generated and divided into training and test
   sets of 150 and 30 respectively.

   All images were then labelled using Matlab Image Labeller app to
   identify required types of bricks and put into workspace as a tables.
   These tables was used as an input to trainACFObjectDetector to generate
   two different models for blue2x4 and red2x2 bricks.
   
   Parameters were tweaked while training and were set to following after a
   number of continuous testing over the test set:
   NegativeSamplesFactor: 5
   NumStages:10
   MaxWeakLearners:3000

   Testing parameters which will be used in current file as well for 
   identifying correct number of bricks are following:
   OverlapThreshold: 0.35(Blue2x4), 0(Red2x2)
   Confidence Threshold: 40%(Blue2x4), 0(Red2x2)
    
   Both the detectors were then saved as output file and are included in
   the current directory.

   Both models are then loaded while running current file the corresponding
   detector along with input image are then put into detect() api to get
   the identified bounding boxes and confidence scores based on above
   thresholds.

References: 
    1. Following documentation of ACF object detector was used as a
    reference:
        https://uk.mathworks.com/help/vision/ref/trainacfobjectdetector.html
    2. Matlab's Image Labeller app for labelling the training and test data
%}
function [numA, numB] = count_lego(I)

    % Load both detectors
    redDetector = load('red2x2BrickDetector.mat');
    blueDetector = load('blue2x4BrickDetector.mat');

    % Detect red 2x2 lego bricks
    [bbox,score] = detect(blueDetector.acfDetectorBlue,I);
    [genuineBbox, genuineScore] = selectStrongestBbox(bbox, score, 'OverlapThreshold', 0.35);
    numA = 0;
    for i = 1:length(genuineScore)
        if genuineScore(i) < 40
            continue
        end
        % Increase count if confidence count is above threshold
        numA = numA + 1;
    end
    
    % Detect red 2x2 lego bricks
    [bbox,score] = detect(redDetector.acfDetectorRed,I);
    [genuineBbox, genuineScore] = selectStrongestBbox(bbox, score, 'OverlapThreshold', 0);
    numB = length(genuineScore);
end