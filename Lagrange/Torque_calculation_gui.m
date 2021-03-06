function [ torque ] = Torque_calculation_gui( theta, velocity, accelerate )
%the function for calculate the torque including inertia forces central and
%coriolias force and gravity
% 2017/11/25  gravity force still need to be added
%   using Lagrange method   

%-----------全局变量声明-------------------------%
global str6_05
%
 %getting and declaring the mass for each link in kg
%m0=3.68893; %base

% m1=4.759;  %link1
% m2_1=1.83014; %link2_1
% m2_2=1.70234; %link2_2
% m3=2.877840;  %link3
% m4=1.99888;  %link4
% m5=0.62124;  %link5
% m6=0.13810; %flunge

%从SerialLinks对象中获取各个杆件的质量
m=zeros(6,1);
for i=1:6  
    temp=str6_05.links(i);
    m(i,1)=temp.m;
end

g=-9.78;

%getting and declaring the inertia tensor for each link in kg m^2
% I0=1e-9*[38979270.52    22434.34       429.91
%          22434.34       21623262.28   -3640766.16
%          429.91         -3640766.16    50133304.35];
% I1=1e-9*[49250.825      -1775.532     11928.810
%          -1775.532      57524.964     -1813.441
%          11928.810      -1813.441     46959.409];
% I2_1=1e-9*[25179831.91  71428.11      -8604.39
%            71428.11     2627776.94    79969.60 
%            -8604.39     79969.60      27076852.23];
% I2_2=1e-9*[24037268.72  -60.36        -19.84
%            -60.36       2620831.94    -545022.41
%            -19.84       -545022.41    25829240.93];
% I3=1e-9*[18032786.30    419242.53     -698501.31
%          419242.53      18139854.28   -1510757.33
%          -698501.31     -1510757.33   19962718.44];
% I4=1e-9*[13334530.40    4181.56       273710.90
%          4181.56        16717972.46   -55905.93   
%          273710.90      -55905.93     7391457.18];
% I5=1e-9*[1472121.05     277.20        2460.73
%          277.20         1631033.43    3231.00   
%          2460.73        3231.00       937374.16];
% I6=1e-9*[55558.12       94.21         75.01
%          94.21          55632.45      146.76
%          75.01          146.76        72135.46];

%从SerialLink 对象中获取各连杆质心出的惯性张量
I=zeros(3,3,6);
for i=1:6  
    temp=str6_05.links(i);
    I(:,:,i)=temp.I;
end



%%%%%%%%torque calculation which contrabuted by inertia forces%%%%%%%%%%%%%
%--------------Jv_i and Jomiga_i calculation
J_velocity=zeros(3,6,6);
J_velocity_dq1=zeros(3,6,6);
J_velocity_dq2=zeros(3,6,6);
J_velocity_dq3=zeros(3,6,6);
J_velocity_dq4=zeros(3,6,6);
J_velocity_dq5=zeros(3,6,6);
J_velocity_dq6=zeros(3,6,6);

[J_velocity,J_velocity_dq1,J_velocity_dq2,J_velocity_dq3,J_velocity_dq4,J_velocity_dq5,J_velocity_dq6]=Calculate_J_velocity(theta);

J_omiga=zeros(3,6,6);
J_omiga_dq1=zeros(3,6,6);
J_omiga_dq2=zeros(3,6,6);
J_omiga_dq3=zeros(3,6,6);
J_omiga_dq4=zeros(3,6,6);
J_omiga_dq5=zeros(3,6,6);
J_omiga_dq6=zeros(3,6,6);

[J_omiga,J_omiga_dq1,J_omiga_dq2,J_omiga_dq3,J_omiga_dq4,J_omiga_dq5,J_omiga_dq6]=Calculate_J_omiga(theta);

%-------------------M_torque calculation --------------------%
M_velo=zeros(6,6,6);
M_omi=zeros(6,6,6);
for i=1:6
    M_velo(:,:,i)=m(i,1)*J_velocity(:,:,i).'*J_velocity(:,:,i);
    M_omi(:,:,i)=J_omiga(:,:,i).'*I(:,:,i)*J_omiga(:,:,i);
