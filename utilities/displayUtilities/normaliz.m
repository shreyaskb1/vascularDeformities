function out = normaliz(data)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

siz = size(data);
data = data(:);
out = (data-min(data))/(max(data)-min(data));
out = reshape(out,siz);

return