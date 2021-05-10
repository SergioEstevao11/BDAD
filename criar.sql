PRAGMA foreign_keys = on;

.mode columns
.headers on

DROP TABLE IF EXISTS Assinatura;
DROP TABLE IF EXISTS Bilhete;
DROP TABLE IF EXISTS BilhetePreco;
DROP TABLE IF EXISTS Cliente;
DROP TABLE IF EXISTS Informacao;
DROP TABLE IF EXISTS RevisorViagem;
DROP TABLE IF EXISTS Viagem;
DROP TABLE IF EXISTS Rota;
DROP TABLE IF EXISTS Servico;
DROP TABLE IF EXISTS Estacao;
DROP TABLE IF EXISTS Maquinista;
DROP TABLE IF EXISTS Revisor;
DROP TABLE IF EXISTS Bilheteiro;
DROP TABLE IF EXISTS ComboioCarga;
DROP TABLE IF EXISTS ComboioPassageiros;
DROP TABLE IF EXISTS PassageirosCaracteristicas;
DROP TABLE IF EXISTS CargaCaracteristicas;

CREATE TABLE Cliente(
    nif  TEXT   PRIMARY KEY    
                CONSTRAINT ck_cliente_nif CHECK(LENGTH(nif) == 9 AND nif NOT GLOB '*[^0-9]*')
                CONSTRAINT nn_cliente_nif NOT NULL,
    nome TEXT
);

CREATE TABLE Servico(
    nome TEXT   PRIMARY KEY   
                CONSTRAINT ck_servico_nome CHECK(nome in('Alfa-Pendular',
                                                        'Intercidades',
                                                        'Regional',
                                                        'Urbano',
                                                        'Cargas'))
                CONSTRAINT nn_servico_nome NOT NULL
);

CREATE TABLE Assinatura(
    nif         TEXT    CONSTRAINT fk_assinatura_cliente REFERENCES Cliente ON DELETE CASCADE 
                                                                            ON UPDATE CASCADE
                        CONSTRAINT nn_assinatura_nif NOT NULL,
    nomeServico TEXT    CONSTRAINT fk_assinatura_servico REFERENCES Servico ON DELETE CASCADE 
                                                                            ON UPDATE CASCADE
                        CONSTRAINT nn_assinatura_nomeServico NOT NULL,
    IDPasse     INTEGER CONSTRAINT ck_assinatura_idPasse CHECK(IDPasse > 0)
                        CONSTRAINT nn_assinatura_idPasse NOT NULL,
    PRIMARY KEY(nif, nomeServico),
    CONSTRAINT uq_servico_idPasse_nomeServico UNIQUE(nomeServico, IDPasse)
);

CREATE TABLE Estacao(
    nome         TEXT PRIMARY KEY
                      CONSTRAINT nn_estacao_nome NOT NULL,
    morada       TEXT CONSTRAINT nn_estacao_morada NOT NULL,
    codigoPostal TEXT CONSTRAINT ck_estacao_codigoPostal CHECK(codigoPostal LIKE('____-___') AND codigoPostal NOT GLOB '*[^0-9-]*')
                      CONSTRAINT nn_estacao_codigoPostal NOT NULL,
    localidade   TEXT CONSTRAINT nn_estacao_localidade NOT NULL,
    CONSTRAINT uq_estacao_morada_codigoPostal UNIQUE(morada, codigoPostal)
);

CREATE TABLE Rota( --Didn't decide yet
    id          INTEGER PRIMARY KEY AUTOINCREMENT
                        CONSTRAINT nn_rota_id NOT NULL,
    titulo      TEXT,
    nomeServico TEXT    CONSTRAINT fk_rota_servico REFERENCES Servico ON DELETE CASCADE
                                                                      ON UPDATE CASCADE
                        CONSTRAINT nn_rota_nomeServico NOT NULL
);

