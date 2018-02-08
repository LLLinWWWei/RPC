function [x,fval,exitflag,output,population,score] = gamul(nvars,lb,ub)
%% This is an auto generated MATLAB file from Optimization Tool.

%% Start with the default options
options = optimoptions('gamultiobj');
%% Modify options setting
options = optimoptions(options,'CrossoverFcn', {  @crossoverintermediate [] });
options = optimoptions(options,'Display', 'off');
options = optimoptions(options,'PlotFcn', { @gaplotpareto });
[x,fval,exitflag,output,population,score] = ...
gamultiobj(@PowerGrid,nvars,[],[],[],[],lb,ub,[],options);