end

% M_velo=zeros(6,6,6);
% M_velo(:,:,1)=m(1,1)*J_velocity(:,:,1).'*J_velocity(:,:,1);
% M_velo(:,:,2)=m(2,1)*J_velocity(:,:,2).'*J_velocity(:,:,2);
% M_velo(:,:,3)=m(3,1)*J_velocity(:,:,3).'*J_velocity(:,:,3);
% M_velo(:,:,4)=m(4,1)*J_velocity(:,:,4).'*J_velocity(:,:,4);
% M_velo(:,:,5)=m(5,1)*J_velocity(:,:,5).'*J_velocity(:,:,5);
% M_velo(:,:,6)=m(6,1)*J_velocity(:,:,6).'*J_velocity(:,:,6);
% 
% M_omi=zeros(6,6,6);
% M_omi(:,:,1)=J_omiga(:,:,1).'*I(1,1)*J_omiga(:,:,1);
% M_omi(:,:,2)=J_omiga(:,:,2).'*I(2,1)*J_omiga(:,:,2);
% M_omi(:,:,3)=J_omiga(:,:,3).'*I(3,1)*J_omiga(:,:,3);
% M_omi(:,:,4)=J_omiga(:,:,4).'*I(4,1)*J_omiga(:,:,4);
% M_omi(:,:,5)=J_omiga(:,:,5).'*I(5,1)*J_omiga(:,:,5);
% M_omi(:,:,6)=J_omiga(:,:,6).'*I(6,1)*J_omiga(:,:,6);

M=zeros(6,6);
for i=1:6
   M=M+M_velo(:,:,i)+M_omi(:,:,i);     
end
% mask=[1 0 0 0 0 0    %because not all the joints are mutually impacted so some of the mij should be zero
%       0 1 1 0 1 0    %joints 2\3\5 are a pair of mutually impacted joints
%       0 1 1 0 1 0    %joints 4\6 are another pair of mutually impacted joints
%       0 0 0 1 0 1
%       0 1 1 0 1 0
%       0 0 0 1 0 1];  


M_torque=zeros(6,1);
M_torque=M*accelerate';

%-----------------G_torque calculation  ---------------------%



%-------------------V_torque calculation --------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%M_dq1 calculation
M_velo_dq1=zeros(6,6,6);
% M_velo_dq1(:,:,1)=m(1,1)*(J_velocity_dq1(:,:,1).'*J_velocity(:,:,1)+J_velocity(:,:,1).'*J_velocity_dq1(:,:,1));
% M_velo_dq1(:,:,2)=m(2,1)*(J_velocity_dq1(:,:,2).'*J_velocity(:,:,2)+J_velocity(:,:,2).'*J_velocity_dq1(:,:,2));
% 
% M_velo_dq1(:,:,3)=m(3,1)*(J_velocity_dq1(:,:,3).'*J_velocity(:,:,3)+J_velocity(:,:,3).'*J_velocity_dq1(:,:,3));
% M_velo_dq1(:,:,4)=m(4,1)*(J_velocity_dq1(:,:,4).'*J_velocity(:,:,4)+J_velocity(:,:,4).'*J_velocity_dq1(:,:,4));
% M_velo_dq1(:,:,5)=m(5,1)*(J_velocity_dq1(:,:,5).'*J_velocity(:,:,5)+J_velocity(:,:,5).'*J_velocity_dq1(:,:,5));
% M_velo_dq1(:,:,6)=m(6,1)*(J_velocity_dq1(:,:,6).'*J_velocity(:,:,6)+J_velocity(:,:,6).'*J_velocity_dq1(:,:,6));
for i=1:6 
    M_velo_dq1(:,:,i)=m(i,1)*(J_velocity_dq1(:,:,i).'*J_velocity(:,:,i)+J_velocity(:,:,i).'*J_velocity_dq1(:,:,i));
end

