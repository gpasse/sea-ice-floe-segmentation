%SAMauto x MANUAL PHASE 0.5 (CLEANING wif CIRCULARITY ECCENTRICITY SOLIDITY – FINAL MERGED SAM AUTOMATIC IMAGE AS OUTPUT)

close all; clear; clc

%PATHS
dayOfCruise = '2022-07-23';
outputSAMtemp = ['/Users/giuliopasserotti/Documents/Pyth.D/seaice_fsd_w_GVF/manual_fsd_pixelmator/output_left_', dayOfCruise, '_SAM/tmp/'];
outputManual = ['/Users/giuliopasserotti/Documents/Pyth.D/seaice_fsd_w_GVF/manual_fsd_pixelmator/output_left_', dayOfCruise, '/'];
savePath = ['/Users/giuliopasserotti/Documents/Pyth.D/seaice_fsd_w_GVF/manual_fsd_pixelmator/output_left_', dayOfCruise, '_SAM/'];

%READ TEMPORARY OUTPUT IMAGES OF SAM AUTOMATIC
outputAggrSAMlist = dir([outputSAMtemp, '*AggrSAM_masks.png']);
outputSAMnames = {outputAggrSAMlist.name}';

for im = 1:length(outputSAMnames)

outputSAMnames{im}(18:end)=[];

outputPathAllcoordinatesSAM_masks = [outputSAMtemp, outputSAMnames{im}, ' AllcoordinatesSAM_masks.mat'];
outputPathCroppedImage = [outputManual, outputSAMnames{im}, ' croppedImage.png'];

AllcoordinatesSAM_masks = importdata(outputPathAllcoordinatesSAM_masks);

croppedImage = imread(outputPathCroppedImage);

% blackMask = false(size(croppedImage));
% blackMask(~croppedImage) = true;

%LOOP CYCLE TO PROCESS EACH OF THE MASK STORED IN AllcoordinatesSAM_masks
mergedCleanSAM_image = false(size(croppedImage));

% circularity_SAM = cell(1, length(AllcoordinatesSAM_masks));
% eccentricity_SAM = cell(1, length(AllcoordinatesSAM_masks));
% solidity_SAM = cell(1, length(AllcoordinatesSAM_masks));
% roundXcentroid_SAM = cell(1, length(AllcoordinatesSAM_masks));
% roundYcentroid_SAM = cell(1, length(AllcoordinatesSAM_masks));
% AllperimPixelList_SAM = cell(1, length(AllcoordinatesSAM_masks));

for gg = 1:length(AllcoordinatesSAM_masks)
    
    binarySAM_masks = false(size(croppedImage));
    binarySAM_masks(sub2ind(size(binarySAM_masks), AllcoordinatesSAM_masks{gg}(:,1), AllcoordinatesSAM_masks{gg}(:,2))) = true;
    
    %FIND CENTROID, CIRCULARITY, ECCENTRICITY AND SOLIDITY OF EACH FLOE
    SAM_stats = regionprops(binarySAM_masks, 'Centroid', 'Circularity', 'Eccentricity', 'Solidity');

    circularity = [SAM_stats.Circularity];
    circularity = round(circularity, 2);
    eccentricity = [SAM_stats.Eccentricity];
    eccentricity = round(eccentricity, 2);
    solidity = [SAM_stats.Solidity];
    solidity = round(solidity, 2);

%     centroid = [SAM_stats.Centroid];
%     Xcentroid = centroid(1:2:end);
%     Ycentroid = centroid(2:2:end);
%     roundXcentroid = round(Xcentroid);
%     roundYcentroid = round(Ycentroid);
        
    %CLEAN wif CIRCULARITY BECAUSE CIRCULARITY GIVES LOWER RESULTS IN PYTHON COMPARED TO MATLAB
    noFloeIdx = find(circularity > 1 | circularity == Inf); 
    noFloeBW = ismember(labelmatrix(bwconncomp(binarySAM_masks)), noFloeIdx);

    cleanSAMimage = binarySAM_masks;
    cleanSAMimage(noFloeBW) = false;

    circularity(noFloeIdx) = [];
    eccentricity(noFloeIdx) = [];
    solidity(noFloeIdx) = [];
