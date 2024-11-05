CREATE DATABASE WorldWatch;

USE WorldWatch;


--Tabelas

CREATE TABLE Funcionario (
	FuncionarioID INT PRIMARY KEY,
	CPF VARCHAR(14) NOT NULL,
	RG VARCHAR(14) NOT NULL,
	Nome VARCHAR(50) NOT NULL,
	Email VARCHAR(100) NOT NULL,
	Nascimento DATE NOT NULL,
	Genero VARCHAR(20) NOT NULL,
	Celular VARCHAR(18) NOT NULL,
	CEP VARCHAR(9) NOT NULL,
	Endereco VARCHAR(100) NOT NULL
);

INSERT INTO Funcionario (FuncionarioID, CPF, RG, Nome, Email, Nascimento, Genero, Celular, CEP, Endereco)
VALUES
    (1, '111.111.111-1', '11.111.112-1', 'Fernanda', 'fernanda@gmail.com', '14/06/1997', 'F', '55 (11) 11111-1111', '11111-111', 'Rua Ameixa, 617'),
    (2, '111.111.111-2', '11.111.112-2', 'Marcos', 'marcos@gmail.com', '17/09/1998', 'M', '55 (11) 11111-1112', '22222-222', 'Rua Ameixa, 618'),
    (3, '111.111.111-3', '11.111.112-3', 'Lara', 'lara@gmail.com', '24/10/2000', 'F', '55 (11) 11111-1113', '33333-333', 'Rua Ameixa, 619');



CREATE TABLE Cliente (
	ClienteID INT PRIMARY KEY,
	CPF VARCHAR(14) NOT NULL,
	RG VARCHAR(14) NOT NULL,
	Nome VARCHAR(50) NOT NULL,
	Email VARCHAR(100) NOT NULL,
	Nascimento DATE NOT NULL,
	Genero VARCHAR(20) NOT NULL,
	Celular VARCHAR(18) NOT NULL,
	CEP VARCHAR(9) NOT NULL,
	Endereco VARCHAR(100) NOT NULL
);

INSERT INTO Cliente (ClienteID, CPF, RG, Nome, Email, Nascimento, Genero, Celular, CEP, Endereco)
VALUES
    (1, '111.111.111-4', '11.111.112-4', 'Maria', 'maria@gmail.com', '18/07/1998', 'F', '55 (11) 11111-1114', '11111-114', 'Rua Ameixa, 616'),
    (2, '111.111.111-5', '11.111.112-5', 'Lucas', 'lucas@gmail.com', '17/12/1999', 'M', '55 (11) 11111-1115', '22222-225', 'Rua Ameixa, 615'),
    (3, '111.111.111-6', '11.111.112-6', 'Denise', 'denise@gmail.com', '20/10/2001', 'F', '55 (11) 11111-1116', '33333-336', 'Rua Ameixa, 614');



CREATE TABLE Produtos (
	ProdutoID INT PRIMARY KEY,
	Nome VARCHAR(50) NOT NULL,
	Preco DECIMAL(5,2) NOT NULL,
	DataEntrada DATETIME NOT NULL
);

INSERT INTO Produtos (ProdutoID, Nome, Preco, DataEntrada)
VALUES
	(1, 'Relogio Infantil', '69.99', '20/06/2023'),
	(2, 'Relogio Tech', '89.99', '14/03/2024'),
	(3, 'Relogio Smart', '99.99', '24/02/2023');


CREATE TABLE Vendas (
	VendasID INT PRIMARY KEY,
	DataVenda DATETIME NOT NULL,
	ProdutoID INT,
	FOREIGN KEY (ProdutoID) REFERENCES Produtos(ProdutoID),   --Declara que o ProdutoID é uma chave estrangeira da tabela Produtos. 
	ClienteID INT,
	FOREIGN KEY (ClienteID) REFERENCES Cliente(ClienteID),
	FuncionarioID INT,
	FOREIGN KEY (FuncionarioID) REFERENCES Funcionario(FuncionarioID)
);

INSERT INTO Vendas (VendasID, DataVenda, ProdutoID, ClienteID, FuncionarioID)
VALUES
	(1, '23/10/2024', 2, 1, 3),
	(2, '14/06/2024', 1, 3, 1),
	(3, '21/07/2023', 1, 1, 3),
	(4, '01/08/2024', 2, 2, 2),
	(5, '20/04/2023', 3, 3, 2);



--VIEWS

--Essa view mostra as vendas realizadas pelo funcionário cujo ID é 1

CREATE VIEW VendaFuncionario
AS
SELECT
	Funcionario.FuncionarioID,
	Funcionario.Nome,
	Vendas.ProdutoID,
	Vendas.ClienteID,
	Vendas.DataVenda
