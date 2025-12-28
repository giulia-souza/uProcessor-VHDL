-----------------------------------------------------------------------
-- Arquitetura e Organizacao de Computadores  S11
-- Prof: Rafael Eleodoro De Goes
-- Lab 4: ULARegs
-- Alunos: Giovana Valim (2449633)
--         Giovanni Luigi Bolzon (1612948)
--         Giulia de Souza Leite (2619075)
-----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity Eq05_Mux2to1_16bit is
    port (
        in0  : in  std_logic_vector(15 downto 0); -- Vindo do RD2
        in1  : in  std_logic_vector(15 downto 0); -- Vindo da const_ext
        sel  : in  std_logic;
        out_s: out std_logic_vector(15 downto 0)
    );
end entity Eq05_Mux2to1_16bit;

architecture Behavioral of Eq05_Mux2to1_16bit is
begin
    -- Seleciona entre a saida do registrador (in0) ou a constante (in1)
    with sel select
        out_s <= in0 when '0',
                 in1 when '1',
                 (others => 'X') when others;
end Behavioral;