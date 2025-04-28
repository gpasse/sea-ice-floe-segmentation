%SAMpred x GVF PHASE 0 (GVF APPLICATION AFTER HAVING USED SAM PREDICTOR)

close all; clear; clc

%PATHS
dayOfCruise = '2022-07-23';
outputSAMpred = ['/Users/giuliopasserotti/Documents/Pyth.D/seaice_fsd_w_GVF/manual_fsd_pixelmator/output_left_', dayOfCruise, '_SAMpred/'];
savePath = ['/Users/giuliopasserotti/Documents/Pyth.D/seaice_fsd_w_GVF/manual_fsd_pixelmator/output_left_', dayOfCruise, '_SAMpredGVF/tmp/']; %remember to create the directory before run the script

%READ INPUT IMAGES
outputSAMpredList = dir([outputSAMpred, '*mergedSAMpredimage.png']);
outputSAMpredNames = {outputSAMpredList.name}';

for im = 1:length(outputSAMpredNames)

outputSAMpredNames{im}(18:end)=[];

outputPathMergedSAMimage = [outputSAMpred, outputSAMpredNames{im},' mergedSAMpredimage.png'];
outputPathCroppedImage = [outputSAMpred, outputSAMpredNames{im},' croppedImage.png'];

mergedSAMpredimage = imread(outputPathMergedSAMimage);
croppedImage = imread(outputPathCroppedImage);

binaryCroppedImage = mergedSAMpredimage;


%FILL HOLES SELECT IN BLACK REGION INSIDE FLOES WITH A SINGLE SEED THAT ARE SEPARETED FROM EACH OTHER
reverseBinaryImage = ~binaryCroppedImage;

holesDistanceTransform = bwdist(~reverseBinaryImage, 'euclidean');
holesLocalMax = imextendedmax(holesDistanceTransform, 3, 8);

holesSingleLocalMax = regionprops(holesLocalMax, 'Centroid');
holesSeeds = [holesSingleLocalMax.Centroid];
holesXseeds = holesSeeds(1:2:end);
holesYseeds = holesSeeds(2:2:end);
roundHolesXseeds = round(holesXseeds);
roundHolesYseeds = round(holesYseeds);

allHoles = bwconncomp(reverseBinaryImage);
Holes1Seed = regionprops(reverseBinaryImage, 'PixelList');

allHolesPixelIdxList = allHoles.PixelIdxList;
holesSeedsIdxList = sub2ind(size(reverseBinaryImage), roundHolesYseeds, roundHolesXseeds);

countSeedsInHoles = zeros(1, length(allHolesPixelIdxList));
positionSeedsInHoles = cell(1, length(allHolesPixelIdxList));

for ss = 1:length(holesSeedsIdxList)
    for bb = 1:length(allHolesPixelIdxList)
        
        if ismember(holesSeedsIdxList(ss), allHolesPixelIdxList{bb})
            countSeedsInHoles(bb) = countSeedsInHoles(bb) + 1;
            howmuch = countSeedsInHoles(bb);
            positionSeedsInHoles{bb}(howmuch) = ss;
        end
        
    end
end

positionSeedsInHoles(countSeedsInHoles~=1) = [];

if ~isempty(positionSeedsInHoles)
    Holes1Seed(countSeedsInHoles~=1) = [];
    
    Holes1SeedImage = false(size(reverseBinaryImage));
    for bs = 1:length(Holes1Seed)
        lgth = length(Holes1Seed(bs).PixelList);
    
        for lg = 1:lgth
            Holes1SeedImage(Holes1Seed(bs).PixelList(lg, 2), Holes1Seed(bs).PixelList(lg, 1)) = true;
        end
    end

    binaryCroppedImage(Holes1SeedImage) = true;
end


%DISTANCE TRANSFORM AND FIND LOCAL MAXIMUM (SEEDS)
distanceTransform = bwdist(~binaryCroppedImage, 'euclidean');

localMax = imextendedmax(distanceTransform, 3, 8);

singleLocalMax = regionprops(localMax, 'Centroid');
seeds = [singleLocalMax.Centroid];
Xseeds = seeds(1:2:end);
Yseeds = seeds(2:2:end);
roundXseeds = round(Xseeds);
roundYseeds = round(Yseeds);


%SHOW SEEDS OF ALL THE FLOES
figure('Name', 'all the seeds')
    imshow(binaryCroppedImage);
    hold on
    plot(roundXseeds, roundYseeds, '*r', 'MarkerSize', 7)
    
    savefig([savePath, outputSAMpredNames{im}, ' allSeeds'])
close


%FIND FLOES WITH A SINGLE SEED SEPARETED FROM EACH OTHER AND SAVE IN AN ANOTHER IMAGE
allBlobs = bwconncomp(binaryCroppedImage);
Blob1Seed = regionprops(binaryCroppedImage, 'PixelList');

