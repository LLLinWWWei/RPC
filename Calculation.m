%   上交大电网、故障概率下的无功规划选址与容量选择
%   Case14 IEEE14标准节点仿真
%   Create in 19/9 2017.
%   MATPOWER
clear;clc;
% define_constants;
%% 载入例子, 设置参数
mpc = loadcase('case39');
bus_number = length(mpc.bus(:,1));
branch_number = length(mpc.branch(:,1));
loop_times = 1; % 循环次数
load('LFB.mat');
%% 初始参数
flag = 0; 
steady_Probility = zeros(branch_number,1);
steady = zeros(branch_number,1);
reliability = zeros(branch_number,1); % 每次内循环目标函数功耗值
cost = zeros(branch_number,1); %成本函数
gen_cost = zeros(branch_number,1);
%% 初始化函数
% F % 新加约束
f = zeros(branch_number,1);  % 目标函数
%% 循环
warning('off');
  Q_binary = [0,0,0,0,0,0,0,0,0,0,0,0,0,0]';
  Q_capacity = [0,0,0,0,0,0,0,0,0,0,0,0,0,0]';
    for j =1:length(mpc.bus(:,1))
          mpc.bus(j,4) = mpc.bus(j,4) - Q_binary(j,1) .* Q_capacity(j,1);
    end
for i=1:length(mpc.branch(:,1))
    %% 初始化
    mpc.branch(:,11)= 1;  % 恢复为原有来的状态
    disp(['第',num2str(i),'线路故障开始计算。']);
    disp('-------------------------------------------------------------------------');
%     Q_binary = zeros(bus_number,1); %% 二值变量
%     Q_capacity = zeros(bus_number,1);  % 连续变量
    cost(i,1) = capacity_Cost(Q_binary, Q_capacity); % 成本函数
%     for j = 1:length(Q_binary)
%         if Q_binary(j) >= 0.4
%             Q_binary(j)=1;
%         else
%             Q_binary(j)=0;
%         end
%     end
    count = 0;
    mpc.branch(i,11)= 0;
       %% Q约束问题
    try
        mpopt = mpoption('verbose',0,'out.lim.v',0,'out.all',0);
        result = runopf(mpc,mpopt);
        loss = sum(abs(get_losses(result)));
        power = sqrt(result.gen(:,2).^2+result.gen(:,3).^2);
        gen_cost_each= mpc.gencost(:,5) .* (power.^2) + mpc.gencost(:,6) .* (power);
        gen_cost = sum(gen_cost_each);
%             disp(['第',num2str(i),'次模拟潮流计算结束!']);
        flag = result.success;        %% 是否存在潮流解
        if flag                       %% 存在潮流解，计算
%                 disp(['第',num2str(i),'次模拟潮流存在，结算指标值。']);
            [P_index ,Q_index] = get_Gen_margin(result);
            V_index = get_V_margin(result);
            count = count + 1;
            Margin =  (P_index +  Q_index + V_index)/3;
            Loss_Margin = (loss_com(i)-loss)/loss_com(i);
            Cost_Margin = (gen_cost_com(i)-gen_cost)/gen_cost_com(i);
            reliability = reliability + Branch_weight(i) *( Margin + Loss_Margin + Cost_Margin);
            disp(['第',num2str(i),'次节点稳定裕度为',num2str(Margin),'!']);
            disp(['第',num2str(i),'次线损裕度为',num2str(Loss_Margin),'!']);
            disp(['第',num2str(i),'次发电成本裕度为',num2str(Cost_Margin),'!']);
        else                        %% 不存在,跳出继续
            disp(['第',num2str(i),'次模拟潮流无法求解!该故障下无法的得到潮流解!']);
            steady_Probility(i,1) = count / loop_times ;
            steady = steady_Probility(i,1);
%             f(i,1) = Inf;
            continue
        end
    catch
        disp(['第',num2str(i),'次模拟潮流无法计算!']);
        continue
    end
    steady_Probility(i,1) = count / loop_times ;
    steady = steady_Probility(i,1);
    f(i,1) = reliability(i,1);
    disp(['steady_Probility 稳定概率为 : ', num2str(steady_Probility(i,1))]);
    disp(['可靠性指标为 :', num2str(reliability(i,1))]);
    disp(['投资目标函数指标为 : ', num2str(f(i,1))]);
    disp('计算完成。');
    disp('=====================================================================================');
end
clear flag count Q_index P_index V_index i j loop_times power loss Margin Loss_Margin Cost_margin steady gen_cost ...
    gen_cost_each branch_number bus_number reliability
disp(['裕度和为 :', num2str(sum(f))]);
disp(['不崩溃次数为',num2str(sum(steady_Probility))]);
