%SAMpred x GVF PHASE 1 (AREA, DIAMETER AND ICE CONCENTRATION FOR EACH IMAGE)

close all; clear; clc

%PATHS
dayOfCruise = '2022-07-23';
outputSAMpredGVF = ['/Users/giuliopasserotti/Documents/Pyth.D/seaice_fsd_w_GVF/manual_fsd_pixelmator/output_left_', dayOfCruise, '_SAMpredGVF/'];
savePath = ['/Users/giuliopasserotti/Documents/Pyth.D/seaice_fsd_w_GVF/manual_fsd_pixelmator/output_left_', dayOfCruise, '_SAMpredGVF/'];

%READ OUTPUT IMAGES
outputList = dir([outputSAMpredGVF, '*mergedCleanSAMpredGVFimage.png']);
outputListNames = {outputList.name}';

for im = 1:length(outputListNames)

outputListNames{im}(18:end)=[];

outputPathAll3cleanSAMpredGVFimage = [outputSAMpredGVF, outputListNames{im},' All3cleanSAMpredGVFimage.mat'];
outputPathMergedCleanSAMpredGVFimage = [outputSAMpredGVF, outputListNames{im},' mergedCleanSAMpredGVFimage.png'];
outputPathCroppedImage = [outputSAMpredGVF, outputListNames{im},' croppedImage.png'];

All3cleanSAMpredGVFimage = importdata(outputPathAll3cleanSAMpredGVFimage);
mergedCleanSAMpredGVFimage = imread(outputPathMergedCleanSAMpredGVFimage);
croppedImage = imread(outputPathCroppedImage);

blackMask = false(size(croppedImage));
blackMask(~croppedImage) = true;

%MEASURE DIAMETER, AREA AND PERIMETER OF EACH FLOE FOR ALL IMAGES
diameter_m = cell(1, length(All3cleanSAMpredGVFimage));
area_m = cell(1, length(All3cleanSAMpredGVFimage));

for gg = 1:length(All3cleanSAMpredGVFimage)
    
    SAMpredGVF_stats = regionprops(All3cleanSAMpredGVFimage{gg}, 'EquivDiameter', 'Area');

    diameter_m{gg} = [SAMpredGVF_stats.EquivDiameter].* 0.05; %remember this value 1 px = 0.05 m
    area_m{gg} = [SAMpredGVF_stats.Area].* (0.05^2);
end

%ICE CONCENTRATION AS AREA OF FLOES / TOTAL AREA OF IMAGE FOR BOTH OUTPUT MERGED IMAGE AND BINARY ORIGINAL IMAGE
iceConcentration = sum(mergedCleanSAMpredGVFimage, 'all') / (numel(mergedCleanSAMpredGVFimage) - sum(blackMask, 'all'));

%MERGE DIAMETER AND AREA FROM 3 GVF OUTPUTS
allDiameter_m = cell2mat(diameter_m)';
allArea_m = cell2mat(area_m)';


%SAVE ALL DIAMETERS, AREAS, IDENTIFICATION PERCENTAGE AND THE 2 ICE CONCENTRATIONS
save([savePath, outputListNames{im}, ' allDiameter_m.txt'], 'allDiameter_m', '-ascii');
save([savePath, outputListNames{im}, ' allArea_m.txt'], 'allArea_m', '-ascii');
save([savePath, outputListNames{im}, ' iceConcentration.txt'], 'iceConcentration', '-ascii');

end

