function [ V_offset ] = Get_V( result )
%  ��ȡsolvecase ,�ڵ�ĵ�ѹƫ��ƽ��+���
%   �˴���ʾ��ϸ˵��
    load_number = length(result.bus(:,1));
    Margin = zeros(load_number,1);
    for i=1:load_number
        if(result.bus(i,2) == 1)
            V = result.bus(i,8);
            Vmax = result.bus(i,12);
            Vmin = result.bus(i,13);
            Margin(i,1) = 1/((1-Vmax)*(1-Vmin)) *(V-Vmax)*(V-Vmin);
        else
            Margin(i,1) = 0;
        end
    end
    Margin(Margin == 0) = [];
    V_offset = min(Margin)+mean(Margin);
end

