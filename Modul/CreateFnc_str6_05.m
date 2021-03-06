function [ str6_05 ] = CreateFnc_str6_05( )
%MDL_STR6_05 Create model of STR6-05 manipulator
%
%      mdl_str6_05
%
% Script creates the workspace variable str6_05 which describes the 
% kinematic and dynamic characterstics of a STR6_05 manipulator 
% modified DH conventions.
%
% Also defines the workspace vectors:
%   qz         zero joint angle configuration
%   qr         vertical 'READY' configuration
%   qstretch   arm is stretched out in the X direction
%
%
% See also SerialLink, mdl_puma560, mdl_stanford, mdl_twolink.

% This file is part of The Robotics Toolbox for Matlab (RTB).
% 
% RTB is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% RTB is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Lesser General Public License for more details.
% 
% You should have received a copy of the GNU Leser General Public License
% along with RTB.  If not, see <http://www.gnu.org/licenses/>.

%------------definition of the global varient----%
global qz qr qstretch;

%------------------------------------------------%
deg = pi/180;

clear L
% 单位m      theta    d        a    alpha     sigma   'mod' means modified  D&H
L(1) = Link([  pi/2   0.4      0.0275  -pi/2    0]);
L(2) = Link([  -pi/2  0        0.4500  0       0]);
L(3) = Link([  0      0        0.035   -pi/2    0]);
L(4) = Link([  0      0.450    0       pi/2    0]);
L(5) = Link([  0      0        0       -pi/2    0]);
L(6) = Link([  0      0.1      0        0       0]);

L(2).offset=-pi/2;
%link limit
L(1).qlim=[-170*deg,170*deg];
L(2).qlim=[-100*deg,135*deg];
L(3).qlim=[-120*deg,155*deg];
L(4).qlim=[-150*deg,150*deg];
L(5).qlim=[-120*deg,120*deg];

% link mass 单位kg
L(1).m = 4.759; %Link1 是否等于基座
L(2).m = 1.83014; %暂定
L(3).m = 2.8784;
L(4).m = 1.99888;
L(5).m = 6.2124;
L(6).m = 1.381;

% link COG wrt link coordinate frame 单位m
%              rx      ry      rz
L(1).r = [0.03145   0.00515   0.14183 ];
L(2).r = [-0.00022   0.12474   0.00778];
L(3).r = [0.00495    0.01855    0.00411 ];
L(4).r = [0.00047    0.0002      0.09764];
L(5).r = [0.00008    0.00267   -0.0548 ];
L(6).r = [0.00014    0.00019    0.02512  ];

% link inertia matrix 杆件惯量矩阵 （对称阵，只有6个独立变量）单位kg.mm^2
%               Ixx     Iyy      Izz    Ixy     Iyz     Ixz
L(1).I = [49250.825   57524.964   46959.409   -1775.532  -1813.441   11928.810];
L(2).I = [25179.83191   2627.77694    27076.8522    71.42811     799.696   -8.60439];
L(3).I = [18032.7863    18139.85428   19962.71844    4.18156   -55.90593   273.7109];
L(4).I = [13334.5304    16717.97246   7391.45718     4.18156  -55.90593     273.7109];
L(5).I = [1472.12105    1631.03343     937.37416    2.772  3.231   2.46073];
L(6).I = [55.55812         55.63245          72.13546     0.09421     0.14676   0.07501 ];

% % motor inertia 电机惯量
L(1).Jm =  291e-6;
L(2).Jm =  409e-6;
L(3).Jm =  299e-6;
L(4).Jm =  35e-6;
L(5).Jm =  35e-6;
L(6).Jm =  35e-6;
% % 
% % Gear ratio  齿轮传动比
L(1).G =  -62.6111;
L(2).G =  107.815;
L(3).G =  -53.7063;
L(4).G =  76.0364;
L(5).G =  71.923;
L(6).G =  76.686;
% % 
% % viscous friction (motor referenced)
% % unknown
% % 
% % Coulomb friction (motor referenced)
% % unknown

%
% some useful poses
%
qz = [0 0 0 0 0 0]; % zero angles, L shaped pose
qr = [0 0 -pi/2 0 0 0]; % ready pose, arm up
qstretch = [0 pi/2 -pi/2 0 0 0]; % horizontal along x-axis

str6_05 = SerialLink(L, 'name', 'STR6-05', 'manufacturer', 'JNU', 'comment', 'prototype');
clear L

end

