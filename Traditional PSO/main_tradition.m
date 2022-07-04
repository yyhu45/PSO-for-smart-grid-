%程序初始化
clear;
clc;
close all;
%定义全局变量
global P_load; %电负荷
global WT;%风电
global PV;%光伏
global buy_price;
global sell_price;
%获取数据
data=xlsread('mopso_data');
P_load=data(:,1);
PV=data(:,2);
WT=data(:,3);
buy_price=data(:,4);
sell_price=data(:,5);

%蓄电池最大放电功率（正表示为电负荷供电，即放电）
BESSMax_dischar=30;
%蓄电池最大充电功率
BESSMax_char=-30;
%柴油机最大发电功率
DEMax=30;
%柴油机最小发电功率
DEMin=6;
%燃气轮机最大发电功率
MTMax=30;
%燃气轮机最小发电功率
MTMin=3;
%主网交互最大功率(正表示为电负荷供电)
GridMax=30;
%主网交互最小功率
GridMin=-30;
%% 调用mopso函数
mm=mopso; %调用mopso函数
nn=length(mm.swarm); %非支配解数目

%% 比较不同目标函数寻优对调度结果的影响
%% 第1种.将两个目标函数值归一化相加，取相加后最小的目标值的粒子，即寻找折衷解并画图
%将非支配解中的运行成本和环境保护成本分别赋值给yyy,xxx
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
% [m,p]=min(object); %得到有着最小目标值的微粒所在的行数P
% pg=mm.swarm(1,p).x; %pg为折衷解
% Title = sprintf('折衷解情况下');
%% 第2种寻找总成本最低时的解并画图
for i=1:nn
    object(i)= mm.swarm(1,i).cost(1)+ mm.swarm(1,i).cost(2);
end
[m,p]=min(object); %得到有着最小目标值的微粒所在的行数P
pg=mm.swarm(1,p).x; %pg为总成本最低时的解
Title = sprintf('总成本最低情况下');
%% 第3种寻找运行成本最低时的解并画图
% for i=1:nn
%     object(i)= mm.swarm(1,i).cost(1);
% end
% [m,p]=min(object); %得到有着最小目标值的微粒所在的行数P
% pg=mm.swarm(1,p).x; %pg为运行成本最低时的解
% Title = sprintf('运行成本最低情况下');
%% 第4种寻找环境保护成本最低时的解并画图
% for i=1:nn
%     object(i)= mm.swarm(1,i).cost(2);
% end
% [m,p]=min(object); %得到有着最小目标值的微粒所在的行数P
% pg=mm.swarm(1,p).x; %pg为环境保护成本最低时的解
% Title = sprintf('环境保护成本最低情况下');

%% 不同情况下的解赋值
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
%% 画图
figure(2)
plot(pg_PV,'-*')
hold on;
plot(PV,'-r*')
xlim([1 24])
grid
legend('实际消纳光伏功率','预测光伏功率');
xlabel('时间');
ylabel('功率');
title('光伏发电机')


figure(3)
plot(pg_WT,'-*')
hold on;
plot(WT,'-r*')
xlim([1 24])
grid
legend('实际消纳风电功率','预测风电功率');
xlabel('时间');
ylabel('功率');
title('风力发电机')

figure(4)
plot(pg_DE,'-k*')
hold on;
xlim([1 24])
grid
xlabel('时间');
ylabel('功率');
title('柴油发电机')

figure(5)
plot(pg_BESS,'-*')
xlim([1 24])
grid
xlabel('时间');
ylabel('功率');
title('蓄电池')


figure(6)
plot(P_load,'-c*')
xlim([1 24])
grid
xlabel('时间');
ylabel('功率');
title('微电网负荷')

figure(7)
plot(pg_MT,'-m*')
grid
xlabel('时间');
ylabel('功率');
title('燃气轮机出力')

figure(8)
plot(pg_grid,'-g*')
xlim([1 24])
grid
xlabel('时间');
ylabel('功率');
title('主网交互')

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
xlabel('时间/h')
ylabel('功率/kw')
title(Title)


