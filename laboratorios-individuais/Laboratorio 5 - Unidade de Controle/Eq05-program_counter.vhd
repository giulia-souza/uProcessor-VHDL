-----------------------------------------------------------------------
-- Arquitetura e Organizacao de Computadores - S11
-- Prof: Rafael Eleodoro De Goes
-- Lab 5: Unidade de Controle
-- Alunos: Giovana Valim (2449633)
-- Giovanni Luigi Bolzon (1612948)
-- Giulia de Souza Leite (2619075)
-----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Eq05_program_counter is
    port(
        clk     : in std_logic;
        rst     : in std_logic;
        wr_en   : in std_logic;                      -- Write Enable do PC
        data_in : in unsigned (6 downto 0);          -- Novo endereco (incrementado ou salto)
        data_out: out unsigned (6 downto 0)          -- Endereco atual da instrucao (para a ROM)
    );
end entity;

architecture a_pc of Eq05_program_counter is
    signal pc_reg : unsigned (6 downto 0) := (others => '0'); 

begin
    -- Registrador comum (PC)
    process (clk, rst)
    begin
        if (rst = '1') then -- Reset assincrono
            pc_reg <= (others => '0');
        elsif rising_edge(clk) then
            if (wr_en = '1') then
                pc_reg <= data_in; -- Carrega novo valor se wr_en for alto
            end if;
        end if;
    end process;
    
    data_out <= pc_reg;

end architecture;