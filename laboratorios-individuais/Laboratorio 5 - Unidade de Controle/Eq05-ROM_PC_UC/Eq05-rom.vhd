-----------------------------------------------------------------------
-- Arquitetura e Organizacao de Computadores - S11
-- Prof: Rafael Eleodoro De Goes
-- Lab 5: Unidade de Controle
-- Alunos: Giovana Valim (2449633)
-- Giovanni Luigi Bolzon (1612948)
-- Giulia de Souza Leite (2619075)
-----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Eq05_rom is
    port(
        clk       : in std_logic;
        -- Endereco de 7 bits (0 a 127)
        endereco  : in unsigned (6 downto 0); 
        dado      : out unsigned (7 downto 0) -- Dado/Instrucao de 8 bits
    );
end entity;

architecture a_rom of Eq05_rom is
    -- ROM de 128 posicoes, 8 bits por posicao
    type mem is array (0 to 127) of unsigned (7 downto 0);

    -- Codificacao do programa: NOP="00", JUMP="11"
    -- Endereco de salto eh o argumento (bits 5 downto 0)
    constant conteudo_rom : mem := (
        -- PRIMEIRO LACO: Sequencia desejada: 0 -> 1 -> 2 -> 7
        -- O JUMP precisa ser colocado no endereco 1 para que seu
        -- Delay Slot seja o endereco 2, e o salto efetivo seja 7.
        
        0  => "00000000", -- NOP (End. 0)
        1  => "11000111", -- JUMP para o endereco 7 (000111) -> 0xC7
        2  => "00000000", -- NOP (End. 2 - ESTE EH O DELAY SLOT: sera executado)
        
        -- MEIO DO PROGRAMA: Sequencia desejada: 7 -> 8 -> 9 -> 0
        -- O JUMP precisa ser colocado no endereco 8 para que seu
        -- Delay Slot seja o endereco 9, e o salto efetivo seja 0.
        7  => "00000000", -- NOP (End. 7)
        8  => "11000000", -- JUMP para o endereco 0 (000000) -> 0xC0
        9  => "00000000", -- NOP (End. 9 - ESTE EH O DELAY SLOT: sera executado)
        
        -- Garante que o restante seja NOP
        others => "00000000" 
    );
    
    signal dado_s : unsigned (7 downto 0); 

begin
    -- Leitura Sincrona da ROM
    process (clk)
    begin
        if (rising_edge(clk)) then
            dado_s <= conteudo_rom(to_integer(endereco));
        end if;
    end process;

    dado <= dado_s;

end architecture;