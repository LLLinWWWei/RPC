function [ cost ] = capacity_Cost(result,x)
%   �˴���ʾ��ϸ˵��
%   ���÷����ܺ���������ɱ�Ϊ����
    loss = sum(abs(get_losses(result)));  % ������
    cop = sum(abs(x));  % �޹����ڷ���
    %gen_cost = totcost(result.gencost, result.gen(:,2));% �����ܳɱ��ı���
    temp = loss + cop; 
    Cp = temp.^2 * 0.01 + temp * 20 ; % 
    cost =Cp;% ���Ѻ���
end

