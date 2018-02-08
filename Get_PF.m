function [ Power_factor]  = Get_PF(result)
%   获得solvecase 数据的发电节点 功率因数
    P =  result.gen(:,2);
    Q = result.gen(:,3);
    Power_factor = mean(P ./ sqrt( P.^2 + Q.^2));
end

