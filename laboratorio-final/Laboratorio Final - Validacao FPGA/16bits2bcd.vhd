-- UTFPR - DAELN
-- Professor Rafael E. de Góes
-- Disciplina de Arquitetura e Organização de Computadores
-- Arquivo que implementa a conversão de binário de 16 bits para BCD
-- versão 1.0 - 2022-06-02 baseado em: https://stackoverflow.com/questions/39548841/16bit-to-bcd-conversion

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bin2bcd is
    port ( 
        input:      in   std_logic_vector (15 downto 0);
        ones:       out  std_logic_vector (3 downto 0);
        tens:       out  std_logic_vector (3 downto 0);
        hundreds:   out  std_logic_vector (3 downto 0);
        thousands:  out  std_logic_vector (3 downto 0);
		  tens_thousands: out std_logic_vector (3 downto 0)
    );
end entity;

architecture fum of bin2bcd is
    alias Hex_Display_Data: std_logic_vector (15 downto 0) is input;
    alias rpm_1:    std_logic_vector (3 downto 0) is ones;
    alias rpm_10:   std_logic_vector (3 downto 0) is tens;
    alias rpm_100:  std_logic_vector (3 downto 0) is hundreds;
    alias rpm_1000: std_logic_vector (3 downto 0) is thousands;
    alias rpm_10000: std_logic_vector (3 downto 0) is tens_thousands;
begin
    process (Hex_Display_Data)
        type fourbits is array (4 downto 0) of std_logic_vector(3 downto 0);
        variable bcd:   std_logic_vector (19 downto 0); -- RdG it was 16 bits 
        variable bint:  std_logic_vector (17 downto 0); -- SEE process body
    begin
        bcd := (others => '0');      -- ADDED for EVERY CONVERSION
        bint := "00"& Hex_Display_Data (15 downto 0); -- ADDED for EVERY CONVERSION

        for i in 0 to 17 loop
            bcd(19 downto 1) := bcd(18 downto 0);
            bcd(0) := bint(17);
            bint(17 downto 1) := bint(16 downto 0);
            bint(0) := '0';

            if i < 17 and bcd(3 downto 0) > "0100" then
                bcd(3 downto 0) := 
                    std_logic_vector (unsigned(bcd(3 downto 0)) + 3);
            end if;
            if i < 17 and bcd(7 downto 4) > "0100" then
                bcd(7 downto 4) := 
                    std_logic_vector(unsigned(bcd(7 downto 4)) + 3);
            end if;
            if i < 17 and bcd(11 downto 8) > "0100" then
                bcd(11 downto 8) := 
                    std_logic_vector(unsigned(bcd(11 downto 8)) + 3);
            end if;
            if i < 17 and bcd(15 downto 12) > "0100" then
                bcd(15 downto 12) := 
                    std_logic_vector(unsigned(bcd(15 downto 12)) + 3);
            end if;
				if i < 17 and bcd(19 downto 16) > "0100" then
                bcd(19 downto 16) := 
                    std_logic_vector(unsigned(bcd(19 downto 16)) + 3);
            end if;
				
        end loop;

        (rpm_10000, rpm_1000, rpm_100, rpm_10, rpm_1)  <= 
                  fourbits'( bcd (19 downto 16), bcd (15 downto 12), bcd (11 downto 8), 
                               bcd ( 7 downto  4), bcd ( 3 downto 0) );
    end process ;
end architecture;