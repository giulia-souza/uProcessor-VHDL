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
        if (rst = '1') then -- Reset assincrono
            estado_s <= '0';
        elsif rising_edge(clk) then
            -- Flip-flop T: troca de estado a cada clock
            estado_s <= not estado_s;
        end if;
    end process;
    
    estado <= estado_s;

end architecture;