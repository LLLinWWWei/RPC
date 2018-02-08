function [D,C,aver_D]=Distance(A)
    %% 求复杂网络中两节点的距离、平均最短路径长度以及节点间最短路径条数
    %% 采用Floyd算法计算任意两节点的距离,并求最短路径条数用于计算介数
    % A—————网络图的邻接矩阵, 亦可以是赋权图
    % D—————网络的距离矩阵
    % C—————节点间最短路径条数
    % aver_D—————网络的平均路径长度
    N=size(A,2);    %N为矩阵A的列数
    D=A;
    C=A;
    C((C==inf))=0;  %若A为赋权图，inf表示两点间无连接，所以连接数记为0
    C((C~=0))=1;    %原先直接相连的边记为1，可以有自连接（若A为赋权图，自连接信息就没了）
    D((D==0))=inf;  %将邻接矩阵变为邻接距离矩阵，两点无边相连时赋值为无穷大

    for i=1:N          
        D(i,i)=0;       %自身到自身的距离为0
    end
    for k=1:N            %Floyd算法求解任意两点的最短路径长度
        for i=1:N
            for j=1:N    %可以只算一半，因为是对称的,**不影响结果大小**,但是记得加上D(j,i)=D(i,j)
                if D(i,j)>D(i,k)+D(k,j)
                    D(i,j)=D(i,k)+D(k,j);   %更新ij间距离
                    C(i,j)=C(i,k)*C(k,j);   %更新最短路径条数
                elseif D(i,j)==D(i,k)+D(k,j)
                     if k~=i&&k~=j    %为避免重复计数，这里排除端点；自身距离为0，貌似没必要
                        C(i,j)=C(i,j)+C(i,k)*C(k,j);    %更新与最短距离相同的路径数
                     end
                end
            end
        end
    end
    aver_D=sum(sum(D))/(N*(N-1));  %平均最短路径长度
    if aver_D==inf
       disp('该网络图不是连通图');
    end
end