FROM Vendas
JOIN Funcionario ON Vendas.FuncionarioID = Funcionario.FuncionarioID
WHERE Funcionario.FuncionarioID = 1

SELECT *
FROM VendaFuncionario



--Subqueries

--Essa Subquerie mostra os clientes que compraram o produto cujo nome é "Relogio Infantil".

SELECT Nome
FROM Cliente
WHERE ClienteID IN (
SELECT ClienteID
FROM Vendas
WHERE ProdutoID = (
SELECT ProdutoID
FROM Produtos
WHERE Produtos.Nome = 'Relogio Infantil')
);



--CTEs

--Essa CTE cria uma tabela temporária para mostrar as vendas de forma detalhada.

WITH VendaDetalhada AS (
SELECT
	Produtos.Nome AS 'Nome Produto',
	DataVenda,
	Produtos.Preco,
	Funcionario.FuncionarioID,
	Cliente.ClienteID
FROM Vendas 
INNER JOIN Produtos ON Vendas.ProdutoID = Produtos.ProdutoID
INNER JOIN Funcionario ON Vendas.FuncionarioID = Funcionario.FuncionarioID
INNER JOIN Cliente ON Vendas.ClienteID = Cliente.ClienteID
)

SELECT *
FROM VendaDetalhada
ORDER BY 'Nome Produto'



--Window Functions

SELECT
	VendasID,
	DataVenda,
NTILE(10) OVER (ORDER BY DataVenda DESC) AS 'Grupo por data de entrada'
FROM Vendas


--Functions

--Essa function nos mostra a idade de cada cliente.

CREATE FUNCTION CalcularIdade (@dataNascimento DATE)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(YEAR, @dataNascimento, GETDATE());
END;

SELECT Nome, dbo.CalcularIdade(Nascimento) AS Idade
FROM Cliente;



--Procedures

--Esse Procedure adiciona uma venda na tabela de vendas.

IF EXISTS (SELECT 1 FROM SYS.objects WHERE TYPE = 'P' AND NAME = 'SP_ADD_VENDA')
	BEGIN
		DROP PROCEDURE SP_ADD_VENDA
	END
GO

CREATE PROCEDURE SP_ADD_VENDA
    @VendasID INT,
    @DataVenda DATETIME,
    @ProdutoID INT,
    @ClienteID INT,
	@FuncionarioID INT
AS
    INSERT INTO Vendas (VendasID, DataVenda, ProdutoID, ClienteID, FuncionarioID)
    VALUES (@VendasID, @DataVenda, @ProdutoID, @ClienteID, @FuncionarioID);
GO

EXEC SP_ADD_VENDA
    @VendasID = 6,
    @DataVenda = '15/04/2024',
    @ProdutoID = 3,
    @ClienteID = 2,
	@FuncionarioID = 1

SELECT * FROM Vendas



--Triggers

--Esse Trigger impede que qualquer dado da tabela vendas seja deletado.

CREATE OR ALTER TRIGGER DeletarVenda
ON Vendas
INSTEAD OF DELETE
AS
BEGIN
	PRINT 'Esses dados não podem ser deletados'
END
GO

DELETE FROM Vendas
WHERE VendasID = 3

SELECT *
FROM Vendas



--Loops

--Esse loop nos diz quais os clientes que não fizeram compras dentro dos últimos 2 meses.

DECLARE @ClienteID INT;
DECLARE @Nome VARCHAR(50);
DECLARE @contador INT = 1;
DECLARE @totalCliente INT;

SELECT @totalCliente = COUNT(*) 
FROM Cliente
WHERE NOT EXISTS (
SELECT 1
FROM Vendas
WHERE Vendas.ClienteID = Cliente.ClienteID AND Vendas.DataVenda >= DATEADD(MONTH, -2, GETDATE())
);

WHILE @contador <= @totalCliente
BEGIN

SELECT
	@ClienteID = ClienteID,
	@Nome = Nome
FROM (
SELECT Cliente.ClienteID, Cliente.Nome,
ROW_NUMBER() OVER (ORDER BY Cliente.Nome) AS RowNum
FROM Cliente
WHERE NOT EXISTS (
SELECT 1 
FROM Vendas 
WHERE Vendas.ClienteID = Cliente.ClienteID AND Vendas.DataVenda >= DATEADD(MONTH, -2, GETDATE()))) AS T
WHERE RowNum = @contador;

PRINT 'Cliente sem compras nos últimos 2 meses:' + @Nome;
SET @contador = @contador + 1;
END;