clc;clear;
mpc = loadcase('case39');
for i=1:size(mpc.branch,1)
    
    mpc.branch(i,11)=0;
    mpopt = mpoption('verbose',0,'out.lim.v',0,'out.all',0);
    result = runpf(mpc,mpopt);
    flag = result.success;        %% 是否存在潮流解
%     if i == 5 | i==14 | i==20 | i== 27 | i==32 | i==33 | i==34 | i==37 | i==39 | i==41 | i==46
%         disp(['第',num2str(i),'跳过*******************************!']);
%         mpc.branch(i,11)=1;
%         continue
%     end
        if flag                       
            disp(['第',num2str(i),'次得到潮流解!']);
        else                        
            disp(['第',num2str(i),'次模拟潮流无法求解!该故障下无法的得到潮流解!']);
        end
      mpc.branch(i,11)=1;
end