*************             Include TOP


*&---------------------------------------------------------------------*
*& Include MZTRMPWES001TOP                                   PoolMóds.        SAPMZTRMPWES001
*&
*&---------------------------------------------------------------------*
PROGRAM sapmztrmpwes001.

*&---------------------------------------------------------------------*
*                             Tables                                   *
*&---------------------------------------------------------------------*
TABLES: ztrtwes001.
*&---------------------------------------------------------------------*
*                             WORKAREAS                                *
*&---------------------------------------------------------------------*
DATA: wa_clientes          TYPE ztrtwes001,
      wa_cad_automoveis    TYPE ztrtwes002,
      wa_aluguel_automovel TYPE ztrtwes004.

*&---------------------------------------------------------------------*
*                             VARIÁVEIS                                *
*&---------------------------------------------------------------------*
DATA: ok_code         TYPE sy-ucomm,  "RETORNO DA AÇÃO DO BOTÃO
      vg_resposta     TYPE c LENGTH 3, "Variável para a função da função do pop-up
      rb_sem_desconto TYPE c LENGTH 1 VALUE 'X', "Variável para O RADIO BUTTON DA TELA 9003
      rb_com_desconto TYPE c LENGTH 1.           "Variável para O RADIO BUTTON DA TELA 9003
