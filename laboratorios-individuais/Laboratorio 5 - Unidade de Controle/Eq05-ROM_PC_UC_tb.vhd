
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
use ieee.numeric_std.all;

entity Eq05_ROM_PC_UC_tb is
end entity;

architecture tb of Eq05_ROM_PC_UC_tb is
    -- Sinais de Clock e Reset
    signal clk     : std_logic := '0';
    signal rst     : std_logic := '1'; -- Inicia em Reset
    constant CLK_PERIOD : time := 10 ns;

    -- Saidas para observacao (portas do DUT)
    signal rom_dado_tb     : unsigned (7 downto 0) := (others => '0');
    signal pc_endereco_tb  : unsigned (6 downto 0) := (others => '0');

    -- Componente a ser testado
    component Eq05_ROM_PC_UC
        port(clk: in std_logic; rst: in std_logic; rom_dado_o: out unsigned (7 downto 0); pc_endereco_o: out unsigned (6 downto 0));
    end component;

begin
    -- Instanciacao do DUT (Device Under Test)
    DUT: Eq05_ROM_PC_UC port map (clk => clk, rst => rst, rom_dado_o => rom_dado_tb, pc_endereco_o => pc_endereco_tb);

    -- Geracao do Clock
    clk_process : process
    begin
        loop
            clk <= '0'; wait for CLK_PERIOD/2;
            clk <= '1'; wait for CLK_PERIOD/2;
        end loop;
    end process;
    
    -- Geracao do Reset e Teste Principal
    stim_process : process
    begin
        -- 1. Reset
        rst <= '1';
        wait for 2 * CLK_PERIOD;
        rst <= '0'; -- Fim do Reset

        -- O programa executa a sequencia (2 estagios / Delay Slot): 
        -- 0 -> 1 -> 2 -> 7 -> 8 -> 9 -> 0 -> ...
        
        -- O ciclo completo tem 6 instrucoes (0, 1, 2, 7, 8, 9).
        -- Cada instrucao leva 2 ciclos de clock (Fetch/Execute).
        -- Tempo de um loop completo: 6 instruções * 2 ciclos/instrução = 12 ciclos CLK_PERIOD
        
        -- Loop 1: Executa 0, 1, 2, 7, 8, 9, 0 (7 instrucoes para fechar o loop)
        wait for 14 * CLK_PERIOD; -- (7 instruções * 2 ciclos)

        -- Loop 2: Comprovacao do laco infinito (mais um ciclo completo de 6 instruções)
        wait for 12 * CLK_PERIOD; 
        
        -- Tempo de simulacao suficiente para comprovar o laco
        wait for 50 * CLK_PERIOD;

        report "Fim da Simulacao. Abra o GTKWave para verificar o laco." severity note;
        wait;
    end process;

end architecture;