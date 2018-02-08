function [ cost ] = capacity_Cost(result,x)
%   此处显示详细说明
%   经济费用总函数，发电成本为主导
    loss = sum(abs(get_losses(result)));  % 总线损
    cop = sum(abs(x));  % 无功调节费用
    %gen_cost = totcost(result.gencost, result.gen(:,2));% 发电总成本改变量
    temp = loss + cop; 
    Cp = temp.^2 * 0.01 + temp * 20 ; % 
    cost =Cp;% 花费函数
end

