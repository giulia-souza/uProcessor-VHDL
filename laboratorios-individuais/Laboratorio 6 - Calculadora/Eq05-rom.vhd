-----------------------------------------------------------------------
-- Arquitetura e Organizacao de Computadores - S11
-- Prof: Rafael Eleodoro De Goes
-- Lab 6: Calculadora
-- Alunas: Giovana Valim (2449633)
-- Giulia de Souza Leite (2619075)
-- ROM agora armazena instrucoes de 24 bits (opcode[23:16] (8 bits), imm13[15:3] (13bits), rd[2:0])
-- (Arquivo modificado do Lab 5)
-----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Eq05_rom is
    port(
        clk       : in std_logic;
        endereco  : in unsigned (12 downto 0);  -- Endereco de 13 bits
        dado      : out unsigned (23 downto 0) -- Dado/Instrucao de 24 bits
    );
end entity;

architecture a_rom of Eq05_rom is
    -- ROM de 8192 posicoes (2^13), 24 bits por posicao
    type mem is array (0 to 8191) of unsigned (23 downto 0);
    
    -- Formato I: [OP(8)] [Rd(3)] [Const(13)] -> b"OOOOOOOO_DDD_CCCCCCCCCCCCC"
    -- Formato R: [OP(8)] [Rd(3)] [Rs(3)] [Rt(3)] [Unused(7)] -> b"OOOOOOOO_DDD_SSS_TTT_UUUUUUU"
    
    constant conteudo_rom : mem := (
        -- 1. Carrega R4 com o valor 4 (ADDI R4, 4)
        --    Op=0x01, Rd=4(100), Const=4
        0  => x"018004", -- b"00000001_100_000000000100"
        
        -- 2. Carrega R5 com 6 (ADDI R5, 6)
        --    Op=0x01, Rd=5(101), Const=6
        1  => x"01A006", -- b"00000001_101_000000000110"
        
        -- 3. Soma R4 com R5 e guarda em R6 (ADD R6, R4, R5)
        --    Op=0x10, Rd=6(110), Rs=4(100), Rt=5(101)
        2  => x"10D280", -- b"00010000_110_100_101_0000000"
        
        -- 4. Subtrai 2 de R6...
        --    Passo 4a: Carrega 2 em R3 (ADDI R3, 2)
        --    Op=0x01, Rd=3(011), Const=2
        3  => x"016002", -- b"00000001_011_000000000010"
        
        --    Passo 4b: Subtrai R6 de R3 (SUB R6, R6, R3)
        --    Op=0x11, Rd=6(110), Rs=6(110), Rt=3(011)
        4  => x"11D980", -- b"00010001_110_110_011_0000000"
        
        -- 5. Salta para o endereço 15 (JMP 15)
        --    Op=0x02, Rd=0(000), Const=15
        5  => x"02000F", -- b"00000010_000_000000001111"
        
        -- ... (Endereços 6 a 14 são NOP por 'others') ...

        -- 6. No endereço 15, copia R6 para R4 (MOV R4, R6 -> ADD R4, R6, R0)
        --    Op=0x13, Rd=4(100), Rs=6(110), Rt=0(000)
        15 => x"139800", -- b"00010011_100_110_000_0000000"
        
        -- 7. No endereço 16, calcula a divisão...
        --    Passo 7a: Carrega 3 em R3 (ADDI R3, 3)
        --    Op=0x01, Rd=3(011), Const=3
        16 => x"016003", -- b"00000001_011_000000000011"
        
        --    Passo 7b: Divide R6 por R3 (DIV R7, R6, R3)
        --    Op=0x12, Rd=7(111), Rs=6(110), Rt=3(011)
        17 => x"12F980", -- b"00010010_111_110_011_0000000"

        -- 8. Salta para a terceira instrução (addr 2) (JMP 2)
        --    Op=0x02, Rd=0(000), Const=2
        18 => x"020002", -- b"00000010_000_000000000010"
        
        -- Garante que o restante seja NOP (6 zeros)
        others => x"000000"
    );
    
    signal dado_s : unsigned (23 downto 0); 

begin
    -- Leitura Sincrona da ROM
    process (clk)
    begin
        if (rising_edge(clk)) then
            dado_s <= conteudo_rom(to_integer(endereco));
        end if;
    end process;

    dado <= dado_s;

end architecture;