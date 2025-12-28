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

entity Eq05_ULARegs is
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
end entity Eq05_ULARegs;

architecture Structural of Eq05_ULARegs is

    component Eq05_BancoRegistradores is
        port (
            write_control, clk, rst : in  std_logic;
            registerAdress1      : in  unsigned(2 downto 0);
            registerAdress2      : in  unsigned(2 downto 0);
            registerAdress3      : in  unsigned(2 downto 0);
            writing_data         : in  unsigned(15 downto 0);
            read_data1           : out unsigned(15 downto 0);
            read_data2           : out unsigned(15 downto 0)
        );
    end component;

    component Eq05_ULA is
        port (
            in_A    : in  std_logic_vector(15 downto 0);
            in_B    : in  std_logic_vector(15 downto 0);
            op      : in  std_logic_vector(1 downto 0);
            out_ULA : out std_logic_vector(15 downto 0);
            zero    : out std_logic;
            gt      : out std_logic
        );
    end component;

    component Eq05_Mux2to1_16bit is
        port (
            in0   : in  std_logic_vector(15 downto 0);
            in1   : in  std_logic_vector(15 downto 0);
            sel   : in  std_logic;
            out_s : out std_logic_vector(15 downto 0)
        );
    end component;

    signal s_rd1, s_rd2     : unsigned(15 downto 0);
    signal s_ula_out        : std_logic_vector(15 downto 0);
    signal s_ula_inB        : std_logic_vector(15 downto 0);
    signal s_flag_zero, s_flag_gt : std_logic;


begin

    RegFile_Unit: Eq05_BancoRegistradores
        port map (
            clk             => clk,
            rst             => rst,
            write_control   => WE3,
            registerAdress1 => unsigned(A1(2 downto 0)),
            registerAdress2 => unsigned(A2(2 downto 0)),
            registerAdress3 => unsigned(A3(2 downto 0)),
            writing_data    => unsigned(s_ula_out),
            read_data1      => s_rd1,
            read_data2      => s_rd2
        );

    Mux_InB_Unit: Eq05_Mux2to1_16bit
        port map (
            in0   => std_logic_vector(s_rd2),
            in1   => const_ext,
            sel   => sel_mux_inb,
            out_s => s_ula_inB
        );

    ULA_Unit: Eq05_ULA
        port map (
            in_A    => std_logic_vector(s_rd1),
            in_B    => s_ula_inB,
            op      => op,
            out_ULA => s_ula_out,
            zero    => s_flag_zero,
            gt      => s_flag_gt
        );

    flag(0) <= s_flag_zero;
    flag(1) <= s_flag_gt;

end architecture Structural;