CREATE TABLE Informacao( --ok
    nomeEstacao    TEXT    CONSTRAINT fk_informacao_estacao REFERENCES Estacao ON DELETE CASCADE 
                                                                               ON UPDATE CASCADE
                           CONSTRAINT nn_informacao_nomeEstacao NOT NULL,
    idRota         INTEGER CONSTRAINT fk_informacao_rota REFERENCES Rota ON DELETE CASCADE 
                                                                         ON UPDATE CASCADE
                           CONSTRAINT nn_informacao_idRota NOT NULL,
    tempoDeChegada INTEGER CONSTRAINT ck_informacao_tempoDeChegada CHECK(tempoDeChegada >= 0)
                           CONSTRAINT nn_informacao_tempoDeChegada NOT NULL,
    PRIMARY KEY(nomeEstacao, idRota),
    CONSTRAINT uq_informacao_idRota_tempoDeChegada UNIQUE(idRota, tempoDeChegada)
);

CREATE TABLE Maquinista(
    nif         TEXT    PRIMARY KEY 
                        CONSTRAINT ck_maquinista_nif CHECK(LENGTH(nif) == 9 AND nif NOT GLOB '*[^0-9]*')
                        CONSTRAINT nn_maquinista_nif NOT NULL,
    nome        TEXT,
    idade       INTEGER CONSTRAINT ck_maquinista_idade CHECK(idade >= 18)
                        CONSTRAINT nn_maquinista_idade NOT NULL,
    numTelefone TEXT    CONSTRAINT ck_maquinista_numTelefone CHECK(numTelefone LIKE '22_______' AND numTelefone NOT GLOB '*[^0-9]*'),
    numLicensa  TEXT    CONSTRAINT ck_maquinista_numLicensa CHECK(LENGTH(numLicensa) == 12 AND numLicensa NOT GLOB '*[^0-9]*')
                        CONSTRAINT uq_maquinista_numLicensa UNIQUE
                        CONSTRAINT nn_maquinista_numLicensa NOT NULL
);

CREATE TABLE Bilheteiro(-- ok
    nif         TEXT    PRIMARY KEY 
                        CONSTRAINT ck_bilheteiro_nif CHECK(LENGTH(nif) == 9 AND nif NOT GLOB '*[^0-9]*')
                        CONSTRAINT nn_bilheteiro_nif NOT NULL,
    nome        TEXT,
    idade       INTEGER CONSTRAINT ck_bilheteiro_idade CHECK(idade >= 18)
                        CONSTRAINT nn_bilheteiro_idade NOT NULL,
    numTelefone TEXT    CONSTRAINT ck_bilheteiro_numTelefone CHECK(numTelefone LIKE '22_______' AND numTelefone NOT GLOB '*[^0-9]*'),
    
    numLicensa  TEXT    CONSTRAINT ck_bilheteiro_numLicensa CHECK(LENGTH(numLicensa) == 12 AND numLicensa NOT GLOB '*[^0-9]*')
                        CONSTRAINT uq_bilheteiro_numLicensa UNIQUE
                        CONSTRAINT nn_bilheteiro_numLicensa NOT NULL, 

    nomeEstacao TEXT    CONSTRAINT fk_bilheteiro_estacao REFERENCES Estacao ON DELETE SET NULL 
                                                                            ON UPDATE CASCADE
                        CONSTRAINT nn_bilheteiro_nomeEstacao NOT NULL
);

CREATE TABLE Revisor(
    nif           TEXT    PRIMARY KEY 
                          CONSTRAINT ck_revisor_nif CHECK(LENGTH(nif) == 9 AND nif NOT GLOB '*[^0-9]*')
                          CONSTRAINT nn_revisor_nif NOT NULL,
    nome          TEXT,
    idade         INTEGER CONSTRAINT ck_revisor_idade CHECK(idade >= 18)
                          CONSTRAINT nn_revisor_idade NOT NULL,
    numTelefone   TEXT    CONSTRAINT ck_revisor_numTelefone CHECK(numTelefone LIKE '22_______' AND numTelefone NOT GLOB '*[^0-9]*'),                                                            
    identificacao TEXT    CONSTRAINT ck_revisor_identificacao CHECK(LENGTH(identificacao) == 9 AND identificacao NOT GLOB '*[^0-9]*')
                          CONSTRAINT uq_identificacao_revisor UNIQUE
                          CONSTRAINT nn_revisor_identificacao NOT NULL
);

