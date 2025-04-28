%SAMpred x MANUAL PHASE 0.5 (CLEANING wif CIRCULARITY ECCENTRICITY SOLIDITY – FINAL MERGED SAM PREDICTOR IMAGE AS OUTPUT)

close all; clear; clc

%PATHS
dayOfCruise = '2022-07-23';
outputSAMpredTemp = ['/Users/giuliopasserotti/Documents/Pyth.D/seaice_fsd_w_GVF/manual_fsd_pixelmator/output_left_', dayOfCruise, '_SAMpred/tmp/'];
outputManual = ['/Users/giuliopasserotti/Documents/Pyth.D/seaice_fsd_w_GVF/manual_fsd_pixelmator/output_left_', dayOfCruise, '/'];
savePath = ['/Users/giuliopasserotti/Documents/Pyth.D/seaice_fsd_w_GVF/manual_fsd_pixelmator/output_left_', dayOfCruise, '_SAMpred/'];

%READ TEMPORARY OUTPUT IMAGES OF SAM PREDICTOR
outputAggrSAMpredList = dir([outputSAMpredTemp, '*AggrSAMpred_masks.png']);
outputSAMpredNames = {outputAggrSAMpredList.name}';

for im = 1:length(outputSAMpredNames)

outputSAMpredNames{im}(18:end)=[];

outputPathAllcoordinatesSAMpred_masks = [outputSAMpredTemp, outputSAMpredNames{im}, ' AllcoordinatesSAMpred_masks.mat'];
outputPathCroppedImage = [outputManual, outputSAMpredNames{im}, ' croppedImage.png'];

AllcoordinatesSAMpred_masks = importdata(outputPathAllcoordinatesSAMpred_masks);

croppedImage = imread(outputPathCroppedImage);

% blackMask = false(size(croppedImage));
% blackMask(~croppedImage) = true;

%LOOP CYCLE TO PROCESS EACH OF THE MASK STORED IN AllcoordinatesSAMpred_masks
mergedCleanSAMpred_image = false(size(croppedImage));

% circularity_SAMpred = cell(1, length(AllcoordinatesSAMpred_masks));
% eccentricity_SAMpred = cell(1, length(AllcoordinatesSAMpred_masks));
% solidity_SAMpred = cell(1, length(AllcoordinatesSAMpred_masks));
% roundXcentroid_SAMpred = cell(1, length(AllcoordinatesSAMpred_masks));
% roundYcentroid_SAMpred = cell(1, length(AllcoordinatesSAMpred_masks));
% AllperimPixelList_SAMpred = cell(1, length(AllcoordinatesSAMpred_masks));

for gg = 1:length(AllcoordinatesSAMpred_masks)
    
    binarySAMpred_masks = false(size(croppedImage));
    binarySAMpred_masks(sub2ind(size(binarySAMpred_masks), AllcoordinatesSAMpred_masks{gg}(:,1), AllcoordinatesSAMpred_masks{gg}(:,2))) = true;
    
    %FIND CENTROID, CIRCULARITY, ECCENTRICITY AND SOLIDITY OF EACH FLOE
    SAMpred_stats = regionprops(binarySAMpred_masks, 'Centroid', 'Circularity', 'Eccentricity', 'Solidity');

    circularity = [SAMpred_stats.Circularity];
    circularity = round(circularity, 2);
    eccentricity = [SAMpred_stats.Eccentricity];
    eccentricity = round(eccentricity, 2);
    solidity = [SAMpred_stats.Solidity];
    solidity = round(solidity, 2);

%     centroid = [SAMpred_stats.Centroid];
%     Xcentroid = centroid(1:2:end);
%     Ycentroid = centroid(2:2:end);
%     roundXcentroid = round(Xcentroid);
%     roundYcentroid = round(Ycentroid);
        
    %CLEAN wif CIRCULARITY BECAUSE CIRCULARITY GIVES LOWER RESULTS IN PYTHON COMPARED TO MATLAB
    noFloeIdx = find(circularity > 1 | circularity == Inf); 
    noFloeBW = ismember(labelmatrix(bwconncomp(binarySAMpred_masks)), noFloeIdx);

    cleanSAMpredimage = binarySAMpred_masks;
    cleanSAMpredimage(noFloeBW) = false;

    circularity(noFloeIdx) = [];
    eccentricity(noFloeIdx) = [];
    solidity(noFloeIdx) = [];
