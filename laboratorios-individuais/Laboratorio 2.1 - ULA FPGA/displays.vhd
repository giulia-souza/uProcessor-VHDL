-- UTFPR - DAELN
-- Professores Rafael E. de Goes e Juliano Mourao Vieira
-- Disciplina de Arquitetura e Organizacao de Computadores
-- versao 1.1 - 2019-10-22
-- versão 2.0 - 2022-03-11 - adaptação para a placa DE10-Lite
-- CONVERSAO DO NUMERO BINARIO PARA ESCRITA NOS DISPLAYS 7 SEGMENTOS
-- versão 3.0 - 2022-08-30 - correção da tabela de decodificação Bin-BCD

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity displays is
    port (
        dado_in   : in unsigned (7 downto 0); -- numero binario de entrada
        disp0_out : out unsigned(6 downto 0); -- display LSd convertido para 7 segmentos
        disp1_out : out unsigned(6 downto 0); -- display MSd convertido - nao usado
        disp2_out : out unsigned(6 downto 0); -- nao usado
        disp3_out : out unsigned(6 downto 0); -- nao usado
		  disp4_out : out unsigned(6 downto 0); -- nao usado
		  disp5_out : out unsigned(6 downto 0)  -- nao usado
    );
end entity;


architecture arch of displays is

    -- TABELA DE CONVERSAO BINARIO => BCD
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

    -- auxiliares para conversao
    signal dado_BCD          : unsigned(7 downto 0);  -- dado_in em BCD
    signal digito0, digito1  : unsigned(3 downto 0);  -- digitos BCD separados
    signal display0,display1 : unsigned(6 downto 0);  -- 7 segmentos para os displays


-- IMPLEMENTACAO PROPRIAMENTE DITA    

begin

    -------------------------------------------------
    -- DECODIFICACAO DA ENTRADA BINARIA PARA BCD
    dado_BCD <= conteudo_BCD (to_integer (unsigned(dado_in)));
    digito0  <= dado_BCD (3 downto 0);
    digito1  <= dado_BCD (7 downto 4);

    -------------------------------------------------
    -- DECODIFICACAO DOS DIGITOS PARA 7 SEGMENTOS
    -- os segmentos sao "gfedcba", 0 acende e 1 apaga
    display0 <= "1000000" when digito0="0000" else 
                "1111001" when digito0="0001" else
                "0100100" when digito0="0010" else
                "0110000" when digito0="0011" else
                "0011001" when digito0="0100" else
                "0010010" when digito0="0101" else
                "0000010" when digito0="0110" else
                "1111000" when digito0="0111" else
                "0000000" when digito0="1000" else
                "0010000" when digito0="1001" else
                "0111111";                           --- traco horizontal
    display1 <= "1000000" when digito1="0000" else 
                "1111001" when digito1="0001" else
                "0100100" when digito1="0010" else
                "0110000" when digito1="0011" else
                "0011001" when digito1="0100" else
                "0010010" when digito1="0101" else
                "0000010" when digito1="0110" else
                "1111000" when digito1="0111" else
                "0000000" when digito1="1000" else
                "0010000" when digito1="1001" else
                "0111111";                           --- traco horizontal

    -------------------------------------------------
    -- ESCRITA EFETIVA NOS PINOS DE SAIDA
    disp0_out <= display0;
    disp1_out <= display1;
    disp2_out <= "1111111";  -- nao utilizado
    disp3_out <= "1111111";  -- nao utilizado
	 disp4_out <= "1111111";  -- nao utilizado
	 disp5_out <= "1111111";  -- nao utilizado

end architecture;
