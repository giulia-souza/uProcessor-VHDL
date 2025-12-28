-----------------------------------------------------------------------
-- Arquitetura e Organizacao de Computadores - S11
-- Prof: Rafael Eleodoro De Goes
-- Lab 8: Validacao
-- Alunas: Giovana Valim (2449633)
-- Giulia de Souza Leite (2619075)
-- Reutilizacao do codigo feito no Lab 5 
-----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity Eq05_maq_estados is
    port(
        clk   : in std_logic;
        rst   : in std_logic;
        estado: out std_logic -- '0' = Fetch, '1' = Decode/Execute
    );
end entity;

architecture a_maq_estados of Eq05_maq_estados is
    signal estado_s : std_logic := '0'; 
begin
    process (clk, rst)
    begin
        if (rst = '1') then 
            estado_s <= '0';
        elsif rising_edge(clk) then
            estado_s <= not estado_s;
        end if;
    end process;
    
    estado <= estado_s;
end architecture;