allBlobsPixelIdxList = allBlobs.PixelIdxList;
seedsIdxList = sub2ind(size(binaryCroppedImage), roundYseeds, roundXseeds);

countSeedsInBlob = zeros(1, length(allBlobsPixelIdxList));
positionSeedsInBlob = cell(1, length(allBlobsPixelIdxList));

for ss = 1:length(seedsIdxList)
    for bb = 1:length(allBlobsPixelIdxList)
        
        if ismember(seedsIdxList(ss), allBlobsPixelIdxList{bb})
            countSeedsInBlob(bb) = countSeedsInBlob(bb) + 1;
            howmuch = countSeedsInBlob(bb);
            positionSeedsInBlob{bb}(howmuch) = ss;
        end
        
    end
end

positionSeedsInBlob(countSeedsInBlob~=1) = [];
Blob1Seed(countSeedsInBlob~=1) = [];

Blob1SeedImage = false(size(binaryCroppedImage));
for bs = 1:length(Blob1Seed)
    lgth = length(Blob1Seed(bs).PixelList);
    
    for lg = 1:lgth
        Blob1SeedImage(Blob1Seed(bs).PixelList(lg, 2), Blob1Seed(bs).PixelList(lg, 1)) = true;
    end
end

positionSeedsInBlob = cell2mat(positionSeedsInBlob);
roundXseeds(positionSeedsInBlob) = [];
roundYseeds(positionSeedsInBlob) = [];
seedsIdxList(positionSeedsInBlob) = [];


%FIND FLOES WITH A SINGLE SEED AFTER HEAVY EROSION AND SAVE THE PERIMETER
se = strel('disk', 5, 0); %remember this value 1 px = 0.05 m
erodeBinaryCroppedImage = imerode(binaryCroppedImage, se);

allErodeBlobs = bwconncomp(erodeBinaryCroppedImage);
erodeBlob1SeedCentroid = regionprops(erodeBinaryCroppedImage, 'Centroid');
[erodePerim, ~] = bwboundaries(erodeBinaryCroppedImage, 'noholes');

allErodeBlobsPixelIdxList = allErodeBlobs.PixelIdxList;

countSeedsInErodeBlob = zeros(1, length(allErodeBlobsPixelIdxList));
positionSeedsInErodeBlob = cell(1, length(allErodeBlobsPixelIdxList));

for ss = 1:length(seedsIdxList)
    for bb = 1:length(allErodeBlobsPixelIdxList)
        
        if ismember(seedsIdxList(ss), allErodeBlobsPixelIdxList{bb})
            countSeedsInErodeBlob(bb) = countSeedsInErodeBlob(bb) + 1;
            howmuch = countSeedsInErodeBlob(bb);
            positionSeedsInErodeBlob{bb}(howmuch) = ss;
        end
        
    end
end

positionSeedsInErodeBlob(countSeedsInErodeBlob~=1) = [];
erodeBlob1SeedCentroid(countSeedsInErodeBlob~=1) = [];
erodePerim(countSeedsInErodeBlob~=1) = [];

erodeCentroid = [erodeBlob1SeedCentroid.Centroid];
erodeRoundXseeds = erodeCentroid(1:2:end);
erodeRoundYseeds = erodeCentroid(2:2:end);


%SHOW AND SAVE CONTOUR OF THE PREVIOUS FLOES AS ELLIPSES
figure('Name', 'erodeContour')
    imshow(binaryCroppedImage);
    
    textFontSize = 20;
    labelShiftX = -10;

    hold on
    for ii = 1:length(erodePerim)
        
        plot(erodePerim{ii}(:,2), erodePerim{ii}(:,1), 'r', 'Linewidth', 5)
        text(erodeRoundXseeds(ii) + labelShiftX, erodeRoundYseeds(ii), num2str(ii), 'FontSize', textFontSize, 'FontWeight', 'Bold', 'Color', 'r');
    end
    hold off
        
    savefig([savePath, outputSAMpredNames{im}, ' erodeContour'])
close


%FIND THE REMAINING FLOES AND SAVE THE VALUE OF THE LOCAL MAX AS DIAMATER OF THE CIRCLE FLOES
positionSeedsInErodeBlob = cell2mat(positionSeedsInErodeBlob);
roundXseeds(positionSeedsInErodeBlob) = [];
roundYseeds(positionSeedsInErodeBlob) = [];

valLocalMax = zeros(1, length(roundXseeds));
for ii = 1:length(roundXseeds)
    
    valLocalMax(ii) = distanceTransform(roundYseeds(ii), roundXseeds(ii));
    
end


