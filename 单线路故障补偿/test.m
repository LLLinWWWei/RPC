clc;clear;
mpc = loadcase('case39');
for i=1:size(mpc.branch,1)
    
    mpc.branch(i,11)=0;
    mpopt = mpoption('verbose',0,'out.lim.v',0,'out.all',0);
    result = runpf(mpc,mpopt);
    flag = result.success;        %% �Ƿ���ڳ�����
%     if i == 5 | i==14 | i==20 | i== 27 | i==32 | i==33 | i==34 | i==37 | i==39 | i==41 | i==46
%         disp(['��',num2str(i),'����*******************************!']);
%         mpc.branch(i,11)=1;
%         continue
%     end
        if flag                       
            disp(['��',num2str(i),'�εõ�������!']);
        else                        
            disp(['��',num2str(i),'��ģ�⳱���޷����!�ù������޷��ĵõ�������!']);
        end
      mpc.branch(i,11)=1;
end