-----------------------------------------------------------------------
-- Arquitetura e Organizacao de Computadores - S11
-- Prof: Rafael Eleodoro De Goes
-- Lab 2 - Unidade Logica e Aritmetica
-- Alunos: Giovana Valim (2449633)
-- Giovanni Luigi Bolzon (1612948)
-- Giulia de Souza Leite (2619075)
-----------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Eq05_ULA is
    port (
		-- poderia ser unsigned na saída!!
		in_A	: in  std_logic_vector(7 downto 0);
		in_B	: in  std_logic_vector(7 downto 0);
		op	    : in  std_logic_vector(1 downto 0);

		out_ULA : out std_logic_vector(7 downto 0);
		zero	: out std_logic; -- flag quando o resultado eh zero
		gt	    : out std_logic  -- flag quando A maior q B
	);
end entity Eq05_ULA;

architecture Behavioral of Eq05_ULA is

	constant OP_SOMA : std_logic_vector(1 downto 0) := "00";
	constant OP_SUB  : std_logic_vector(1 downto 0) := "01";
	constant OP_DIV  : std_logic_vector(1 downto 0) := "10";
	constant OP_XOR  : std_logic_vector(1 downto 0) := "11";
	
	signal  var_soma : unsigned(7 downto 0);
	signal var_sub  : unsigned(7 downto 0);
	signal var_div  : unsigned(7 downto 0);
	signal var_xor  : std_logic_vector(7 downto 0);
	signal var_res  : std_logic_vector(7 downto 0);

begin
	var_soma <= unsigned(in_A) + unsigned(in_B);
	var_sub  <= unsigned(in_A) - unsigned(in_B);
	var_xor  <= in_A xor in_B;

	var_div <= (others => '0') when unsigned(in_B) = "00000000" else (unsigned(in_A) / unsigned(in_B));
		
	with op select
		var_res <= std_logic_vector(var_soma) when OP_SOMA,
				std_logic_vector(var_sub)  when OP_SUB,
                std_logic_vector(var_div)  when OP_DIV,
                var_xor                    when OP_XOR,
                (others => '0')            when others;

	out_ULA <= var_res;
	
	zero <= '1' when var_res = "00000000" else '0';

	gt <= '1' when unsigned(in_A) > unsigned(in_B) else '0';

end architecture Behavioral;