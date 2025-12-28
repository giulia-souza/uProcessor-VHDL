@echo off
:: Eq05-Calc.bat
:: Script para compilar e simular o projeto da Calculadora Programavel (GHDL + GTKWave)
:: Arquivos: Eq05-nome-do-arquivo.vhd (hifen)
:: Entidades: Eq05_nome_da_entidade (underscore)
::
:: Equipe: Giovana Valim (2449633), Giulia de Souza Leite (2619075)

:: A entidade de topo para simulacao e o Testbench
set ENTIDADE_TOP=Eq05_Calc_tb
set ARQUIVO_WAVE=Eq05-Calc

echo ------------------------------------------
echo -- Compilando Laboratorio 5 - Eq05-Calc --
echo ------------------------------------------

:: Limpeza de arquivos anteriores
del %ARQUIVO_WAVE%.ghw 2>nul
del work-obj93.cf 2>nul

echo [1/9] Analisando Registrador (Eq05-Registrador.vhd)...
ghdl -a Eq05-Registrador.vhd

echo [2/9] Analisando Banco de Registradores (Eq05-BancoRegistradores.vhd)...
ghdl -a Eq05-BancoRegistradores.vhd

echo [3/9] Analisando ULA (Eq05-ULA.vhd)...
ghdl -a Eq05-ULA.vhd

echo [4/9] Analisando Maquina de Estados (Eq05-maq_estados.vhd)...
ghdl -a Eq05-maq_estados.vhd

echo [5/9] Analisando Program Counter (Eq05-program_counter.vhd)...
ghdl -a Eq05-program_counter.vhd

echo [6/9] Analisando ROM (Eq05-rom.vhd)...
ghdl -a Eq05-rom.vhd

echo [7/9] Analisando Unidade de Controle (Eq05-unidade_controle.vhd)...
ghdl -a Eq05-unidade_controle.vhd

echo [8/9] Analisando Top Level (Eq05-Calc.vhd)...
ghdl -a Eq05-Calc.vhd

echo [9/9] Analisando Test Bench (Eq05-Calc_tb.vhd)...
ghdl -a Eq05-Calc_tb.vhd

:: ------------------------------------------

:: 2. Elaboracao (ghdl -e)
echo Elaborando a entidade de topo: %ENTIDADE_TOP%...
ghdl -e %ENTIDADE_TOP%

:: 3. Simulacao (ghdl -r)
echo Simulando %ENTIDADE_TOP% e gerando %ARQUIVO_WAVE%.ghw...
:: Simulando por 20000ns para dar tempo de ver o loop.
ghdl -r %ENTIDADE_TOP% --stop-time=20000ns --wave=%ARQUIVO_WAVE%.ghw

echo ------------------------------------------
echo -- Simulacao Concluida --
echo ------------------------------------------

:: 4. Abrir GTKWave
echo Abrindo formas de onda %ARQUIVO_WAVE%.ghw...
:: O start "" e importante para o GTKWave abrir em um processo separado.
start "" gtkwave %ARQUIVO_WAVE%.ghw %ARQUIVO_WAVE%.gtkw

echo.
echo Arquivo de simulacao %ARQUIVO_WAVE%.ghw gerado.
pause