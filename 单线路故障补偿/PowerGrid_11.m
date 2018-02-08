function f = PowerGrid_11(x)
%   故障下的无功补偿策略
%   Case14 IEEE14标准节点仿真
%   Create in 5/2 2018
%   MATPOWER
%% 载入例子, 设置参数
warning('off');
mpc = loadcase('case39');
load('LFB.mat'); %#ok<LOAD>
num_branch = size(mpc.branch,1);
num_bus = size(mpc.bus,1);
%num_load = size(find(mpc.bus(:,2)==1),1);
k = 1; %设置与无功补偿与负荷节点


%%  设置多目标函数
f = zeros(2,1);
%%  无功补偿量，补偿与负荷节点
%  x 为负载节点补偿量
    for i =1:num_bus
         if mpc.bus(i,2) == 1
            mpc.bus(i,4) = mpc.bus(i,4) - x(k);
            k = k+1;
         end
    end
    mpc.branch(11,11) = 0;
    mpopt = mpoption('verbose',0,'out.lim.v',0,'out.all',0);
    result = runpf(mpc, mpopt);
  %%  目标函数--故障下电能质量计算
%    for i = 1:num_branch
%        %disp(['第',num2str(i),'线路故障开始计算。']);
%         %disp('=========================================================');
%         flag = result.success;        %% 是否存在潮流解     
%         %disp(['第',num2str(i),'根线路故障下flag值为!',num2str(flag)]);
%          % 故障下不补偿的发电成本、网损
%         if flag                     %% 存在潮流解，计算
            V_offset = Get_V(result);
            PowerFactor = Get_PF(result);
            f(1) = f(1) + LFB(11) * (V_offset-PowerFactor);
%         else                       
%             %disp(['第',num2str(i),'根线路故障下模拟潮流无法求解!该故障下无法的得到潮流解!']);
%             f(1) =  f(1) + LFB(i);  
%         end
        %% 线损-功率补偿成本计算
        f(2) = capacity_Cost(result,x);
%     end
    disp(['目标函数f(1)为 :', num2str(f(1))]);
    disp(['目标函数f(2)为 : ', num2str(f(2))]);
   % disp('计算完成。');
   disp('************************************************************************************');
 end

