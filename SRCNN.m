function im_h = SRCNN(w, im_b, varargin)

%%Initialize
channel = 1;
if ~isempty(varargin)
    for c = 1 : 2 : nargin - 2
        switch varargin{c}
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

%% load CNN model parameters
if channel == 1
    [conv1_patchsize, conv1_filters] = size(w.weights_conv1);
    conv1_patchsize = sqrt(conv1_patchsize);
    [conv2_channels, conv2_patchsize2, conv2_filters] = size(w.weights_conv2);
    conv2_patchsize = sqrt(conv2_patchsize2);
    [conv3_channels,conv3_patchsize2] = size(w.weights_conv3);
    conv3_patchsize = sqrt(conv3_patchsize2);
elseif channel == 3
    [~, conv1_patchsize2, conv1_filters] = size(w.weights_conv1);
    conv1_patchsize = sqrt(conv1_patchsize2);
    [conv2_channels, conv2_patchsize2, conv2_filters] = size(w.weights_conv2);
    conv2_patchsize = sqrt(conv2_patchsize2);
    [conv3_channels, conv3_patchsize2, ~] = size(w.weights_conv3);
    conv3_patchsize = sqrt(conv3_patchsize2);
end
[hei, wid, ~] = size(im_b);

%% conv1
if channel == 1
    weights_conv1 = reshape(w.weights_conv1, conv1_patchsize, conv1_patchsize, conv1_filters);
elseif channel == 3
    weights_conv1 = zeros(conv1_patchsize, conv1_patchsize, 3, conv1_filters);
    weights_conv1(:, :, 1, :) = reshape(w.weights_conv1(1, :, :), conv1_patchsize, conv1_patchsize, conv1_filters);
    weights_conv1(:, :, 2, :) = reshape(w.weights_conv1(2, :, :), conv1_patchsize, conv1_patchsize, conv1_filters);
    weights_conv1(:, :, 3, :) = reshape(w.weights_conv1(3, :, :), conv1_patchsize, conv1_patchsize, conv1_filters);
end
conv1_data = zeros(hei, wid, conv1_filters);
for i = 1 : conv1_filters
    if channel == 1
        conv1_data(:,:,i) = imfilter(im_b, weights_conv1(:,:,i), 'same', 'replicate');
        conv1_data(:,:,i) = max(conv1_data(:,:,i) + w.biases_conv1(i), 0);
    elseif channel == 3
        conv1_result = imfilter(im_b, weights_conv1(:,:,:,i), 'same', 'replicate');
        conv1_data(:,:,i) = conv1_result(:, :, 2);
        conv1_data(:,:,i) = max(conv1_data(:,:,i) + w.biases_conv1(i), 0);
    end
end

%% conv2
conv2_data = zeros(hei, wid, conv2_filters);
for i = 1 : conv2_filters
    for j = 1 : conv2_channels
        conv2_subfilter = reshape(w.weights_conv2(j,:,i), conv2_patchsize, conv2_patchsize);
        conv2_data(:,:,i) = conv2_data(:,:,i) + imfilter(conv1_data(:,:,j), conv2_subfilter, 'same', 'replicate');
    end
    conv2_data(:,:,i) = max(conv2_data(:,:,i) + w.biases_conv2(i), 0);
end

%% conv3
if channel == 1
    conv3_data = zeros(hei, wid);
elseif channel == 3
    conv3_data = zeros(hei, wid, 3);
end
for i = 1 : conv3_channels
    if channel == 1
        conv3_subfilter = reshape(w.weights_conv3(i,:), conv3_patchsize, conv3_patchsize);
        conv3_data(:,:) = conv3_data(:,:) + imfilter(conv2_data(:,:,i), conv3_subfilter, 'same', 'replicate');
        conv3_data(:,:) = conv3_data(:,:) + imfilter(conv2_data(:,:,i), conv3_subfilter, 'same', 'replicate');
    elseif channel == 3
        conv3_subfilter = zeros(conv3_patchsize, conv3_patchsize, 3);
        conv3_subfilter(:, :, 1) = reshape(w.weights_conv3(i, :, 1), conv3_patchsize, conv3_patchsize);
        conv3_subfilter(:, :, 2) = reshape(w.weights_conv3(i, :, 2), conv3_patchsize, conv3_patchsize);
        conv3_subfilter(:, :, 3) = reshape(w.weights_conv3(i, :, 3), conv3_patchsize, conv3_patchsize);
        conv3_res = imfilter(conv2_data(:, :, i), conv3_subfilter(:, :, 1), 'same', 'replicate');
        conv3_data(:, :, 1) = conv3_data(:, :, 1) + conv3_res(:, :);
        conv3_res = imfilter(conv2_data(:, :, i), conv3_subfilter(:, :, 2), 'same', 'replicate');
        conv3_data(:, :, 2) = conv3_data(:, :, 2) + conv3_res(:, :);
        conv3_res = imfilter(conv2_data(:, :, i), conv3_subfilter(:, :, 3), 'same', 'replicate');
        conv3_data(:, :, 3) = conv3_data(:, :, 3) + conv3_res(:, :);
    end
end

%% SRCNN reconstruction
if channel == 1
    im_h = conv3_data + w.biases_conv3;
elseif channel == 3
    im_h = conv3_data;
    im_h(:, :, 1) = im_h(:, :, 1) + w.biases_conv3(1);
    im_h(:, :, 2) = im_h(:, :, 2) + w.biases_conv3(2);
    im_h(:, :, 3) = im_h(:, :, 3) + w.biases_conv3(3);
end

end