M_omi_dq1=zeros(6,6,6);
% M_omi_dq1(:,:,1)=J_omiga_dq1(:,:,1).'*I(1,1)*J_omiga(:,:,1)+J_omiga(:,:,1).'*I(1,1)*J_omiga_dq1(:,:,1);
% M_omi_dq1(:,:,2)=J_omiga_dq1(:,:,2).'*I(2,1)*J_omiga(:,:,2)+J_omiga(:,:,2).'*I(2,1)*J_omiga_dq1(:,:,2);
% 
% M_omi_dq1(:,:,3)=J_omiga_dq1(:,:,3).'*I(3,1)*J_omiga(:,:,3)+J_omiga(:,:,3).'*I(3,1)*J_omiga_dq1(:,:,3);
% M_omi_dq1(:,:,4)=J_omiga_dq1(:,:,4).'*I(4,1)*J_omiga(:,:,4)+J_omiga(:,:,4).'*I(4,1)*J_omiga_dq1(:,:,4);
% M_omi_dq1(:,:,5)=J_omiga_dq1(:,:,5).'*I(5,1)*J_omiga(:,:,5)+J_omiga(:,:,5).'*I(5,1)*J_omiga_dq1(:,:,5);
% M_omi_dq1(:,:,6)=J_omiga_dq1(:,:,6).'*I(6,1)*J_omiga(:,:,6)+J_omiga(:,:,6).'*I(6,1)*J_omiga_dq1(:,:,6);
for i=1:6 
    M_omi_dq1(:,:,i)=J_omiga_dq1(:,:,i).'*I(:,:,i)*J_omiga(:,:,i)+J_omiga(:,:,i).'*I(:,:,i)*J_omiga_dq1(:,:,i);
end

M_dq1=zeros(6,6);
for i=1:6
   M_dq1=M_dq1+M_velo_dq1(:,:,i)+M_omi_dq1(:,:,i);     
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%M_dq2 calculation
M_velo_dq2=zeros(6,6,6);
% M_velo_dq2(:,:,1)=m(1,1)*(J_velocity_dq2(:,:,1).'*J_velocity(:,:,1)+J_velocity(:,:,1).'*J_velocity_dq2(:,:,1));
% M_velo_dq2(:,:,2)=m(2,1)*(J_velocity_dq2(:,:,2).'*J_velocity(:,:,2)+J_velocity(:,:,2).'*J_velocity_dq2(:,:,2));
% 
% M_velo_dq2(:,:,3)=m(3,1)*(J_velocity_dq2(:,:,3).'*J_velocity(:,:,3)+J_velocity(:,:,3).'*J_velocity_dq2(:,:,3));
% M_velo_dq2(:,:,4)=m(4,1)*(J_velocity_dq2(:,:,4).'*J_velocity(:,:,4)+J_velocity(:,:,4).'*J_velocity_dq2(:,:,4));
% M_velo_dq2(:,:,5)=m(5,1)*(J_velocity_dq2(:,:,5).'*J_velocity(:,:,5)+J_velocity(:,:,5).'*J_velocity_dq2(:,:,5));
% M_velo_dq2(:,:,6)=m(6,1)*(J_velocity_dq2(:,:,6).'*J_velocity(:,:,6)+J_velocity(:,:,6).'*J_velocity_dq2(:,:,6));
for i=1:6 
    M_velo_dq2(:,:,i)=m(i,1)*(J_velocity_dq2(:,:,i).'*J_velocity(:,:,i)+J_velocity(:,:,i).'*J_velocity_dq2(:,:,i));
end

