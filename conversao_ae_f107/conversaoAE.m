clc             % Limpa a janela de comandos
clear all       % Remove todas as variáveis da memória
close all       % Fecha todas as figuras abertas

% Abrir o arquivo com os dados originais
filename = 'AE_5min_Evento.txt'; % Nome do arquivo de entrada contendo os dados brutos de AE

% Ler os dados do arquivo
data = importdata(filename); % Importa todo o conteúdo do arquivo

% Extrair as colunas do arquivo em variáveis separadas
year     = data(:,1); % Ano (ex: 2017)
doy      = data(:,2); % Dia do ano (1 a 365/366)
hour     = data(:,3); % Hora (0 a 23)
minute   = data(:,4); % Minuto (0 a 59)
ae_index = data(:,5); % Índice AE medido

% Converter DOY para data completa no formato yyyymmdd
dates = strings(length(doy), 1);
for i = 1:length(doy)
    dates(i,:) = datestr(datetime(year(i), 1, 1) + days(doy(i) - 1), 'yyyymmdd');
end
dates = str2double(dates); % Exemplo: "20170815" ? 20170815

% Número de dias únicos no arquivo AE
nDias = length(unique(dates));

% Vetor de horários de 0h até 23h45 (96 pontos por dia, 15 em 15 min)
horasDia = (0:0.25:23.75)';

% Repete o vetor de horários para cada dia disponível
new_time_in_minutes = repmat(horasDia, nDias, 1);

% Inicializar índice de leitura
ii = 1;

% Loop para agrupar os dados em blocos de 15 minutos e calcular a média do AE
for i = 1:length(dates)/3
    avg_ae(i,:) = mean(ae_index(ii:ii+2)); % média de 3 valores consecutivos (5min × 3 = 15min)
    dia(i,:) = dates(ii);                  % guarda a data correspondente
    ii = ii + 3;                           % avança para o próximo bloco
end

% Definir o nome do arquivo de saída
output_filename = 'Ae_15min_Evento.txt';
fileID = fopen(output_filename, 'w'); % Abre o arquivo para escrita

% Escrever os resultados processados no arquivo de saída
for i = 1:length(avg_ae)
    fprintf(fileID, '%8d %6.2f %6.2f\n', dia(i), new_time_in_minutes(i), avg_ae(i));
end

fclose(fileID); % Fecha o arquivo

disp('Arquivo processado e salvo com sucesso.');


%O script não altera o índice AE; ele apenas rebaixa a resolução de 5 minutos ? 15 minutos.
%Isso é feito por média aritmética em blocos de 3 pontos consecutivos.
%O objetivo é padronizar a resolução com a usada em modelos de deriva (ex.: PPEF/DDEF, Fejer),
%que geralmente trabalham em 15 min ou 1h.
%Exemplo de cálculo: 112, 98, 100  média = (112+98+100)/3 = 103.33
% Tempo Universal representa 23H25 sendo 23h15, 23h50=23h30...


