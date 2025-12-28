-- UTFPR - DAELN
-- Professor Rafael E. de Góes
-- Disciplina de Arquitetura e Organização de Computadores
-- Arquivo que encapsula a conversão de um digito BCD em 7 segmentos
-- versão 1.0 - 2018-10-15
-- versão 2.0 - 2022-03-29: adição da decodificação de dígito em hexadecimal

LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
use ieee.numeric_std.all;

ENTITY hex_7seg IS
PORT ( 
	Digit : IN unsigned (3 DOWNTO 0);
	Display : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
	);
END entity hex_7seg;

ARCHITECTURE Behavior OF hex_7seg IS
BEGIN
-- considerando"gfedcba", nivel '1' apaga o segmento
	DISPLAY <= 	"1000000" when Digit="0000" else --0x0
					"1111001" when Digit="0001" else --0x1
					"0100100" when DIgit="0010" else --0x2
					"0110000" when Digit="0011" else --0x3
					"0011001" when Digit="0100" else --0x4
					"0010010" when Digit="0101" else --0x5
					"0000010" when Digit="0110" else --0x6
					"1111000" when Digit="0111" else --0x7
					"0000000" when Digit="1000" else --0x8
					"0010000" when Digit="1001" else --0x9
					"0001000" when Digit="1010" else --0xA
					"0000011" when Digit="1011" else --0xB
					"1000110" when Digit="1100" else --0xC
					"0100001" when Digit="1101" else --0xD
					"0000110" when Digit="1110" else --0xE
					"0001110" when DIgit="1111" else --0xF
					"1111111";							--- tudo apagado
END Behavior;