M_omi_dq2=zeros(6,6,6);
% M_omi_dq2(:,:,1)=J_omiga_dq2(:,:,1).'*I(1,1)*J_omiga(:,:,1)+J_omiga(:,:,1).'*I(1,1)*J_omiga_dq2(:,:,1);
% M_omi_dq2(:,:,2)=J_omiga_dq2(:,:,2).'*I(2,1)*J_omiga(:,:,2)+J_omiga(:,:,2).'*I(2,1)*J_omiga_dq2(:,:,2);
% 
% M_omi_dq2(:,:,3)=J_omiga_dq2(:,:,3).'*I(3,1)*J_omiga(:,:,3)+J_omiga(:,:,3).'*I(3,1)*J_omiga_dq2(:,:,3);
% M_omi_dq2(:,:,4)=J_omiga_dq2(:,:,4).'*I(4,1)*J_omiga(:,:,4)+J_omiga(:,:,4).'*I(4,1)*J_omiga_dq2(:,:,4);
% M_omi_dq2(:,:,5)=J_omiga_dq2(:,:,5).'*I(5,1)*J_omiga(:,:,5)+J_omiga(:,:,5).'*I(5,1)*J_omiga_dq2(:,:,5);
% M_omi_dq2(:,:,6)=J_omiga_dq2(:,:,6).'*I(6,1)*J_omiga(:,:,6)+J_omiga(:,:,6).'*I(6,1)*J_omiga_dq2(:,:,6);
for i=1:6 
    M_omi_dq2(:,:,i)=J_omiga_dq2(:,:,i).'*I(:,:,i)*J_omiga(:,:,i)+J_omiga(:,:,i).'*I(:,:,i)*J_omiga_dq2(:,:,i);
end

M_dq2=zeros(6,6);
for i=1:6
   M_dq2=M_dq2+M_velo_dq2(:,:,i)+M_omi_dq2(:,:,i);     
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%M_dq3 calculation
M_velo_dq3=zeros(6,6,6);
% M_velo_dq3(:,:,1)=m(1,1)*(J_velocity_dq3(:,:,1).'*J_velocity(:,:,1)+J_velocity(:,:,1).'*J_velocity_dq3(:,:,1));
% M_velo_dq3(:,:,2)=m(2,1)*(J_velocity_dq3(:,:,2).'*J_velocity(:,:,2)+J_velocity(:,:,2).'*J_velocity_dq3(:,:,2));
% 
% M_velo_dq3(:,:,3)=m(3,1)*(J_velocity_dq3(:,:,4).'*J_velocity(:,:,4)+J_velocity(:,:,4).'*J_velocity_dq3(:,:,4));
% M_velo_dq3(:,:,4)=m(4,1)*(J_velocity_dq3(:,:,5).'*J_velocity(:,:,5)+J_velocity(:,:,5).'*J_velocity_dq3(:,:,5));
% M_velo_dq3(:,:,5)=m(5,1)*(J_velocity_dq3(:,:,6).'*J_velocity(:,:,6)+J_velocity(:,:,6).'*J_velocity_dq3(:,:,6));
% M_velo_dq3(:,:,6)=m(6,1)*(J_velocity_dq3(:,:,7).'*J_velocity(:,:,7)+J_velocity(:,:,7).'*J_velocity_dq3(:,:,7));
for i=1:6 
    M_velo_dq3(:,:,i)=m(i,1)*(J_velocity_dq3(:,:,i).'*J_velocity(:,:,i)+J_velocity(:,:,i).'*J_velocity_dq3(:,:,i));
end

M_omi_dq3=zeros(6,6,6);
% M_omi_dq3(:,:,1)=J_omiga_dq3(:,:,1).'*I(1,1)*J_omiga(:,:,1)+J_omiga(:,:,1).'*I(1,1)*J_omiga_dq3(:,:,1);
% M_omi_dq3(:,:,2)=J_omiga_dq3(:,:,2).'*I(2,1)*J_omiga(:,:,2)+J_omiga(:,:,2).'*I(2,1)*J_omiga_dq3(:,:,2);
% 
% M_omi_dq3(:,:,3)=J_omiga_dq3(:,:,3).'*I(3,1)*J_omiga(:,:,3)+J_omiga(:,:,3).'*I(3,1)*J_omiga_dq3(:,:,3);
% M_omi_dq3(:,:,4)=J_omiga_dq3(:,:,4).'*I(4,1)*J_omiga(:,:,4)+J_omiga(:,:,4).'*I(4,1)*J_omiga_dq3(:,:,4);
% M_omi_dq3(:,:,5)=J_omiga_dq3(:,:,5).'*I(5,1)*J_omiga(:,:,5)+J_omiga(:,:,5).'*I(5,1)*J_omiga_dq3(:,:,5);
% M_omi_dq3(:,:,6)=J_omiga_dq3(:,:,6).'*I(6,1)*J_omiga(:,:,6)+J_omiga(:,:,6).'*I(6,1)*J_omiga_dq3(:,:,6);
for i=1:6 
    M_omi_dq3(:,:,i)=J_omiga_dq3(:,:,i).'*I(:,:,i)*J_omiga(:,:,i)+J_omiga(:,:,i).'*I(:,:,i)*J_omiga_dq3(:,:,i);
