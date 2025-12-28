-----------------------------------------------------------------------
-- Arquitetura e Organizacao de Computadores - S11
-- Prof: Rafael Eleodoro De Goes
-- Lab 8: Validacao - ULA com Multiplicacao
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
        op      : in  std_logic_vector(2 downto 0); -- Aumentado para 3 bits para caber MUL
        out_ULA : out std_logic_vector(15 downto 0);
        zero    : out std_logic; 
        gt      : out std_logic
    );
end entity Eq05_ULA;

architecture Behavioral of Eq05_ULA is
    -- Agora usamos 3 bits de seletor interno
    constant OP_SOMA : std_logic_vector(2 downto 0) := "000";
    constant OP_SUB  : std_logic_vector(2 downto 0) := "001";
    constant OP_DIV  : std_logic_vector(2 downto 0) := "010";
    constant OP_MUL  : std_logic_vector(2 downto 0) := "011"; -- NOVO
    constant OP_PASS : std_logic_vector(2 downto 0) := "100"; 
    
    signal var_soma : unsigned(15 downto 0) := (others => '0');
    signal var_sub  : unsigned(15 downto 0) := (others => '0');
    signal var_div  : unsigned(15 downto 0) := (others => '0');
    signal var_mul  : unsigned(15 downto 0) := (others => '0');
    signal var_res  : std_logic_vector(15 downto 0) := (others => '0');

begin
    var_soma <= unsigned(in_A) + unsigned(in_B);
    var_sub  <= unsigned(in_A) - unsigned(in_B);
    
    -- divisao protegida
    var_div <= to_unsigned(0, 16) when unsigned(in_B) = 0 else 
               unsigned(in_A) / unsigned(in_B); 
    
    -- multiplicacao (pega os 16 bits menos significativos)
    var_mul <= resize(unsigned(in_A) * unsigned(in_B), 16);

    with op select
        var_res <= std_logic_vector(var_soma) when OP_SOMA,
                   std_logic_vector(var_sub)  when OP_SUB,
                   std_logic_vector(var_div)  when OP_DIV,
                   std_logic_vector(var_mul)  when OP_MUL,
                   in_A                       when OP_PASS,
                   (others => '0')            when others;

    out_ULA <= var_res;
    
    zero <= '1' when unsigned(var_res) = 0 else '0';
    gt   <= '1' when unsigned(in_A) > unsigned(in_B) else '0';

end architecture Behavioral;