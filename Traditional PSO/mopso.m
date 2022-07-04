function [REP]= mopso(c,iw,max_iter,lower_bound,upper_bound,swarm_size,rep_size,grid_size,alpha,beta,gamma,mu,problem)
%mopso 是多目标粒子群优化的实现
% 最小化问题的技术
%% 初始化参数
global PV;
global WT;
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
%% 种群初始化
if nargin==0  %nargin是判断输入变量个数的函数
    c = [0.1,0.2]; % 加速因子
    iw = 0.6; % 惯性因子
    max_iter =100; % 最大迭代次数
    %各设备出力约束
    for n=1:144 %粒子长度为144（光伏，风电，储能，柴油,燃气轮机，主网的6*24个小时出力）
         if n<25
            lower_bound(n)=0;
            upper_bound(n) =PV(n);
          end
         if n>24&&n<49
            lower_bound(n)=0;
            upper_bound(n) =WT(n-24);
         end
         if n>48&&n<73
         lower_bound(n)=BESSMax_char;
         upper_bound(n) =BESSMax_dischar;
         end
         if n>72&&n<97
         lower_bound(n)=DEMin;
         upper_bound(n) =DEMax;
         end
          if n>96&&n<121
         lower_bound(n)=MTMin;
         upper_bound(n) =MTMax;
          end
          if n>120
         lower_bound(n)=GridMin;
         upper_bound(n) =GridMax;
         end
    end
    swarm_size=100; % 种群个数
    rep_size=100; % 存档库大小
    grid_size=7; % 每个维度的网格数
    alpha=0.1; % 通货膨胀率
    beta=2; % 领导人选择压力
    gamma=2; % 删除选择压力
    mu=0.1; % 变异速率
    problem=@prob; % 创建函数句柄为problem，函数为pro，可以简单理解为调用
end
%% 初始化粒子
fprintf('初始化种群中\n')
%传统粒子群算法，惯性因子固定，粒子不变异
w = @(it) (0.6); %传统粒子群算法，惯性因子是固定的，取0.6
pm = @(it) (0); %传统粒子群算法，不变异，在particle函数的78-84行
swarm(1,swarm_size) = Particle(); %调用Particle函数，从obj中得到swarm_size
for i = 1:swarm_size
    swarm(i)=Particle(lower_bound,upper_bound,problem);%调用Particle函数
    retry = 0;
    while swarm(i).infeasablity > 0 && retry < 100 %循环条件为：无不可行解且次数低于100
        swarm(i)=Particle(lower_bound,upper_bound,problem);%调用Particle函数
        retry = retry + 1;
    end
end
REP = Repository(swarm,rep_size,grid_size,alpha,beta,gamma); %调用Repository函数
%% 算法循环
fprintf('优化算法开始循环中\n')
for it=1:max_iter
    leader = REP.SelectLeader(); %选择领导者
    wc = w(it); %目前的惯性因子
    pc=pm(it); %目前的变异因子
    for i =1:swarm_size %更新种群
        swarm(i)=swarm(i).update(wc,c,pc,leader,problem);
    end
    REP = REP.update(swarm);
    Title = sprintf('迭代第 %d 次 , 存档库内非支配解个数 = %d',it,length(REP.swarm));
    PlotCosts(swarm,REP.swarm,Title) %调用下面的PlotCosts函数
    disp(Title);
end

function PlotCosts(swarm,rep,Title)
    %画出粒子群的动态
figure(1)
feasable_swarm = swarm([swarm.infeasablity]==0); %可行解
infeasable_swarm = swarm([swarm.infeasablity]>0); %非可行解
LEG = {};
if ~isempty(feasable_swarm)
    swarm_costs=vertcat(feasable_swarm.cost);
    plot(swarm_costs(:,1),swarm_costs(:,2),'go')
    hold on
    LEG = {'mospo的可行解'};
    Title = sprintf([Title '\n可行解的个数=%d'],length(feasable_swarm));
end
if ~isempty(infeasable_swarm)
    swarm_costs=vertcat(infeasable_swarm.cost);
    plot(swarm_costs(:,1),swarm_costs(:,2),'ro')
    hold on
    LEG = [LEG, 'mopso的非可行解'];
    if contains(Title,newline)
        Title = sprintf([Title ', 非可行解的个数 =%d'],length(infeasable_swarm));
    else
        Title = sprintf([Title '\n可行解的个数=%d'],length(infeasable_swarm));
    end
end
rep_costs=vertcat(rep.cost);
plot(rep_costs(:,1),rep_costs(:,2),'b*')
xlabel('目标函数1：运行成本')
ylabel('目标函数2：环境保护成本')
grid on
hold off
title(Title)
legend([LEG ,'存档库内非占优解'],'location','best')
drawnow

figure(10)
plot(rep_costs(:,1),rep_costs(:,2),'m*')
xlabel('运行成本')
ylabel('环境保护成本')
grid on
hold off
title('pareto前沿解集')
drawnow
end
end