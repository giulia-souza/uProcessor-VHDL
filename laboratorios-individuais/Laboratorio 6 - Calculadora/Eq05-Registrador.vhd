-----------------------------------------------------------------------
-- Arquitetura e Organizacao de Computadores - S11
-- Prof: Rafael Eleodoro De Goes
-- Lab 6: Calculadora
-- Alunas: Giovana Valim (2449633)
-- Giulia de Souza Leite (2619075)
-----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity Eq05_Registrador is
    port(
        clk     : in std_logic;
        rst     : in std_logic;
        wr_en   : in std_logic;
        data_in : in unsigned(15 downto 0);
        data_out: out unsigned(15 downto 0)
    );
end entity;

architecture a_registrador of Eq05_Registrador is
begin
    process (clk, rst)
    begin
        if (rst = '1') then
            data_out <= (others => '0');
        elsif rising_edge(clk) then
            if (wr_en = '1') then
                data_out <= data_in;
            end if;
        end if;
    end process;
end architecture;