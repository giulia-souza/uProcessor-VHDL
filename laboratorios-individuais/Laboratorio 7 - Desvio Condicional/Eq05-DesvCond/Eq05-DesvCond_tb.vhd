-----------------------------------------------------------------------
-- Arquitetura e Organizacao de Computadores - S11
-- Prof: Rafael Eleodoro De Goes
-- Lab 7: Desvios Condicionais
-- Alunas: Giovana Valim (2449633)
-- Giulia de Souza Leite (2619075)
-----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Eq05_DesvCond_tb is
end entity;

architecture tb of Eq05_DesvCond_tb is
    -- Componente a ser testado (DUT)
    component Eq05_DesvCond is
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

    -- Sinais de Clock e Reset
    signal s_clk : std_logic := '0';
    signal s_rst : std_logic := '1'; -- Inicia em Reset
    constant CLK_PERIOD : time := 10 ns; -- Clock de 100 MHz

    -- Sinais de debug (saidas do DUT)
    signal s_estado    : std_logic;
    signal s_pc        : unsigned (12 downto 0);
    signal s_instrucao : unsigned (23 downto 0);
    signal s_ula_in_A  : std_logic_vector (15 downto 0);
    signal s_ula_in_B  : std_logic_vector (15 downto 0);
    signal s_ula_out   : std_logic_vector (15 downto 0);
    signal s_R4        : unsigned (15 downto 0);
    signal s_R5        : unsigned (15 downto 0);
    signal s_R6        : unsigned (15 downto 0);
    signal s_R7        : unsigned (15 downto 0);

begin
    -- 1. Instanciacao do DUT (Device Under Test)
    DUT: Eq05_DesvCond port map (
        clk => s_clk,
        rst => s_rst,
        debug_estado    => s_estado,
        debug_pc        => s_pc,
        debug_instrucao => s_instrucao,
        debug_ula_in_A  => s_ula_in_A,
        debug_ula_in_B  => s_ula_in_B,
        debug_ula_out   => s_ula_out,
        debug_R4        => s_R4,
        debug_R5        => s_R5,
        debug_R6        => s_R6,
        debug_R7        => s_R7
    );

    -- 2. Geracao do Clock
    clk_process : process
    begin
        loop
            s_clk <= '0'; wait for CLK_PERIOD/2;
            s_clk <= '1'; wait for CLK_PERIOD/2;
        end loop;
    end process;
    
    -- 3. Geracao de Estimulos (Reset)
    stim_process : process
    begin
        -- Aplica Reset por 2 ciclos
        s_rst <= '1';
        wait for 2 * CLK_PERIOD;
        
        -- Libera o Reset
        s_rst <= '0';

        -- A simulacao continuara indefinidamente (ou até o stop-time do script .bat)
        report "Testbench: Reset liberado. Simulacao em andamento." severity note;
        wait;
    end process;

end architecture;