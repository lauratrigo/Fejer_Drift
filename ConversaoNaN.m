% Passo 1: Ler o arquivo original (troque o nome pelo seu)
data = readmatrix('EyOmni5min.txt');

% Passo 2: Substituir valores inválidos por NaN
data(data == 9999.99 | data == 99999.9 | data == 999.99) = NaN;

% Passo 3: Salvar um novo arquivo limpo
outFile = 'EyOmni5min_NaN.txt';
writematrix(data, outFile, 'Delimiter','\t');

% Passo 4: Mensagem de confirmação
if isfile(outFile)
    fprintf('Arquivo "%s" criado com sucesso!\n', outFile);
else
    fprintf('Erro: o arquivo não foi criado.\n');
end
