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

entity Eq05_DesvCond is
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
end entity;

architecture a_Eq05_DesvCond of Eq05_DesvCond is
    component Eq05_maq_estados is
        port(clk: in std_logic; rst: in std_logic; estado: out std_logic);
    end component;
    component Eq05_program_counter is
        port(clk: in std_logic; rst: in std_logic; wr_en: in std_logic;
             data_in: in unsigned (12 downto 0); data_out: out unsigned (12 downto 0));
    end component;
    component Eq05_rom is
        port(clk: in std_logic; endereco: in unsigned (12 downto 0);
             dado: out unsigned (23 downto 0));
    end component;
    component Eq05_unidade_controle is
        port(clk: in std_logic; rst: in std_logic; estado: in std_logic;
             instrucao: in unsigned (23 downto 0);
             ula_zero: in std_logic; 
             pc_wr_en: out std_logic; pc_sel: out std_logic;
             reg_wr_en: out std_logic;
             reg_addr1_out: out unsigned (2 downto 0);
             reg_addr2_out: out unsigned (2 downto 0);
             reg_addr3_out: out unsigned (2 downto 0);
             ula_op_out: out std_logic_vector (1 downto 0);
             ula_A_sel: out std_logic; ula_B_sel: out std_logic);
    end component;
    component Eq05_BancoRegistradores is
        port(write_control: in std_logic; clk: in std_logic; rst: in std_logic;
             registerAdress1: in unsigned(2 downto 0); registerAdress2: in unsigned(2 downto 0); registerAdress3: in unsigned(2 downto 0);
             writing_data: in unsigned(15 downto 0);
             read_data1: out unsigned(15 downto 0); read_data2: out unsigned(15 downto 0);
             debug_out_R4: out unsigned(15 downto 0); debug_out_R5: out unsigned(15 downto 0); debug_out_R6: out unsigned(15 downto 0); debug_out_R7: out unsigned(15 downto 0));
    end component;
    component Eq05_ULA is
        port(in_A: in std_logic_vector(15 downto 0); in_B: in std_logic_vector(15 downto 0);
             op: in std_logic_vector(1 downto 0); out_ULA: out std_logic_vector(15 downto 0);
             zero: out std_logic; gt: out std_logic);
    end component;
    
    -- Sinais Internos (Inicializados)
    signal s_estado, s_pc_wr_en, s_pc_sel, s_reg_wr_en, s_ula_A_sel, s_ula_B_sel, s_ula_zero : std_logic := '0';
    signal s_pc_out, s_pc_in, s_pc_plus_1, s_const_13, s_jump_target_full : unsigned (12 downto 0) := (others => '0');
    signal s_rom_dado : unsigned (23 downto 0) := (others => '0');
    signal s_reg_addr1, s_reg_addr2, s_reg_addr3 : unsigned (2 downto 0) := (others => '0');
    signal s_reg_read_data1, s_reg_read_data2, s_reg_write_data : unsigned (15 downto 0) := (others => '0');
    signal s_ula_op : std_logic_vector (1 downto 0) := (others => '0');
    signal s_ula_in_A, s_ula_in_B, s_ula_out : std_logic_vector (15 downto 0) := (others => '0');
    signal s_jump_target_10 : unsigned (9 downto 0) := (others => '0');

begin
    U_FSM: Eq05_maq_estados port map (clk => clk, rst => rst, estado => s_estado);
    U_PC: Eq05_program_counter port map (clk => clk, rst => rst, wr_en => s_pc_wr_en, data_in => s_pc_in, data_out => s_pc_out);
    U_ROM: Eq05_rom port map (clk => clk, endereco => s_pc_out, dado => s_rom_dado);
    
    U_UC: Eq05_unidade_controle port map (
        clk => clk, rst => rst, estado => s_estado, instrucao => s_rom_dado,
        ula_zero => s_ula_zero,
        pc_wr_en => s_pc_wr_en, pc_sel => s_pc_sel,
        reg_wr_en => s_reg_wr_en,
        reg_addr1_out => s_reg_addr1, reg_addr2_out => s_reg_addr2, reg_addr3_out => s_reg_addr3,
        ula_op_out => s_ula_op, ula_A_sel => s_ula_A_sel, ula_B_sel => s_ula_B_sel
    );

    U_BANCO_REG: Eq05_BancoRegistradores port map (
        write_control => s_reg_wr_en, clk => clk, rst => rst,
        registerAdress1 => s_reg_addr1, registerAdress2 => s_reg_addr2, registerAdress3 => s_reg_addr3,
        writing_data => s_reg_write_data, read_data1 => s_reg_read_data1, read_data2 => s_reg_read_data2,
        debug_out_R4 => debug_R4, debug_out_R5 => debug_R5, debug_out_R6 => debug_R6, debug_out_R7 => debug_R7
    );

    U_ULA: Eq05_ULA port map (in_A => s_ula_in_A, in_B => s_ula_in_B, op => s_ula_op, out_ULA => s_ula_out, zero => s_ula_zero, gt => open);

    -- Logica de Enderecos (PC)
    s_pc_plus_1 <= s_pc_out + 1;
    s_jump_target_10 <= s_rom_dado(9 downto 0);
    s_jump_target_full <= "000" & s_jump_target_10;
    s_pc_in <= s_jump_target_full when s_pc_sel = '1' else s_pc_plus_1;

    -- Logica da ULA
    s_const_13 <= s_rom_dado(12 downto 0); 
    s_ula_in_A <= (others => '0') when s_ula_A_sel = '1' else std_logic_vector(s_reg_read_data1);
    s_ula_in_B <= std_logic_vector(resize(s_const_13, 16)) when s_ula_B_sel = '1' else std_logic_vector(s_reg_read_data2);
    s_reg_write_data <= unsigned(s_ula_out);

    -- Debugs
    debug_estado <= s_estado; debug_pc <= s_pc_out; debug_instrucao <= s_rom_dado;
    debug_ula_in_A <= s_ula_in_A; debug_ula_in_B <= s_ula_in_B; debug_ula_out <= s_ula_out;
end architecture;