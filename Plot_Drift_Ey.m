clear; close all; clc;

% ------------------------------
% Carregar dados drift
% ------------------------------
filename = 'drift.dat';
data = importdata(filename);

date_str = data(:,1);    % Date strings
time_str = data(:,2);    % Time strings
Vd_mean = data(:,3);        
Vd_storm = data(:,4);          
Vd_total = data(:,5);  
PPEF = data(:,6);  
DDEF = data(:,7);  

% ------------------------------
% Carregar dados OMNI (vento solar, indices)
% ------------------------------
data = importdata('omni_aug_2017NaN.txt');
Vsw = data(:,6);   % Solar wind speed (km/s)
Nsw = data(:,7);   % Proton density (N/cm^3)
Bz = data(:,5);    % IMF Bz (nT)
SymH = data(:,9);  % Sym-H index (nT)
AE = data(:,8);    % AE index (nT)
%Usado resolução de 1 minutos nesses dados do OMNI
% ------------------------------
% Carregar Ey (OMNI) separado
% ------------------------------
dataEy = readmatrix('EyOMNI_NaN');

year  = dataEy(:,1);
doy   = dataEy(:,2);
hh    = dataEy(:,3);
mm    = dataEy(:,4);
Ey    = dataEy(:,5);

% Converter para datetime (UTC)
tEY = datetime(year,1,1,hh,mm,0,'TimeZone','UTC') + days(doy-1);

% Máscara de pontos válidos
mOK = isfinite(Ey) & Ey ~= 999.99;

% Converter para datenum
tEY_num = datenum(tEY(mOK));

% ------------------------------
% Eixos de tempo cobrindo todo agosto/2017
% ------------------------------
t_start = datenum(2017,8,1,0,0,0);
t_end   = datenum(2017,8,31,23,59,59);
xticks_days = t_start:1:t_end;

time2 = linspace(t_start,t_end,length(Vsw));      % para OMNI
time  = linspace(t_start,t_end,length(date_str)); % para drift

grayColor = [0.7, 0.7, 0.7];  % Light gray

% ================== FIGURA COM 8 SUBPLOTS ==================
figure;
set(groot,'defaultAxesFontSize',14);
set(groot,'defaultTextFontSize',14);

% --- 1. Ey (OMNI) ---
subplot(8,1,1);
plot(tEY_num, Ey(mOK), 'b-', 'LineWidth', 2);
ylabel({'E_y';'(mV/m)'},'FontSize',16);
xlim([t_start t_end]);
set(gca,'XTick',xticks_days,'XTickLabel',[]);
grid on; ax=gca; ax.XMinorTick='on'; ax.MinorGridAlpha=0.5;

% --- 2. Bz ---
subplot(8,1,2);
plot(time2, Bz, 'b-', 'LineWidth', 1.5);
ylabel({'Bz';'(nT)'},'FontSize',16);
xlim([t_start t_end]);
set(gca,'XTick',xticks_days,'XTickLabel',[]);
grid on; ax=gca; ax.XMinorTick='on'; ax.MinorGridAlpha=0.5;

% --- 3. SymH ---
subplot(8,1,3);
plot(time2, SymH, 'b-', 'LineWidth', 1.5);
ylabel({'SymH';'(nT)'},'FontSize',16);
xlim([t_start t_end]);
set(gca,'XTick',xticks_days,'XTickLabel',[]);
grid on; ax=gca; ax.XMinorTick='on'; ax.MinorGridAlpha=0.5;

% --- 4. Vd_mean ---
subplot(8,1,4);
plot(time, Vd_mean, 'b-', 'LineWidth', 1.5);
ylabel({'Vd mean';'(m/s)'},'FontSize',16);
xlim([t_start t_end]);
set(gca,'XTick',xticks_days,'XTickLabel',[]);
grid on; ax=gca; ax.XMinorTick='on'; ax.MinorGridAlpha=0.5;

% --- 5. Vd_storm ---
subplot(8,1,5);
plot(time, Vd_storm, 'b-', 'LineWidth', 1.5);
ylabel({'Vd storm';'(m/s)'},'FontSize',16);
xlim([t_start t_end]);
set(gca,'XTick',xticks_days,'XTickLabel',[]);
grid on; ax=gca; ax.XMinorTick='on'; ax.MinorGridAlpha=0.5;

% --- 6. Vd_total ---
subplot(8,1,6);
plot(time, Vd_total, 'b-', 'LineWidth', 1.5);
ylabel({'Vd total';'(m/s)'},'FontSize',16);
xlim([t_start t_end]);
set(gca,'XTick',xticks_days,'XTickLabel',[]);
grid on; ax=gca; ax.XMinorTick='on'; ax.MinorGridAlpha=0.5;

% --- 7. PPEF ---
subplot(8,1,7);
plot(time, PPEF, 'b-', 'LineWidth', 1.5);
ylabel({'PPEF';'(m/s)'},'FontSize',16);
xlim([t_start t_end]);
set(gca,'XTick',xticks_days,'XTickLabel',[]);
grid on; ax=gca; ax.XMinorTick='on'; ax.MinorGridAlpha=0.5;

% --- 8. DDEF ---
subplot(8,1,8);
plot(time, DDEF, 'b-', 'LineWidth', 1.5);
ylabel({'DDEF';'(m/s)'},'FontSize',16);
xlabel('Time (Days)','FontSize',16);
xlim([t_start t_end]);
set(gca,'XTick',xticks_days, ...
    'XTickLabel', datestr(xticks_days,'dd/mm'), 'FontSize', 12);
grid on; ax=gca; ax.XMinorTick='on'; ax.MinorGridAlpha=0.5;


% Ajusta os ticks menores em todos os subplots
for i = 1:8
    subplot(8,1,i);
    ax = gca;
    ax.XMinorTick = 'on';
    ax.MinorGridAlpha = 0.5;
    ax.LineWidth = 1.8;   
    ax.XAxis.MinorTickValues = ax.XLim(1):0.2498:ax.XLim(2); % 3 barrinhas
end

