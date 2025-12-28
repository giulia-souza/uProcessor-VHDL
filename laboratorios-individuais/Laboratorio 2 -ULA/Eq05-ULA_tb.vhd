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

entity Eq05_ULA_tb is
end entity Eq05_ULA_tb;

architecture Behavioral of Eq05_ULA_tb is

    component Eq05_ULA is
        port (
            in_A    : in  std_logic_vector(15 downto 0);
            in_B    : in  std_logic_vector(15 downto 0);
            op      : in  std_logic_vector(1 downto 0);
            out_ULA : out std_logic_vector(15 downto 0);
            zero    : out std_logic;
            gt      : out std_logic
        );
    end component Eq05_ULA;

    constant OP_SOMA : std_logic_vector(1 downto 0) := "00";
    constant OP_SUB  : std_logic_vector(1 downto 0) := "01";
    constant OP_DIV  : std_logic_vector(1 downto 0) := "10";
    constant OP_XOR  : std_logic_vector(1 downto 0) := "11";
    
    constant c_DELAY : time := 20 ns; -- cte p tempo de delay

    signal s_in_A    : std_logic_vector(15 downto 0) := (others => '0');
    signal s_in_B    : std_logic_vector(15 downto 0) := (others => '0');
    signal s_op      : std_logic_vector(1 downto 0) := "00";
    signal s_out_ULA : std_logic_vector(15 downto 0);
    signal s_zero    : std_logic;
    signal s_gt      : std_logic;

begin

    UUT : Eq05_ULA
        port map (
            in_A    => s_in_A,
            in_B    => s_in_B,
            op      => s_op,
            out_ULA => s_out_ULA,
            zero    => s_zero,
            gt      => s_gt
        );

    process
    begin
        report "Iniciando o Testbench da ULA...";
        wait for c_DELAY;

        -- SOMA 10 + 5 -- resultado 000F
        s_op   <= OP_SOMA;
        s_in_A <= std_logic_vector(to_unsigned(10, 16));
        s_in_B <= std_logic_vector(to_unsigned(5, 16));
        wait for c_DELAY;

        -- SUBTRACAO 20 - 8 -- resultado 000C
        s_op   <= OP_SUB;
        s_in_A <= std_logic_vector(to_unsigned(20, 16));
        s_in_B <= std_logic_vector(to_unsigned(8, 16));
        wait for c_DELAY;

        -- SUBTRACAO COM RESULTADO ZERO 15 - 15 -- resultado 0000
        s_op   <= OP_SUB;
        s_in_A <= std_logic_vector(to_unsigned(15, 16));
        s_in_B <= std_logic_vector(to_unsigned(15, 16));
        wait for c_DELAY;

        -- SUBTRACAO COM A < B  5 - 10 -- resultado FFFB
        s_op   <= OP_SUB;
        s_in_A <= std_logic_vector(to_unsigned(5, 16));
        s_in_B <= std_logic_vector(to_unsigned(10, 16));
        wait for c_DELAY;

        -- DIVISAO 50 / 10 -- resultado 0005
        s_op   <= OP_DIV;
        s_in_A <= std_logic_vector(to_unsigned(50, 16));
        s_in_B <= std_logic_vector(to_unsigned(10, 16));
        wait for c_DELAY;

        -- DIVISAO POR ZERO 100 / 0 -- resultado 0000
        s_op   <= OP_DIV;
        s_in_A <= std_logic_vector(to_unsigned(100, 16));
        s_in_B <= std_logic_vector(to_unsigned(0, 16));
        wait for c_DELAY;

        -- XOR     F0F0 xor 0F0F -- resultado FFFF
        s_op   <= OP_XOR;
        s_in_A <= x"F0F0";
        s_in_B <= x"0F0F";
        wait for c_DELAY;

        -- XOR COM RESULTADO ZERO    ABCD xor ABCD -- resultado 0000
        s_op   <= OP_XOR;
        s_in_A <= x"ABCD";
        s_in_B <= x"ABCD";
        wait for c_DELAY;

		-- DIVISAO COM RAs 26190 / 16129 -- resultado 0001
        s_op   <= OP_DIV;
        s_in_A <= std_logic_vector(to_unsigned(26190, 16));
        s_in_B <= std_logic_vector(to_unsigned(16129, 16));
        wait for c_DELAY;

        report "Fim dos testes.";
        wait;

    end process;

end architecture Behavioral;