-- UTFPR - DAELN
-- Professor Rafael E. de Góes
-- Disciplina de Arquitetura e Organização de Computadores
-- Arquivo que implementa a RAM com display de 7 segmentos mapeado no endereço 127
-- inclui o divisor de clock de 50 MHz para 10Hz e 200 Hz (turbo)
-- versão 1.0 - 2018-10-15
-- versão 2.0 - 2019-09-07: inversão da lógica de rst para uso do sinal 'rst_proc' que correspode 
--									à not(KEY0) e deve ser usado para o processador e RAMDisp
-- versão 3.0 - 2022-03-29: Ajuste para usar dígito Hex para 7seg. Se o digito for decimal usa-se o BCD para escrever 
--										se o digito for hex, usa-se o nibble para escrever
-- versão 3.1 - 2022-05-11: Ajuste na largua do dado escrito para apresentar o byte menos significativo dos 16its como
--									decimal em HEX5.HEX4 e o bytes mais significativo como hexadecimal em HEX1.HEX0
-- versão 3.2 - 2022-05-18: Ajuste para se o numero for  maior que 99, imprimir EE.
-- versão 3.3 - 2022-06-02: Mudança para apresentar em decimal um numero de 16 bits (conversão multiciclo bin2bcd)



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
		HEX1   : out STD_LOGIC_VECTOR(6 DOWNTO 0); 
		HEX2   : out STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX3   : out STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX4   : out STD_LOGIC_VECTOR(6 DOWNTO 0); -- max 65535
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
	
	COMPONENT bin2bcd is
    port ( 
        input:      in   std_logic_vector (15 downto 0);
        ones:       out  std_logic_vector (3 downto 0);
        tens:       out  std_logic_vector (3 downto 0);
        hundreds:   out  std_logic_vector (3 downto 0);
        thousands:  out  std_logic_vector (3 downto 0);
		  tens_thousands: out std_logic_vector (3 downto 0)
    );
	end component;
	
	SIGNAL D0,D1,D2,D3,D4: unsigned(3 DOWNTO 0);
	
	SIGNAL BCD: std_logic_vector(19 DOWNTO 0);
	
	SIGNAL conteudo_reg: unsigned (15 DOWNTO 0);
	

	signal contador: integer range 0 to 5000000 ; -- conta até 5M com o clock de 50 MHz, gera 10 Hz 
	
----------------- processo da ram com escrita síncrona	
begin
	process(clk,wr_en)
	begin
		if rising_edge(clk) then
			if wr_en='1' then
				if endereco_interno = "1111111" then
					conteudo_reg( 15 downto 0) <= dado_in ( 15 downto 0 );
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
						contador <= contador + 100; -- de 20 em 20, gera 200Hz, de 100 em 100, gera 1kHz
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
	
	-- da maneira abaixo, o que é mostrado nos displays:
	-- Numero de 16 bits do registrador em decimal 
	
	conv: bin2bcd port map (
		input => 				std_logic_vector(conteudo_reg),
		ones => 					BCD ( 3 downto  0),
		tens => 					BCD ( 7 downto  4),
		hundreds => 			BCD (11 downto  8),
		thousands => 			BCD (15 downto 12),
		tens_thousands => 	BCD (19 downto 16)
	
	);

	--BCD <= conteudo_BCD (to_integer (conteudo_reg));
		
	D0 <= unsigned (BCD (3 downto 0));
	D1 <= unsigned (BCD (7 downto 4));
	D2 <= unsigned (BCD (11 downto 8));
	D3 <= unsigned (BCD (15 downto 12));
	D4 <= unsigned (BCD (19 downto 16));

	H0: hex_7seg PORT MAP (Digit=>D0, Display=>HEX0);
	H1: hex_7seg PORT MAP (Digit=>D1, Display=>HEX1);
	H2: hex_7seg PORT MAP (Digit=>D2, Display=>HEX2);
	H3: hex_7seg PORT MAP (Digit=>D3, Display=>HEX3);
	H4: hex_7seg PORT MAP (Digit=>D4, Display=>HEX4);
	
	HEX5 <= "1111111";		-- para 16 bits o valor máximo é 65535


	
end architecture;