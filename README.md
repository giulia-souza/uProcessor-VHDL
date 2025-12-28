# Microprocessador - Projeto de Arquitetura de Computadores

Este repositório contém o desenvolvimento completo de um **microprocessador em VHDL**, realizado como projeto final para a disciplina de Arquitetura de Computadores (UTFPR). O projeto evoluiu através de diversos laboratórios práticos até culminar na validação em hardware real utilizando uma FPGA.

## 🎯 Objetivo do Projeto
O objetivo central é a validação da arquitetura através da implementação de um algoritmo para resolver um problema matemático específico: **Calcular quantos números primos há em um intervalo de números inteiros**.

A validação utiliza os recursos da ISA (Instruction Set Architecture) desenvolvida, aplicando laços de repetição e saltos condicionais para processar os números de maneira incremental.

## 🏗️ Especificações Técnicas
A arquitetura do processador baseia-se nos seguintes pilares:

* **Unidade Lógica e Aritmética (ULA):** Implementação combinacional com suporte a Adição, Subtração e Divisão.
* **Lógica de Primalidade:** O resto da divisão é calculado via laços de subtrações sucessivas com uso de flags de comparação ("maior que").
* **Controle de Fluxo:** Suporte a saltos condicionais e uso de registradores para sub-rotinas para otimização do software.
* **Registradores de Status:**
    * **R6:** Armazena a contagem total de números primos encontrados.
    * **R7:** Armazena o valor do último número primo identificado.
      

## 📂 Organização do Repositório
Para facilitar a navegação, o repositório está dividido da seguinte forma:

* **`/laboratorio-final`**: Contém os arquivos fonte (VHDL, ROM, .qsf) do processador completo e validado.
* **`/laboratorios-preparatorios`**: Pasta contendo todos os projetos alternativos e etapas intermediárias que serviram de base para o processador final. 

## 💻 Implementação e Validação
O fluxo de desenvolvimento seguiu os seguintes critérios:

1. **Simulação:** Testado via arquivos `.ghw` para verificar a lógica funcional (mínimo de 30 números primos identificados).
2. **Desenvolvimento de Software:** Algoritmo validado previamente no simulador MARS com instruções similares.
3. **Hardware (FPGA):** Implementação na placa **DE10-Lite**, utilizando decodificação de 16 bits para exibir os resultados em 5 displays de 7 segmentos.
4. **Debug em Tempo Real:** O banco de registradores foi instrumentado para permitir que o usuário selecione, via chaves de hardware (switches), qual registrador interno será visualizado no display.

## 🛠️ Ferramentas Utilizadas
* **Linguagem:** VHDL.
* **Ambiente de Síntese:** Intel Quartus Prime (Projeto exemplo para DE10-Lite).
* **Simulação:** GHDL e GTKWave.
* **Assembly:** Definição customizada da ISA.

---
*Este projeto faz parte dos requisitos da disciplina ministrada pelos professores Juliano e Rafael (DAELN - UTFPR)*.
