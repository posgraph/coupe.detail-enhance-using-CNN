function  generateSet( infolder, outfile, varargin )
%GENERATESET Generate art-photography training set to HDF5
%   Usage: generateSet('art_photograph_dataset', 'model/train.h5');

%% Initialize
data_files = dir(fullfile(infolder, '*_input.png'));
label_files = dir(fullfile(infolder, '*_result.png'));
stride = 16; % stride
dpsize = 32; % patch size for data
lpsize = 20; % patch size for label
chunk = 128;
channel = 1;

if ~isempty(varargin)
    for c = 1 : 2 : nargin - 2
        switch varargin{c}
            case {'stride'}
                stride = varargin{c + 1};
            case {'dataPatchSize'}
                dpsize = varargin{c + 1};
            case {'labelPatchSize'}
                lpsize = varargin{c + 1};
            case {'batchSize'}
                chunk = varargin{c + 1};
            case {'channel'}
                channel = varargin{c + 1};
                if (channel ~= 1 && channel ~=3)
                    error('invalid channel number');
                end
            otherwise
                error(['Invalid optional argument, ', varargin{c}]);
        end
    end
end

if channel == 3
    data = zeros(dpsize, dpsize, 3, 1);
    label = zeros(lpsize, lpsize, 3, 1);
else
    data = zeros(dpsize, dpsize, 1, 1);
    label = zeros(lpsize, lpsize, 1, 1);
end
count = 0;

%% Generate data pair
for i = 1 : length(data_files)
    data_img = imread(fullfile(infolder, data_files(i).name));
    if size(data_img, 3) == 1
        data_img = repmat(data_img, [1, 1, 3]);
    end
    data_img = rgb2lab(data_img);
    if channel == 3
        data_img = im2double(data_img(:, :, :));
    else
        data_img = im2double(data_img(:, :, 1));
    end
    
    label_img = imread(fullfile(infolder, label_files(i).name));
    if size(label_img, 3) == 1
        label_img = repmat(label_img, 3);
    end
    label_img = rgb2lab(label_img);
    if channel == 3
        label_img = im2double(label_img(:, :, :));
    else
        label_img = im2double(label_img(:, :, 1));
    end

    assert(size(data_img, 1) == size(label_img, 1), ...
        strcat('Size error: ', data_files(i).name));
    assert(size(data_img, 2) == size(label_img, 2), ...
        strcat('Size error: ', data_files(i).name));
    
    for y = 1 : stride : size(data_img, 1) - dpsize
        for x = 1 : stride : size(data_img, 2) - dpsize
            yrange = y : y + dpsize - 1;
            xrange = x : x + dpsize - 1;
            data_subimg = data_img(yrange, xrange, :);
            
            padding = (dpsize - lpsize) / 2;
            yrange = y + padding : y + padding + lpsize - 1;
            xrange = x + padding : x + padding + lpsize - 1;
            label_subimg = label_img(yrange, xrange, :);
            
            count = count + 1;
            if channel == 3
                data(:, :, :, count) = data_subimg;
                label(:, :, :, count) = label_subimg;
            else
                data(:, :, 1, count) = data_subimg;
                label(:, :, 1, count) = label_subimg;
            end
        end
    end
end

order = randperm(count);
data = data(:, :, :, order);
label = label(:, :, :, order);

%% Write to HDF5
created = false;
totalct = 0;

for batchno = 1 : floor(count / chunk)
    lastidx = (batchno-1) * chunk;
    bdata = data(:, :, :, lastidx + 1 : lastidx + chunk); 
    blabel = label(:, :, :, lastidx + 1 : lastidx + chunk);

    loc = struct('dat',[1, 1, 1, totalct + 1], 'lab', [1, 1, 1, totalct + 1]);
    curr_dat_sz = store2hdf5(outfile, bdata, blabel, ~created, loc, chunk); 
    created = true;
    totalct = curr_dat_sz(end);
end
h5disp(outfile);

end

