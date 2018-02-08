%**********************************************************************************************
%                 Create by  2018 / 1/ 31 Lin Wei                                                                            *
%                 Falut betweeness calculation process                                                                   *
%                 Using LODF, LCDF, Delta_S(change after line outage)                                          *
%                 Scaling the weight to 20                                                                                        *
%                 计算LFB介数，作为目标函数中的权值                                                                       *
%**********************************************************************************************
clc;clear;
warning('off')
disp("*************************************初始化计算**********************************************")
%**********************************************************************************************
%%                载入Case
mpc = loadcase('case39');
mpopt = mpoption('verbose',0,'out.lim.v',0,'out.all',0);
num_branch = size(mpc.branch, 1);
num_bus = size(mpc.bus, 1);
disp("*************************************载入节点模型********************************************")
%**********************************************************************************************
%%               PTDF, LODF ，LCDF and OTDF//     PTDF_B2B is 20X20
PTDF = makePTDF(mpc);
LODF = makeLODF(mpc.branch, PTDF);
%平衡节点为1，其他为0
LODF(:,14)=1;
LODF(isnan(LODF))=0;
PTDF_B2B = zeros(num_branch, num_branch);
OTDF = zeros(num_branch, num_branch);
for i =1:num_branch
      for j =1 :num_branch
            PTDF_B2B(i,j) = PTDF(i,mpc.branch(j,1)) - PTDF(i, mpc.branch(j,2));
      end
end
LCDF = -PTDF_B2B;

for i =1:num_branch
      for j =1 :num_branch
            OTDF(i,j) = PTDF_B2B(i,j) + PTDF_B2B(j,i) *( LODF(i,j)+LCDF(i,j));
      end
end
OTDF(isnan(OTDF))=1;
clear PTDF LODF PTDF_B2B 
disp("*************************************计算PTDFLODF,OTDF***********************************")
%**********************************************************************************************
%%                 互阻抗计算
Y =  makeYbus(mpc);
Y = full(Y);
Y(abs(Y) ==0 + 0j)=inf + inf*j;
Z = abs(1 ./Y);
Z = Distance(Z);
for i =1:size(Z,1)
    Z(i,i)=1;
end
clear Y
disp("*************************************互阻抗计算******************************");
%**********************************************************************************************
%%             R-LODF/R-LCDF  无功改变量/无功原值 ， 无功改变量/故障后无功值
%               (xy, uv) line xy Considering outage of the uv
%               线路xy对于断路发生于uv，当纵轴uv对横轴的影响       
%               ROTDF -无功功率变化指标
    R_LODF = zeros(num_branch, num_branch);
    R_LCDF = zeros(num_branch, num_branch);
    result = runpf(mpc,mpopt);
    Q_nf = max(abs(result.branch(:,15)),abs(result.branch(:,16))); %无功原值
    for i=1:num_branch
        mpc.branch(i,11) = 0;
        result_f = runpf(mpc,mpopt);
        Q_f = max(abs(result_f.branch(:,15)),abs(result_f.branch(:,16))); %故障后无功值
        R_LODF(:,i) = ((Q_f - Q_nf)./Q_nf)';
        R_LCDF(:,i) = ((Q_f - Q_nf)./Q_f)';
        mpc.branch(i,11) = 1; %单边短路，下一阶段前恢复原有线路
    end
    % 分母为0，对角线取值0
    for i =1:num_branch 
        R_LCDF(i,i)=0;
    end
    ROTDF = R_LODF+R_LCDF;
    %clear result

disp("*************************************计算R-LODF,R-LCDF************************************")

%**********************************************************************************************
%%               LFB 介数计算，缩放至20
    LFB = zeros(num_branch,1);
    P_lfb = abs(result.branch(:,14));
    Q_lfb = abs(result.branch(:,15));
    for i = 1:num_branch %% 第 i 条线路断开 
        for j = 1:num_branch
            if  i ~= j 
                LFB(i)  = LFB(i) + (P_lfb(j) .* OTDF(j,i) + Q_lfb(j) .*ROTDF(j,i))/Z(result.branch(i,1), result.branch(j,2));
            end
        end
    end

    LFB = LFB / sum(LFB) * num_branch;
clear P_lfb Q_lfb i j Z
clear num_branch num_bus
clear Q_f  Q_nf  result_f i j R_LODF R_LCDF
save LFB
    
