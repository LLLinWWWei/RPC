function [ Power_factor]  = Get_PF(result)
%   ���solvecase ���ݵķ���ڵ� ��������
    P =  result.gen(:,2);
    Q = result.gen(:,3);
    Power_factor = mean(P ./ sqrt( P.^2 + Q.^2));
end

