clear; clc;
path = fileparts(which('analysis_sup_diffuser.m'));

ymax = 0.44; % keep throat Mach number below 1.8
ymin = -0.26; % keep throat Mach number greater than 1.1
bmax = 0.04; % max bleed 
bmin = -0.01; % keeps total bleed positive (steady state + pert)
zUB = [ymax];
zLB = [ymin];
uUB = [bmax];
uLB = [bmin];
Z = rectanglePolytope(zUB, zLB);
U = rectanglePolytope(uUB, uLB);

% Analyze error bounds WITH noise
load(strcat(path, '/data/EBOUND.mat'));
[Dz, Du, ~, ~] = tightenConstraints(Z, U, EBOUND, 0);
fprintf('z bounds, %% (with noise): ');
for i = 1:length(Dz)
    fprintf('%.1f, ', 100*Dz(i)/Z.b(i));
end
fprintf('\n');
fprintf('u bounds, %% (with noise): ');
for i = 1:length(Du)
    fprintf('%.1f, ', 100*Du(i)/U.b(i));
end
fprintf('\n');

% Analyze error bounds WITHOUT noise
load(strcat(path, '/data/EBOUND_no_noise.mat'));
[Dz, Du, ~, ~] = tightenConstraints(Z, U, EBOUND, 0);
fprintf('z bounds, %% (without noise): ');
for i = 1:length(Dz)
    fprintf('%.1f, ', 100*Dz(i)/Z.b(i));
end
fprintf('\n');
fprintf('u bounds, %% (without noise): ');
for i = 1:length(Du)
    fprintf('%.1f, ', 100*Du(i)/U.b(i));
end
fprintf('\n');

% Analyze D_1./D_2
eta_2tau = 1e10;
Dz1 = EBOUND.eta_z*(EBOUND.D_1a*eta_2tau + EBOUND.D_1b);
Dz2 = EBOUND.Dz_2;
rz = Dz1./Z.b;
Du1 = EBOUND.eta_u*(EBOUND.D_1a*eta_2tau + EBOUND.D_1b);
Du2 = EBOUND.Du_2;
ru = Du1./U.b;
r = [rz; ru];
fprintf('(without noise) %% Max Dz1/Dz: %.1e\n', 100*max(abs(r)));
fprintf('(without noise) tau = %d\n', EBOUND.tau');