-- UTFPR - DAELN
-- Professor Rafael E. de Góes
-- Disciplina de Arquitetura e Organização de Computadores
-- Arquivo que implementa a RAM com diplasy de 7 segmentos mapeado no endereço 127
-- inclui o divisor de clock de 50 MHz para 10Hz e 200 Hz (turbo)
-- versão 1.0 - 2018-10-15
-- versão 2.0 - 2019-09-07: inversão da lógica de rst para uso do sinal 'rst_proc' que correspode 
--									à not(KEY0) e deve ser usado para o processador e RAMDisp
-- versão 3.0 - 2022-03-29: Ajuste para usar dígito Hex para 7seg. Se o digito for decimal usa-se o BCD para escrever 
--										se o digito for hex, usa-se o nibble para escrever

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

------------------------------------------------------------------------
entity ramDisp is
	port(
		clk : in std_logic;
		endereco : in unsigned(15 downto 0);
		wr_en : in std_logic;
		dado_in : in unsigned(15 downto 0);
		dado_out : out unsigned(15 downto 0);
		
						--- sinais que saem da RAM para o circuito físico
		HEX0   : out STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX1   : out STD_LOGIC_VECTOR(6 DOWNTO 0); --(max 99)
		HEX2   : out STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX3   : out STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX4   : out STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX5   : out STD_LOGIC_VECTOR(6 DOWNTO 0);

		--- sinais de teste de chaves, novas funções, divisor de clock para SW08 e SW09
		--- clock 1 = 55-> 1MHz , clock 2 (3 ciclos para escrever, aproximar 500 ms por digito: 10 Hz)
		halt	 : in std_logic;
		turbo  : in std_logic;
		clk_h  : in std_logic;
		clk_div: out std_logic;
		rst    : in std_logic
	);
end entity;
------------------------------------------------------------------------
architecture a_ram of ramDisp is
	type mem is array (0 to 127) of unsigned(15 downto 0);
	signal endereco_interno: unsigned(6 downto 0);
	signal conteudo_ram : mem;
	
	COMPONENT hex_7seg
	PORT ( 	Digit : IN unsigned(3 DOWNTO 0);
				Display : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
			);
	END COMPONENT;
	
	SIGNAL D0: unsigned(3 DOWNTO 0);
	SIGNAL D1: unsigned(3 DOWNTO 0); 
	SIGNAL D0h: unsigned(3 DOWNTO 0); 
	SIGNAL D1h: unsigned(3 DOWNTO 0); 
	
	SIGNAL BCD: unsigned(7 DOWNTO 0);
	
	SIGNAL conteudo_reg: unsigned (15 DOWNTO 0);
	

	type NumBCD is array (0 to 99) of unsigned(7 DOWNTO 0);
	constant conteudo_BCD : NumBCD := (
		 0 => "00000000", 1 => "00000001", 2 => "00000010", 3 => "00000011", 4 => "00000100", 5 => "00000101",
		 6 => "00000110", 7 => "00000111", 8 => "00001000", 9 => "00001001",10 => "00010000",11 => "00010001",
		12 => "00010010",13 => "00010011",14 => "00010100",15 => "00010101",16 => "00010110",17 => "00010111",
		18 => "00011000",19 => "00011001",20 => "00100000",21 => "00100001",22 => "00100010",23 => "00100011",
		24 => "00100100",25 => "00100101",26 => "00100110",27 => "00100111",28 => "00101000",29 => "00101001",
		30 => "00110000",31 => "00110001",32 => "00110010",33 => "00110011",34 => "00110100",35 => "00110101",
		36 => "00110110",37 => "00110111",38 => "00111000",39 => "00111001",40 => "01000000",41 => "01000001",
		42 => "01000010",43 => "01000011",44 => "01000100",45 => "01000101",46 => "01000110",47 => "01000111",
		48 => "01001000",49 => "01001001",50 => "01010000",51 => "01010001",52 => "01010010",53 => "01010011",
		54 => "01010100",55 => "01010101",56 => "01010110",57 => "01010111",58 => "01010100",59 => "01011001",
		60 => "01100000",61 => "01100001",62 => "01100010",63 => "01100011",64 => "01100100",65 => "01100101",
		
		66 => "01100110",67 => "01100111",68 => "01101000",69 => "01101001",70 => "01110000",71 => "01110001",
		72 => "01110010",73 => "01110011",74 => "01110100",75 => "01110101",76 => "01110110",77 => "01110111",
		78 => "01111000",79 => "01111001",80 => "10000000",81 => "10000001",82 => "10000010",83 => "10000011",
		84 => "10000100",85 => "10000101",86 => "10000110",87 => "10000111",88 => "10000100",89 => "10001001",
		90 => "10010000",91 => "10010001",92 => "10010010",93 => "10010011",94 => "10010100",95 => "10010101",
		96 => "10010110",97 => "10010111",98 => "10011000",99 => "10011001",	others => (others=>'1')
	);

	signal contador: integer range 0 to 5000000 ; -- conta até 5M com o clock de 50 MHz, gera 10 Hz 
	
----------------- processo da ram com escrita síncrona	
begin
	process(clk,wr_en)
	begin
		if rising_edge(clk) then
			if wr_en='1' then
				if endereco_interno = "1111111" then
					conteudo_reg( 7 downto 0) <= dado_in ( 7 downto 0 );
				else
					conteudo_ram(to_integer(endereco_interno)) <= dado_in;
				end if;
			end if;
		end if;
	end process;

---------------- processo de divisão do clock (com HALT e TURBO)	

	process (clk_h, rst)
	begin 
		if rst = '1' then 
			clk_div <= '0';
			contador <= 0;
			
		elsif clk_h = '1' and clk_h'event then 
			if halt = '0' then 
				if contador >= 5000000 then 
					clk_div <= '1';
					contador <= 0;
				else
					if turbo = '1' then 
						contador <= contador + 20; -- de 20 em 20, gera 200Hz
						clk_div <= '0';
					else
						contador <= contador + 1;
						clk_div <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;

		
	
----------------- parte assíncrona
	
	endereco_interno <= endereco(6 downto 0);
	dado_out <= conteudo_ram(to_integer(endereco_interno));
	
	-- como exemplo, da maneira a seguir, o que é mostrado nos displays:
	-- Numero de 8 bits em decimal nos 2 digitos menos significativos dos diplays de 7 segmentos (HEX1 e HEX2)
	-- Numero de 8 bits em decimal nos 2 dígitos mais significativos dos diplays de 7 segmentos (HEX5 e HEX4)


	BCD <= conteudo_BCD (to_integer (conteudo_reg));
		
	D0 <= BCD (3 downto 0);
	D1 <= BCD (7 downto 4);

	H0: hex_7seg PORT MAP (Digit=>D0, Display=>HEX0);
	H1: hex_7seg PORT MAP (Digit=>D1, Display=>HEX1);
	
	HEX2 <= "1111111";      -- pendente de implementação
	HEX3 <= "1111111";		-- pendente de implementação

	D0h  <= conteudo_reg (3 downto 0) ;      
	D1h  <= conteudo_reg (7 downto 4) ;		

	H3: hex_7seg PORT MAP (Digit=>D0h, Display=>HEX4);
	H4: hex_7seg PORT MAP (Digit=>D1h, Display=>HEX5);


	
	
end architecture;