%     roundXcentroid(noFloeIdx) = [];
%     roundYcentroid(noFloeIdx) = [];

    %CLEAN wif ECCENTRICITY BECAUSE ECCENTRICITY GIVES LOWER RESULTS IN PYTHON COMPARED TO MATLAB
    lineFloeIdx = find(eccentricity >= 0.9);
    lineFloeBW = ismember(labelmatrix(bwconncomp(cleanSAMpredimage)), lineFloeIdx);

    cleanSAMpredimage(lineFloeBW) = false;

    circularity(lineFloeIdx) = [];
    eccentricity(lineFloeIdx) = [];
    solidity(lineFloeIdx) = [];
%     roundXcentroid(lineFloeIdx) = [];
%     roundYcentroid(lineFloeIdx) = [];

    %CLEAN wif SOLIDITY < 0.8 BECAUSE SAM FINDS SO MANY ERRONOUS CONCAVE BLOBS
    noConvexIdx = find(solidity <= 0.8);
    noConvexBW = ismember(labelmatrix(bwconncomp(cleanSAMpredimage)), noConvexIdx);

    cleanSAMpredimage(noConvexBW) = false;

%     circularity(noConvexIdx) = [];
%     eccentricity(noConvexIdx) = [];
%     solidity(noConvexIdx) = [];
%     roundXcentroid(noConvexIdx) = [];
%     roundYcentroid(noConvexIdx) = [];

    %SAVE THESE VARIABLE IF YOU WANT TO PLOT PERIMETERS FOR A SINGLE mergedCleanSAMpred_image
%     circularity_SAMpred{gg} = circularity;
%     eccentricity_SAMpred{gg} = eccentricity;
%     solidity_SAMpred{gg} = solidity;
%     roundXcentroid_SAMpred{gg} = roundXcentroid;
%     roundYcentroid_SAMpred{gg} = roundYcentroid;
%     [perimPixelList, ~] = bwboundaries(cleanSAMpredimage, 'noholes');
%     AllperimPixelList_SAMpred{gg} = cell2mat(perimPixelList);

    %MERGE CLEANED FLOES FROM EACH SAM PREDICTOR MASK STORED IN AllcoordinatesSAMpred_masks
    mergedCleanSAMpred_image(cleanSAMpredimage) = true; 
end


%SHOW ORIGINAL CROPPED IMAGE WITH PERIMETER OF FOUND FLOES + PROPERTIES
% figure('Name', 'perimeter of floes and properties')        
%     imshow(croppedImage);
% 
%     textFontSize = 20;
%     hold on
%     for gg = 1:length(AllperimPixelList_SAMpred)
%             colorrr = rand(1,3);
%             if ~isempty(AllperimPixelList_SAMpred{gg})
%                 plot(AllperimPixelList_SAMpred{gg}(:,2), AllperimPixelList_SAMpred{gg}(:,1), 'Color', colorrr, 'Linewidth', 5)
%             
%                 text(roundXcentroid_SAMpred{gg}, roundYcentroid_SAMpred{gg}, num2str(circularity_SAMpred{gg}), 'FontSize', textFontSize, 'FontWeight', 'Bold', 'Color', colorrr);
% %               text(roundXcentroid_SAMpred{gg}, roundYcentroid_SAMpred{gg}, num2str(eccentricity_SAMpred{gg}), 'FontSize', textFontSize, 'FontWeight', 'Bold', 'Color', colorrr);
% %               text(roundXcentroid_SAMpred{gg}, roundYcentroid_SAMpred{gg}, num2str(solidity_SAMpred{gg}), 'FontSize', textFontSize, 'FontWeight', 'Bold', 'Color', colorrr);
%             end
%     end
%     hold off

    
%SAVE IMAGE OF CLEANED FLOES FROM EACH SAM PREDICTOR MASK MERGED TOGETHER
imwrite(mergedCleanSAMpred_image, [savePath, outputSAMpredNames{im}, ' mergedSAMpredimage.png']);

%RE-SAVE CROPPED ORIGINAL IMAGE
imwrite(croppedImage, [savePath, outputSAMpredNames{im}, ' croppedImage.png']);

end