%     roundXcentroid(noFloeIdx) = [];
%     roundYcentroid(noFloeIdx) = [];

    %CLEAN wif ECCENTRICITY BECAUSE ECCENTRICITY GIVES LOWER RESULTS IN PYTHON COMPARED TO MATLAB
    lineFloeIdx = find(eccentricity >= 0.9);
    lineFloeBW = ismember(labelmatrix(bwconncomp(cleanSAMimage)), lineFloeIdx);

    cleanSAMimage(lineFloeBW) = false;

    circularity(lineFloeIdx) = [];
    eccentricity(lineFloeIdx) = [];
    solidity(lineFloeIdx) = [];
%     roundXcentroid(lineFloeIdx) = [];
%     roundYcentroid(lineFloeIdx) = [];

    %CLEAN wif SOLIDITY < 0.8 BECAUSE SAM FINDS SO MANY ERRONOUS CONCAVE BLOBS
    noConvexIdx = find(solidity <= 0.8);
    noConvexBW = ismember(labelmatrix(bwconncomp(cleanSAMimage)), noConvexIdx);

    cleanSAMimage(noConvexBW) = false;

%     circularity(noConvexIdx) = [];
%     eccentricity(noConvexIdx) = [];
%     solidity(noConvexIdx) = [];
%     roundXcentroid(noConvexIdx) = [];
%     roundYcentroid(noConvexIdx) = [];

    %SAVE THESE VARIABLE IF YOU WANT TO PLOT PERIMETERS FOR A SINGLE mergedCleanSAM_image
%     circularity_SAM{gg} = circularity;
%     eccentricity_SAM{gg} = eccentricity;
%     solidity_SAM{gg} = solidity;
%     roundXcentroid_SAM{gg} = roundXcentroid;
%     roundYcentroid_SAM{gg} = roundYcentroid;
%     [perimPixelList, ~] = bwboundaries(cleanSAMimage, 'noholes');
%     AllperimPixelList_SAM{gg} = cell2mat(perimPixelList);

    %MERGE CLEANED FLOES FROM EACH SAM AUTOMATIC MASK STORED IN AllcoordinatesSAM_masks
    mergedCleanSAM_image(cleanSAMimage) = true; 
end


%SHOW ORIGINAL CROPPED IMAGE WITH PERIMETER OF FOUND FLOES + PROPERTIES
% figure('Name', 'perimeter of floes and properties')        
%     imshow(croppedImage);
% 
%     textFontSize = 20;
%     hold on
%     for gg = 1:length(AllperimPixelList_SAM)
%             colorrr = rand(1,3);
%             if ~isempty(AllperimPixelList_SAM{gg})
%                 plot(AllperimPixelList_SAM{gg}(:,2), AllperimPixelList_SAM{gg}(:,1), 'Color', colorrr, 'Linewidth', 5)
%             
%                 text(roundXcentroid_SAM{gg}, roundYcentroid_SAM{gg}, num2str(circularity_SAM{gg}), 'FontSize', textFontSize, 'FontWeight', 'Bold', 'Color', colorrr);
% %               text(roundXcentroid_SAM{gg}, roundYcentroid_SAM{gg}, num2str(eccentricity_SAM{gg}), 'FontSize', textFontSize, 'FontWeight', 'Bold', 'Color', colorrr);
% %               text(roundXcentroid_SAM{gg}, roundYcentroid_SAM{gg}, num2str(solidity_SAM{gg}), 'FontSize', textFontSize, 'FontWeight', 'Bold', 'Color', colorrr);
%             end
%     end
%     hold off

    
%SAVE IMAGE OF CLEANED FLOES FROM EACH SAM AUTOMATIC MASK MERGED TOGETHER
imwrite(mergedCleanSAM_image, [savePath, outputSAMnames{im}, ' mergedSAMimage.png']);

%RE-SAVE CROPPED ORIGINAL IMAGE
imwrite(croppedImage, [savePath, outputSAMnames{im}, ' croppedImage.png']);

end

