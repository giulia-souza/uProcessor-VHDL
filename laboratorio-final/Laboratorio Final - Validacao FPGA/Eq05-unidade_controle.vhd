-----------------------------------------------------------------------
-- Arquitetura e Organizacao de Computadores - S11
-- Prof: Rafael Eleodoro De Goes
-- Lab 8: Validacao - Unidade de Controle (Suporte a MUL)
-- Alunas: Giovana Valim (2449633)
-- Giulia de Souza Leite (2619075)
-----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Eq05_unidade_controle is
    port(
        clk          : in std_logic;
        rst          : in std_logic;
        estado       : in std_logic;
        instrucao    : in unsigned (23 downto 0);
        ula_zero     : in std_logic;
        pc_wr_en     : out std_logic;
        pc_sel       : out std_logic; 
        reg_wr_en    : out std_logic;
        reg_addr1_out: out unsigned (2 downto 0); 
        reg_addr2_out: out unsigned (2 downto 0); 
        reg_addr3_out: out unsigned (2 downto 0); 
        ula_op_out   : out std_logic_vector (2 downto 0);
        ula_A_sel    : out std_logic; 
        ula_B_sel    : out std_logic  
    );
end entity;

architecture a_uc of Eq05_unidade_controle is
    constant OP_NOP  : unsigned(7 downto 0) := x"00";
    constant OP_ADDI : unsigned(7 downto 0) := x"01";
    constant OP_JMP  : unsigned(7 downto 0) := x"02";
    constant OP_BEQ  : unsigned(7 downto 0) := x"03";
    constant OP_ADD  : unsigned(7 downto 0) := x"10";
    constant OP_SUB  : unsigned(7 downto 0) := x"11";
    constant OP_DIV  : unsigned(7 downto 0) := x"12";
    constant OP_MOV  : unsigned(7 downto 0) := x"13";
    constant OP_MUL  : unsigned(7 downto 0) := x"14"; 

    constant ULA_SOMA: std_logic_vector(2 downto 0) := "000";
    constant ULA_SUB : std_logic_vector(2 downto 0) := "001";
    constant ULA_DIV : std_logic_vector(2 downto 0) := "010";
    constant ULA_MUL : std_logic_vector(2 downto 0) := "011";
    
    signal opcode : unsigned(7 downto 0);
    signal reg_d  : unsigned(2 downto 0);
    signal reg_s  : unsigned(2 downto 0);
    signal reg_t  : unsigned(2 downto 0);
    
    signal pc_sel_c   : std_logic;
    signal reg_wr_en_c: std_logic;
    
begin
    opcode <= instrucao(23 downto 16);
    reg_d  <= instrucao(15 downto 13);
    reg_s  <= instrucao(12 downto 10);
    reg_t  <= instrucao(9 downto 7);
    
    -- 1 decodificacao de escrita
    reg_wr_en_c <= '1' when (opcode = OP_ADDI) or (opcode = OP_ADD) or 
                            (opcode = OP_SUB)  or (opcode = OP_DIV) or 
                            (opcode = OP_MOV)  or (opcode = OP_MUL)
                       else '0';

    -- 2 controle do PC (Decisao de Salto)
    pc_sel_c   <= '1' when (opcode = OP_JMP) or 
                           (opcode = OP_BEQ and ula_zero = '1') 
                      else '0';

    -- 3 muxes de endereco
    reg_addr1_out <= reg_d when (opcode = OP_BEQ) else
                     reg_s when (opcode = OP_ADD or opcode = OP_SUB or opcode = OP_DIV or opcode = OP_MOV or opcode = OP_MUL) else
                     "000"; 

    reg_addr2_out <= reg_s when (opcode = OP_BEQ) else
                     reg_t when (opcode = OP_ADD or opcode = OP_SUB or opcode = OP_DIV or opcode = OP_MUL) else
                     "000"; 

    reg_addr3_out <= reg_d;

    -- 4 controle da ULA
    ula_op_out <= ULA_SUB when (opcode = OP_SUB or opcode = OP_BEQ) else
                  ULA_DIV when (opcode = OP_DIV) else
                  ULA_MUL when (opcode = OP_MUL) else
                  ULA_SOMA;

    ula_A_sel <= '1' when (opcode = OP_ADDI) else '0'; 
    ula_B_sel <= '1' when (opcode = OP_ADDI) else '0'; 

    pc_wr_en <= '1' when (estado = '1') else '0';
    
    pc_sel   <= pc_sel_c when estado = '1' else '0';
    reg_wr_en <= '1' when (estado = '1' and reg_wr_en_c = '1') else '0';

end architecture;