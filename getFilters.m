function [ w ] = getFilters( modelfilename, weightsfilename )
%SAVEFILTERS Extract filter kernel parameters from caffe model
%   example: getFilters('model/SRCNN_mat.prototxt', 'SRCNN_iter_500.caffemodel')

caffe.reset_all();
%% settings
layers = 3;

%% load model using mat_caffe
net = caffe.Net(modelfilename, weightsfilename, 'test');

%% reshap parameters
weights_conv = cell(layers,1);

for idx = 1 : layers
    conv_filters = net.layers(['conv' num2str(idx)]).params(1).get_data();
    [~,fsize,channel,fnum] = size(conv_filters);

    if channel == 1
        weights = single(ones(fsize^2, fnum));
    else
        weights = single(ones(channel, fsize^2, fnum));
    end
    
    for i = 1 : channel
        for j = 1 : fnum
             temp = conv_filters(:,:,i,j);
             if channel == 1
                weights(:,j) = temp(:);
             else
                weights(i,:,j) = temp(:);
             end
        end
    end

    weights_conv{idx} = weights;
end

%% save parameters
w.weights_conv1 = double(weights_conv{1});
w.weights_conv2 = double(weights_conv{2});
w.weights_conv3 = double(weights_conv{3});
w.biases_conv1 = double(net.layers('conv1').params(2).get_data());
w.biases_conv2 = double(net.layers('conv2').params(2).get_data());
w.biases_conv3 = double(net.layers('conv3').params(2).get_data());

end

