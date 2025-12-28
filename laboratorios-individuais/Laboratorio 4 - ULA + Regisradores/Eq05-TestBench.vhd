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

entity Eq05_TestBench is
end entity Eq05_TestBench;

architecture Behavioral of Eq05_TestBench is

    component Eq05_ULARegs is
        port (
            clk         : in  std_logic;
            rst         : in  std_logic;
            WE3         : in  std_logic;
            A1          : in  std_logic_vector(3 downto 0);
            A2          : in  std_logic_vector(3 downto 0);
            A3          : in  std_logic_vector(3 downto 0);
            op          : in  std_logic_vector(1 downto 0);
            const_ext   : in  std_logic_vector(15 downto 0);
            sel_mux_inb : in  std_logic;
            flag        : out std_logic_vector(1 downto 0)
        );
    end component;

    -- Sinais de estimulo (drivers) inicializados
    signal s_clk         : std_logic := '0';
    signal s_rst         : std_logic := '0';
    signal s_WE3         : std_logic := '0';
    signal s_A1          : std_logic_vector(3 downto 0) := (others => '0');
    signal s_A2          : std_logic_vector(3 downto 0) := (others => '0');
    signal s_A3          : std_logic_vector(3 downto 0) := (others => '0');
    signal s_op          : std_logic_vector(1 downto 0) := (others => '0');
    signal s_const_ext   : std_logic_vector(15 downto 0) := (others => '0');
    signal s_sel_mux_inb : std_logic := '0';
    
    -- Sinais de observacao (driven pelos componentes)
    signal s_flag        : std_logic_vector(1 downto 0);

    -- Constantes do Roteiro
    constant CLK_PERIOD : time := 100 ns;
    
    constant RA_MAIOR : std_logic_vector(15 downto 0) := x"03B4"; -- 948
    constant RA_MENOR : std_logic_vector(15 downto 0) := x"0279"; -- 633
    
    constant OP_SOMA : std_logic_vector(1 downto 0) := "00";
    constant OP_DIV  : std_logic_vector(1 downto 0) := "10";
    
    constant R0 : std_logic_vector(3 downto 0) := "0000";
    constant R6 : std_logic_vector(3 downto 0) := "0110";
    constant R7 : std_logic_vector(3 downto 0) := "0111";

begin

    UUT: Eq05_ULARegs
        port map (
            clk         => s_clk,
            rst         => s_rst,
            WE3         => s_WE3,
            A1          => s_A1,
            A2          => s_A2,
            A3          => s_A3,
            op          => s_op,
            const_ext   => s_const_ext,
            sel_mux_inb => s_sel_mux_inb,
            flag        => s_flag
        );

    Clock_Process: process
    begin
        s_clk <= '0';
        wait for CLK_PERIOD / 2;
        s_clk <= '1';
        wait for CLK_PERIOD / 2;
    end process Clock_Process;

    Stimulus_Process: process
    begin
        report "Inicio da Simulacao do Test Bench ULARegs.";
        
        -- Passo 0: Reset Explicito
        s_rst <= '1';
        s_WE3 <= '0';
        s_A1 <= (others => '0');
        s_A2 <= (others => '0');
        s_A3 <= (others => '0');
        s_op <= (others => '0');
        s_const_ext <= (others => '0');
        s_sel_mux_inb <= '0';
        wait for CLK_PERIOD;
        s_rst <= '0';
        wait for CLK_PERIOD;

        -- Passo 1: Escreve RA_MAIOR (x"03B4") em R6
        report "Passo 1: Escrevendo RA_MAIOR (948) em R6";
        s_A1          <= R0;
        s_A3          <= R6;
        s_op          <= OP_SOMA;
        s_const_ext   <= RA_MAIOR;
        s_sel_mux_inb <= '1'; 
        s_WE3         <= '1';
        wait for CLK_PERIOD;
        s_WE3         <= '0';

        -- Passo 2: Escreve RA_MENOR (x"0279") em R7
        report "Passo 2: Escrevendo RA_MENOR (633) em R7";
        s_A1          <= R0;
        s_A3          <= R7;
        s_op          <= OP_SOMA;
        s_const_ext   <= RA_MENOR;
        s_sel_mux_inb <= '1'; 
        s_WE3         <= '1';
        wait for CLK_PERIOD;
        s_WE3         <= '0';

        -- Passo 3: Calculo da divisao (R6 / R7) -> R6
        report "Passo 3: Calculando R6 = R6 / R7 (948 / 633)";
        s_A1          <= R6; -- Agora in_A lera R6 (948)
        s_A2          <= R7;
        s_A3          <= R6;
        s_op          <= OP_DIV;
        s_sel_mux_inb <= '0';
        s_WE3         <= '1';
        wait for CLK_PERIOD;
        s_WE3         <= '0';

        -- Passo 4: Divisao de R6 por $zero (R0)
        report "Passo 4: Calculando R6 = R6 / R0 (Divisao por Zero)";
        s_A1          <= R6; -- Agora in_A lera R6 (1)
        s_A2          <= R0;
        s_A3          <= R6;
        s_op          <= OP_DIV;
        s_sel_mux_inb <= '0';
        s_WE3         <= '1';
        wait for CLK_PERIOD;
        s_WE3         <= '0';

        report "Fim da Simulacao.";
        wait;
    end process Stimulus_Process;

end architecture Behavioral;