-----------------------------------------------------------------------
-- Arquitetura e Organizacao de Computadores - S11
-- Prof: Rafael Eleodoro De Goes
-- Lab 8: Validacao
-- Alunas: Giovana Valim (2449633)
-- Giulia de Souza Leite (2619075)
-----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Eq05_rom is
    port(
        clk       : in std_logic;
        endereco  : in unsigned (12 downto 0);
        dado      : out unsigned (23 downto 0)
    );
end entity;

architecture a_rom of Eq05_rom is
    type mem is array (0 to 8191) of unsigned (23 downto 0);
    
    constant conteudo_rom : mem := (
        -- inicializando...
        0  => x"012001", -- ADDI R1, 1 (Constante 1)
        1  => x"014002", -- ADDI R2, 2 (Candidato = 2)
        2  => x"01C000", -- ADDI R6, 0 (Contador = 0)
        3  => x"01E000", -- ADDI R7, 0 (Ultimo Primo = 0)
        
        -- LOOP CANDIDATO (End 4)
		-- prepara para testar se R2 eh primo, assim reinicia o divisor (R3) para 2
        4  => x"016002", -- ADDI R3, 2 (Divisor = 2)
        
        -- LOOP DIVISOR (End 5)
        -- se o divisor (R3) alcancou o candidato (R2), entao R2 eh PRIMO
        5  => x"036810", -- BEQ R3, R2, 16 --- se R3 == R2, desvia para ACHOU_PRIMO (End 16)
        6  => x"000000", -- NOP
        
        -- CALCULA RESTO
        -- Resto = Candidato - (Divisor * (Candidato / Divisor))
		
		-- 1 divisao inteira: R5 = R2 / R3
        7  => x"12A980", -- DIV R5, R2, R3
        
        -- 2 multiplicacao: R5 = R3 * R5
        8  => x"14AE80", -- MUL R5, R3, R5 
        
        -- 3 resto: R4 = R2 - R5
        9  => x"118A80", -- SUB R4, R2, R5
        
        -- VERIFICA RESTO
        -- se Resto (R4) == 0 (R0), nao eh primo
        10 => x"03800E", -- BEQ R4, R0, 14 (vai para NAO_PRIMO)
        11 => x"000000", -- NOP
        
        -- PROXIMO DIVISOR
        -- se nao teve divizao exata, incrementa divisor e tenta novamente
        12 => x"106C80", -- ADD R3, R3, R1
        13 => x"020005", -- JMP 5
        
        -- NAO_PRIMO (End 14)
		-- se o numero nao for primo
        14 => x"000000", -- NOP
        15 => x"020013", -- JMP 19 (vai para INCREMENTAR_CANDIDATO (end 19))
        
        -- ACHOU_PRIMO (End 16)
		-- se encontrou um numero primo
        16 => x"000000", -- NOP
        17 => x"13E800", -- MOV R7, R2 (Salva Primo)
        18 => x"10D880", -- ADD R6, R6, R1 (Incrementa Contador)
        
        -- INCREMENTAR_CANDIDATO (End 19)
		-- testa o proximo numero inteiro
        19 => x"104880", -- ADD R2, R2, R1
		
		-- RETORNO INCONDICIONAL (sem limite de 30)
        20 => x"020004", -- JMP 4          ; Volta para LOOP_CANDIDATO
        
		--COMENTADO POR QUESTAO DE DUVIDA
        -- TESTE DE PARADA (Busca 30 primos)
		-- verifica se encontrou os 30 numeros primos
        --20 => x"01A01E", -- ADDI R5, 30 -- 30 eh o limite
        --21 => x"03D418", -- BEQ R6, R5, 24 -- se r6 for 30 vai para fim (End 24)
        --22 => x"000000", -- NOP
        
        --23 => x"020004", -- JMP 4 (Proximo Candidato)
        
        -- FIM
        --24 => x"000000", -- NOP
        --25 => x"020019", -- JMP 25 (Loop Infinito) - 25 Dec é 19 Hex
        
        others => x"000000"
    );
    
    signal dado_s : unsigned (23 downto 0) := (others => '0'); 
begin
    process (clk) begin
        if (rising_edge(clk)) then
            dado_s <= conteudo_rom(to_integer(endereco));
        end if;
    end process;
    dado <= dado_s;
end architecture;