@echo off
:: Eq05-Prime.bat
:: Equipe: Giovana Valim, Giulia de Souza Leite

:: Mudamos o nome do Top Level para refletir o Lab 8
set ENTIDADE_TOP=Eq05_Prime_tb
set ARQUIVO_WAVE=Eq05-Prime

echo ------------------------------------------
echo -- Compilando Laboratorio 8 (Numeros Primos)
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

echo [8/9] Analisando Top Level (Prime)...
ghdl -a --ieee=synopsys Eq05-Prime.vhd
if %errorlevel% neq 0 goto :erro

echo [9/9] Analisando Test Bench (Prime)...
ghdl -a --ieee=synopsys Eq05-Prime_tb.vhd
if %errorlevel% neq 0 goto :erro

:: 2. Elaboracao
echo.
echo Elaborando %ENTIDADE_TOP%...
ghdl -e --ieee=synopsys %ENTIDADE_TOP%
if %errorlevel% neq 0 goto :erro

:: 3. Simulacao 
echo.
echo Simulando (Tempo estendido para achar os primos)...
:: Aumentar para 3300000ns pois o calculo de 30 primos leva tempo
:: 2700000ns para caber no .zip
ghdl -r %ENTIDADE_TOP% --stop-time=2700000ns --wave=%ARQUIVO_WAVE%.ghw --ieee-asserts=disable
if %errorlevel% neq 0 goto :erro

:: 4. Abrir GTKWave
echo.
echo Abrindo GTKWave...

if exist %ARQUIVO_WAVE%.gtkw (
    echo [OK] Carregando layout salvo: %ARQUIVO_WAVE%.gtkw
    :: Abre carregando a onda E o seu arquivo de configuracao visual
    start "" gtkwave %ARQUIVO_WAVE%.ghw %ARQUIVO_WAVE%.gtkw
) else (
    echo [AVISO] Arquivo .gtkw nao encontrado. Abrindo simulacao crua.
    :: Abre apenas o arquivo de onda, pois nao achou config salva
    start "" gtkwave %ARQUIVO_WAVE%.ghw
)

echo.
echo Simulacao concluida.
pause
goto :eof

:erro
echo.
echo [ERRO] Ocorreu um erro durante a compilacao ou simulacao.
pause