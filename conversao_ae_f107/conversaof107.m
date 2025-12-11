clc             % Limpa a janela de comandos
clear all       % Remove todas as variáveis da memória
close all       % Fecha todas as janelas de figuras abertas

% Abrir o arquivo com os dados originais
filename = 'Daily_f107_Evento.txt'; % Nome do arquivo de entrada (dados do índice F10.7)
%delimiter = ' ';  % Caso necessário, definir o delimitador usado no arquivo

% Ler os dados do arquivo
% Formato esperado (colunas): [Ano, Dia do Ano, Hora, F10.7]
% formatSpec = '%4d%4d%3d%3d%6d'; % Exemplo de formato para leitura manual
% fileID = fopen(filename, 'r');   % Abre o arquivo para leitura
% data = textscan(fileID, formatSpec, 'Delimiter', delimiter); % Lê os dados no formato especificado
% fclose(fileID);  % Fecha o arquivo

data = importdata(filename); % Importa os dados diretamente (método mais simples)

% Extrair as colunas
year        = data(:,1); % Ano (ex: 2003 ou 2017)
doy         = data(:,2); % Dia do ano (DOY: 1 a 365/366)
hour        = data(:,3); % Hora (geralmente 0, pois o índice F10.7 é diário)
f107_index  = data(:,4); % Valor do índice F10.7 (fluxo solar em 10.7 cm)

% Inicializar vetor para armazenar as datas no formato yyyy-mm-dd
dates = strings(length(doy), 1); 

% Converter DOY para data no formato yyyy-mm-dd
for i = 1:length(doy)
    % Converte cada par (Ano + DOY) em data completa
    dates(i,:) = datestr(datetime(year(i), 1, 1) + days(doy(i) - 1), 'yyyy-mm-dd');
end

% Definir o nome do arquivo de saída
output_filename = 'f107_2017_Evento.txt'; % Nome do arquivo convertido
fileID = fopen(output_filename, 'w');    % Abre o arquivo para escrita

%fprintf(fileID, 'Year Day Hour(Decimal) AE-index\n'); % Cabeçalho opcional (comentado)

% Loop para escrever os dados convertidos no novo arquivo
for i = 1:length(f107_index)
    % Escreve: Data, hora fixa "00:00", valor do índice F10.7, e dois campos extras vazios ("" "")
    fprintf(fileID, '%s %s %6.2f %s %s\n', dates(i), '00:00', f107_index(i), '""', '""');
end

fclose(fileID); % Fecha o arquivo de saída

disp('Arquivo processado e salvo com sucesso.'); % Mensagem final no console
