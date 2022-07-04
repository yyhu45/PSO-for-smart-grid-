%�����ʼ��
clear;
clc;
close all;
%����ȫ�ֱ���
global P_load; %�縺��
global WT;%���
global PV;%���
global buy_price;
global sell_price;
%��ȡ����
data=xlsread('mopso_data');
P_load=data(:,1);
PV=data(:,2);
WT=data(:,3);
buy_price=data(:,4);
sell_price=data(:,5);

%�������ŵ繦�ʣ�����ʾΪ�縺�ɹ��磬���ŵ磩
BESSMax_dischar=30;
%��������繦��
BESSMax_char=-30;
%���ͻ���󷢵繦��
DEMax=30;
%���ͻ���С���繦��
DEMin=6;
%ȼ���ֻ���󷢵繦��
MTMax=30;
%ȼ���ֻ���С���繦��
MTMin=3;
%�������������(����ʾΪ�縺�ɹ���)
GridMax=30;
%����������С����
GridMin=-30;
%% ����mopso����
mm=mopso; %����mopso����
nn=length(mm.swarm); %��֧�����Ŀ

%% �Ƚϲ�ͬĿ�꺯��Ѱ�ŶԵ��Ƚ����Ӱ��
%% ��1��.������Ŀ�꺯��ֵ��һ����ӣ�ȡ��Ӻ���С��Ŀ��ֵ�����ӣ���Ѱ�����ԽⲢ��ͼ
%����֧����е����гɱ��ͻ��������ɱ��ֱ�ֵ��yyy,xxx
% for i=1:nn
%    yyy(i)= mm.swarm(1,i).cost(1);
%    xxx(i)= mm.swarm(1,i).cost(2);
% end
% m1=max(yyy);
% m2=max(xxx);
% 
% for i=1:nn
%     object(i)= mm.swarm(1,i).cost(1)./m1+ mm.swarm(1,i).cost(2)./m2;
%     f1(i)=mm.swarm(1,i).cost(1)./m1;
%     f2(i)=mm.swarm(1,i).cost(2)./m2;
% end
% [m,p]=min(object); %�õ�������СĿ��ֵ��΢�����ڵ�����P
% pg=mm.swarm(1,p).x; %pgΪ���Խ�
% Title = sprintf('���Խ������');
%% ��2��Ѱ���ܳɱ����ʱ�ĽⲢ��ͼ
for i=1:nn
    object(i)= mm.swarm(1,i).cost(1)+ mm.swarm(1,i).cost(2);
end
[m,p]=min(object); %�õ�������СĿ��ֵ��΢�����ڵ�����P
pg=mm.swarm(1,p).x; %pgΪ�ܳɱ����ʱ�Ľ�
Title = sprintf('�ܳɱ���������');
%% ��3��Ѱ�����гɱ����ʱ�ĽⲢ��ͼ
% for i=1:nn
%     object(i)= mm.swarm(1,i).cost(1);
% end
% [m,p]=min(object); %�õ�������СĿ��ֵ��΢�����ڵ�����P
% pg=mm.swarm(1,p).x; %pgΪ���гɱ����ʱ�Ľ�
% Title = sprintf('���гɱ���������');
%% ��4��Ѱ�һ��������ɱ����ʱ�ĽⲢ��ͼ
% for i=1:nn
%     object(i)= mm.swarm(1,i).cost(2);
% end
% [m,p]=min(object); %�õ�������СĿ��ֵ��΢�����ڵ�����P
% pg=mm.swarm(1,p).x; %pgΪ���������ɱ����ʱ�Ľ�
% Title = sprintf('���������ɱ���������');

%% ��ͬ����µĽ⸳ֵ
 for i=1:24
   pg_PV(i)=pg(i);
 end  
 
 for m=25:48
    pg_WT(m-24)=pg(m);
end
for m=49:72
    pg_BESS(m-48)=pg(m);
end
for m=73:96
    pg_DE(m-72)=pg(m);
end
for m=97:120
    pg_MT(m-96)=pg(m);
end
for m=121:144
    pg_grid(m-120)=pg(m);
end
%% ��ͼ
figure(2)
plot(pg_PV,'-*')
hold on;
plot(PV,'-r*')
xlim([1 24])
grid
legend('ʵ�����ɹ������','Ԥ��������');
xlabel('ʱ��');
ylabel('����');
title('��������')


figure(3)
plot(pg_WT,'-*')
hold on;
plot(WT,'-r*')
xlim([1 24])
grid
legend('ʵ�����ɷ�繦��','Ԥ���繦��');
xlabel('ʱ��');
ylabel('����');
title('���������')

figure(4)
plot(pg_DE,'-k*')
hold on;
xlim([1 24])
grid
xlabel('ʱ��');
ylabel('����');
title('���ͷ����')

figure(5)
plot(pg_BESS,'-*')
xlim([1 24])
grid
xlabel('ʱ��');
ylabel('����');
title('����')


figure(6)
plot(P_load,'-c*')
xlim([1 24])
grid
xlabel('ʱ��');
ylabel('����');
title('΢��������')

figure(7)
plot(pg_MT,'-m*')
grid
xlabel('ʱ��');
ylabel('����');
title('ȼ���ֻ�����')

figure(8)
plot(pg_grid,'-g*')
xlim([1 24])
grid
xlabel('ʱ��');
ylabel('����');
title('��������')

figure(9)
plot(pg_BESS);
hold on
plot(pg_PV,'-d')
grid
plot(pg_WT,'-d');
plot( pg_DE,'-d')
plot(pg_grid,'-d')
plot(pg_MT,'-d')
legend('BESS','PV','WT','DE','grid','MT');
xlabel('ʱ��/h')
ylabel('����/kw')
title(Title)


