%**********************************************************************************************
%                 Create by  2018 / 1/ 31 Lin Wei                                                                            *
%                 Falut betweeness calculation process                                                                   *
%                 Using LODF, LCDF, Delta_S(change after line outage)                                          *
%                 Scaling the weight to 20                                                                                        *
%                 ����LFB��������ΪĿ�꺯���е�Ȩֵ                                                                       *
%**********************************************************************************************
clc;clear;
warning('off')
disp("*************************************��ʼ������**********************************************")
%**********************************************************************************************
%%                ����Case
mpc = loadcase('case39');
mpopt = mpoption('verbose',0,'out.lim.v',0,'out.all',0);
num_branch = size(mpc.branch, 1);
num_bus = size(mpc.bus, 1);
disp("*************************************����ڵ�ģ��********************************************")
%**********************************************************************************************
%%               PTDF, LODF ��LCDF and OTDF//     PTDF_B2B is 20X20
PTDF = makePTDF(mpc);
LODF = makeLODF(mpc.branch, PTDF);
%ƽ��ڵ�Ϊ1������Ϊ0
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
disp("*************************************����PTDFLODF,OTDF***********************************")
%**********************************************************************************************
%%                 ���迹����
Y =  makeYbus(mpc);
Y = full(Y);
Y(abs(Y) ==0 + 0j)=inf + inf*j;
Z = abs(1 ./Y);
Z = Distance(Z);
for i =1:size(Z,1)
    Z(i,i)=1;
end
clear Y
disp("*************************************���迹����******************************");
%**********************************************************************************************
%%             R-LODF/R-LCDF  �޹��ı���/�޹�ԭֵ �� �޹��ı���/���Ϻ��޹�ֵ
%               (xy, uv) line xy Considering outage of the uv
%               ��·xy���ڶ�·������uv��������uv�Ժ����Ӱ��       
%               ROTDF -�޹����ʱ仯ָ��
    R_LODF = zeros(num_branch, num_branch);
    R_LCDF = zeros(num_branch, num_branch);
    result = runpf(mpc,mpopt);
    Q_nf = max(abs(result.branch(:,15)),abs(result.branch(:,16))); %�޹�ԭֵ
    for i=1:num_branch
        mpc.branch(i,11) = 0;
        result_f = runpf(mpc,mpopt);
        Q_f = max(abs(result_f.branch(:,15)),abs(result_f.branch(:,16))); %���Ϻ��޹�ֵ
        R_LODF(:,i) = ((Q_f - Q_nf)./Q_nf)';
        R_LCDF(:,i) = ((Q_f - Q_nf)./Q_f)';
        mpc.branch(i,11) = 1; %���߶�·����һ�׶�ǰ�ָ�ԭ����·
    end
    % ��ĸΪ0���Խ���ȡֵ0
    for i =1:num_branch 
        R_LCDF(i,i)=0;
    end
    ROTDF = R_LODF+R_LCDF;
    %clear result

disp("*************************************����R-LODF,R-LCDF************************************")

%**********************************************************************************************
%%               LFB �������㣬������20
    LFB = zeros(num_branch,1);
    P_lfb = abs(result.branch(:,14));
    Q_lfb = abs(result.branch(:,15));
    for i = 1:num_branch %% �� i ����·�Ͽ� 
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
    
