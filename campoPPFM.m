clear; close all; clc;   % limpa variáveis, fecha figuras abertas e limpa o console

% ================== PPFM (campo elétrico, mV/m) ==================
% Define o caminho do arquivo contendo os dados do modelo de Fejer
arqPPFM = fullfile('Fejer_Josy','todos_PPFM.txt'); % ajuste caminho se preciso

% ---- Leitura da tabela com detecção automática ----
% detectImportOptions ajuda a identificar delimitadores e cabeçalhos
opts = detectImportOptions(arqPPFM,'Delimiter',',','ReadVariableNames',true);

% Alguns MATLABs mais novos renomeiam colunas automaticamente. 
% Esse ajuste garante que os nomes originais sejam preservados.
if isprop(opts,'VariableNamingRule'); opts.VariableNamingRule = 'preserve'; end

% Lê o arquivo em forma de tabela
Tpp = readtable(arqPPFM, opts);

% ---- Ajuste de nomes de colunas ----
% Extrai os nomes das colunas
names = string(Tpp.Properties.VariableNames);

% Normaliza para minúsculo e só letras/números (facilita comparação)
norm  = lower(regexprep(names,'[^a-z0-9]',''));  

% Função auxiliar para localizar índice de uma coluna por possíveis nomes
findIdx = @(cands) find(ismember(norm, cands), 1, 'first');

% Localiza colunas de tempo, penetração, quiet e total
iTime  = findIdx(["observationtimeutc","timeutc","datetime","time"]); 
if isempty(iTime),  iTime=1; end

iPen   = findIdx(["penetrationmvm","penetration"]);                    
if isempty(iPen),   iPen=2; end

iQuiet = findIdx(["quietmvm","quiet"]);                                
if isempty(iQuiet), iQuiet=3; end

iTotal = findIdx(["quietpluspenetrationmvm","quietpluspenetration","quietpenetration","quietplus"]); 
if isempty(iTotal), iTotal=4; end

% ---- Conversão da coluna de tempo ----
colTime = Tpp.(names(iTime));
if iscell(colTime), colTime = string(colTime); end

if isstring(colTime)
    % Se já estiver em string, tenta converter no formato YYYY-MM-DD HH:mm:ss
    tPPFM_dt = datetime(colTime, 'InputFormat','yyyy-MM-dd HH:mm:ss', 'TimeZone','UTC');
else
    % Caso contrário, tenta outros formatos possíveis
    try
        tPPFM_dt = datetime(colTime, 'ConvertFrom','excel','TimeZone','UTC');
    catch
        try
            tPPFM_dt = datetime(colTime, 'ConvertFrom','datenum','TimeZone','UTC');
        catch
            % Se nada funcionar, gera vetor vazio (NaT = Not a Time)
            tPPFM_dt = NaT(size(colTime)); tPPFM_dt.TimeZone='UTC';
        end
    end
end

% ---- Conversão das séries numéricas ----
% Função auxiliar: converte texto para double, forçando mesmo se vier errado
toDbl = @(v) double(str2double(string(v)));

% Extrai cada coluna
E_pen   = toDbl(Tpp.(names(iPen)));    % só penetração
E_quiet = toDbl(Tpp.(names(iQuiet)));  % só quiet
E_total = toDbl(Tpp.(names(iTotal)));  % quiet + penetração (Ey total)

% ---- Cria máscara de pontos válidos ----
% (ignora valores NaN ou tempos inválidos)
mOK_total = isfinite(E_total) & ~isnat(tPPFM_dt);

% ====== Parâmetros do eixo X ======
startDT  = dateshift(min(tPPFM_dt(mOK_total)),'start','day'); % início arredondado p/ dia
endDT    = dateshift(max(tPPFM_dt(mOK_total)),'end','day');   % fim arredondado p/ dia
ticksMajorDT = startDT:caldays(1):endDT;   % ticks maiores a cada 1 dia
ticksMinorDT = startDT:hours(6):endDT;     % ticks menores a cada 6 horas

% (opcional) marcas verticais de referência
tMarksDT = [];   % pode preencher com datas de eventos
addMarks = @(ax) arrayfun(@(tm) xline(ax, tm, 'k--', 'LineWidth', 1.3), tMarksDT);

% ================== PLOT ==================
figure;
set(groot,'defaultAxesFontSize',14);    % tamanho padrão da fonte dos eixos
set(groot,'defaultTextFontSize',14);    % tamanho padrão do texto

% --- Subplot 1: Ey_total ---
subplot(6,1,1);
plot(tPPFM_dt(mOK_total), E_total(mOK_total), 'b-', 'LineWidth', 2); % plota Ey_total
grid on; hold on;
xlim([startDT endDT]);       % limites no eixo X
addMarks(gca);               % adiciona linhas verticais (se houver)
set(gca,'Layer','top');      % grade abaixo, dados acima

% Ajustes visuais do eixo
ax = gca;
ax.FontSize = 14;
ax.XAxis.LineWidth = 2;
ax.XTick = ticksMajorDT; 
ax.XMinorTick = 'on';   
ax.XAxis.MinorTickValues = ticksMinorDT;
ax.MinorGridAlpha = 0.5;
xtickformat('dd/MM');        % formato do eixo X (dia/mês)

ylabel({'E total','(mV/m)'},'FontSize',14);  % rótulo Y
set(gca,'XTickLabel',[]);                   % remove rótulos do eixo X nesse subplot
