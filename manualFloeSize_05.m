%MANUAL FSD PHASE 0.5 (IMAGE CORRECTION AND CLEANING – FIG PERIMETER WITH FLOES OVERIMPOSED ON ORIGINAL IMAGE AS OUTPUT)

close all; clear; clc

%PATHS
dayOfCruise = '2022-07-23';
outputManualTemp = ['/Users/giuliopasserotti/Documents/Pyth.D/seaice_fsd_w_GVF/manual_fsd_pixelmator/output_left_', dayOfCruise, '/tmp/']; %remember to move output of Pixelmator on temporary folder
savePath = ['/Users/giuliopasserotti/Documents/Pyth.D/seaice_fsd_w_GVF/manual_fsd_pixelmator/output_left_', dayOfCruise, '/'];

%READ TEMPORARY OUTPUT IMAGES OF PIXELMATOR (MANUAL FLOE SIZE)
outputMergedList = dir([outputManualTemp, '*mergedGVFimage.png']);
outputMergedImageNames = {outputMergedList.name}';

for im = 1:length(outputMergedImageNames)

outputMergedImageNames{im}(18:end)=[];

outputFilePathmergedGVFimage = [outputManualTemp, outputMergedImageNames{im}, ' mergedGVFimage.png'];
outputFilePathcroppedImage = [outputManualTemp, outputMergedImageNames{im},' croppedImage.png'];

mergedGVFimage = imread(outputFilePathmergedGVFimage);

croppedImage = imread(outputFilePathcroppedImage);

blackMask = false(size(croppedImage));
blackMask(~croppedImage) = true;

%DELETE FLOES TOUCHING IMAGE BORDERS
mergedGVFimage(blackMask) = true;

margin = 1;
woBorderImage = imcrop(mergedGVFimage, [margin + 1, margin + 1, size(mergedGVFimage, 2) - (2 * margin + 1), size(mergedGVFimage, 1) - (2 * margin + 1)]);
mergedCleanGVFimage = imclearborder(woBorderImage);
mergedCleanGVFimage(mergedCleanGVFimage < 255/2) = 0; %This is to prevent pixels that are not completely black from being considered white pixels during the logical transformation
mergedCleanGVFimage = logical(padarray(mergedCleanGVFimage, [margin margin], 'both'));

%PERIMETER OF CLEANED FLOES
[perimPixelList, ~] = bwboundaries(mergedCleanGVFimage, 'noholes');

%SHOW AND SAVE ORIGINAL CROPPED IMAGE WITH PERIMETER OF FOUND FLOES IN RED
figure('Name', 'perimeter of floes')        
    imshow(croppedImage)
    hold on
    
    for ii = 1:length(perimPixelList)
        
        plot(perimPixelList{ii}(:,2), perimPixelList{ii}(:,1), 'r', 'Linewidth', 5)
    end
    
    savefig([savePath, outputMergedImageNames{im}, ' perimeter'])
close

%SAVE IMAGE OF CLEANED FLOES MERGED TOGETHER
imwrite(mergedCleanGVFimage, [savePath, outputMergedImageNames{im}, ' mergedGVFimage.png']);

%SAVE PERIMETER PIXEL LIST OF CLEANED FLOES
save([savePath, outputMergedImageNames{im}, ' perimPixelList.mat'], 'perimPixelList');

%RE-SAVE CROPPED ORIGINAL IMAGE
imwrite(croppedImage, [savePath, outputMergedImageNames{im}, ' croppedImage.png']);

end

