-----------------------------------------------------------------------
-- Arquitetura e Organizacao de Computadores - S11
-- Prof: Rafael Eleodoro De Goes
-- Lab 6: Calculadora
-- Alunas: Giovana Valim (2449633)
-- Giulia de Souza Leite (2619075)
-----------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Eq05_ULA is
    port (
        in_A    : in  std_logic_vector(15 downto 0);
        in_B    : in  std_logic_vector(15 downto 0);
        op      : in  std_logic_vector(1 downto 0); 
        out_ULA : out std_logic_vector(15 downto 0);
        zero    : out std_logic; 
        gt      : out std_logic
    );
end entity Eq05_ULA;

architecture Behavioral of Eq05_ULA is

    constant OP_SOMA : std_logic_vector(1 downto 0) := "00";
    constant OP_SUB  : std_logic_vector(1 downto 0) := "01";
    constant OP_DIV  : std_logic_vector(1 downto 0) := "10";
    constant OP_PASS : std_logic_vector(1 downto 0) := "11"; -- Usado para operacoes que so precisam passar A ou um imediato
    
    signal   var_soma : unsigned(15 downto 0) := (others => '0');
    signal var_sub  : unsigned(15 downto 0) := (others => '0');
    signal var_div  : unsigned(15 downto 0) := (others => '0');
    signal var_res  : std_logic_vector(15 downto 0) := (others => '0');

begin
    var_soma <= unsigned(in_A) + unsigned(in_B);
    var_sub  <= unsigned(in_A) - unsigned(in_B);
    
    -- Divisao de inteiros. Se B for 0, resultado e 0.
    var_div <= to_unsigned(0, 16) when unsigned(in_B) = 0 else unsigned(in_A) / unsigned(in_B); 
        
    with op select
        var_res <= std_logic_vector(var_soma) when OP_SOMA,
                   std_logic_vector(var_sub)  when OP_SUB,
                   std_logic_vector(var_div)  when OP_DIV,
                   in_A                       when OP_PASS,
                   (others => '0')            when others;

    out_ULA <= var_res;
    
    zero <= '1' when var_res = X"0000" else '0';
    gt   <= '1' when unsigned(in_A) > unsigned(in_B) else '0';
end architecture Behavioral;