%{
   The idea is to find the features using SURF, Harris and Brisk feature
   detectors for both images, find the matching features, calculate the
   transformation matrix and then using that transformation matrix to find
   correposponding points of first image(given as input) in second image.

   The reason of using different featur detectors is to detect both "Blob" (SURF)
   and "Corner" (Harris and Brisk) features as well as having scale
   independecy (SURF and BRISK). Combining these will ensure better results
   covering variety of image distortions.

   Further comments are added inline.

References: 
    1. The idea of combining multiple feature detectors is taken from:
        https://uk.mathworks.com/help/vision/ug/local-feature-detection-and-extraction.html#bulhkoi
%}

function [pos2] = find_matches(I1, pos1, I2)

    % Convert images to grayscale
    original = rgb2gray(I1);
    transformed = rgb2gray(I2);

    % Get detected features from different types for both images
    originalFeatures = getDetectedFeatures(original);
    transformedFeatures = getDetectedFeatures(transformed);
    
    % Extract descriptors for feature points retrieved for both images
    [originalDescriptors, originalValidPts] = extractFeaturePts(original, originalFeatures);
    [transformedDescriptors, transformedValidPts] = extractFeaturePts(transformed, transformedFeatures);

    % Find matching pairs of feature points in both images
    indexPairs = getMatchedFeatures(originalDescriptors,transformedDescriptors);
    
    % Retrieve matched points from the complete feature lists
    [originalMatchedPtsList,transformedMatchedPtsList]  = getMatchedPoints(originalValidPts,transformedValidPts,indexPairs);
    
    % Combine matched feature list from all detectors for both images
    originalMatched = combinePoints(originalMatchedPtsList);
    transformedMatched = combinePoints(transformedMatchedPtsList);
    
    % Calculate approximate transformation matrix using all the matched
    % features from various detectors
    [tform, inlierIdx] = estimateGeometricTransform2D(...
    transformedMatched, originalMatched, 'similarity');
     
    % Apply transformation on input points of first image to find
    % corresponding coordinates of points in second image
    pos2 = transformPointsInverse(tform, pos1);
end

%{
    Detect features from mulitple algorithms
    Returns list of feature lists  
%}
function features = getDetectedFeatures(I)
    features = cell(2);
    surfFD = detectSURFFeatures(I);
    harrisFD = detectHarrisFeatures(I);
    briskFD = detectBRISKFeatures(I);
    features{1} = surfFD;
    features{2} = harrisFD;
    features{3} = briskFD;
end 

%{
    Extract feature points from each of the lists
    Returns list of descriptor lists and list of validPts lists
%}
function [descriptorsList,validPtsList] = extractFeaturePts(I, features)
    descriptorsList = cell(size(features));
    validPtsList = cell(size(features));
    for idx = 1:size(features)
        [descriptor,validPt]  = extractFeatures(I,features{idx});
        descriptorsList{idx} = descriptor;
        validPtsList{idx} = validPt;
    end
end

%{
    Match features by comparing individual lists
    Returns list of indexPair lists
%}
function indexPairsList = getMatchedFeatures(features1,features2)
    indexPairsList = cell(size(features1));
    for idx = 1:size(features1)
        indexPairs = matchFeatures(features1{idx}, features2{idx});
        indexPairsList{idx} = indexPairs;
    end
end

%{
    Return matched points from index pair to original point list
    for both images for all detector lists
    Returns list of matchedPts lists of both images
%}
function [matchedPtsList1, matchedPtsList2] = getMatchedPoints(ptList1, ptList2, indexPairsList)
    matchedPtsList1 = cell(size(indexPairsList));
    matchedPtsList2 = cell(size(indexPairsList));
    for idx = 1:size(indexPairsList)
        indexPairs = indexPairsList{idx};
        firstList = ptList1{idx};
        secondList = ptList2{idx};
        matchedPts1 = firstList(indexPairs(:,1));
        matchedPts2 = secondList(indexPairs(:,2));
        matchedPtsList1{idx} = matchedPts1;
        matchedPtsList2{idx} = matchedPts2;
    end
end

%{
    Combine all lists in to one adding Location as the element
    Returns fully combined list of all matched feature points 
    recovered from all three lists
%}
function combinedList = combinePoints(listOfPoints)
    combinedList = [];
    for idx = 1:size(listOfPoints)
        combinedList = [combinedList;listOfPoints{idx}.Location];
    end
end