CREATE TABLE ComboioCarga(
    id       INTEGER PRIMARY KEY AUTOINCREMENT
                     CONSTRAINT nn_comboioCarga_id NOT NULL,
    marca    TEXT    CONSTRAINT nn_comboioCarga_marca NOT NULL,
    modelo   TEXT    CONSTRAINT nn_comboioCarga_modelo NOT NULL  
                     CONSTRAINT nn_comboioCarga_id NOT NULL                                                                  
);

CREATE TABLE CargaCaracteristicas(
    marca     TEXT    CONSTRAINT nn_comboioCarga_marca NOT NULL,
    modelo    TEXT    CONSTRAINT nn_comboioCarga_modelo NOT NULL,
    velMaxima INTEGER CONSTRAINT ck_comboioCarga_velMaxima CHECK (velMaxima > 0)
                      CONSTRAINT nn_comboioCarga_velMaxima NOT NULL,
    maxCarga  FLOAT   CONSTRAINT ck_comboioCarga_maxCarga CHECK (maxCarga > 0 AND maxCarga < 5)
                      CONSTRAINT nn_comboioCarga_maxCarga NOT NULL,
    PRIMARY KEY(marca,modelo)
);

CREATE TABLE ComboioPassageiros(
    id       INTEGER PRIMARY KEY AUTOINCREMENT
                     CONSTRAINT nn_comboioPassageiros_id NOT NULL,
    marca    TEXT    CONSTRAINT nn_comboioPassageiros_marca NOT NULL,
    modelo   TEXT    CONSTRAINT nn_comboioPassageiros_modelo NOT NULL  
                     CONSTRAINT nn_comboioPassageiros_id NOT NULL
);

CREATE TABLE PassageirosCaracteristicas(
    marca     TEXT    CONSTRAINT nn_passageirosCaracteristicas_marca NOT NULL,
    modelo    TEXT    CONSTRAINT nn_passageirosCaracteristicas_modelo NOT NULL,
    velMaxima INTEGER CONSTRAINT ck_passageirosCaracteristicas_velMaxima CHECK (velMaxima > 0)
                      CONSTRAINT nn_passageirosCaracteristicas_velMaxima NOT NULL,
    lugares   INTEGER CONSTRAINT ck_passageirosCaracteristicas_lugares CHECK (lugares > 0)
                      CONSTRAINT nn_passageirosCaracteristicas_lugares NOT NULL,
    PRIMARY KEY(marca,modelo)
);


CREATE TABLE Viagem(--ok
    id                   INTEGER PRIMARY KEY AUTOINCREMENT
                                 CONSTRAINT nn_viagem_id NOT NULL,
    dataDePartida        DATE    CONSTRAINT nn_viagem_id NOT NULL,
    dataDeChegada        DATE    CONSTRAINT nn_viagem_id NOT NULL,
    idComboioCarga       INTEGER CONSTRAINT fk_viagem_comboio REFERENCES ComboioCarga ON DELETE SET NULL 
                                                                                      ON UPDATE CASCADE,
    idComboioPassageiros INTEGER CONSTRAINT fk_viagem_comboio REFERENCES ComboioPassageiros ON DELETE SET NULL 
                                                                                            ON UPDATE CASCADE,
    idRota               INTEGER CONSTRAINT fk_viagem_rota REFERENCES Rota ON DELETE CASCADE
                                                                           ON UPDATE CASCADE
                                 CONSTRAINT nn_viagem_idRota NOT NULL,
    nifMaquinista        TEXT    REFERENCES Maquinista ON DELETE SET NULL
                                                       ON UPDATE CASCADE
                                 CONSTRAINT nn_viagem_id NOT NULL,     
    CONSTRAINT uq_viagem_dataDePartida_idRota UNIQUE(dataDePartida,idRota),
    CONSTRAINT ck_viagem_idComboioCarga_idComboioPassageiros CHECK((idComboioCarga IS NULL) <> (idComboioPassageiros IS NULL))
);

