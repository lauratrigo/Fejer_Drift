clc
clear all
close all

% Abrir o arquivo com os dados originais
filename = 'f107.txt'; % Substitua pelo seu arquivo
%delimiter = ' ';  % Definir o delimitador de acordo com seu arquivo

% Ler os dados do arquivo
% Formato esperado: [Year, Day, Hour, Minute, AE-index]
% formatSpec = '%4d%4d%3d%3d%6d';
% fileID = fopen(filename, 'r');
% data = textscan(fileID, formatSpec, 'Delimiter', delimiter);
% fclose(fileID);

data=importdata(filename);

% Extrair as colunas
year = data(:,1);
doy = data(:,2);
hour = data(:,3);
f107_index = data(:,4);

% Inicializar um vetor para armazenar as datas no formato yyyy-mm-dd
    dates = strings(length(doy), 1);
    
    % Converter DOY para data yyyy-mm-dd
    for i = 1:length(doy)
        % Converter para data usando o Day of Year (DOY)
        dates(i,:) = datestr(datetime(year(i), 1, 1) + days(doy(i) - 1), 'yyyy-mm-dd');
    end

    
    % Gravar o resultado em um novo arquivo
output_filename = 'dados_f107_2003.txt';
fileID = fopen(output_filename, 'w');
%fprintf(fileID, 'Year Day Hour(Decimal) AE-index\n');

for i = 1:length(f107_index)
    % Escrever os dados no formato desejado
    fprintf(fileID, '%s %s %6.2f %s %s\n', dates(i), '00:00', f107_index(i),'""','""');
end

fclose(fileID);

disp('Arquivo processado e salvo com sucesso.');
