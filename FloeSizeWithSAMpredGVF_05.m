%SAMpred x GVF PHASE 0.5 (CLEANING wif CIRCULARITY ECCENTRICITY – FIG PERIMETER WITH FLOES OVERIMPOSED ON ORIGINAL IMAGE AS OUTPUT)

close all; clear; clc

%PATHS
dayOfCruise = '2022-07-23';
outputSAMpredGVFtemp = ['/Users/giuliopasserotti/Documents/Pyth.D/seaice_fsd_w_GVF/manual_fsd_pixelmator/output_left_', dayOfCruise, '_SAMpredGVF/tmp/'];
savePath = ['/Users/giuliopasserotti/Documents/Pyth.D/seaice_fsd_w_GVF/manual_fsd_pixelmator/output_left_', dayOfCruise, '_SAMpredGVF/'];

%READ TEMPORARY OUTPUT IMAGES
outputList = dir([outputSAMpredGVFtemp, '*howmuchtime.txt']);
outputListNames = {outputList.name}';

for im = 1:length(outputListNames)

outputListNames{im}(18:end)=[];

outputPathImages = {[outputSAMpredGVFtemp, outputListNames{im},' SAMpredGVFerodeImage.png'];...
                    [outputSAMpredGVFtemp, outputListNames{im},' SAMpredGVFremainingImage.png'];...
                    [outputSAMpredGVFtemp, outputListNames{im},' Blob1SeedImage.png']};

outputPathCroppedImage = [outputSAMpredGVFtemp, outputListNames{im},' croppedImage.png'];

croppedImage = imread(outputPathCroppedImage);

blackMask = false(size(croppedImage));
blackMask(~croppedImage) = true;

%LOOP CYCLE TO PROCESS EACH OF THE 3 SAMpred x GVF OUTPUTS
mergedCleanSAMpredGVFimage = false(size(croppedImage));
mergedPerimCleanSAMpredGVFimage = false(size(croppedImage));
All3cleanSAMpredGVFimage = cell(1, length(outputPathImages));
All3perimPixelList = cell(1, length(outputPathImages));

for gg = 1:length(outputPathImages)
    SAMpredGVFimage = imread(outputPathImages{gg});
    
    %DELETE FLOES TOUCHING IMAGE BORDERS
    SAMpredGVFimage(blackMask) = true;

    margin = 1;
    woBorderImage = imcrop(SAMpredGVFimage, [margin + 1, margin + 1, size(SAMpredGVFimage, 2) - (2 * margin + 1), size(SAMpredGVFimage, 1) - (2 * margin + 1)]);
    bclearSAMpredGVFimage = imclearborder(woBorderImage);
    bclearSAMpredGVFimage = logical(padarray(bclearSAMpredGVFimage, [margin margin], 'both'));

    %FILL HOLES INSIDE FLOES
    bclearSAMpredGVFimage = imfill(bclearSAMpredGVFimage, 'holes');
    
    %SLIGHT EROSION OF ALL FLOES
    se = strel('disk', 2, 0);   %remember this value 1 px = 0.05 m
    erodebclearSAMpredGVFimage = imerode(bclearSAMpredGVFimage, se);


    %FIND CENTROID, CIRCULARITY AND ECCENTRICITY OF EACH FLOE
    SAMpredGVFstats = regionprops(erodebclearSAMpredGVFimage, 'Centroid', 'Circularity', 'Eccentricity');

    circularity = [SAMpredGVFstats.Circularity];
    circularity = round(circularity, 2);
    eccentricity = [SAMpredGVFstats.Eccentricity];
    eccentricity = round(eccentricity, 2);
    centroid = [SAMpredGVFstats.Centroid];
    Xcentroid = centroid(1:2:end);
    Ycentroid = centroid(2:2:end);
    roundXcentroid = round(Xcentroid);
    roundYcentroid = round(Ycentroid);


    %SHOW CIRCULARITY AND CLEAN FLOES COMPOSED BY FEW PIXELS (CIRCULARITY > 1 OR == INF)
