-----------------------------------------------------------------------
-- Arquitetura e Organizacao de Computadores - S11
-- Prof: Rafael Eleodoro De Goes
-- Lab 6: Calculadora
-- Alunas: Giovana Valim (2449633)
-- Giulia de Souza Leite (2619075)
-- Banco de registradores 
-----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; -- Garante que 'unsigned' e do tipo correto

entity Eq05_BancoRegistradores is
    port( 
        write_control, clk, rst: in std_logic;
        registerAdress1      : in unsigned(2 downto 0);
        registerAdress2      : in unsigned(2 downto 0);
        registerAdress3      : in unsigned(2 downto 0);
        writing_data         : in unsigned(15 downto 0);
        read_data1           : out unsigned(15 downto 0);
        read_data2           : out unsigned(15 downto 0);
        
        
        debug_out_R4         : out unsigned(15 downto 0);
        debug_out_R5         : out unsigned(15 downto 0);
        debug_out_R6         : out unsigned(15 downto 0);
        debug_out_R7         : out unsigned(15 downto 0)
    );
end entity Eq05_BancoRegistradores;

architecture a_banco_reg of Eq05_BancoRegistradores is
    
    component Eq05_Registrador is
        port(
            clk      : in std_logic;
            rst      : in std_logic;
            wr_en    : in std_logic;
            data_in  : in unsigned(15 downto 0);
            data_out : out unsigned(15 downto 0)
        );
    end component;
    
    signal we0,we1,we2,we3,we4,we5,we6,we7: std_logic := '0';
    signal out0, out1, out2, out3, out4, out5, out6, out7: unsigned(15 downto 0);

begin
    -- Instanciacao dos 8 registradores
    uut0: Eq05_Registrador port map(clk=>clk, rst=>rst, wr_en=>we0, data_in=>writing_data, data_out=>out0);
    uut1: Eq05_Registrador port map(clk=>clk, rst=>rst, wr_en=>we1, data_in=>writing_data, data_out=>out1);
    uut2: Eq05_Registrador port map(clk=>clk, rst=>rst, wr_en=>we2, data_in=>writing_data, data_out=>out2);
    uut3: Eq05_Registrador port map(clk=>clk, rst=>rst, wr_en=>we3, data_in=>writing_data, data_out=>out3);
    uut4: Eq05_Registrador port map(clk=>clk, rst=>rst, wr_en=>we4, data_in=>writing_data, data_out=>out4);
    uut5: Eq05_Registrador port map(clk=>clk, rst=>rst, wr_en=>we5, data_in=>writing_data, data_out=>out5);
    uut6: Eq05_Registrador port map(clk=>clk, rst=>rst, wr_en=>we6, data_in=>writing_data, data_out=>out6);
    uut7: Eq05_Registrador port map(clk=>clk, rst=>rst, wr_en=>we7, data_in=>writing_data, data_out=>out7);
    
    
    -- Logica de Escrita (Write Enable)
    we0<='1' when (rst = '0' and registerAdress3 = "000" and write_control='1') else '0';
    we1<='1' when (rst = '0' and registerAdress3 = "001" and write_control='1') else '0';
    we2<='1' when (rst = '0' and registerAdress3 = "010" and write_control='1') else '0';
    we3<='1' when (rst = '0' and registerAdress3 = "011" and write_control='1') else '0';
    we4<='1' when (rst = '0' and registerAdress3 = "100" and write_control='1') else '0';
    we5<='1' when (rst = '0' and registerAdress3 = "101" and write_control='1') else '0';
    we6<='1' when (rst = '0' and registerAdress3 = "110" and write_control='1') else '0';
    we7<='1' when (rst = '0' and registerAdress3 = "111" and write_control='1') else '0';
    
    
    -- Logica de Leitura (Mux)
    read_data1 <= (others => '0') when rst = '1' else
                  out1 when registerAdress1 = "001" else
                  out2 when registerAdress1 = "010" else
                  out3 when registerAdress1 = "011" else
                  out4 when registerAdress1 = "100" else
                  out5 when registerAdress1 = "101" else
                  out6 when registerAdress1 = "110" else
                  out7 when registerAdress1 = "111" else
                  (others => '0'); -- R0
    
    read_data2 <= (others => '0') when rst = '1' else
                  out1 when registerAdress2 = "001" else
                  out2 when registerAdress2 = "010" else
                  out3 when registerAdress2 = "011" else
                  out4 when registerAdress2 = "100" else
                  out5 when registerAdress2 = "101" else
                  out6 when registerAdress2 = "110" else
                  out7 when registerAdress2 = "111" else
                  (others => '0'); -- R0
                  
    -- Liga as saidas de debug diretamente aos sinais internos
    -- dos registradores.
    debug_out_R4 <= out4;
    debug_out_R5 <= out5;
    debug_out_R6 <= out6;
    debug_out_R7 <= out7;
    
end architecture a_banco_reg;