library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_banco_reg is
end entity tb_banco_reg;

architecture test of tb_banco_reg is

    -- DUT
    component banco_reg is
        port(
            write_control, clk, rst: in std_logic;
            registerAdress1     : in unsigned(2 downto 0);
            registerAdress2     : in unsigned(2 downto 0);
            registerAdress3     : in unsigned(2 downto 0);
            writing_data        : in unsigned(15 downto 0);
            read_data1          : out unsigned(15 downto 0);
            read_data2          : out unsigned(15 downto 0)
        );
    end component;

    -- Sinais do testbench
    signal s_clk           : std_logic := '0';
    signal s_rst           : std_logic := '0';
    signal s_write_control : std_logic := '0';
    signal s_addr1         : unsigned(2 downto 0) := (others => '0');
    signal s_addr2         : unsigned(2 downto 0) := (others => '0');
    signal s_addr3         : unsigned(2 downto 0) := (others => '0');
    signal s_write_data    : unsigned(15 downto 0) := (others => '0');
    signal s_read_data1    : unsigned(15 downto 0);
    signal s_read_data2    : unsigned(15 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instancia DUT
    uut: banco_reg
        port map(
            clk             => s_clk,
            rst             => s_rst,
            write_control   => s_write_control,
            registerAdress1 => s_addr1,
            registerAdress2 => s_addr2,
            registerAdress3 => s_addr3,
            writing_data    => s_write_data,
            read_data1      => s_read_data1,
            read_data2      => s_read_data2
        );

    -- Clock
    clk_process: process
    begin
        while true loop
            s_clk <= '0';
            wait for CLK_PERIOD/2;
            s_clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;

    -- Estímulos
    stimulus_proc: process
    begin
        ------------------------------------------------------
        -- CENARIO 1: RESET
        ------------------------------------------------------
        s_rst <= '1';
        wait for 2*CLK_PERIOD;   -- segura reset por 2 ciclos
        s_rst <= '0';
        wait for CLK_PERIOD;

        ------------------------------------------------------
        -- CENARIO 2: ESCRITAS
        ------------------------------------------------------
        -- Escreve CAFE em R3
        s_addr3         <= "011";
        s_write_data    <= x"CAFE";
        s_write_control <= '1';
        wait for CLK_PERIOD;     -- borda de subida faz a escrita
        s_write_control <= '0';
        wait for CLK_PERIOD;     -- espera 1 ciclo extra

        -- Escreve BEEF em R5
        s_addr3         <= "101";
        s_write_data    <= x"BEEF";
        s_write_control <= '1';
        wait for CLK_PERIOD;
        s_write_control <= '0';
        wait for CLK_PERIOD;

        ------------------------------------------------------
        -- CENARIO 3: LEITURA E VERIFICACAO
        ------------------------------------------------------
        s_addr1 <= "011"; -- lê R3
        s_addr2 <= "101"; -- lê R5
        wait for 1 ns;    -- tempo de propagaCAo combinacional

        assert s_read_data1 = x"CAFE"
            report "FALHA! Esperado x'CAFE' em R3" severity error;
        assert s_read_data2 = x"BEEF"
            report "FALHA! Esperado x'BEEF' em R5" severity error;

        ------------------------------------------------------
        -- CENARIO 4: TESTE DO R0
        ------------------------------------------------------
        -- Tenta escrever DEAD em R0 (ignorado)
        s_addr3         <= "000";
        s_write_data    <= x"DEAD";
        s_write_control <= '1';
        wait for CLK_PERIOD;
        s_write_control <= '0';
        wait for CLK_PERIOD;

        -- Leitura: R0 deve ser 0, R3 deve continuar CAFE
        s_addr1 <= "000";
        s_addr2 <= "011";
        wait for 1 ns;

        assert s_read_data1 = x"0000"
            report "FALHA! R0 não deveria armazenar nada" severity error;
        assert s_read_data2 = x"CAFE"
            report "FALHA! R3 foi corrompido!" severity error;

        ------------------------------------------------------
        -- Se chegou atE aqui, tudo OK
        ------------------------------------------------------
        report " Todos os testes passaram com sucesso!" severity note;
        wait;
    end process;

end architecture test;