end

M_dq3=zeros(6,6);
for i=1:6
   M_dq3=M_dq3+M_velo_dq3(:,:,i)+M_omi_dq3(:,:,i);     
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%M_dq4 calculation
M_velo_dq4=zeros(6,6,6);
% M_velo_dq4(:,:,1)=m(1,1)*(J_velocity_dq4(:,:,1).'*J_velocity(:,:,1)+J_velocity(:,:,1).'*J_velocity_dq4(:,:,1));
% M_velo_dq4(:,:,2)=m(2,1)*(J_velocity_dq4(:,:,2).'*J_velocity(:,:,2)+J_velocity(:,:,2).'*J_velocity_dq4(:,:,2));
% 
% M_velo_dq4(:,:,3)=m(3,1)*(J_velocity_dq4(:,:,3).'*J_velocity(:,:,3)+J_velocity(:,:,3).'*J_velocity_dq4(:,:,3));
% M_velo_dq4(:,:,4)=m(4,1)*(J_velocity_dq4(:,:,4).'*J_velocity(:,:,4)+J_velocity(:,:,4).'*J_velocity_dq4(:,:,4));
% M_velo_dq4(:,:,5)=m(5,1)*(J_velocity_dq4(:,:,5).'*J_velocity(:,:,5)+J_velocity(:,:,5).'*J_velocity_dq4(:,:,5));
% M_velo_dq4(:,:,6)=m(6,1)*(J_velocity_dq4(:,:,6).'*J_velocity(:,:,6)+J_velocity(:,:,6).'*J_velocity_dq4(:,:,6));
for i=1:6 
    M_velo_dq4(:,:,i)=m(i,1)*(J_velocity_dq4(:,:,i).'*J_velocity(:,:,i)+J_velocity(:,:,i).'*J_velocity_dq4(:,:,i));
end

M_omi_dq4=zeros(6,6,6);
% M_omi_dq4(:,:,1)=J_omiga_dq4(:,:,1).'*I(1,1)*J_omiga(:,:,1)+J_omiga(:,:,1).'*I(1,1)*J_omiga_dq4(:,:,1);
% M_omi_dq4(:,:,2)=J_omiga_dq4(:,:,2).'*I(2,1)*J_omiga(:,:,2)+J_omiga(:,:,2).'*I(2,1)*J_omiga_dq4(:,:,2);
% 
% M_omi_dq4(:,:,3)=J_omiga_dq4(:,:,3).'*I(3,1)*J_omiga(:,:,3)+J_omiga(:,:,3).'*I(3,1)*J_omiga_dq4(:,:,3);
% M_omi_dq4(:,:,4)=J_omiga_dq4(:,:,4).'*I(4,1)*J_omiga(:,:,4)+J_omiga(:,:,4).'*I(4,1)*J_omiga_dq4(:,:,4);
% M_omi_dq4(:,:,5)=J_omiga_dq4(:,:,5).'*I(5,1)*J_omiga(:,:,5)+J_omiga(:,:,5).'*I(5,1)*J_omiga_dq4(:,:,5);
% M_omi_dq4(:,:,6)=J_omiga_dq4(:,:,6).'*I(6,1)*J_omiga(:,:,6)+J_omiga(:,:,6).'*I(6,1)*J_omiga_dq4(:,:,6);
for i=1:6 
    M_omi_dq4(:,:,i)=J_omiga_dq4(:,:,i).'*I(:,:,i)*J_omiga(:,:,i)+J_omiga(:,:,i).'*I(:,:,i)*J_omiga_dq4(:,:,i);
