%求解多目标粒子群的适应度
function [c,result]=fitness(x)
global P_load;
global buy_price;
global sell_price;
%% 约束条件%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DE爬坡约束处理
DE_sum=0;
for i=73:95
   DE_temp(i)=abs(x(i+1)-x(i));
   DE_sum=DE_sum+DE_temp(i);
end
f_DE=0;
%DE爬坡阶梯惩罚系数(未满足爬坡约束惩罚)
if(DE_sum<=345)
   f_DE=0;
elseif(DE_sum>345&&DE_sum<=400)
   f_DE=2;%%%%%迭代次数
elseif(DE_sum>445&&DE_sum<=500)
   f_DE=5;
else
   f_DE=20;
end

%% MT爬坡约束处理
MT_sum=0;
for i=97:119
   MT_temp(i)=abs(x(i+1)-x(i));
   MT_sum=MT_sum+MT_temp(i);
end
f_MT=0;
%MT爬坡阶梯惩罚系数(未满足爬坡约束惩罚)
if(MT_sum<=345)
   f_MT=0;
elseif(MT_sum>345&&MT_sum<=400)
   f_MT=2;%%%%%迭代次数
elseif(MT_sum>445&&MT_sum<=500)
   f_MT=5;
else
   f_MT=20;
end
    
%% 储能SOC约束
%储能荷电状态
SOCMax=150;
SOCMin=5;   
SOC_sum=50; %初始容量
SOC_sum_delt=0;
n=0.9;%充放电效率
for i=49:72 
    if x(i)>0 %充放电
       n=-1/0.9; 
    else
        n=0.9; 
    end
      SOC_sum=SOC_sum+n*x(i);
      if  SOC_sum>SOCMax
    SOC_sum_delt= SOC_sum_delt+max(0,SOC_sum-SOCMax); 
      end
      if   SOC_sum<SOCMin
    SOC_sum_delt= SOC_sum_delt+abs(SOC_sum-SOCMin); 
      end
end 
f_SOC=0.05;
%SOC容量阶梯惩罚系数(未满足SOC约束惩罚)
if(SOC_sum_delt<=0)
    f_SOC=0;
elseif(SOC_sum_delt>0&&SOC_sum_delt<=10)
   f_SOC=1;%%%%%迭代次数
elseif(SOC_sum_delt>10&&SOC_sum_delt<50)
    f_SOC=2;
elseif(SOC_sum_delt>50&&SOC_sum_delt<=100)
    f_SOC=5;
else
    f_SOC=20;
end

%% 电功率平衡约束处理
ele_sum=0;
for i=1:24
   ele_temp(i)=abs(x(i)+x(i+24)+x(i+48)+x(i+72)+x(i+96)+x(i+120)-P_load(i));
   ele_sum=ele_sum+ele_temp(i);
end
f_ele=0;
%电平衡阶梯惩罚系数(未满足电平衡约束惩罚)
if(ele_sum==0)
   f_ele=0.0;
elseif(ele_sum>0&&ele_sum<=100)
   f_ele=1;
elseif(ele_sum>100&&ele_sum<=500)
   f_ele=5;
elseif(ele_sum>500&&ele_sum<=800)
   f_ele=10;
else
   f_ele=50;
end

%% 判断是否为可行解
if ele_sum>4500
    c=1;
else
    c=0;
end
%% 目标函数%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%目标函数1：运行成本
%% BESS&&DE&&MT (运维成本 && 燃料成本)
C_DE=0;C_BESS=0;C_MT=0;
for i=1:144
    if i>48&&i<73
      C_BESS=C_BESS+(0.026)*abs(x(i));%运维成本
    elseif i>72&&i<97
      C_DE=C_DE+(0.128*x(i))+(0.00011*x(i)^2+0.180*x(i)+6); %运维成本 && 燃料成本
    elseif  i>96&&i<121
     C_MT=C_MT+(0.0293*x(i))+2.55/9.8*x(i)/(0.0753*x(i)^3-0.3095*x(i)^2+0.4174*x(i)+0.1068); %运维成本 && 燃料成本
    end
end
C_OM_F= C_DE+ C_MT+ C_BESS;

%% Grid成本
C_grid=0;
for i=121:144
    if x(i)>0
        C_grid=C_grid+buy_price(i-120)*x(i);
    else
        C_grid=C_grid-sell_price(i-120)*x(i);
    end
end

 
result=C_grid+C_OM_F+f_DE*DE_sum+f_MT*MT_sum+f_SOC*SOC_sum_delt+f_ele*ele_sum;







