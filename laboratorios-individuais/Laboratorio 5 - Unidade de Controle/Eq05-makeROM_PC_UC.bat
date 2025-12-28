@echo off
REM 
set FILE_PREFIX=Eq05-
set ENTITY_PREFIX=Eq05_
set TEST_BENCH_FILE=%FILE_PREFIX%ROM_PC_UC_tb
set TEST_BENCH_ENTITY=%ENTITY_PREFIX%ROM_PC_UC_tb
set WAVE_FILE=%FILE_PREFIX%ROM_PC_UC.ghw
REM 

echo -------------------------------------------------------------------------
echo Executavel do Laboratorio UC
echo -------------------------------------------------------------------------


echo.
echo 1. Compilando a ROM (%FILE_PREFIX%rom.vhd)...
ghdl -a %FILE_PREFIX%rom.vhd
if errorlevel 1 goto error

echo 2. Compilando o Program Counter (%FILE_PREFIX%program_counter.vhd)...
ghdl -a %FILE_PREFIX%program_counter.vhd
if errorlevel 1 goto error

echo 3. Compilando a Maquina de Estados (%FILE_PREFIX%maq_estados.vhd)...
ghdl -a %FILE_PREFIX%maq_estados.vhd
if errorlevel 1 goto error

echo 4. Compilando a Estrutura Top-Level (%FILE_PREFIX%ROM_PC_UC.vhd)...
ghdl -a %FILE_PREFIX%ROM_PC_UC.vhd
if errorlevel 1 goto error

echo 5. Compilando o Test Bench (%TEST_BENCH_FILE%.vhd)...
ghdl -a %TEST_BENCH_FILE%.vhd
if errorlevel 1 goto error

echo.
echo 6. Elaborando o Top-Level Test Bench (Entidade: %TEST_BENCH_ENTITY%)...
ghdl -e %TEST_BENCH_ENTITY%
if errorlevel 1 goto error

echo.
echo 7. Simulacao e Geracao do Waveform (%WAVE_FILE%)...
ghdl -r %TEST_BENCH_ENTITY% --stop-time=1000ns --wave=%WAVE_FILE%
if errorlevel 1 goto error

echo.
echo Simulacao concluida com sucesso!
echo Arquivo de waveform %WAVE_FILE% gerado.
echo.
gtkwave %WAVE_FILE%
goto end

:error
echo.
echo =========================================================
echo ERRO: Falha de compilacao, elaboracao ou simulacao do VHDL.
echo Revise as mensagens de erro acima.
echo =========================================================
pause
exit /b 1

:end
echo.
echo Programa finalizado. Pressione qualquer tecla para sair.
pause