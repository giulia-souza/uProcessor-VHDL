-----------------------------------------------------------------------
-- Arquitetura e Organizacao de Computadores - S11
-- Prof: Rafael Eleodoro De Goes
-- Lab 6: Processador
-- Alunas: Giovana Valim (2449633), Giulia de Souza Leite (2619075)
-- (Nova Unidade de Controle)
-----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Eq05_unidade_controle is
    port(
        clk          : in std_logic;
        rst          : in std_logic;
        -- Entrada da FSM
        estado       : in std_logic; -- '0' = Fetch, '1' = Execute
        -- Entrada da ROM
        instrucao    : in unsigned (23 downto 0);
        
        -- Sinais de Controle para o PC
        pc_wr_en     : out std_logic;
        pc_sel       : out std_logic; -- '0' = PC+1, '1' = Endereco de Jump
        
        -- Sinais de Controle para o Banco de Registradores
        reg_wr_en    : out std_logic;
        reg_addr1_out: out unsigned (2 downto 0); -- Endereco Leitura 1 (Rs)
        reg_addr2_out: out unsigned (2 downto 0); -- Endereco Leitura 2 (Rt)
        reg_addr3_out: out unsigned (2 downto 0); -- Endereco Escrita (Rd)

        -- Sinais de Controle para a ULA e MUXs
        ula_op_out   : out std_logic_vector (1 downto 0); -- "00" SOMA, "01" SUB, "10" DIV
        ula_A_sel    : out std_logic; -- '0' = Reg[Rs], '1' = 0 (para ADDI)
        ula_B_sel    : out std_logic  -- '0' = Reg[Rt], '1' = Constante (para ADDI)
    );
end entity;

architecture a_uc of Eq05_unidade_controle is
    -- Opcodes (da ISA)
    constant OP_NOP  : unsigned(7 downto 0) := x"00";
    constant OP_ADDI : unsigned(7 downto 0) := x"01";
    constant OP_JMP  : unsigned(7 downto 0) := x"02";
    constant OP_ADD  : unsigned(7 downto 0) := x"10";
    constant OP_SUB  : unsigned(7 downto 0) := x"11";
    constant OP_DIV  : unsigned(7 downto 0) := x"12";
    constant OP_MOV  : unsigned(7 downto 0) := x"13";

    -- Sinais de Controle da ULA (do arquivo ULA)
    constant ULA_SOMA: std_logic_vector(1 downto 0) := "00";
    constant ULA_SUB : std_logic_vector(1 downto 0) := "01";
    constant ULA_DIV : std_logic_vector(1 downto 0) := "10";
    
    -- Descodificacao dos campos da instrucao
    signal opcode : unsigned(7 downto 0);
    signal reg_d  : unsigned(2 downto 0);
    signal reg_s  : unsigned(2 downto 0);
    signal reg_t  : unsigned(2 downto 0);
    
    -- Sinais de controle (logica combinacional)
    signal pc_wr_en_c : std_logic;
    signal pc_sel_c   : std_logic;
    signal reg_wr_en_c: std_logic;
    
begin
    -- 1. Descodificar campos da instrucao (Combinacional)
    opcode <= instrucao(23 downto 16);
    reg_d  <= instrucao(15 downto 13);
    reg_s  <= instrucao(12 downto 10);
    reg_t  <= instrucao(9 downto 7);
    
    -- 2. Logica de Descodificacao (Combinacional, baseada no opcode)
    process (opcode, reg_d, reg_s, reg_t, rst)
    begin
        -- Se o reset estiver ativo, forca todos os sinais de controle
        -- combinacionais para um estado inativo, sem fazer comparacoes.
        if rst = '1' then
            pc_wr_en_c      <= '0';
            pc_sel_c        <= '0';
            reg_wr_en_c     <= '0';
            reg_addr1_out <= (others => '0');
            reg_addr2_out <= (others => '0');
            reg_addr3_out <= (others => '0');
            ula_op_out    <= ULA_SOMA; -- Valor padrao
            ula_A_sel     <= '0';
            ula_B_sel     <= '0';
        
        -- Se nao houver reset, executa a logica normal.
        else
            -- --- Valores Padrao (NOP) ---
            pc_wr_en_c      <= '0';
            pc_sel_c        <= '0'; -- PC+1
            reg_wr_en_c     <= '0';
            reg_addr1_out <= "000"; -- R0
            reg_addr2_out <= "000"; -- R0
            reg_addr3_out <= "000"; -- R0
            ula_op_out    <= ULA_SOMA; -- Tanto faz
            ula_A_sel     <= '0';
            ula_B_sel     <= '0';
            -- ----------------------------

            case opcode is
                when OP_ADDI => -- R[Rd] <- Const13 (Implementado como 0 + Const)
                    reg_wr_en_c  <= '1';
                    reg_addr3_out<= reg_d;      -- Endereco de escrita
                    ula_op_out   <= ULA_SOMA;
                    ula_A_sel    <= '1';        -- MUX_A seleciona '0'
                    ula_B_sel    <= '1';        -- MUX_B seleciona Constante
                    
                when OP_ADD =>  -- R[Rd] <- R[Rs] + R[Rt]
                    reg_wr_en_c  <= '1';
                    reg_addr1_out<= reg_s;
                    reg_addr2_out<= reg_t;
                    reg_addr3_out<= reg_d;
                    ula_op_out   <= ULA_SOMA;
                    ula_A_sel    <= '0';        -- MUX_A seleciona Reg[Rs]
                    ula_B_sel    <= '0';        -- MUX_B seleciona Reg[Rt]

                when OP_SUB =>  -- R[Rd] <- R[Rs] - R[Rt]
                    reg_wr_en_c  <= '1';
                    reg_addr1_out<= reg_s;
                    reg_addr2_out<= reg_t;
                    reg_addr3_out<= reg_d;
                    ula_op_out   <= ULA_SUB;
                    ula_A_sel    <= '0';
                    ula_B_sel    <= '0';

                when OP_DIV =>  -- R[Rd] <- R[Rs] / R[Rt]
                    reg_wr_en_c  <= '1';
                    reg_addr1_out<= reg_s;
                    reg_addr2_out<= reg_t;
                    reg_addr3_out<= reg_d;
                    ula_op_out   <= ULA_DIV;
                    ula_A_sel    <= '0';
                    ula_B_sel    <= '0';

                when OP_MOV =>  -- R[Rd] <- R[Rs] (Implementado como R[Rs] + R0)
                    reg_wr_en_c  <= '1';
                    reg_addr1_out<= reg_s;      -- Rs
                    reg_addr2_out<= "000";      -- R0
                    reg_addr3_out<= reg_d;      -- Rd
                    ula_op_out   <= ULA_SOMA;
                    ula_A_sel    <= '0';
                    ula_B_sel    <= '0';

                when OP_JMP =>
                    pc_wr_en_c   <= '1';
                    pc_sel_c     <= '1';        -- Seleciona Endereco de Jump
                
                when others =>
                    -- Mantem os valores padrao
                    null;
                    
            end case;
        end if;
    end process;

    -- 3. Geracao de Sinais de Controle (Sincrono com a FSM)
    
    pc_wr_en <= '1' when (estado = '0') or (estado = '1' and pc_wr_en_c = '1') else '0';
    
    pc_sel <= pc_sel_c when estado = '1' else '0';
    
    reg_wr_en <= '1' when (estado = '1' and reg_wr_en_c = '1') else '0';

end architecture;