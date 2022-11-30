**************          Include FORM


*&---------------------------------------------------------------------*
*&  Include           MZTRMPWES001F01
*&---------------------------------------------------------------------*

*FORMS
*&---------------------------------------------------------------------*
*       Form zf_cadastra_cli
*----------------------------------------------------------------------*
*Função para o Pop-up do botão "Limpar"
FORM zf_popup.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Atenção!'
      text_question         = ' Tem certeza que deseja limpar os campos? '
      text_button_1         = 'Sim'(001)
      icon_button_1         = 'ICON_CHECKED'
      text_button_2         = 'Não'(002)
      icon_button_2         = 'ICON_INCOMPLETE'
      display_cancel_button = ''
    IMPORTING
      answer                = vg_resposta.

  IF vg_resposta EQ 001.
    PERFORM zf_limpa_wa.
  ENDIF.


ENDFORM.
