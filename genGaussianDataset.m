close all;

img_files = dir(fullfile('art_photograph_dataset/eval', '*_input.png'));

for i = 1 : length(img_files)
    filename = strsplit(img_files(i).name, '_input');
    filename = filename{1};
    infilename = strcat(filename, '_input.png');
    outfilename = strcat(filename, '_result.png');
    
    img = imread(fullfile('art_photograph_dataset/eval', img_files(i).name));
    imwrite(img, fullfile('art_photograph_dataset/eval', 'simple_gaussian_set', infilename));
    
    if size(img, 3) == 1
        img = repmat(img, [1, 1, 3]);
    end
    img = rgb2lab(img);
    h = fspecial('gaussian', 5, 10);
    img_base = imfilter(img(:, :, 1), h);
    img_detail = img(:, :, 1) - img_base;
    img_res = img;
    img_res(:, :, 1) = img_base +  2 * img_detail;
    img_res(:, :, 1) = max(img_res(:, :, 1), 0);
    img_res(:, :, 1) = min(img_res(:, :, 1), 100);
    img_res = lab2rgb(img_res);
    
    imwrite(img_res, fullfile('art_photograph_dataset/eval', 'simple_gaussian_set', outfilename));
end