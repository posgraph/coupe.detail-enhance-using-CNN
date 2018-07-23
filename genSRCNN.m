w = getFilters('model2/SRCNN_mat.prototxt', 'model2/snapshot/_iter_1000000.caffemodel');

indir = 'asdf';
outdir = 'out_AVA';
imgfiles = dir(fullfile(indir, '*.jpg'));

for i = 1 : length(imgfiles)
    outfilename = strsplit(imgfiles(i).name, '.jpg');
    outfilename = strcat(outfilename{1}, '.png');
    img = imread(fullfile(indir, imgfiles(i).name));
    if size(img, 3) == 1
        img = repmat(img, [1, 1, 3]);
    end
    img_lab = rgb2lab(img);
    img_lab_res = SRCNN(w, img_lab, 'channel', 3);
    img_res = lab2rgb(img_lab_res);
    imwrite(img_res, fullfile(outdir, outfilename));
end