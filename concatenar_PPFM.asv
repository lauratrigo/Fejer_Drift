function concatenar_PPFM
% Define a função principal que irá executar todo o processo
    % Seleciona a pasta (ex.: ...\DadosPPFM)
    pasta = uigetdir(pwd, 'Selecione a pasta DadosPPFM');   % Abre um seletor de pasta e retorna o caminho escolhido
    if isequal(pasta,0), disp('Operação cancelada.'); return; end  % Se o usuário cancelar, mostra mensagem e sai da função

    % Lista PPFM*.csv
    L = dir(fullfile(pasta, 'PPFM*.csv'));                  % Lista todos os arquivos na pasta cujo nome começa com PPFM e termina com .csv
    if isempty(L), error('Nenhum arquivo PPFM*.csv encontrado em: %s', pasta); end  % Se não houver arquivos, lança erro

    % Ordena na ordem natural PPFM01-05, PPFM06-10, ..., PPFM31
    nomes = {L.name};                                       % Extrai apenas os nomes dos arquivos (cell array de strings)
    chaves = arrayfun(@(s) extraiPrimeiroNumero(s.name), L);% Para cada arquivo, extrai o primeiro número depois de "PPFM" (para ordenar)
    [~, ord] = sort(chaves, 'ascend');                      % Ordena os índices pela chave numérica em ordem crescente
    nomes = nomes(ord);                                     % Reorganiza os nomes conforme a ordem calculada

    % Cabeçalho final
    HEADER = 'Observation Time (UTC),Penetration (mV/m),Quiet (mV/m),Quiet plus Penetration (mV/m)'; % Cabeçalho desejado no arquivo final
    COLS_INTERNAL = {'Time','Penetration','Quiet','QuietPlusPenetration'}; % Nomes internos válidos para a tabela no MATLAB

    % Acumulador
    Acum = table('Size',[0 4], ...                          % Cria uma tabela vazia com 0 linhas e 4 colunas
                 'VariableTypes', {'string','double','double','double'}, ... % Define os tipos das 4 colunas
                 'VariableNames', COLS_INTERNAL);           % Define os nomes internos das colunas

    CODIF = 'UTF-8';                                        % Define a codificação de texto usada na leitura/escrita

    for k = 1:numel(nomes)                                  % Loop por todos os arquivos na ordem definida
        arquivo = fullfile(pasta, nomes{k});                % Monta o caminho completo do arquivo atual

        % Detecta importação (aceita , ; ou TAB)
        opts = detectImportOptions(arquivo, 'Encoding', CODIF); % Cria opções automáticas de importação para o arquivo
        if isempty(opts.Delimiter) || all(cellfun(@isempty, opts.Delimiter)) % Se o delimitador não foi detectado
            opts.Delimiter = {',',';','\t'};                % Tenta vírgula, ponto-e-vírgula ou TAB como delimitadores
        end
        T = readtable(arquivo, opts);                        % Lê o arquivo como tabela usando as opções detectadas

        % --- Nomes das colunas de origem (normalizados) ---
        fonte = string(T.Properties.VariableNames);          % Pega os nomes originais das colunas como string array
        fonte = lower(replace(fonte, "_", ""));              % Remove underscores e coloca em minúsculas
        fonte = lower(replace(fonte, " ", ""));              % Remove espaços (fica tudo “grudado” para facilitar a busca)

        % Tabela parcial
        Parc = table('Size',[height(T) 4], ...               % Cria uma tabela parcial com o mesmo número de linhas do arquivo atual
                     'VariableTypes', {'string','double','double','double'}, ... % Tipos das colunas
                     'VariableNames', COLS_INTERNAL);        % Nomes internos das colunas

        % Tempo
        idxTime = encontraColuna(fonte, ["observationtime","timeutc","utc","datetime","time"]); % Procura coluna que pareça “tempo”
        if ~isempty(idxTime)                                 % Se encontrou uma coluna candidata a tempo
            Parc.Time = toStringDatetime(T.(T.Properties.VariableNames{idxTime})); % Converte essa coluna para string no formato desejado
        elseif width(T) >= 1                                 % Caso não ache por nome, tenta assumir a 1ª coluna como tempo
            Parc.Time = toStringDatetime(T{:,1});            % Converte a 1ª coluna para string de data/hora
        else
            Parc.Time = repmat("", height(T), 1);            % Se não houver coluna, preenche com strings vazias
        end

        % Penetration
        idxPen = encontraColuna(fonte, ["penetration","penet"]); % Procura coluna que pareça “Penetration”
        Parc.Penetration = toDouble( escolheColuna(T, idxPen, 2) ); % Usa essa coluna (ou fallback para 2ª coluna), convertendo para double

        % Quiet
        idxQuiet = encontraColuna(fonte, "quiet");           % Procura coluna que pareça “Quiet”
        Parc.Quiet = toDouble( escolheColuna(T, idxQuiet, 3) ); % Usa essa coluna (ou fallback para 3ª), convertendo para double

        % Quiet + Penetration
        idxQPlus = encontraColuna(fonte, ["quietpluspenetration","quietpenetration","quietpluspenet","quietplus"]); % Procura a soma
        Parc.QuietPlusPenetration = toDouble( escolheColuna(T, idxQPlus, 4) ); % Usa a coluna mapeada (ou 4ª), convertendo para double

        Acum = [Acum; Parc];                                  % Empilha a tabela parcial no acumulador (concatena por linhas)
        fprintf('OK: %s (%d linhas)\n', nomes{k}, height(Parc)); % Log no console informando progresso
    end

    % === Escrever arquivo final com o cabeçalho exato ===
    saida = fullfile(pasta, 'todos_PPFM.txt');               % Caminho do arquivo final a ser gerado
    fid = fopen(saida, 'w');  assert(fid>0, 'Não foi possível criar o arquivo.'); % Abre o arquivo para escrita e checa sucesso
    fprintf(fid, '%s\n', HEADER);                            % Escreve a primeira linha (cabeçalho desejado)
    for i = 1:height(Acum)                                   % Itera por todas as linhas do acumulador
        fprintf(fid, '%s,%.16g,%.16g,%.16g\n', ...           % Escreve cada linha em CSV com 16 dígitos de precisão para números
            char(Acum.Time(i)), ...                          % Tempo como texto (yyyy-MM-dd HH:mm:ss)
            Acum.Penetration(i), ...                         % Coluna Penetration
            Acum.Quiet(i), ...                               % Coluna Quiet
            Acum.QuietPlusPenetration(i));                   % Coluna Quiet plus Penetration
    end
    fclose(fid);                                             % Fecha o arquivo final
    fprintf('\nGerado: %s\n', saida);                        % Mensagem no console informando o caminho do arquivo gerado

    % ======= Funções auxiliares =======
    function n = extraiPrimeiroNumero(fname)                 % Extrai o primeiro número imediatamente após “PPFM”
        tok = regexp(fname, 'PPFM(\d+)', 'tokens', 'once');  % Usa expressão regular para capturar os dígitos após PPFM
        if isempty(tok), n = inf; else, n = str2double(tok{1}); end % Se não achar, retorna inf; senão, retorna o número como double
    end

    function idx = encontraColuna(nomesFonte, keys)          % Localiza índice de coluna cujo nome contenha alguma das “keys”
        keys = string(keys);                                 % Garante que keys é string array
        m = false(size(nomesFonte));                         % Cria máscara booleana inicial (todas falsas)
        for kk = 1:numel(keys)                               % Varre todas as chaves
            m = m | contains(nomesFonte, lower(keys(kk)));   % Marca true onde o nome da coluna contém a chave
        end
        idx = find(m, 1, 'first');                           % Retorna o primeiro índice que casou (ou vazio se nenhum)
    end

    function col = escolheColuna(T, idx, fallbackPos)        % Devolve a coluna T.(idx) ou uma coluna de fallback (por posição)
        if ~isempty(idx)                                     % Se um índice válido foi encontrado
            col = T.(T.Properties.VariableNames{idx});       % Retorna a coluna pelo nome original
        elseif width(T) >= fallbackPos                       % Caso contrário, se a tabela tem a posição fallback
            col = T{:, fallbackPos};                         % Retorna a coluna pela posição fallback
        else
            col = NaN(height(T),1);                          % Se nada der certo, retorna um vetor de NaN do mesmo tamanho
        end
    end

    function s = toStringDatetime(v)                         % Converte vários formatos para string de data/hora
        % Converte para 'yyyy-MM-dd HH:mm:ss'
        if istimetable(v), v = v.Time; end                   % Se for timetable, usa a coluna Time
        if iscell(v), v = string(v); end                     % Se for cell array, converte para string array
        if isstring(v)                                       % Se já for string/texto
            try
                dt = datetime(v, 'InputFormat','yyyy-MM-dd HH:mm:ss', 'TimeZone','UTC'); % Tenta interpretar com esse formato
            catch
                try
                    dt = datetime(v, 'Interpreter','none', 'TimeZone','UTC'); % Senão, tenta interpretação mais flexível
                catch
                    dt = NaT(size(v)); dt.TimeZone = 'UTC';  % Se falhar, cria NaT (Not-a-Time)
                end
            end
        elseif isdatetime(v)                                  % Se já for datetime
            dt = v; dt.TimeZone = 'UTC';                     % Garante fuso UTC
        else                                                  % Caso seja numérico (Excel/datenum) ou outro tipo
            % tenta Excel/datenum
            try
                dt = datetime(v, 'ConvertFrom','excel', 'TimeZone','UTC'); % Tenta converter de número estilo Excel
            catch
                try
                    dt = datetime(v, 'ConvertFrom','datenum', 'TimeZone','UTC'); % Ou de datenumm
                catch
                    dt = NaT(size(v)); dt.TimeZone = 'UTC';  % Se falhar, NaT
                end
            end
        end
        s = string(datestr(dt, 'yyyy-mm-dd HH:MM:SS'));      % Converte datetime para string no formato desejado
    end

    function d = toDouble(v)                                  % Converte diferentes tipos em vetor numérico double
        if istable(v), v = table2array(v); end               % Se for tabela, transforma na matriz de dados
        if iscell(v), v = str2double(string(v)); end         % Se for cell, tenta converter strings para double
        if isstring(v), v = str2double(v); end               % Se for string, converte para double
        if isdatetime(v), v = NaN(size(v)); end              % Se for datetime, não faz sentido — vira NaN
        if ~isnumeric(v), v = NaN(size(v)); end              % Se não for numérico, vira NaN
        d = double(v);                                       % Garante tipo double
    end
end