end

M_dq4=zeros(6,6);
for i=1:6
   M_dq4=M_dq4+M_velo_dq4(:,:,i)+M_omi_dq4(:,:,i);     
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%M_dq5 calculation
M_velo_dq5=zeros(6,6,6);
% M_velo_dq5(:,:,1)=m(1,1)*(J_velocity_dq5(:,:,1).'*J_velocity(:,:,1)+J_velocity(:,:,1).'*J_velocity_dq5(:,:,1));
% M_velo_dq5(:,:,2)=m(2,1)*(J_velocity_dq5(:,:,2).'*J_velocity(:,:,2)+J_velocity(:,:,2).'*J_velocity_dq5(:,:,2));
% 
% M_velo_dq5(:,:,3)=m(3,1)*(J_velocity_dq5(:,:,3).'*J_velocity(:,:,3)+J_velocity(:,:,3).'*J_velocity_dq5(:,:,3));
% M_velo_dq5(:,:,4)=m(4,1)*(J_velocity_dq5(:,:,4).'*J_velocity(:,:,4)+J_velocity(:,:,4).'*J_velocity_dq5(:,:,4));
% M_velo_dq5(:,:,5)=m(5,1)*(J_velocity_dq5(:,:,5).'*J_velocity(:,:,5)+J_velocity(:,:,5).'*J_velocity_dq5(:,:,5));
% M_velo_dq5(:,:,6)=m(6,1)*(J_velocity_dq5(:,:,6).'*J_velocity(:,:,6)+J_velocity(:,:,6).'*J_velocity_dq5(:,:,6));
for i=1:6 
    M_velo_dq5(:,:,i)=m(i,1)*(J_velocity_dq5(:,:,i).'*J_velocity(:,:,i)+J_velocity(:,:,i).'*J_velocity_dq5(:,:,i));
end

M_omi_dq5=zeros(6,6,6);
% M_omi_dq5(:,:,1)=J_omiga_dq5(:,:,1).'*I(1,1)*J_omiga(:,:,1)+J_omiga(:,:,1).'*I1*J_omiga_dq5(:,:,1);
% M_omi_dq5(:,:,2)=J_omiga_dq5(:,:,2).'*I(2,1)*J_omiga(:,:,2)+J_omiga(:,:,2).'*I2_1*J_omiga_dq5(:,:,2);
% 
% M_omi_dq5(:,:,3)=J_omiga_dq5(:,:,3).'*I(3,1)*J_omiga(:,:,3)+J_omiga(:,:,3).'*I(3,1)*J_omiga_dq5(:,:,3);
% M_omi_dq5(:,:,4)=J_omiga_dq5(:,:,4).'*I(4,1)*J_omiga(:,:,4)+J_omiga(:,:,4).'*I(4,1)*J_omiga_dq5(:,:,4);
% M_omi_dq5(:,:,5)=J_omiga_dq5(:,:,5).'*I(5,1)*J_omiga(:,:,5)+J_omiga(:,:,5).'*I(5,1)*J_omiga_dq5(:,:,5);
% M_omi_dq5(:,:,6)=J_omiga_dq5(:,:,6).'*I(6,1)*J_omiga(:,:,6)+J_omiga(:,:,6).'*I(6,1)*J_omiga_dq5(:,:,6);
for i=1:6 
    M_omi_dq5(:,:,i)=J_omiga_dq5(:,:,i).'*I(:,:,i)*J_omiga(:,:,i)+J_omiga(:,:,i).'*I(:,:,i)*J_omiga_dq5(:,:,i);
end

