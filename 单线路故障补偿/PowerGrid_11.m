function f = PowerGrid_11(x)
%   �����µ��޹���������
%   Case14 IEEE14��׼�ڵ����
%   Create in 5/2 2018
%   MATPOWER
%% ��������, ���ò���
warning('off');
mpc = loadcase('case39');
load('LFB.mat'); %#ok<LOAD>
num_branch = size(mpc.branch,1);
num_bus = size(mpc.bus,1);
%num_load = size(find(mpc.bus(:,2)==1),1);
k = 1; %�������޹������븺�ɽڵ�


%%  ���ö�Ŀ�꺯��
f = zeros(2,1);
%%  �޹��������������븺�ɽڵ�
%  x Ϊ���ؽڵ㲹����
    for i =1:num_bus
         if mpc.bus(i,2) == 1
            mpc.bus(i,4) = mpc.bus(i,4) - x(k);
            k = k+1;
         end
    end
    mpc.branch(11,11) = 0;
    mpopt = mpoption('verbose',0,'out.lim.v',0,'out.all',0);
    result = runpf(mpc, mpopt);
  %%  Ŀ�꺯��--�����µ�����������
%    for i = 1:num_branch
%        %disp(['��',num2str(i),'��·���Ͽ�ʼ���㡣']);
%         %disp('=========================================================');
%         flag = result.success;        %% �Ƿ���ڳ�����     
%         %disp(['��',num2str(i),'����·������flagֵΪ!',num2str(flag)]);
%          % �����²������ķ���ɱ�������
%         if flag                     %% ���ڳ����⣬����
            V_offset = Get_V(result);
            PowerFactor = Get_PF(result);
            f(1) = f(1) + LFB(11) * (V_offset-PowerFactor);
%         else                       
%             %disp(['��',num2str(i),'����·������ģ�⳱���޷����!�ù������޷��ĵõ�������!']);
%             f(1) =  f(1) + LFB(i);  
%         end
        %% ����-���ʲ����ɱ�����
        f(2) = capacity_Cost(result,x);
%     end
    disp(['Ŀ�꺯��f(1)Ϊ :', num2str(f(1))]);
    disp(['Ŀ�꺯��f(2)Ϊ : ', num2str(f(2))]);
   % disp('������ɡ�');
   disp('************************************************************************************');
 end

