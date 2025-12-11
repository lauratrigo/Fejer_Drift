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

% ==============================================================
% === Substitui Ey (OMNI) por dados do arquivo todos_PPFM.txt ===
% ==============================================================

% Define o caminho do arquivo contendo os dados do modelo de Fejer
arqPPFM = fullfile('todos_PPFM.txt'); % ajuste o caminho se necessário

% Leitura automática do CSV com cabeçalho
opts = detectImportOptions(arqPPFM,'Delimiter',',','ReadVariableNames',true);
if isprop(opts,'VariableNamingRule'); opts.VariableNamingRule = 'preserve'; end
Tpp = readtable(arqPPFM, opts);

% Extrai nomes de colunas
names = string(Tpp.Properties.VariableNames);
norm  = lower(regexprep(names,'[^a-z0-9]',''));
findIdx = @(cands) find(ismember(norm, cands), 1, 'first');

% Localiza colunas de tempo e total
iTime  = findIdx(["observationtimeutc","timeutc","datetime","time"]);
iTotal = findIdx(["quietpluspenetrationmvm","quietpluspenetration","quietpenetration","quietplus"]);
if isempty(iTime),  iTime=1; end
if isempty(iTotal), iTotal=4; end

% Converte tempo
colTime = Tpp.(names(iTime));
if iscell(colTime), colTime = string(colTime); end
tPPFM_dt = datetime(colTime, 'InputFormat','yyyy-MM-dd HH:mm:ss', 'TimeZone','UTC');

% Extrai campo elétrico total
toDbl = @(v) double(str2double(string(v)));
E_total = toDbl(Tpp.(names(iTotal)));

% Máscara de pontos válidos
mOK = isfinite(E_total) & ~isnat(tPPFM_dt);

% Converter datetime para datenum
tPPFM_num = datenum(tPPFM_dt(mOK));

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
set(groot,'defaultAxesFontSize',16);
set(groot,'defaultTextFontSize',16);

% --- 1. PPFM (E_total) ---
subplot(8,1,1);
plot(tPPFM_num, E_total(mOK), 'b-', 'LineWidth', 2);
ylabel({'E_{total}';'(mV/m)'},'FontSize',16);
xlim([t_start t_end]);
set(gca,'XTick',xticks_days,'XTickLabel',[]);
grid on;
ax=gca;
ax.XMinorTick='on';
ax.MinorGridAlpha=0.5;
ax.LineWidth=1.8;
ax.XAxis.MinorTickValues = ax.XLim(1):0.2498:ax.XLim(2); % 3 barrinhas

% --- 2. Bz ---
subplot(8,1,2);
plot(time2, Bz, 'b-', 'LineWidth', 1.5);
ylabel({'Bz';'(nT)'},'FontSize',16);
xlim([t_start t_end]);
set(gca,'XTick',xticks_days,'XTickLabel',[]);
grid on;
ax=gca;
ax.XMinorTick='on';
ax.MinorGridAlpha=0.5;
ax.LineWidth=1.8;

% --- 3. SymH ---
subplot(8,1,3);
plot(time2, SymH, 'b-', 'LineWidth', 1.5);
ylabel({'SymH';'(nT)'},'FontSize',16);
xlim([t_start t_end]);
set(gca,'XTick',xticks_days,'XTickLabel',[]);
grid on;
ax=gca;
ax.XMinorTick='on';
ax.MinorGridAlpha=0.5;
ax.LineWidth=1.8;

% --- 4. Vd_mean ---
subplot(8,1,4);
plot(time, Vd_mean, 'b-', 'LineWidth', 1.5);
ylabel({'Vd mean';'(m/s)'},'FontSize',16);
xlim([t_start t_end]);
set(gca,'XTick',xticks_days,'XTickLabel',[]);
grid on;
ax=gca;
ax.XMinorTick='on';
ax.MinorGridAlpha=0.5;
ax.LineWidth=1.8;

% --- 5. Vd_storm ---
subplot(8,1,5);
plot(time, Vd_storm, 'b-', 'LineWidth', 1.5);
ylabel({'Vd storm';'(m/s)'},'FontSize',16);
xlim([t_start t_end]);
set(gca,'XTick',xticks_days,'XTickLabel',[]);
grid on;
ax=gca;
ax.XMinorTick='on';
ax.MinorGridAlpha=0.5;
ax.LineWidth=1.8;

% --- 6. Vd_total ---
subplot(8,1,6);
plot(time, Vd_total, 'b-', 'LineWidth', 1.5);
ylabel({'Vd total';'(m/s)'},'FontSize',16);
xlim([t_start t_end]);
set(gca,'XTick',xticks_days,'XTickLabel',[]);
grid on;
ax=gca;
ax.XMinorTick='on';
ax.MinorGridAlpha=0.5;
ax.LineWidth=1.8;

% --- 7. PPEF ---
subplot(8,1,7);
plot(time, PPEF, 'b-', 'LineWidth', 1.5);
ylabel({'PPEF';'(m/s)'},'FontSize',16);
xlim([t_start t_end]);
set(gca,'XTick',xticks_days,'XTickLabel',[]);
grid on;
ax=gca;
ax.XMinorTick='on';
ax.MinorGridAlpha=0.5;
ax.LineWidth=1.8;

% --- 8. DDEF ---
subplot(8,1,8);
plot(time, DDEF, 'b-', 'LineWidth', 1.5);
ylabel({'DDEF';'(m/s)'},'FontSize',16);
xlabel('Time (DD/Aug/2017)','FontSize',16);
xlim([t_start t_end]);
set(gca,'XTick',xticks_days,'XTickLabel',datestr(xticks_days,'dd'), 'FontSize', 12);
grid on;
ax=gca;
ax.XMinorTick='on';
ax.MinorGridAlpha=0.5;
ax.LineWidth=1.8;

% Ajusta ticks menores
for i = 1:8
    subplot(8,1,i);
    ax = gca;
    ax.XMinorTick = 'on';
    ax.MinorGridAlpha = 0.5;
    ax.LineWidth = 1.8;
    ax.XAxis.MinorTickValues = ax.XLim(1):0.2498:ax.XLim(2);
end

% ====== Aqui entra o retângulo ======
figure1 = gcf;
annotation(figure1,'rectangle',...
    [0.2203125 0.1121495 0.0578125 0.807064473799127],'Color',[0.83 0.82 0.78],...
    'FaceColor',[0.501960813999176 0.501960813999176 0.501960813999176],...
    'FaceAlpha',0.5);

% Create rectangle
annotation(figure1,'rectangle',...
    [0.544749933333333 0.1121495 0.0948334000000003 0.807064473799127],...
    'Color',[0.83 0.82 0.78],...
    'FaceColor',[0.501960813999176 0.501960813999176 0.501960813999176],...
    'FaceAlpha',0.5);


