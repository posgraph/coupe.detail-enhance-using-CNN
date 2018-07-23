function genLowContrast( infolder, outfolder, stride, maxlevel )
%GENLOWCONTRAST generate low_level image
%   자세한 설명 위치

a1 = 1 / (1 - stride);
b1 = -stride / (1 - stride);
a2 = 1 / (1 - stride);
b2 = 0;

image_files = dir(fullfile(infolder, '*.jpg'));

if ~exist(outfolder, 'dir')
    mkdir(outfolder);
end
for i = 0 : maxlevel
    if ~exist(strcat(outfolder, '/', int2str(i)), 'dir')
        mkdir(strcat(outfolder, '/', int2str(i)))
    end
end

fileID = fopen(fullfile(outfolder, 'info.txt'), 'w');
for i = 1 : length(image_files)
    filename = strsplit(image_files(i).name, '.');
    origfilename = strcat(filename{1}, '.png');
    origfullfile = fullfile(outfolder, int2str(0), origfilename);
    img = im2double(imread(fullfile(infolder, image_files(i).name)));
    img_dark = img;
    img_light = img;
    imwrite(img, origfullfile);
    fprintf(fileID, '%s %d\n', origfullfile, 0);
    for j = 1 : maxlevel
        darkfname = strcat(filename{1}, '_dark.png');
        darkfullfname = fullfile(outfolder, int2str(j), darkfname);
        img_dark = img_dark * a1 + b1;
        img_dark = max(img_dark, 0);
        img_dark = min(img_dark, 1);
        imwrite(img_dark, darkfullfname);
        fprintf(fileID, '%s %d\n', darkfullfname, j);
        
        lightfname = strcat(filename{1}, '_light.png');
        lightfullfname = fullfile(outfolder, int2str(j), lightfname);
        img_light = img_light * a2 + b2;
        img_light = max(img_light, 0);
        img_light = min(img_light, 1);
        imwrite(img_light, lightfullfname);
        fprintf(fileID, '%s %d\n', lightfullfname, j);
    end
end

fclose(fileID);

end