%     figure('Name', 'circularity')
%         imshow(erodebclearSAMpredGVFimage);
% 
%         textFontSize = 20;
%         labelShiftX = -10;
% 
%         hold on
%         plot(roundXcentroid, roundYcentroid, '*r', 'MarkerSize', 7)
%         for ii = 1:length(circularity)
% 
%             text(roundXcentroid(ii) + labelShiftX, roundYcentroid(ii), num2str(circularity(ii)), 'FontSize', textFontSize, 'FontWeight', 'Bold', 'Color', 'r');
%         end
%         hold off
%     close


    noFloeIdx = find(circularity > 1 | circularity == Inf); 
    noFloeBW = ismember(labelmatrix(bwconncomp(erodebclearSAMpredGVFimage)), noFloeIdx);

    cleanSAMpredGVFimage = erodebclearSAMpredGVFimage;
    cleanSAMpredGVFimage(noFloeBW) = false;

    circularity(noFloeIdx) = [];
    eccentricity(noFloeIdx) = [];
    roundXcentroid(noFloeIdx) = [];
    roundYcentroid(noFloeIdx) = [];


    %SHOW ECCENTRICITY AND CLEAN FLOES NOT CIRCULAR AT ALL (ECCENTRICITY >= 0.9)
%     figure('Name', 'eccentricity')
%         imshow(cleanSAMpredGVFimage);
% 
%         textFontSize = 20;
%         labelShiftX = -10;
% 
%         hold on
%         plot(roundXcentroid, roundYcentroid, '*r', 'MarkerSize', 7)
%         for ii = 1:length(eccentricity)
% 
%             text(roundXcentroid(ii) + labelShiftX, roundYcentroid(ii), num2str(eccentricity(ii)), 'FontSize', textFontSize, 'FontWeight', 'Bold', 'Color', 'r');
%         end
%         hold off
%     close


    lineFloeIdx = find(eccentricity >= 0.9);
    lineFloeBW = ismember(labelmatrix(bwconncomp(cleanSAMpredGVFimage)), lineFloeIdx);

    cleanSAMpredGVFimage(lineFloeBW) = false;


    %MERGE PERIMETER OF CLEANED FLOES FROM 3 SAMpred x GVF OUTPUTS
    [perimPixelList, ~] = bwboundaries(cleanSAMpredGVFimage, 'noholes');
    All3perimPixelList{gg} = perimPixelList;

    %MERGE CLEANED FLOES FROM 3 SAMpred x GVF OUTPUTS
    mergedCleanSAMpredGVFimage(cleanSAMpredGVFimage) = true; 
    All3cleanSAMpredGVFimage{gg} = cleanSAMpredGVFimage;
end


%SHOW AND SAVE ORIGINAL CROPPED IMAGE WITH PERIMETER OF FOUND FLOES IN RED
figure('Name', 'perimeter of floes', 'visible', 'on')        
    imshow(croppedImage)

    hold on
    for gg = 1:length(All3perimPixelList)

        for ii = 1:length(All3perimPixelList{gg})

            plot(All3perimPixelList{gg}{ii}(:,2), All3perimPixelList{gg}{ii}(:,1), 'r', 'Linewidth', 5)
        end
    end

    savefig([savePath, outputListNames{im}, ' perimeter'])
close

%SAVE IMAGE OF CLEANED FLOES FROM 3 GVF OUTPUTS MERGED TOGETHER AND NOT
imwrite(mergedCleanSAMpredGVFimage, [savePath, outputListNames{im}, ' mergedCleanSAMpredGVFimage.png']);
save([savePath, outputListNames{im}, ' All3cleanSAMpredGVFimage.mat'], 'All3cleanSAMpredGVFimage');

%SAVE PERIMETER PIXEL LIST OF CLEANED FLOES
save([savePath, outputListNames{im}, ' perimPixelList.mat'], 'All3perimPixelList');

%RE-SAVE CROPPED ORIGINAL IMAGE
imwrite(croppedImage, [savePath, outputListNames{im}, ' croppedImage.png']);

end

