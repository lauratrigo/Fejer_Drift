clc
clear all
close all

% Abrir o arquivo com os dados originais
filename = 'ae.txt'; % Substitua pelo seu arquivo
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
minute = data(:,4);
ae_index = data(:,5);

% Inicializar arrays para armazenar os dados de 15 em 15 minutos
new_time_in_minutes = [];
new_ae_index = [];

new_time_in_minutes = 0:0.25:23.75';

new_time_in_minutes =repmat(new_time_in_minutes,1,16)';

% Inicializar um vetor para armazenar as datas no formato yyyy-mm-dd
    dates = strings(length(doy), 1);
    
    % Converter DOY para data yyyy-mm-dd
    for i = 1:length(doy)
        % Converter para data usando o Day of Year (DOY)
        dates(i,:) = datestr(datetime(year(i), 1, 1) + days(doy(i) - 1), 'yyyymmdd');
    end
    

    dates=str2double(dates);
    
  
    
    ii=1   ;

% Loop para agrupar os dados de 15 minutos e calcular a média
for i = 1:length(dates)/3
       
    % Calcular a média do AE-index nesses 15 minutos
    avg_ae(i,:) = mean(ae_index(ii:ii+2));
    dia(i,:)=dates(ii);
    ii=ii+3;
        
    
end

% Gravar o resultado em um novo arquivo
output_filename = 'dados_ae_15min.txt';
fileID = fopen(output_filename, 'w');
%fprintf(fileID, 'Year Day Hour(Decimal) AE-index\n');

for i = 1:length(avg_ae)
    % Escrever os dados no formato desejado
    fprintf(fileID, '%4d %6.2f %6.2f\n', dia(i), new_time_in_minutes(i), avg_ae(i));
end

fclose(fileID);

disp('Arquivo processado e salvo com sucesso.');
