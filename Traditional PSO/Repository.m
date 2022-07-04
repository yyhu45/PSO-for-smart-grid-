%%存档库（储藏室）作用：存档，用来储存过去产生的非支配解
%这里的程序尽量不要动，直接套用即可
classdef Repository %储藏室
    properties
        swarm
        rep_size
        Grid
        grid_size
        alpha
        beta
        gamma
    end
    
    methods
        function obj = Repository(swarm,rep_size,grid_size,alpha,beta,gamma) %存档库
            if nargin>0
                obj.rep_size = rep_size;
                swarm = Particle.updateDomination(swarm);
                obj.swarm = swarm(~[swarm.isDominated]);
                obj.grid_size=grid_size;
                obj.alpha=alpha;
                obj.beta = beta;
                obj.gamma = gamma;
                obj.Grid=obj.grid();
                for i = 1:length(obj.swarm)
                    obj.swarm(i) = obj.swarm(i).updateGridIndex(obj.Grid);
                end
            end
        end
        function Grid = grid(obj) %更新网格
            C = vertcat(obj.swarm.cost);
            cmin = min(C,[],1);
            cmax = max(C,[],1);
            dc = cmax - cmin;
            cmin = cmin - obj.alpha * dc;
            cmax = cmax + obj.alpha * dc;
            nObj = size(C,2);
            empty_grid.LB = [];
            empty_grid.UB = [];
            Grid = repmat(empty_grid,nObj,1);
            for j = 1:nObj
                cj = linspace(cmin(j),cmax(j),obj.grid_size+1);
                Grid(j).LB = [-inf, cj];
                Grid(j).UB = [cj, +inf];
            end
        end
        function leader = SelectLeader(obj) %选择领导者
            GI = [obj.swarm.GridIndex];
            OC = unique(GI);
            N = zeros(size(OC));
            for k = 1:length(OC)
                N(k) = length(find(GI==OC(k)));
            end
            P = exp(-obj.beta*N);
            P = P/sum(P);
            sci = Repository.RouletteWheelSelection(P);
            sc = OC(sci);
            SCM = find(GI==sc);
            smi = randi([1 length(SCM)]);
            sm = SCM(smi);
            leader = obj.swarm(sm);
        end
        function obj = DeleteOneRepMemebr(obj) %删除一个存档库的成员
            GI=[obj.swarm.GridIndex];
            OC=unique(GI);
            N=zeros(size(OC));
            for k=1:length(OC)
                N(k)=length(find(GI==OC(k)));
            end
            P=exp(obj.gamma*N);
            P=P/sum(P);
            sci=Repository.RouletteWheelSelection(P);
            sc=OC(sci);
            SCM=find(GI==sc);
            smi=randi([1 length(SCM)]);
            sm=SCM(smi);
            obj.swarm(sm)=[];
        end
        function obj = update(obj,swarm)  %更新
            swarm = Particle.updateDomination(swarm);
            obj.swarm = [obj.swarm,swarm(~[swarm.isDominated])];
            obj.swarm = Particle.updateDomination(obj.swarm);
            obj.swarm = obj.swarm(~[obj.swarm.isDominated]);
            obj.Grid=obj.grid();
            for i = 1:length(obj.swarm)
                obj.swarm(i) = obj.swarm(i).updateGridIndex(obj.Grid);
            end
            Extra=length(obj.swarm)-obj.rep_size;
            for e=1:Extra
                obj=obj.DeleteOneRepMemebr();
            end
        end
    end
    methods (Static)
        function i = RouletteWheelSelection(P) %轮盘赌筛选进行删除
            i = find(rand<=cumsum(P),1,'first');
        end
    end
end

