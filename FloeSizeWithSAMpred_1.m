%SAMpred x MANUAL PHASE 1 (AREA, DIAMETER, ICE CONCENTRATION - FIG PERIMETER OF FLOES OVERIMPOSED ON ORIGINAL IMAGE)

close all; clear; clc

%PATHS
dayOfCruise = '2022-07-23';
outputSAMpred = ['/Users/giuliopasserotti/Documents/Pyth.D/seaice_fsd_w_GVF/manual_fsd_pixelmator/output_left_', dayOfCruise, '_SAMpred/'];
savePath = ['/Users/giuliopasserotti/Documents/Pyth.D/seaice_fsd_w_GVF/manual_fsd_pixelmator/output_left_', dayOfCruise, '_SAMpred/'];

%READ OUTPUT IMAGES
outputSAMpredList = dir([outputSAMpred, '*mergedSAMpredimage.png']);
outputSAMpredNames = {outputSAMpredList.name}';

for im = 1:length(outputSAMpredNames)

outputSAMpredNames{im}(18:end)=[];

outputPathMergedSAMimage = [outputSAMpred, outputSAMpredNames{im},' mergedSAMpredimage.png'];
outputPathCroppedImage = [outputSAMpred, outputSAMpredNames{im},' croppedImage.png'];

mergedSAMpredimage = imread(outputPathMergedSAMimage);
croppedImage = imread(outputPathCroppedImage);

blackMask = false(size(croppedImage));
blackMask(~croppedImage) = true;

%MEASURE DIAMETER, AREA AND PERIMETER OF EACH FLOE FOR ALL IMAGES
SAMpred_stats = regionprops(mergedSAMpredimage, 'EquivDiameter', 'Area');

allDiameter_m = [SAMpred_stats.EquivDiameter]'.* 0.05'; %remember this value 1 px = 0.05 m
allArea_m = [SAMpred_stats.Area]'.* (0.05^2);

[allPerimeter_px, ~] = bwboundaries(mergedSAMpredimage, 'noholes');


%ICE CONCENTRATION AS AREA OF FLOES / TOTAL AREA OF IMAGE FOR OUTPUT MERGED IMAGE
iceConcentration = sum(mergedSAMpredimage, 'all') / (numel(mergedSAMpredimage) - sum(blackMask, 'all'));


%SHOW AND SAVE ORIGINAL CROPPED IMAGE WITH PERIMETER OF FOUND FLOES IN RED
figure('Name', 'perimeter of floes', 'visible', 'on')        
    imshow(croppedImage)
    hold on
    
    for ii = 1:length(allPerimeter_px)
        plot(allPerimeter_px{ii}(:,2), allPerimeter_px{ii}(:,1), 'r', 'Linewidth', 5)
    end

savefig([savePath, outputSAMpredNames{im}, ' perimeter'])
close


%SAVE PERIMETER PIXEL LIST OF FLOES
save([savePath, outputSAMpredNames{im}, ' perimPixelList.mat'], 'allPerimeter_px');

%SAVE ALL DIAMETERS, AREAS AND ICE CONCENTRATION
save([savePath, outputSAMpredNames{im}, ' allDiameter_m.txt'], 'allDiameter_m', '-ascii');
save([savePath, outputSAMpredNames{im}, ' allArea_m.txt'], 'allArea_m', '-ascii');
save([savePath, outputSAMpredNames{im}, ' iceConcentration.txt'], 'iceConcentration', '-ascii');

end

