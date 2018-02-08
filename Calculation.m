%   �Ͻ�����������ϸ����µ��޹��滮ѡַ������ѡ��
%   Case14 IEEE14��׼�ڵ����
%   Create in 19/9 2017.
%   MATPOWER
clear;clc;
% define_constants;
%% ��������, ���ò���
mpc = loadcase('case39');
bus_number = length(mpc.bus(:,1));
branch_number = length(mpc.branch(:,1));
loop_times = 1; % ѭ������
load('LFB.mat');
%% ��ʼ����
flag = 0; 
steady_Probility = zeros(branch_number,1);
steady = zeros(branch_number,1);
reliability = zeros(branch_number,1); % ÿ����ѭ��Ŀ�꺯������ֵ
cost = zeros(branch_number,1); %�ɱ�����
gen_cost = zeros(branch_number,1);
%% ��ʼ������
% F % �¼�Լ��
f = zeros(branch_number,1);  % Ŀ�꺯��
%% ѭ��
warning('off');
  Q_binary = [0,0,0,0,0,0,0,0,0,0,0,0,0,0]';
  Q_capacity = [0,0,0,0,0,0,0,0,0,0,0,0,0,0]';
    for j =1:length(mpc.bus(:,1))
          mpc.bus(j,4) = mpc.bus(j,4) - Q_binary(j,1) .* Q_capacity(j,1);
    end
for i=1:length(mpc.branch(:,1))
    %% ��ʼ��
    mpc.branch(:,11)= 1;  % �ָ�Ϊԭ������״̬
    disp(['��',num2str(i),'��·���Ͽ�ʼ���㡣']);
    disp('-------------------------------------------------------------------------');
%     Q_binary = zeros(bus_number,1); %% ��ֵ����
%     Q_capacity = zeros(bus_number,1);  % ��������
    cost(i,1) = capacity_Cost(Q_binary, Q_capacity); % �ɱ�����
%     for j = 1:length(Q_binary)
%         if Q_binary(j) >= 0.4
%             Q_binary(j)=1;
%         else
%             Q_binary(j)=0;
%         end
%     end
    count = 0;
    mpc.branch(i,11)= 0;
       %% QԼ������
    try
        mpopt = mpoption('verbose',0,'out.lim.v',0,'out.all',0);
        result = runopf(mpc,mpopt);
        loss = sum(abs(get_losses(result)));
        power = sqrt(result.gen(:,2).^2+result.gen(:,3).^2);
        gen_cost_each= mpc.gencost(:,5) .* (power.^2) + mpc.gencost(:,6) .* (power);
        gen_cost = sum(gen_cost_each);
%             disp(['��',num2str(i),'��ģ�⳱���������!']);
        flag = result.success;        %% �Ƿ���ڳ�����
        if flag                       %% ���ڳ����⣬����
%                 disp(['��',num2str(i),'��ģ�⳱�����ڣ�����ָ��ֵ��']);
            [P_index ,Q_index] = get_Gen_margin(result);
            V_index = get_V_margin(result);
            count = count + 1;
            Margin =  (P_index +  Q_index + V_index)/3;
            Loss_Margin = (loss_com(i)-loss)/loss_com(i);
            Cost_Margin = (gen_cost_com(i)-gen_cost)/gen_cost_com(i);
            reliability = reliability + Branch_weight(i) *( Margin + Loss_Margin + Cost_Margin);
            disp(['��',num2str(i),'�νڵ��ȶ�ԣ��Ϊ',num2str(Margin),'!']);
            disp(['��',num2str(i),'������ԣ��Ϊ',num2str(Loss_Margin),'!']);
            disp(['��',num2str(i),'�η���ɱ�ԣ��Ϊ',num2str(Cost_Margin),'!']);
        else                        %% ������,��������
            disp(['��',num2str(i),'��ģ�⳱���޷����!�ù������޷��ĵõ�������!']);
            steady_Probility(i,1) = count / loop_times ;
            steady = steady_Probility(i,1);
%             f(i,1) = Inf;
            continue
        end
    catch
        disp(['��',num2str(i),'��ģ�⳱���޷�����!']);
        continue
    end
    steady_Probility(i,1) = count / loop_times ;
    steady = steady_Probility(i,1);
    f(i,1) = reliability(i,1);
    disp(['steady_Probility �ȶ�����Ϊ : ', num2str(steady_Probility(i,1))]);
    disp(['�ɿ���ָ��Ϊ :', num2str(reliability(i,1))]);
    disp(['Ͷ��Ŀ�꺯��ָ��Ϊ : ', num2str(f(i,1))]);
    disp('������ɡ�');
    disp('=====================================================================================');
end
clear flag count Q_index P_index V_index i j loop_times power loss Margin Loss_Margin Cost_margin steady gen_cost ...
    gen_cost_each branch_number bus_number reliability
disp(['ԣ�Ⱥ�Ϊ :', num2str(sum(f))]);
disp(['����������Ϊ',num2str(sum(steady_Probility))]);
