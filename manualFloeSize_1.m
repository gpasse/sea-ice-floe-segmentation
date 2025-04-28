%MANUAL FSD PHASE 1 (AREA, DIAMETER AND ICE CONCENTRATION FOR EACH IMAGE)

close all; clear; clc

%PATHS
dayOfCruise = '2022-07-23';
outputManual = ['/Users/giuliopasserotti/Documents/Pyth.D/seaice_fsd_w_GVF/manual_fsd_pixelmator/output_left_', dayOfCruise, '/'];
savePath = ['/Users/giuliopasserotti/Documents/Pyth.D/seaice_fsd_w_GVF/manual_fsd_pixelmator/output_left_', dayOfCruise, '/'];

%READ OUTPUT IMAGES
outputList = dir([outputManual, '*mergedGVFimage.png']);
outputListImageNames = {outputList.name}';

for im = 1:length(outputListImageNames)

outputListImageNames{im}(18:end)=[];

outputFilePathmergedGVFimage = [outputManual, outputListImageNames{im},' mergedGVFimage.png'];
outputFilePathcroppedImage = [outputManual, outputListImageNames{im},' croppedImage.png'];

mergedGVFimage = imread(outputFilePathmergedGVFimage);
croppedImage = imread(outputFilePathcroppedImage);

blackMask = false(size(croppedImage));
blackMask(~croppedImage) = true;

%MEASURE DIAMETER, AREA AND PERIMETER OF EACH FLOE FOR ALL IMAGES
GVFstats = regionprops(mergedGVFimage, 'Centroid', 'EquivDiameter', 'Area');

centroid = [GVFstats.Centroid];
allXcentroid_px = round(centroid(1:2:end))';
allYcentroid_px = round(centroid(2:2:end))';

[allPerimeter_px, ~] = bwboundaries(mergedGVFimage, 'noholes');
    
allDiameter_m = [GVFstats.EquivDiameter]'.* 0.05'; %remember this value 1 px = 0.05 m
allArea_m = [GVFstats.Area]'.* (0.05^2);


%ICE CONCENTRATION AS AREA OF FLOES / TOTAL AREA OF IMAGE FOR OUTPUT MERGED IMAGE
iceConcentration = sum(mergedGVFimage, 'all') / (numel(mergedGVFimage) - sum(blackMask, 'all'));


%SHOW ORIGINAL CROPPED IMAGE WITH PERIMETER AND NUMBER # OF FLOES IN RED FOR ERROR IDENTIFICATION

% figure('Name', ['Find # of Floes for Error Identification for ',outputListImageNames{im}])
%     imshow(croppedImage)
% 
%     textFontSize = 20;
%     labelShiftX = -10;
% 
%     hold on
%     plot(allXcentroid_px, allYcentroid_px, '*r', 'MarkerSize', 7)
%         for ii = 1:length(allPerimeter_px)
% 
%         text(allXcentroid_px(ii) + labelShiftX, allYcentroid_px(ii), num2str(ii), 'FontSize', textFontSize, 'FontWeight', 'Bold', 'Color', 'r');
%         plot(allPerimeter_px{ii}(:,2), allPerimeter_px{ii}(:,1), 'r', 'Linewidth', 5)
%         end
% close


%SAVE ALL DIAMETERS, AREAS, IDENTIFICATION PERCENTAGE AND THE 2 ICE CONCENTRATIONS
save([savePath, outputListImageNames{im}, ' allDiameter_m.txt'], 'allDiameter_m', '-ascii');
save([savePath, outputListImageNames{im}, ' allArea_m.txt'], 'allArea_m', '-ascii');
save([savePath, outputListImageNames{im}, ' iceConcentration.txt'], 'iceConcentration', '-ascii');

end

