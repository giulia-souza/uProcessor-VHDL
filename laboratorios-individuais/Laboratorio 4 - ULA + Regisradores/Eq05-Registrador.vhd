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
use ieee.numeric_std.all;

entity Eq05_Registrador is
    port( clk      : in std_logic;
          rst      : in std_logic;
          wr_en    : in std_logic;
          data_in  : in unsigned(15 downto 0);
          data_out : out unsigned(15 downto 0)
    );
end entity Eq05_Registrador;

architecture a_reg16bits of Eq05_Registrador is
    signal registro: unsigned(15 downto 0):= (others => '0');
begin
    process(clk,rst,wr_en)
    begin           
        if rst='1' then
            registro <= (others => '0');
        elsif wr_en='1' then
            if rising_edge(clk) then
                registro <= data_in;
            end if;
        end if;
    end process;
    
    data_out <= registro;  -- conexao direta, fora do processo
end architecture a_reg16bits;