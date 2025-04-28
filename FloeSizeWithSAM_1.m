%SAM x MANUAL PHASE 1 (AREA, DIAMETER, ICE CONCENTRATION - FIG PERIMETER OF FLOES OVERIMPOSED ON ORIGINAL IMAGE)

close all; clear; clc

%PATHS
dayOfCruise = '2022-07-23';
outputSAM = ['/Users/giuliopasserotti/Documents/Pyth.D/seaice_fsd_w_GVF/manual_fsd_pixelmator/output_left_', dayOfCruise, '_SAM/'];
savePath = ['/Users/giuliopasserotti/Documents/Pyth.D/seaice_fsd_w_GVF/manual_fsd_pixelmator/output_left_', dayOfCruise, '_SAM/'];

%READ OUTPUT IMAGES
outputSAMlist = dir([outputSAM, '*mergedSAMimage.png']);
outputSAMnames = {outputSAMlist.name}';

for im = 1:length(outputSAMnames)

outputSAMnames{im}(18:end)=[];

outputPathMergedSAMimage = [outputSAM, outputSAMnames{im},' mergedSAMimage.png'];
outputPathCroppedImage = [outputSAM, outputSAMnames{im},' croppedImage.png'];

mergedSAMimage = imread(outputPathMergedSAMimage);
croppedImage = imread(outputPathCroppedImage);

blackMask = false(size(croppedImage));
blackMask(~croppedImage) = true;

%MEASURE DIAMETER, AREA AND PERIMETER OF EACH FLOE FOR ALL IMAGES
SAM_stats = regionprops(mergedSAMimage, 'EquivDiameter', 'Area');

allDiameter_m = [SAM_stats.EquivDiameter]'.* 0.05'; %remember this value 1 px = 0.05 m
allArea_m = [SAM_stats.Area]'.* (0.05^2);

[allPerimeter_px, ~] = bwboundaries(mergedSAMimage, 'noholes');


%ICE CONCENTRATION AS AREA OF FLOES / TOTAL AREA OF IMAGE FOR OUTPUT MERGED IMAGE
iceConcentration = sum(mergedSAMimage, 'all') / (numel(mergedSAMimage) - sum(blackMask, 'all'));


%SHOW AND SAVE ORIGINAL CROPPED IMAGE WITH PERIMETER OF FOUND FLOES IN RED
figure('Name', 'perimeter of floes', 'visible', 'on')        
    imshow(croppedImage)
    hold on
    
    for ii = 1:length(allPerimeter_px)
        plot(allPerimeter_px{ii}(:,2), allPerimeter_px{ii}(:,1), 'r', 'Linewidth', 5)
    end

savefig([savePath, outputSAMnames{im}, ' perimeter'])
close


%SAVE PERIMETER PIXEL LIST OF FLOES
save([savePath, outputSAMnames{im}, ' perimPixelList.mat'], 'allPerimeter_px');

%SAVE ALL DIAMETERS, AREAS AND ICE CONCENTRATION
save([savePath, outputSAMnames{im}, ' allDiameter_m.txt'], 'allDiameter_m', '-ascii');
save([savePath, outputSAMnames{im}, ' allArea_m.txt'], 'allArea_m', '-ascii');
save([savePath, outputSAMnames{im}, ' iceConcentration.txt'], 'iceConcentration', '-ascii');

end

