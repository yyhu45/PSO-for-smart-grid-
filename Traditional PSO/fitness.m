%����Ŀ������Ⱥ����Ӧ��
function [c,result]=fitness(x)
global P_load;
global buy_price;
global sell_price;
%% Լ������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DE����Լ������
DE_sum=0;
for i=73:95
   DE_temp(i)=abs(x(i+1)-x(i));
   DE_sum=DE_sum+DE_temp(i);
end
f_DE=0;
%DE���½��ݳͷ�ϵ��(δ��������Լ���ͷ�)
if(DE_sum<=345)
   f_DE=0;
elseif(DE_sum>345&&DE_sum<=400)
   f_DE=2;%%%%%��������
elseif(DE_sum>445&&DE_sum<=500)
   f_DE=5;
else
   f_DE=20;
end

%% MT����Լ������
MT_sum=0;
for i=97:119
   MT_temp(i)=abs(x(i+1)-x(i));
   MT_sum=MT_sum+MT_temp(i);
end
f_MT=0;
%MT���½��ݳͷ�ϵ��(δ��������Լ���ͷ�)
if(MT_sum<=345)
   f_MT=0;
elseif(MT_sum>345&&MT_sum<=400)
   f_MT=2;%%%%%��������
elseif(MT_sum>445&&MT_sum<=500)
   f_MT=5;
else
   f_MT=20;
end
    
%% ����SOCԼ��
%���ܺɵ�״̬
SOCMax=150;
SOCMin=5;   
SOC_sum=50; %��ʼ����
SOC_sum_delt=0;
n=0.9;%��ŵ�Ч��
for i=49:72 
    if x(i)>0 %��ŵ�
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
%SOC�������ݳͷ�ϵ��(δ����SOCԼ���ͷ�)
if(SOC_sum_delt<=0)
    f_SOC=0;
elseif(SOC_sum_delt>0&&SOC_sum_delt<=10)
   f_SOC=1;%%%%%��������
elseif(SOC_sum_delt>10&&SOC_sum_delt<50)
    f_SOC=2;
elseif(SOC_sum_delt>50&&SOC_sum_delt<=100)
    f_SOC=5;
else
    f_SOC=20;
end

%% �繦��ƽ��Լ������
ele_sum=0;
for i=1:24
   ele_temp(i)=abs(x(i)+x(i+24)+x(i+48)+x(i+72)+x(i+96)+x(i+120)-P_load(i));
   ele_sum=ele_sum+ele_temp(i);
end
f_ele=0;
%��ƽ����ݳͷ�ϵ��(δ�����ƽ��Լ���ͷ�)
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

%% �ж��Ƿ�Ϊ���н�
if ele_sum>4500
    c=1;
else
    c=0;
end
%% Ŀ�꺯��%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Ŀ�꺯��1�����гɱ�
%% BESS&&DE&&MT (��ά�ɱ� && ȼ�ϳɱ�)
C_DE=0;C_BESS=0;C_MT=0;
for i=1:144
    if i>48&&i<73
      C_BESS=C_BESS+(0.026)*abs(x(i));%��ά�ɱ�
    elseif i>72&&i<97
      C_DE=C_DE+(0.128*x(i))+(0.00011*x(i)^2+0.180*x(i)+6); %��ά�ɱ� && ȼ�ϳɱ�
    elseif  i>96&&i<121
     C_MT=C_MT+(0.0293*x(i))+2.55/9.8*x(i)/(0.0753*x(i)^3-0.3095*x(i)^2+0.4174*x(i)+0.1068); %��ά�ɱ� && ȼ�ϳɱ�
    end
end
C_OM_F= C_DE+ C_MT+ C_BESS;

%% Grid�ɱ�
C_grid=0;
for i=121:144
    if x(i)>0
        C_grid=C_grid+buy_price(i-120)*x(i);
    else
        C_grid=C_grid-sell_price(i-120)*x(i);
    end
end

 
result=C_grid+C_OM_F+f_DE*DE_sum+f_MT*MT_sum+f_SOC*SOC_sum_delt+f_ele*ele_sum;







