% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

function [alpha1,alpha2,alpha3] = runMixer(h,tilt_x,tilt_y)
% Approx servo angles (in rad) from plate position.
% tilt_x (in rad) is the tilt angle w.r.t. y axis
% tilt_y (in rad) is the tilt angle w.r.t. x axis
%
% Ref. System modeling and controller design for moab pg. 8-10.
% Corrected equations:
%   zc3 = R - s/2 * sin(tilt_y)

s = 0.5 * 0.2 * sqrt(3);    % m, side length of equilateral traingle (calculated from CAD drawing)
L = 0.055;                  % m, arm length of links

R   = h - s/(2*sqrt(3)) * sin(tilt_x);
zc1 = h + s/sqrt(3) * sin(tilt_x);     % m, height of arm1 magnet center from servo
zc2 = R + s/2 * sin(tilt_y);           % m, height of arm2 magnet center from servo
zc3 = R - s/2 * sin(tilt_y);           % m, height of arm2 magnet center from servo
  
alpha1 = pi - asin(zc1/(2*L));        % rad, initial angle of arm1 servo
alpha2 = pi - asin(zc2/(2*L));        % rad, initial angle of arm2 servo
alpha3 = pi - asin(zc3/(2*L));        % rad, initial angle of arm3 servo