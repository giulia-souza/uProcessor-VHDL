@echo off
:: Eq05-DesvCond.bat
:: Equipe: Giovana Valim, Giulia de Souza Leite

set ENTIDADE_TOP=Eq05_DesvCond_tb
set ARQUIVO_WAVE=Eq05-DesvCond

echo ------------------------------------------
echo -- Compilando Laboratorio 7 
echo ------------------------------------------


del %ARQUIVO_WAVE%.ghw 2>nul
del work-obj93.cf 2>nul

:: 1. Analise 
echo [1/9] Analisando Registrador...
ghdl -a --ieee=synopsys Eq05-Registrador.vhd
if %errorlevel% neq 0 goto :erro

echo [2/9] Analisando Banco de Registradores...
ghdl -a --ieee=synopsys Eq05-BancoRegistradores.vhd
if %errorlevel% neq 0 goto :erro

echo [3/9] Analisando ULA...
ghdl -a --ieee=synopsys Eq05-ULA.vhd
if %errorlevel% neq 0 goto :erro

echo [4/9] Analisando Maquina de Estados...
ghdl -a --ieee=synopsys Eq05-maq_estados.vhd
if %errorlevel% neq 0 goto :erro

echo [5/9] Analisando Program Counter...
ghdl -a --ieee=synopsys Eq05-program_counter.vhd
if %errorlevel% neq 0 goto :erro

echo [6/9] Analisando ROM...
ghdl -a --ieee=synopsys Eq05-rom.vhd
if %errorlevel% neq 0 goto :erro

echo [7/9] Analisando Unidade de Controle...
ghdl -a --ieee=synopsys Eq05-unidade_controle.vhd
if %errorlevel% neq 0 goto :erro

echo [8/9] Analisando Top Level...
ghdl -a --ieee=synopsys Eq05-DesvCond.vhd
if %errorlevel% neq 0 goto :erro

echo [9/9] Analisando Test Bench...
ghdl -a --ieee=synopsys Eq05-DesvCond_tb.vhd
if %errorlevel% neq 0 goto :erro

:: 2. Elaboracao
echo.
echo Elaborando %ENTIDADE_TOP%...
ghdl -e --ieee=synopsys %ENTIDADE_TOP%
if %errorlevel% neq 0 goto :erro

:: 3. Simulacao 
echo.
echo Simulando...

ghdl -r %ENTIDADE_TOP% --stop-time=2000ns --wave=%ARQUIVO_WAVE%.ghw --ieee-asserts=disable
if %errorlevel% neq 0 goto :erro

:: 4. Abrir GTKWave
echo.
echo Abrindo GTKWave...
if exist %ARQUIVO_WAVE%.gtkw (
    start "" gtkwave %ARQUIVO_WAVE%.ghw %ARQUIVO_WAVE%.gtkw
) else (
    echo AVISO: Arquivo %ARQUIVO_WAVE%.gtkw nao encontrado!
    echo Criando arquivo padrao temporario...
    (
        echo [*]
        echo [dumpfile] "%ARQUIVO_WAVE%.ghw"
    ) > %ARQUIVO_WAVE%.gtkw
    start "" gtkwave %ARQUIVO_WAVE%.ghw %ARQUIVO_WAVE%.gtkw
)

echo.
echo Simulacao concluida sem erros.
pause
goto :eof

:erro
echo.
echo [ERRO] Ocorreu um erro durante a compilacao ou simulacao.
pause