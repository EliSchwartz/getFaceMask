function [ mask ] = getFaceMask( img_path )
%getFaceMask returns a mask for the face eyes+nose+mouth area 
%   Inputs:
%       img_path - path to RGB image
%   Outputs:
%       mask - a binary image of the same dimensions as the input image
%   
%   In case of multiple faces the mask is created for only one of them.
%
%   This function uses landmarkpp matlab code (can be found here
%   https://github.com/t0nyren/landmarkpp) which uses the api of the cloud 
%   service landmark++.
%   

% add the landmarkpp folders to path
pathstr = fileparts(mfilename('fullpath'));
addpath(genpath(pathstr));

API_KEY = 'd45344602f6ffd77baeab05b99fb7730';
API_SECRET = 'jKb9XJ_GQ5cKs0QOk6Cj1HordHFBWrgL';
api = facepp(API_KEY, API_SECRET);
rst = detect_file(api, img_path, 'none');
face = rst{1}.face;

N = rst{1}.img_width;
M = rst{1}.img_height;
mask = false(M,N);

fprintf('Totally %d faces detected!\n', length(face));

if isempty(face),
    return
end


face_i = face{1};
% Detect facial key points.
rst2 = api.landmark(face_i.face_id, '83p');
landmark = rst2{1}.result{1}.landmark;

% get coordinates of all landmarks ehich aren't contour
% leaving only eyes+mouth+nose
fields = fieldnames(landmark);
matchContour = regexp(fields, 'contour', 'once');
x = [];
y = [];
for i = 1:numel(fields)
    if ~isempty(matchContour{i}),
        continue
    end
    x = [x landmark.(fields{i}).x * N / 100];
    y = [y landmark.(fields{i}).y * M / 100];
end


% create mask
conv_ind = convhull(x, y);
conv_ind = conv_ind(1:end-1); % remove duplication of start and end point

mask = poly2mask(x(conv_ind), y(conv_ind), M, N);

end

