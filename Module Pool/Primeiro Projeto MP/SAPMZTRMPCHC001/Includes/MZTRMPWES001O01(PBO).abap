******************       Include PBO


*&---------------------------------------------------------------------*
*&  Include           MZTRMPWES001O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_9001  OUTPUT


*&---------------------------------------------------------------------*
*       tela 9000
*----------------------------------------------------------------------*
MODULE status_9000 OUTPUT.

  SET PF-STATUS 'PF_9000'.
  SET TITLEBAR 'TITLE_9000' WITH 'Tela inicial'.

ENDMODULE.


*&---------------------------------------------------------------------*
*       tela 9001
*----------------------------------------------------------------------*
MODULE status_9001 OUTPUT.
  SET PF-STATUS 'PF_9001'.
  SET TITLEBAR 'TITLE_9001' WITH 'Cadastro de clientes'.
ENDMODULE.
*OCULTA EDIÇÃO DOS CAMPOS DA TELA 9001
MODULE oculta_dados OUTPUT.

  IF ok_code EQ 'CONSULTAR'. "O ok_code é sempre da tela anterior; a que chama a acção. Nesse caso a 9000
    LOOP AT SCREEN.
      CASE screen-name.
        WHEN 'BT_01'.
          screen-input = 0.
        WHEN 'WA_CLIENTES-NOMECLI'.
          screen-input = 0.
        WHEN 'WA_CLIENTES-RGCLI'.
          screen-input = 0.
        WHEN 'WA_CLIENTES-CPFCLI'.
          screen-input = 0.
        WHEN 'WA_CLIENTES-DATANASC'.
          screen-input = 0.
        WHEN 'WA_CLIENTES-RUACLI'.
          screen-input = 0.
        WHEN 'WA_CLIENTES-BAIRROCLI'.
          screen-input = 0.
        WHEN 'WA_CLIENTES-CIDADECLI'.
          screen-input = 0.
        WHEN 'WA_CLIENTES-CEPCLI'.
          screen-input = 0.
        WHEN 'WA_CLIENTES-SEXCLI'.
          screen-input = 0.
        WHEN 'BT_LIMPAR'.
          screen-input = 0.
      ENDCASE.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

ENDMODULE.
*OCULTA BOTÃO "ALTERAR" TELA 9001
MODULE oculta_botao OUTPUT.
  PERFORM zf_oculta_bt_alt.
ENDMODULE.


*&---------------------------------------------------------------------*
*       tela 9002
*----------------------------------------------------------------------*
MODULE status_9002 OUTPUT.
  SET PF-STATUS 'PF_9002'.
  SET TITLEBAR 'TITLE_9002' WITH 'Consulta de cliente'.
ENDMODULE.

*&---------------------------------------------------------------------*
*       tela 9003
*----------------------------------------------------------------------*
MODULE status_9003 OUTPUT.
  SET PF-STATUS 'PF_9003'.
  SET TITLEBAR 'TITLE_9003' WITH 'Cadastro de Aluguel'.
ENDMODULE.
*DESABILITA EDIÇÃO DOS CAMPOS DA TELA 9003
MODULE oculta_dados_9003 OUTPUT.
  PERFORM zf_oculta_campos_9003.
ENDMODULE.
*OCULTA BOTÃO "ALTERAR" TELA 9003
MODULE oculta_botao_9003 OUTPUT.
  PERFORM zf_oculta_bt_alt.
ENDMODULE.
*OCULTA CAMPOS BOTÕES GRAVAR E LIMPAR DA TELA 9003
MODULE oculta_bts_gravar_limpar_9003 OUTPUT.

  IF ok_code EQ 'BT_CONSULTAR'.
    LOOP AT SCREEN.
      CASE screen-name.
        WHEN 'GRAVAR'.
          screen-input = 0.
        WHEN 'LIMPAR'.
          screen-input = 0.
        WHEN 'WA_ALUGUEL_AUTOMOVEL-VALOR'.
          screen-input = 0.
        WHEN 'WA_ALUGUEL_AUTOMOVEL-HORAFIM'.
          screen-input = 0.
        WHEN 'WA_ALUGUEL_AUTOMOVEL-DATAFIM'.
          screen-input = 0.
        WHEN 'WA_ALUGUEL_AUTOMOVEL-HORAINICIO'.
          screen-input = 0.
        WHEN 'WA_ALUGUEL_AUTOMOVEL-DATAINICIO'.
          screen-input = 0.
        WHEN 'WA_CAD_AUTOMOVEIS-PLACA'.
          screen-input = 0.
        WHEN 'WA_CLIENTES-CODCLI'.
          screen-input = 0.
        WHEN 'BT_LIMPAR'.
          screen-input = 0.
        WHEN 'RB_SEM_DESCONTO'.
          screen-input = 0.
        WHEN 'RB_COM_DESCONTO'.
          screen-input = 0.
        WHEN 'BT_ALTERAR'.
          screen-input = 1.
      ENDCASE.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

ENDMODULE.


*&---------------------------------------------------------------------*
*       tela 9004
*----------------------------------------------------------------------*
MODULE status_9004 OUTPUT.
  SET PF-STATUS 'PF_9004'.
  SET TITLEBAR 'TITLE_9003' WITH 'Consultar Alugueis'.
ENDMODULE.