M_dq5=zeros(6,6);
for i=1:6
   M_dq5=M_dq5+M_velo_dq5(:,:,i)+M_omi_dq5(:,:,i);     
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%M_dq6 calculation
M_velo_dq6=zeros(6,6,6);
% M_velo_dq6(:,:,1)=m(1,1)*(J_velocity_dq6(:,:,1).'*J_velocity(:,:,1)+J_velocity(:,:,1).'*J_velocity_dq6(:,:,1));
% M_velo_dq6(:,:,2)=m(2,1)*(J_velocity_dq6(:,:,2).'*J_velocity(:,:,2)+J_velocity(:,:,2).'*J_velocity_dq6(:,:,2));
% 
% M_velo_dq6(:,:,3)=m(3,1)*(J_velocity_dq6(:,:,3).'*J_velocity(:,:,3)+J_velocity(:,:,3).'*J_velocity_dq6(:,:,3));
% M_velo_dq6(:,:,4)=m(4,1)*(J_velocity_dq6(:,:,4).'*J_velocity(:,:,4)+J_velocity(:,:,4).'*J_velocity_dq6(:,:,4));
% M_velo_dq6(:,:,5)=m(5,1)*(J_velocity_dq6(:,:,5).'*J_velocity(:,:,5)+J_velocity(:,:,5).'*J_velocity_dq6(:,:,5));
% M_velo_dq6(:,:,6)=m(6,1)*(J_velocity_dq6(:,:,6).'*J_velocity(:,:,6)+J_velocity(:,:,6).'*J_velocity_dq6(:,:,6));
for i=1:6 
    M_velo_dq6(:,:,i)=m(i,1)*(J_velocity_dq6(:,:,i).'*J_velocity(:,:,i)+J_velocity(:,:,i).'*J_velocity_dq6(:,:,i));
end

M_omi_dq6=zeros(6,6,6);
% M_omi_dq6(:,:,1)=J_omiga_dq6(:,:,1).'*I(1,1)*J_omiga(:,:,1)+J_omiga(:,:,1).'*I(1,1)*J_omiga_dq6(:,:,1);
% M_omi_dq6(:,:,2)=J_omiga_dq6(:,:,2).'*I(2,1)*J_omiga(:,:,2)+J_omiga(:,:,2).'*I(2,1)*J_omiga_dq6(:,:,2);
% 
% M_omi_dq6(:,:,3)=J_omiga_dq6(:,:,3).'*I(3,1)*J_omiga(:,:,3)+J_omiga(:,:,3).'*I(3,1)*J_omiga_dq6(:,:,3);
% M_omi_dq6(:,:,4)=J_omiga_dq6(:,:,4).'*I(4,1)*J_omiga(:,:,4)+J_omiga(:,:,4).'*I(4,1)*J_omiga_dq6(:,:,4);
% M_omi_dq6(:,:,5)=J_omiga_dq6(:,:,5).'*I(5,1)*J_omiga(:,:,5)+J_omiga(:,:,5).'*I(5,1)*J_omiga_dq6(:,:,5);
% M_omi_dq6(:,:,6)=J_omiga_dq6(:,:,6).'*I(6,1)*J_omiga(:,:,6)+J_omiga(:,:,6).'*I(6,1)*J_omiga_dq6(:,:,6);
for i=1:6 
    M_omi_dq6(:,:,i)=J_omiga_dq6(:,:,i).'*I(:,:,i)*J_omiga(:,:,i)+J_omiga(:,:,i).'*I(:,:,i)*J_omiga_dq6(:,:,i);
end

M_dq6=zeros(6,6);
for i=1:6
   M_dq6=M_dq6+M_velo_dq6(:,:,i)+M_omi_dq6(:,:,i);     
end

%%%%%%%%%%%%%%%%%%%%%%%%% V_torque
dq1=velocity(1,1);
dq2=velocity(1,2);
dq3=velocity(1,3);
dq4=velocity(1,4);
dq5=velocity(1,5);
dq6=velocity(1,6);

temp=M_dq1*dq1+M_dq2*dq2+M_dq3*dq3+M_dq4*dq4+M_dq5*dq5+M_dq6*dq6;
V_torque=temp*velocity.';

%------------------ torque caltulation----%
torque= M_torque.'+V_torque.';

end