%SHOW AND SAVE CONTOUR OF THE PREVIOUS FLOES AS CIRCLES
figure('Name', 'remainingContour')
    imshow(binaryCroppedImage);

    t = linspace(0, 2 * pi, 100);
    textFontSize = 20;
    labelShiftX = -10;
    
    allXcircle = zeros(length(roundXseeds), length(t));
    allYcircle = zeros(length(roundXseeds), length(t));
    hold on
    for ii = 1:length(roundXseeds)
        
        xCircle = valLocalMax(ii) * cos(t) + roundXseeds(ii);
        yCircle = valLocalMax(ii) * sin(t) + roundYseeds(ii);
        
        xCircle(xCircle > size(binaryCroppedImage, 2)) = size(binaryCroppedImage, 2);
        xCircle(xCircle < 1) = 1;
        yCircle(yCircle > size(binaryCroppedImage, 1)) = size(binaryCroppedImage, 1);
        yCircle(yCircle < 1) = 1;
        
        plot(xCircle, yCircle, 'r', 'Linewidth', 5)
        text(roundXseeds(ii) + labelShiftX, roundYseeds(ii), num2str(ii), 'FontSize', textFontSize, 'FontWeight', 'Bold', 'Color', 'r');
    
        allXcircle(ii, :) = xCircle;
        allYcircle(ii, :) = yCircle;
    end
    hold off
    
    savefig([savePath, outputSAMpredNames{im}, ' remainingContour'])

close


%PREPARE OPTIONS FOR GVF
imageDouble = im2double(binaryCroppedImage); 

Options = struct;
Options.Verbose = false;
Options.Iterations = 400;
Options.Wedge = 2;
Options.Wline = 0;
Options.Wterm = 0;
Options.Kappa = 4;
Options.Sigma1 = 8;
Options.Sigma2 = 8;
Options.Alpha = 0.1;
Options.Beta = 0.1;
Options.Mu = 0.2;
Options.Delta = -0.1;
Options.GIterations = 600;

tic

%GVF SNAKE ALGORITHM ON THE FLOES WITH THE CONTOUR AS PERIMETER AND SAVE RESULTING IMAGE
perimSAMpredGVFerodeImage = false(size(binaryCroppedImage));
SAMpredGVFerodeImage = false(size(binaryCroppedImage));

for gvf = 1:length(erodePerim)
    
    if length(erodePerim{gvf}) > 2
    erodeContour = [erodePerim{gvf}(:,1) erodePerim{gvf}(:,2)];
    [~, SAMpredGVFerodeFloe] = Snake2D(imageDouble, erodeContour, Options);
    
    perimSAMpredGVFerodeFloe = bwperim(SAMpredGVFerodeFloe);
    perimSAMpredGVFerodeImage(perimSAMpredGVFerodeFloe) = true;

    SAMpredGVFerodeImage(SAMpredGVFerodeFloe) = true;
    end
end

imwrite(SAMpredGVFerodeImage, [savePath, outputSAMpredNames{im}, ' SAMpredGVFerodeImage.png']);
imwrite(perimSAMpredGVFerodeImage, [savePath, outputSAMpredNames{im}, ' perimSAMpredGVFerodeImage.png']);


%GVF SNAKE ALGORITHM ON THE FLOES WITH THE CONTOUR AS CIRCLES AND SAVE RESULTING IMAGE
perimSAMpredGVFremainingImage = false(size(binaryCroppedImage));
SAMpredGVFremainingImage = false(size(binaryCroppedImage));

for gvf = 1:size(allXcircle, 1)
    
    remainingContour = [allYcircle(gvf, :)' allXcircle(gvf, :)'];
    [~, SAMpredGVFremainingFloe] = Snake2D(imageDouble, remainingContour, Options);
    
    perimSAMpredGVFremainingFloe = bwperim(SAMpredGVFremainingFloe);
    perimSAMpredGVFremainingImage(perimSAMpredGVFremainingFloe) = true;

    SAMpredGVFremainingImage(SAMpredGVFremainingFloe) = true;
end

imwrite(SAMpredGVFremainingImage, [savePath, outputSAMpredNames{im}, ' SAMpredGVFremainingImage.png']);
imwrite(perimSAMpredGVFremainingImage, [savePath, outputSAMpredNames{im}, ' perimSAMpredGVFremainingImage.png']);


%SAVE THE FLOES OF THE FIRST FLOES WITH A SINGLE SEED SEPARETED FROM EACH OTHER
imwrite(Blob1SeedImage, [savePath, outputSAMpredNames{im}, ' Blob1SeedImage.png']);


%SAVE BINARY AND CROPPED ORIGINAL IMAGE
imwrite(binaryCroppedImage, [savePath, outputSAMpredNames{im}, ' binaryCroppedImage.png']);
imwrite(croppedImage, [savePath, outputSAMpredNames{im}, ' croppedImage.png']);

howmuchtime = toc;
save([savePath, outputSAMpredNames{im}, ' howmuchtime.txt'], 'howmuchtime', '-ascii');

end

