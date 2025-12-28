library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY MikroP IS
    PORT (    
        -- sinais que sao usados no toplevel (substituem o que vinha do testbench)
        CLK_H_HW : in std_logic;                -- PIN_N14 (50 MHz)
        RST_HW   : in std_logic;                -- KEY0 PIN_B8
            
        -- sinais que sao a interface de teste no HW fisico
        KEY1_HW   : in std_logic;                -- KEY1 PIN_A7
        
        SWITCH_HW : in unsigned (9 downto 0);    -- SW9 a SW0  (PINS F15, B14, A14, A13, B12, A12, C12, D12, C11, C10) 
        LED_HW    : out unsigned (9 downto 0);   -- LED9..LED0 (PINS B11, A11, D14, E14, C13, D13, B10, A10, A9, A8)

        -- displays da placa conectados na FPGA
        HEX0_HW   : out std_logic_vector(6 downto 0);    -- display 7 segmentos (LSd)
        HEX1_HW   : out std_logic_vector(6 downto 0);    -- display 7 segmentos
        HEX2_HW   : out std_logic_vector(6 downto 0);    -- display 7 segmentos
        HEX3_HW   : out std_logic_vector(6 downto 0);    -- display 7 segmentos 
        HEX4_HW   : out std_logic_vector(6 downto 0);    -- display 7 segmentos 
        HEX5_HW   : out std_logic_vector(6 downto 0)     -- display 7 segmentos (MSd)    
    );
END MikroP;


ARCHITECTURE LogicFunction OF MikroP IS
    
    -- Declaração do componente RAMDisp
    COMPONENT RAMDisp is
    PORT (     
        clk       : in std_logic;
        endereco  : in unsigned(15 downto 0);
        wr_en     : in std_logic;
        dado_in   : in unsigned(15 downto 0);
        dado_out  : out unsigned(15 downto 0);
        
        -- sinais adicionais da RAMDisp
        -- decodificação 7seg
        HEX0      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        HEX1      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- (max 99)
        HEX2      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        HEX3      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        HEX4      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        HEX5      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        
        -- divisão de clock 
        rst       : in std_logic;
        clk_h     : in std_logic;
        turbo     : in std_logic;
        halt      : in std_logic;
        clk_div   : out std_logic
    );
    END COMPONENT RAMDisp;
    
    component Eq05_ULA 
        port(
            in_A          :in  std_logic_vector(7 downto 0);
            in_B          :in  std_logic_vector(7 downto 0);
            op            : in  std_logic_vector(1 downto 0);
            out_ULA       : out std_logic_vector(7 downto 0); -- Resultado.
            zero : out std_logic;
            gt: out std_logic 
        );
    end component Eq05_ULA;    
   
    signal enderecoRAMDisp   : unsigned(15 downto 0);
    signal wr_enRAMDisp      : std_logic;
    signal dado_inRAMDisp    : unsigned(15 downto 0) := "0000000000000000";
    signal ram_out           : unsigned(15 downto 0);
    
    signal CONT              : unsigned(7 downto 0) := "00000000";
    signal clk_div_s         : std_logic;  -- clock dividido por TURBO
    signal rst_proc          : std_logic;  -- reset para processador
    signal num_chaves        : unsigned(7 downto 0) := "00000000"; -- Entradas das chaves
    signal oper              : std_logic_vector(1 downto 0); 
    signal flag_zero         : std_logic;
    signal flag_maior        : std_logic;
    signal ula_out_s : std_logic_vector(7 downto 0);

BEGIN

    -- Instância do componente RAMDisp
    RAMeDISP : RAMDisp
    PORT MAP (    
        clk      => clk_div_s,
        endereco => enderecoRAMDisp,
        dado_in  => dado_inRAMDisp,
        dado_out => ram_out,
        wr_en    => wr_enRAMDisp,
        
        HEX0     => HEX0_HW, 
        HEX1     => HEX1_HW, 
        HEX2     => HEX2_HW, 
        HEX3     => HEX3_HW,
        HEX4     => HEX4_HW,
        HEX5     => HEX5_HW,
        
        halt     => SWITCH_HW(9),
        turbo    => SWITCH_HW(8),
        clk_h    => CLK_H_HW,  
        clk_div  => clk_div_s,
        rst      => rst_proc
    );
	 
    ULA : Eq05_ULA
    PORT MAP (    
        in_A          => std_logic_vector(num_chaves), 
        in_B          => std_logic_vector(CONT),
        op            => oper,
        out_ula       => ula_out_s,
        zero => flag_zero,
        gt=> flag_maior
    );
            
    -- Processo que roda na cadência de clk_div
    process (clk_div_s, rst_proc)
    Begin
        If rst_proc = '1' then
            CONT <= (others => '0'); -- Forma mais robusta de zerar
        elsif rising_edge(clk_div_s) then -- sintaxe preferida
            CONT <= CONT + 1 ;
        end if;
    end process;

    -- Parte combinacional assíncrona
    rst_proc  <= not RST_HW; -- Reset ativo-alto (pressionando KEY0, que é ativo-baixo)

    -- Sinais ligados ao RAMDisp
    enderecoRAMDisp <= "0000000001111111"; -- endereço 127
    wr_enRAMDisp    <= '1';
     
    dado_inRAMDisp(7 downto 0) <= unsigned(ula_out_s);
    dado_inRAMDisp(15 downto 8) <= (others => '0');
    
    -- Atribuição dos LEDs
    LED_HW(9) <= flag_zero;        -- LED9 para flag 0
    LED_HW(8) <= flag_maior;       -- LED8 para flag in_A > in_B
    LED_HW(7 downto 0) <= CONT;    -- LEDs 7-0 mostram o contador
    num_chaves <= SWITCH_HW(7 downto 0);
    oper <= "00";
    
END LogicFunction;