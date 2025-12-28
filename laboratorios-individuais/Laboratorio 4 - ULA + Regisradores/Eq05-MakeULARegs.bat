@echo off
set ENTIDADE_TOP=Eq05_TestBench
set ARQUIVO_WAVE=Eq05-ULARegs

echo ------------------------------------------
echo -- Compilando Laboratorio 4 - Eq05-ULARegs --
echo ------------------------------------------

del %ARQUIVO_WAVE%.ghw 2>nul
del work-obj93.cf 2>nul

:: 1. Analise (ghdl -a) na ordem de dependencia
echo [1/6] Analisando Registrador (Eq05-Registrador.vhd)...
ghdl -a Eq05-Registrador.vhd

echo [2/6] Analisando Banco de Registradores (Eq05-BancoRegistradores.vhd)...
ghdl -a Eq05-BancoRegistradores.vhd

echo [3/6] Analisando ULA (Eq05-ULA.vhd)...
ghdl -a Eq05-ULA.vhd

echo [4/6] Analisando MUX (Eq05-Mux2to1_16bit.vhd)...
ghdl -a Eq05-Mux2to1_16bit.vhd

echo [5/6] Analisando Top Level (Eq05-ULARegs.vhd)...
ghdl -a Eq05-ULARegs.vhd

echo [6/6] Analisando Test Bench (Eq05-TestBench.vhd)...
ghdl -a Eq05-TestBench.vhd

:: 2. Elaboracao (ghdl -e)
echo Elaborando a entidade de topo: %ENTIDADE_TOP%...
ghdl -e %ENTIDADE_TOP%

:: 3. Simulacao (ghdl -r)
echo Simulando %ENTIDADE_TOP% e gerando %ARQUIVO_WAVE%.ghw...
ghdl -r %ENTIDADE_TOP% --stop-time=800ns --wave=%ARQUIVO_WAVE%.ghw

echo ------------------------------------------
echo -- Simulacao Concluida --
echo ------------------------------------------

:: 4. Abrir GTKWave
echo Abrindo formas de onda %ARQUIVO_WAVE%.ghw...
gtkwave %ARQUIVO_WAVE%.ghw

echo.
echo Arquivo de simulacao %ARQUIVO_WAVE%.ghw gerado.
pause