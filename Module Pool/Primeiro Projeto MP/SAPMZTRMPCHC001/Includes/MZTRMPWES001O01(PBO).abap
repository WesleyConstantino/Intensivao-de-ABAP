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
  PERFORM zf_oculta_campos.
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
