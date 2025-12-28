-----------------------------------------------------------------------
-- Arquitetura e Organizacao de Computadores - S11
-- Prof: Rafael Eleodoro De Goes
-- Lab 2 - Unidade Logica e Aritmetica
-- Alunos: Giovana Valim (2449633)
-- Giovanni Luigi Bolzon (1612948)
-- Giulia de Souza Leite (2619075)
-----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity toplevel is
    -- sinais que sao usados no toplevel, mapeados no hardware da placa
    port (   
      --- clock master da placa ligado na FPGA
      CLK_H_HW 	: in std_logic;             -- PIN_N14 (50 MHz)
            
      -- sinais que sao a interface de teste no HW fisico
      RST_HW 		: in std_logic;               -- KEY0 PIN_B8
		KEY1_HW		: in std_logic;			 -- KEY1 PIN_A7
        
		SWITCH_HW 	: in unsigned (9 downto 0);  --SW9 a SW0  (PINS F15, B14, A14, A13, B12, A12, C12, D12, C11, C10) 
      LED_HW      : out unsigned (9 downto 0);    -- LED9..LED0 (PINS B11, A11, D14, E14, C13, D13, B10, A10, A9, A8)

      -- displays da placa conectados na FPGA
      HEX0_HW		: out std_logic_vector(6 downto 0);   -- display 7 segmentos (LSd)
      HEX1_HW		: out std_logic_vector(6 downto 0);   -- display 7 segmentos
      HEX2_HW		: out std_logic_vector(6 downto 0);   -- display 7 segmentos
      HEX3_HW		: out std_logic_vector(6 downto 0);   -- display 7 segmentos 
	  HEX4_HW		: out std_logic_vector(6 downto 0);   -- display 7 segmentos 
	  HEX5_HW		: out std_logic_vector(6 downto 0)    -- display 7 segmentos (MSd)
	 
    );
end entity;

architecture arch of toplevel is
   component displays is
       port(
         dado_in   : in unsigned (7 downto 0);         -- numero binario de entrada
         disp0_out : out std_logic_vector(6 downto 0); -- display LSd convertido para 7 segmentos
         disp1_out : out std_logic_vector(6 downto 0); -- 
         disp2_out : out std_logic_vector(6 downto 0); -- 
		 disp3_out : out std_logic_vector(6 downto 0); -- 
		 disp4_out : out std_logic_vector(6 downto 0); -- 
		 disp5_out : out std_logic_vector(6 downto 0)  -- display MSd convertido para 7 segmentos
       );
   end component;

   component ULA is
        port (
            in_A    : in  std_logic_vector(15 downto 0);
            in_B    : in  std_logic_vector(15 downto 0);
            op      : in  std_logic_vector(1 downto 0);
            out_ULA : out std_logic_vector(15 downto 0);
            zero    : out std_logic; -- flag quando o resultado eh zero
            gt      : out std_logic  -- flag quando A maior q B
        );
    end component;
	 
	 -- Sinais para os switches
    signal A_sig_4bit, B_sig_4bit : unsigned(3 downto 0);
    signal OP_sig                 : unsigned(1 downto 0);
    
    -- Sinais para a ULA de 16 bits
    signal A_sig_16bit, B_sig_16bit : unsigned(15 downto 0);
    signal res_ula_out              : std_logic_vector(15 downto 0);
    signal res_sig                  : unsigned(15 downto 0);
    
    -- Flags da ULA
    signal flag_zero : std_logic;
    signal flag_gt   : std_logic;
    
    signal mostra_disp : unsigned(7 downto 0);

begin

	display: displays port map (
        dado_in   => mostra_disp,
        disp0_out => HEX0_HW,
        disp1_out => HEX1_HW,
        disp2_out => HEX2_HW,
        disp3_out => HEX3_HW,
        disp4_out => HEX4_HW,
        disp5_out => HEX5_HW);
                  
    
    A_sig_4bit <= SWITCH_HW(3 downto 0);  -- SW0-3 = A
    B_sig_4bit <= SWITCH_HW(7 downto 4);  -- SW4-7 = B
    OP_sig     <= SWITCH_HW(9 downto 8);  -- SW8-9 = operação
    
    -- resize para funcionar na ULA...
    A_sig_16bit <= resize(A_sig_4bit, 16);
    B_sig_16bit <= resize(B_sig_4bit, 16);
    
    ula_externa: ULA port map (
        in_A    => std_logic_vector(A_sig_16bit),
        in_B    => std_logic_vector(B_sig_16bit),
        op      => std_logic_vector(OP_sig),
        out_ULA => res_ula_out,
        zero    => flag_zero,
        gt      => flag_gt
    );
    
    -- Converte a saída da ULA para unsigned
    res_sig <= unsigned(res_ula_out);
      
    -- LEDs
    LED_HW(3 downto 0) <= res_sig(3 downto 0);  -- Mostra os 4 bits menos significativos do resultado
    LED_HW(4) <= res_sig(4) when OP_sig = "00" else '0'; -- LED 4 só acende quando tem carry na soma
    LED_HW(5) <= flag_zero;                   -- LED 5 para a flag Zero
    LED_HW(6) <= flag_gt;                     -- LED 6 para a flag 'A > B'
    LED_HW(9 downto 7) <= OP_sig & '0';       -- LEDS da operação

    mostra_disp <= res_sig(7 downto 0); 
	
end architecture;