CREATE TABLE RevisorViagem(--ok
    nifRevisor TEXT    CONSTRAINT fk_revisorViagem_revisor REFERENCES Revisor ON DELETE CASCADE 
                                                                              ON UPDATE CASCADE
                       CONSTRAINT nn_revisorViagem_nifRevisor NOT NULL,
    idViagem   INTEGER CONSTRAINT fk_revisorViagem_Viagem REFERENCES Viagem ON DELETE CASCADE 
                                                                            ON UPDATE CASCADE
                       CONSTRAINT nn_revisorViagem_idViagem NOT NULL,
    PRIMARY KEY(nifRevisor, idViagem)
);

CREATE TABLE Bilhete(--ok
    id                 INTEGER PRIMARY KEY AUTOINCREMENT
                               CONSTRAINT nn_bilhete_id NOT NULL,
    lugarDestinado     TEXT,
    nifCliente         TEXT    CONSTRAINT fk_bilhete_cliente REFERENCES Cliente ON DELETE SET NULL 
                                                                                ON UPDATE CASCADE
                               CONSTRAINT nn_bilhete_nifCliente NOT NULL,
    nomeEstacaoPartida TEXT    CONSTRAINT fk_bilhete_estacao REFERENCES Estacao ON DELETE SET NULL 
                                                                                ON UPDATE CASCADE
                               CONSTRAINT nn_bilhete_nomeEstacaoPartida NOT NULL,
    nomeEstacaoChegada TEXT    CONSTRAINT fk_bilhete_estacao REFERENCES Estacao ON DELETE SET NULL 
                                                                                ON UPDATE CASCADE
                               CONSTRAINT nn_bilhete_nomeEstacaoChegada NOT NULL,
    idViagem           INTEGER CONSTRAINT fk_bilhete_viagem REFERENCES Viagem  ON DELETE CASCADE
                                                                               ON UPDATE CASCADE
                               CONSTRAINT nn_bilhete_idViagem NOT NULL,
    nifBilheteiro      INTEGER CONSTRAINT fk_bilhete_bilheteiro REFERENCES Bilheteiro ON DELETE SET NULL 
                                                                                      ON UPDATE CASCADE,
    CONSTRAINT ck_bilhete_nomeEstacaoPartida_nomeEstacaoChegada CHECK(nomeEstacaoChegada != nomeEstacaoPartida)
);


CREATE TABLE BilhetePreco(
    nomeEstacaoPartida TEXT    CONSTRAINT fk_bilhetePreco_estacao REFERENCES Estacao ON DELETE SET NULL 
                                                                                     ON UPDATE CASCADE
                               CONSTRAINT nn_bilhetePreco_nomeEstacaoPartida NOT NULL,
    nomeEstacaoChegada TEXT    CONSTRAINT fk_bilhetePreco_estacao REFERENCES Estacao ON DELETE SET NULL 
                                                                                     ON UPDATE CASCADE
                               CONSTRAINT nn_bilhetePreco_nomeEstacaoChegada NOT NULL,
    idViagem           INTEGER CONSTRAINT fk_bilhetePreco_viagem REFERENCES Viagem  ON DELETE CASCADE 
                                                                                    ON UPDATE CASCADE
                               CONSTRAINT nn_bilhetePreco_idViagem NOT NULL,
    preco              FLOAT   CONSTRAINT fk_bilhetePreco_preco CHECK(preco > 0)
                               CONSTRAINT nn_bilhetePreco_preco NOT NULL,
    CONSTRAINT ck_bilhetePreco_nomeEstacaoPartida_nomeEstacaoChegada CHECK(nomeEstacaoChegada != nomeEstacaoPartida),
    PRIMARY KEY(nomeEstacaoPartida, nomeEstacaoChegada,idViagem)
);
