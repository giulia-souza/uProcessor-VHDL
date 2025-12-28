-----------------------------------------------------------------------
-- Arquitetura e Organizacao de Computadores - S11
-- Prof: Rafael Eleodoro De Goes
-- Lab 7: Desvios Condicionais
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
    
    -- Formato R: [OP(8)] [Rd(3)] [Rs(3)] [Rt(3)] [zeros(7)]
    -- R4=100, R5=101, R6=110, R7=111

    constant conteudo_rom : mem := (
        -- 1. Carrega R4 com 3 (Multiplicando)
        0  => x"018003", -- ADDI R4, 3
        
        -- 2. Carrega R5 com 4 (Contador)
        1  => x"01A004", -- ADDI R5, 4
        
        -- 3. Zera R6 (Acumulador)
        2  => x"01C000", -- ADDI R6, 0
        
        -- 4. Carrega R7 com 1 (Para decrementar)
        3  => x"01E001", -- ADDI R7, 1
        
        -- INICIO DO LOOP (Endereco 4)
        
        -- 5. BEQ R5, R0, 10
        4  => x"03A00A", 
        
        -- 6. NOP 
        5  => x"000000", 
        
        -- 7. Soma: R6 = R6 + R4
        --    Op=10, Rd=6(110), Rs=6(110), Rt=4(100)
        --    Bin: 00010000 110 110 100 0000000 -> Hex: 10DA00
        6  => x"10DA00", 
        
        -- 8. Decrementa: R5 = R5 - R7
        --    Op=11, Rd=5(101), Rs=5(101), Rt=7(111)
        --    Bin: 00010001 101 101 111 0000000 -> Hex: 11B780
        7  => x"11B780", 
        
        -- 9. JMP 4 (Volta para o loop)
        8  => x"020004", 
        
        -- 10. Delay Slot do JMP
        9  => x"000000", 
        
        -- FIM (Endereco 10)
        -- 11. Loop infinito no fim (JMP 10)
        10 => x"02000A",
        11 => x"000000",
        
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