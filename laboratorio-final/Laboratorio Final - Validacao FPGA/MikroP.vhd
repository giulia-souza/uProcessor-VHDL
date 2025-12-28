LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY MikroP IS
	PORT (
		CLK_H_HW  : IN STD_LOGIC;
		RST_HW    : IN STD_LOGIC;
		KEY1_HW   : IN STD_LOGIC;
		SWITCH_HW : IN unsigned (9 DOWNTO 0);
		LED_HW    : OUT unsigned (9 DOWNTO 0);
		HEX0_HW   : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX1_HW   : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX2_HW   : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX3_HW   : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX4_HW   : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX5_HW   : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
	);
END MikroP;

ARCHITECTURE LogicFunction OF MikroP IS

	COMPONENT RAMDisp IS
		PORT (
			clk      : IN STD_LOGIC;
			endereco : IN unsigned(15 DOWNTO 0);
			wr_en    : IN STD_LOGIC;
			dado_in  : IN unsigned(15 DOWNTO 0);
			dado_out : OUT unsigned(15 DOWNTO 0);
			HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			rst      : IN STD_LOGIC;
			clk_h    : IN STD_LOGIC;
			turbo    : IN STD_LOGIC;
			halt     : IN STD_LOGIC;
			clk_div  : OUT STD_LOGIC
		);
	END COMPONENT RAMDisp;

	-- SEU COMPONENTE EXATO
	COMPONENT Eq05_Prime IS
		port(
        clk : in std_logic;
        rst : in std_logic;
        debug_estado    : out std_logic;
        debug_pc        : out unsigned (12 downto 0);
        debug_instrucao : out unsigned (23 downto 0);
        debug_ula_in_A  : out std_logic_vector (15 downto 0);
        debug_ula_in_B  : out std_logic_vector (15 downto 0);
        debug_ula_out   : out std_logic_vector (15 downto 0);
		  debug_R1			: out unsigned (15 downto 0);
		  debug_R2			: out unsigned (15 downto 0);
		  debug_R3			: out unsigned (15 downto 0);
        debug_R4        : out unsigned (15 downto 0);
        debug_R5        : out unsigned (15 downto 0);
        debug_R6        : out unsigned (15 downto 0);
        debug_R7        : out unsigned (15 downto 0)
    );
	END COMPONENT;

	SIGNAL clk_div_s : STD_LOGIC;
	SIGNAL rst_proc  : STD_LOGIC;
	
	-- Sinais Internos para Debug
	SIGNAL w_debug_pc : unsigned(12 downto 0);
	SIGNAL w_debug_r1, w_debug_r2, w_debug_r3, w_debug_r4, w_debug_r5, w_debug_r6, w_debug_r7 : unsigned(15 downto 0);

	SIGNAL enderecoRAMDisp : unsigned(15 DOWNTO 0);
	SIGNAL wr_enRAMDisp    : STD_LOGIC;
	SIGNAL dado_inRAMDisp  : unsigned(15 DOWNTO 0);
	SIGNAL ram_out         : unsigned(15 DOWNTO 0);

BEGIN

	rst_proc <= NOT RST_HW;

	-- Instancia do seu processador com as portas corretas
	CPU : Eq05_Prime
	PORT MAP (
		clk             => clk_div_s,
		rst             => rst_proc,
		debug_estado    => open,
		debug_pc        => w_debug_pc,
		debug_instrucao => open,
		debug_ula_in_A  => open,
		debug_ula_in_B  => open,
		debug_ula_out   => open,
		debug_R1			 => w_debug_r1,
		debug_R2			 => w_debug_r2,
		debug_R3			 => w_debug_r3,
		debug_R4        => w_debug_r4,
		debug_R5        => w_debug_r5,
		debug_R6        => w_debug_r6,
		debug_R7        => w_debug_r7
	);

	RAMeDISP : RAMDisp
	PORT MAP(
		clk      => clk_div_s,
		endereco => enderecoRAMDisp,
		dado_in  => dado_inRAMDisp,
		dado_out => ram_out,
		wr_en    => wr_enRAMDisp,
		HEX0 => HEX0_HW, HEX1 => HEX1_HW, HEX2 => HEX2_HW,
		HEX3 => HEX3_HW, HEX4 => HEX4_HW, HEX5 => HEX5_HW,
		halt    => SWITCH_HW(9),
		turbo   => SWITCH_HW(8),
		clk_h   => CLK_H_HW,
		clk_div => clk_div_s,
		rst     => rst_proc
	);

	enderecoRAMDisp <= to_unsigned(127, 16);
	wr_enRAMDisp    <= '1';

	dado_inRAMDisp <= w_debug_r7 when SWITCH_HW(2 downto 0) = "000" else
                     w_debug_r6 when SWITCH_HW(2 downto 0) = "001" else
                     w_debug_r5 when SWITCH_HW(2 downto 0) = "010" else
                     w_debug_r4 when SWITCH_HW(2 downto 0) = "011" else
                     w_debug_r3 when SWITCH_HW(2 downto 0) = "100" else
                     w_debug_r2 when SWITCH_HW(2 downto 0) = "101" else
                     w_debug_r1 when SWITCH_HW(2 downto 0) = "110" else
                     (others => '0');

	-- LEDs mostram o PC (Program Counter) para ver se esta travado ou rodando
	LED_HW(7 downto 0) <= w_debug_pc(7 downto 0);
	LED_HW(9 downto 8) <= (others => '0');

END LogicFunction;