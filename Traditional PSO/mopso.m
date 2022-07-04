function [REP]= mopso(c,iw,max_iter,lower_bound,upper_bound,swarm_size,rep_size,grid_size,alpha,beta,gamma,mu,problem)
%mopso �Ƕ�Ŀ������Ⱥ�Ż���ʵ��
% ��С������ļ���
%% ��ʼ������
global PV;
global WT;
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
%% ��Ⱥ��ʼ��
if nargin==0  %nargin���ж�������������ĺ���
    c = [0.1,0.2]; % ��������
    iw = 0.6; % ��������
    max_iter =100; % ����������
    %���豸����Լ��
    for n=1:144 %���ӳ���Ϊ144���������磬���ܣ�����,ȼ���ֻ���������6*24��Сʱ������
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
    swarm_size=100; % ��Ⱥ����
    rep_size=100; % �浵���С
    grid_size=7; % ÿ��ά�ȵ�������
    alpha=0.1; % ͨ��������
    beta=2; % �쵼��ѡ��ѹ��
    gamma=2; % ɾ��ѡ��ѹ��
    mu=0.1; % ��������
    problem=@prob; % �����������Ϊproblem������Ϊpro�����Լ����Ϊ����
end
%% ��ʼ������
fprintf('��ʼ����Ⱥ��\n')
%��ͳ����Ⱥ�㷨���������ӹ̶������Ӳ�����
w = @(it) (0.6); %��ͳ����Ⱥ�㷨�����������ǹ̶��ģ�ȡ0.6
pm = @(it) (0); %��ͳ����Ⱥ�㷨�������죬��particle������78-84��
swarm(1,swarm_size) = Particle(); %����Particle��������obj�еõ�swarm_size
for i = 1:swarm_size
    swarm(i)=Particle(lower_bound,upper_bound,problem);%����Particle����
    retry = 0;
    while swarm(i).infeasablity > 0 && retry < 100 %ѭ������Ϊ���޲����н��Ҵ�������100
        swarm(i)=Particle(lower_bound,upper_bound,problem);%����Particle����
        retry = retry + 1;
    end
end
REP = Repository(swarm,rep_size,grid_size,alpha,beta,gamma); %����Repository����
%% �㷨ѭ��
fprintf('�Ż��㷨��ʼѭ����\n')
for it=1:max_iter
    leader = REP.SelectLeader(); %ѡ���쵼��
    wc = w(it); %Ŀǰ�Ĺ�������
    pc=pm(it); %Ŀǰ�ı�������
    for i =1:swarm_size %������Ⱥ
        swarm(i)=swarm(i).update(wc,c,pc,leader,problem);
    end
    REP = REP.update(swarm);
    Title = sprintf('������ %d �� , �浵���ڷ�֧������ = %d',it,length(REP.swarm));
    PlotCosts(swarm,REP.swarm,Title) %���������PlotCosts����
    disp(Title);
end

function PlotCosts(swarm,rep,Title)
    %��������Ⱥ�Ķ�̬
figure(1)
feasable_swarm = swarm([swarm.infeasablity]==0); %���н�
infeasable_swarm = swarm([swarm.infeasablity]>0); %�ǿ��н�
LEG = {};
if ~isempty(feasable_swarm)
    swarm_costs=vertcat(feasable_swarm.cost);
    plot(swarm_costs(:,1),swarm_costs(:,2),'go')
    hold on
    LEG = {'mospo�Ŀ��н�'};
    Title = sprintf([Title '\n���н�ĸ���=%d'],length(feasable_swarm));
end
if ~isempty(infeasable_swarm)
    swarm_costs=vertcat(infeasable_swarm.cost);
    plot(swarm_costs(:,1),swarm_costs(:,2),'ro')
    hold on
    LEG = [LEG, 'mopso�ķǿ��н�'];
    if contains(Title,newline)
        Title = sprintf([Title ', �ǿ��н�ĸ��� =%d'],length(infeasable_swarm));
    else
        Title = sprintf([Title '\n���н�ĸ���=%d'],length(infeasable_swarm));
    end
end
rep_costs=vertcat(rep.cost);
plot(rep_costs(:,1),rep_costs(:,2),'b*')
xlabel('Ŀ�꺯��1�����гɱ�')
ylabel('Ŀ�꺯��2�����������ɱ�')
grid on
hold off
title(Title)
legend([LEG ,'�浵���ڷ�ռ�Ž�'],'location','best')
drawnow

figure(10)
plot(rep_costs(:,1),rep_costs(:,2),'m*')
xlabel('���гɱ�')
ylabel('���������ɱ�')
grid on
hold off
title('paretoǰ�ؽ⼯')
drawnow
end
end