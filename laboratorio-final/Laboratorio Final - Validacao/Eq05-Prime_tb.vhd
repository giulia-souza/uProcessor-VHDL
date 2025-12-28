-----------------------------------------------------------------------
-- Arquitetura e Organizacao de Computadores - S11
-- Prof: Rafael Eleodoro De Goes
-- Lab 8: Validacao - Testbench (Prime)
-- Alunas: Giovana Valim (2449633)
-- Giulia de Souza Leite (2619075)
-----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Eq05_Prime_tb is
end entity;

architecture a_tb of Eq05_Prime_tb is
    component Eq05_Prime is
        port(
            clk : in std_logic;
            rst : in std_logic;
            debug_estado    : out std_logic;
            debug_pc        : out unsigned (12 downto 0);
            debug_instrucao : out unsigned (23 downto 0);
            debug_ula_in_A  : out std_logic_vector (15 downto 0);
            debug_ula_in_B  : out std_logic_vector (15 downto 0);
            debug_ula_out   : out std_logic_vector (15 downto 0);
            debug_R4        : out unsigned (15 downto 0);
            debug_R5        : out unsigned (15 downto 0);
            debug_R6        : out unsigned (15 downto 0);
            debug_R7        : out unsigned (15 downto 0)
        );
    end component;
    
    signal s_clk, s_rst : std_logic := '0';
begin
    dut: Eq05_Prime port map (
        clk => s_clk, 
        rst => s_rst,
        debug_estado => open,
        debug_pc => open,
        debug_instrucao => open,
        debug_ula_in_A => open,
        debug_ula_in_B => open,
        debug_ula_out => open,
        debug_R4 => open,
        debug_R5 => open,
        debug_R6 => open,
        debug_R7 => open
    );

    -- Clock de 100ns (50 high / 50 low)
    process begin
        s_clk <= '0'; wait for 50 ns;
        s_clk <= '1'; wait for 50 ns;
    end process;

    -- Reset inicial
    process begin
        s_rst <= '1'; wait for 20 ns;
        s_rst <= '0'; wait;
    end process;
end architecture;