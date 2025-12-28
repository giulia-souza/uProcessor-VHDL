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

entity Eq05_ROM_PC_UC is
    port(
        clk       : in std_logic;
        rst       : in std_logic;
        -- Pinos de saida para visualizacao (Top-level)
        rom_dado_o: out unsigned (7 downto 0);
        pc_endereco_o: out unsigned (6 downto 0)
    );
end entity;

architecture a_rom_pc_uc of Eq05_ROM_PC_UC is
    -- Sinais internos
    signal estado_s      : std_logic;
    signal pc_wr_en_s    : std_logic;
    signal pc_out_s      : unsigned (6 downto 0);
    signal pc_next_s     : unsigned (6 downto 0);
    signal rom_dado_s    : unsigned (7 downto 0);
    
    -- Sinais para Decodificacao SINCRONA
    signal jump_en_reg     : std_logic := '0';        -- Registra o JUMP_EN do ciclo anterior
    signal jump_target_reg : unsigned (6 downto 0) := (others => '0'); -- Registra o alvo do JUMP

    -- Sinais combinacionais de decodificacao
    signal opcode_comb   : unsigned (1 downto 0);     -- Opcode lido (combinacional)
    signal jump_en_comb  : std_logic;                 -- Jump Enable lido (combinacional)
    signal jump_target_comb : unsigned (6 downto 0);  -- Jump Target lido (combinacional)

    -- Componentes 
    component Eq05_rom
        port(clk: in std_logic; endereco: in unsigned (6 downto 0); dado: out unsigned (7 downto 0));
    end component;
    
    component Eq05_maq_estados
        port(clk: in std_logic; rst: in std_logic; estado: out std_logic);
    end component;
    
    component Eq05_program_counter
        port(clk: in std_logic; rst: in std_logic; wr_en: in std_logic; 
             data_in: in unsigned (6 downto 0); data_out: out unsigned (6 downto 0));
    end component;

begin
    -- Instanciacao dos componentes
    U_ROM: Eq05_rom port map (clk => clk, endereco => pc_out_s, dado => rom_dado_s);
    U_MAQ_ESTADOS: Eq05_maq_estados port map (clk => clk, rst => rst, estado => estado_s);
    U_PC: Eq05_program_counter port map (clk => clk, rst => rst, wr_en => pc_wr_en_s, data_in => pc_next_s, data_out => pc_out_s);

    -- 1. Decodificacao COMBINACIONAL (imediata)
    opcode_comb <= rom_dado_s(7 downto 6);
    jump_target_comb <= '0' & rom_dado_s(5 downto 0); 
    
    -- JUMP Enable combinacional
    jump_en_comb <= '1' when opcode_comb = "11" else 
                    '0';

    -- 2. Registro Sincrono (Atrasando os Sinais de Controle)
    -- Esses sinais estarao prontos no ciclo de Execute
    process (clk)
    begin
        if rising_edge(clk) then
            -- Os sinais de controle lidos (combinacionais) sao registrados
            jump_en_reg     <= jump_en_comb;
            jump_target_reg <= jump_target_comb;
        end if;
    end process;
    
    pc_next_s <= jump_target_reg when jump_en_reg = '1' else 
                 (pc_out_s + 1);                             

    pc_wr_en_s <= estado_s; 

    -- Saidas para visualizacao
    rom_dado_o    <= rom_dado_s;
    pc_endereco_o <= pc_out_s;

end architecture;