CREATE DATABASE Prova

--DataBase de Loja

--Tabelas: Cliente, Vendas, Endereco


--Criação das tabelas: Cliente, Vendas, Endereco
CREATE TABLE Cliente(
	ID_Cliente INT NOT NULL PRIMARY KEY,
	PrimeiroNome VARCHAR(MAX) NOT NULL,
	SegundoNome VARCHAR(MAX),
	TerceiroNome VARCHAR(MAX),
	DataNascimento DATE,
	CPF VARCHAR(MAX),
	ID_Endereco INT
)

INSERT INTO Cliente (ID_Cliente, PrimeiroNome, SegundoNome, TerceiroNome, DataNascimento, CPF, ID_Endereco)
VALUES (1, 'Gabriel', 'Morais', 'Silva', '20070208', '123.456.789-05', NULL),
	   (2, 'Lucas', NULL , 'Beni', '20000617', '392.108.123-05', NULL),
       (3, 'Rian', NULL, NULL, '19701225', '093.209.120-05', NULL),
	   (4, 'Alexandre', 'Santos', 'da Silva', '19700321', '780.283.763-05', NULL),
	   (5, 'Beatriz', 'do Nascimento', 'Morais', '19721127', '983.092.833-05', NULL)

SELECT * FROM Cliente


CREATE TABLE Vendas (
	ID_Vendas INT NOT NULL PRIMARY KEY,
	NomeProduto VARCHAR(MAX) NOT NULL,
	QuantidadeVendida INT NOT NULL,
	Marca VARCHAR(MAX),
	ID_Cliente INT
)

INSERT INTO Vendas (ID_Vendas, NomeProduto, QuantidadeVendida, Marca, ID_Cliente)
VALUES (1, 'Furadeira', 1, NULL, 4),
	   (2, 'Pai_Rico_Pai_Pobre', 10, NULL, 1),
	   (3, 'Bicicleta', 3, 'Shimano', 4),
	   (4, 'Camisa_Nike', 20, 'Nike', 5) 



CREATE TABLE Endereco(
	ID_Endereco INT NOT NULL PRIMARY KEY,
	Rua VARCHAR (MAX),
	Numero INT,
	Cidade VARCHAR(MAX),
	Estado VARCHAR(MAX)
)

INSERT INTO Endereco (ID_Endereco, Rua, Numero, Cidade, Estado)
VALUES (1, 'Oratório', 1789, 'São_Paulo', 'SP'),
	   (2, 'Mooca', 2894, 'São_Paulo', 'SP'),
	   (3, 'Capitaes_Mores', 100, 'São_Paulo', 'SP'),
	   (4, 'Joao_Antonio', 729, 'São_Paulo', 'SP')



------------------------------------------------------------------------------------------------------------------------------------------------



--Adição de chaves estrangeiras
ALTER TABLE Cliente
ADD CONSTRAINT fk_Endereco
FOREIGN KEY (ID_Endereco) REFERENCES Endereco(ID_Endereco)

ALTER TABLE Vendas
ADD CONSTRAINT fk_Cliente
FOREIGN KEY (ID_Cliente) REFERENCES Cliente(ID_Cliente)



------------------------------------------------------------------------------------------------------------------------------------------------



--CTEs
WITH Consulta AS (
	SELECT
	Cliente.PrimeiroNome,
	Cliente.TerceiroNome,
	Vendas.NomeProduto,
	Endereco.Rua,
	Endereco.Numero

FROM Vendas
JOIN Cliente ON Vendas.ID_Cliente = Cliente.ID_Cliente
JOIN Endereco ON Cliente.ID_Endereco = Endereco.ID_Endereco
)

SELECT
	Cliente.PrimeiroNome,
	Cliente.TerceiroNome,
	Vendas.NomeProduto,
	Endereco.Rua,
	Endereco.Numero
FROM Consulta



------------------------------------------------------------------------------------------------------------------------------------------------



--Procedure
IF EXISTS (SELECT 1 FROM SYS.objects WHERE TYPE = 'P' AND NAME = 'Valores_Cliente')
	BEGIN 
		DROP PROCEDURE Valores_Cliente
	END

GO

CREATE PROCEDURE Valores_Cliente
	@ID_Cliente INT,
	@PrimeiroNomeCliente VARCHAR(MAX),
	@SegundoNomeCliente VARCHAR(MAX),
	@TerceiroNomeCliente VARCHAR(MAX),
	@DataNascimento DATE,
	--@ID_Vendas INT,
	@ID_Endereco INT

AS
	
	INSERT INTO Cliente (ID_Cliente, PrimeiroNome, SegundoNome, TerceiroNome, DataNascimento, ID_Endereco)
	VALUES (@ID_Cliente, @PrimeiroNomeCliente, @SegundoNomeCliente, @TerceiroNomeCliente, @DataNascimento, @ID_Endereco)

GO

EXEC Valores_Cliente @ID_Cliente = 6, @PrimeiroNomeCliente = 'Luiz', @SegundoNomeCliente = NULL, @TerceiroNomeCliente = NULL, @DataNascimento = '20020511', @ID_Endereco = '5'

SELECT * FROM Cliente



------------------------------------------------------------------------------------------------------------------------------------------------



--LOOP
DECLARE @Contador INT = 10
DECLARE @FinalContador INT = 15
DECLARE @Cidade VARCHAR(MAX) = 'São_Paulo'
DECLARE @Estado VARCHAR(MAX) = 'SP'


WHILE @Contador <= @FinalContador
BEGIN
	INSERT INTO Endereco (ID_Endereco, Rua, Numero, Cidade, Estado)
	VALUES (@Contador, NULL, NULL, @Cidade, @Estado)
	
	SET @Contador = @Contador + 1
END

SELECT * FROM Endereco



------------------------------------------------------------------------------------------------------------------------------------------------



--VIEW
CREATE VIEW CompraCliente AS
SELECT
	Cliente.PrimeiroNome,
	Cliente.TerceiroNome,
	Vendas.NomeProduto,
	Vendas.QuantidadeVendida AS 'Quantidade Comprada',
	Endereco.Rua,
	Endereco.Numero

FROM Vendas
JOIN Cliente ON Vendas.ID_Cliente = Cliente.ID_Cliente
JOIN Endereco ON Cliente.ID_Endereco = Endereco.ID_Endereco	

SELECT * FROM CompraCliente



------------------------------------------------------------------------------------------------------------------------------------------------



--TRIGGERS
CREATE OR ALTER TRIGGER Deletar
ON Vendas
INSTEAD OF DELETE
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Vendas WHERE ID_Vendas < 10000)
	BEGIN
	PRINT 'Esse dado não pode ser deletado, pois é importante para o controle de vendas da loja.'
	END
END

DELETE FROM Vendas WHERE ID_Vendas = 3

SELECT * FROM Vendas



------------------------------------------------------------------------------------------------------------------------------------------------



--SUBQUERY
SELECT * 
FROM Cliente
WHERE ID_Cliente IN 
(SELECT ID_Cliente
FROM Vendas
WHERE QuantidadeVendida > 9)

SELECT * FROM Vendas



------------------------------------------------------------------------------------------------------------------------------------------------



--Function
CREATE FUNCTION CalcularQtdVendas()
RETURNS INT
AS
BEGIN
	DECLARE @TotalVendas INT

	SELECT @TotalVendas = SUM(QuantidadeVendida)
	FROM Vendas

	RETURN @TotalVendas
END

SELECT dbo.CalcularQtdVendas() AS TotalVendas