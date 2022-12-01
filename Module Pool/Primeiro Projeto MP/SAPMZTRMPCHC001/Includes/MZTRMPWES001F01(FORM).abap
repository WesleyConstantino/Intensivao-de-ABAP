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

*&---------------------------------------------------------------------*
*       Form zf_oculta_bt_alt
*----------------------------------------------------------------------*
*OCULTA BOTÃO "ALTERAR"
FORM zf_oculta_bt_alt.

  IF ok_code NE 'CONSULTAR'.
    LOOP AT SCREEN.
      CASE screen-name.
        WHEN 'BT_ALTERAR'.
          screen-input = 0.
          MODIFY SCREEN.
      ENDCASE.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*       Form zf_oculta_campos
*----------------------------------------------------------------------*
*OCULTA CAMPOS DA TELA 9001
FORM zf_oculta_campos.

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

ENDFORM.

*&---------------------------------------------------------------------*
*       Form zf_oculta_campos_9003
*----------------------------------------------------------------------*
*OCULTA CAMPOS DA TELA 9003
FORM zf_oculta_campos_9003.

  IF ok_code <> 'ATUALIZAR'. .
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
        WHEN 'WA_ALUGUEL_AUTOMOVEL-CODALU'.
          screen-input = 0.
        WHEN 'WA_CAD_AUTOMOVEIS-CHASSI'.
          screen-input = 0.
        WHEN 'WA_CAD_AUTOMOVEIS-VALOR'.
          screen-input = 0.
        WHEN 'WA_CAD_AUTOMOVEIS-MODELO'.
          screen-input = 0.
      ENDCASE.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*       Form zf_selciona_cli_9003
*----------------------------------------------------------------------*
*FAZ A SELEÇÃO DOS CAMPOS DO CLIENTE NA TELA 9003
FORM zf_selciona_cli_9003.

  IF wa_clientes IS NOT INITIAL.
    SELECT SINGLE *
      INTO wa_clientes FROM ztrtwes001
      WHERE codcli = wa_clientes-codcli.
  ENDIF.

  IF wa_clientes IS NOT INITIAL.
    SELECT SINGLE *
      INTO wa_cad_automoveis FROM ztrtwes002
      WHERE placa = wa_cad_automoveis-placa.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*       Form zf_select_9002
*----------------------------------------------------------------------*
*SELECT DA TELA 9002
FORM zf_select_9002.
  SELECT SINGLE *
           FROM ztrtwes001
           INTO CORRESPONDING FIELDS OF wa_clientes
           WHERE cpfcli = wa_clientes-cpfcli
           OR    rgcli  = wa_clientes-rgcli
           OR    codcli = wa_clientes-codcli.
  IF  sy-subrc EQ 0.
    CALL SCREEN 9001.
  ELSE.
    MESSAGE s398(00) WITH text-m01 DISPLAY LIKE 'E'. "mensagem de erro
  ENDIF.
ENDFORM.


*&---------------------------------------------------------------------*
*       Form zf_gera_cod_autmatico
*----------------------------------------------------------------------*
*Gera códigos de cliente automáticamente
FORM zf_gera_cod_autmatico.

  SELECT MAX( codcli ) INTO wa_clientes-codcli  "Seleciona o maior código do cliente
  FROM ztrtwes001.
  ADD 1 TO wa_clientes-codcli.  "Adiciona mais +1 ao maior código encontrado. *Gera um código automático

ENDFORM.

*&---------------------------------------------------------------------*
*       Form zf_gera_cod_autmatico_9003
*----------------------------------------------------------------------*
*Gera códigos de ALUGUEL DE CARROS automáticamente
FORM zf_gera_cod_autmatico_9003.

  SELECT MAX( codalu ) INTO wa_aluguel_automovel-codalu  "Seleciona o maior código do cliente
  FROM ztrtwes004.
  ADD 1 TO wa_aluguel_automovel-codalu.  "Adiciona mais +1 ao maior código encontrado. *Gera um código automático

ENDFORM.

*&---------------------------------------------------------------------*
*       Form zf_limpa_wa
*----------------------------------------------------------------------*
*Limpa wokarea
FORM zf_limpa_wa.
  CLEAR: wa_clientes-nomecli,
         wa_clientes-rgcli,
         wa_clientes-cpfcli,
         wa_clientes-datanasc,
         wa_clientes-ruacli,
         wa_clientes-bairrocli,
         wa_clientes-cidadecli,
         wa_clientes-cepcli,
         wa_clientes-sexcli.
ENDFORM.

*&---------------------------------------------------------------------*
*       Form zf_zf_grava
*----------------------------------------------------------------------*
*Verifica se há campos vazios ao cadastrar um cliente, senão, grava. Tela 9001
FORM zf_grava.

  IF wa_clientes-nomecli IS INITIAL AND
         wa_clientes-rgcli IS INITIAL AND
         wa_clientes-cpfcli IS INITIAL AND
         wa_clientes-datanasc IS INITIAL AND
         wa_clientes-ruacli IS INITIAL AND
         wa_clientes-bairrocli IS INITIAL AND
         wa_clientes-cidadecli IS INITIAL AND
         wa_clientes-cepcli IS INITIAL AND
         wa_clientes-sexcli IS INITIAL.
    MESSAGE s398(00) WITH text-m02 DISPLAY LIKE 'E'.

  ELSE.
    MODIFY ztrtwes001 FROM wa_clientes.
    IF sy-subrc IS INITIAL.
      CLEAR: wa_clientes.
      MESSAGE s398(00) WITH 'Cadastro efetuado com sucesso'.
      PERFORM zf_gera_cod_autmatico.
    ENDIF.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*       Form zf_grava_aluguel
*----------------------------------------------------------------------*
*Verifica se há campos vazios solicitar um aluguel, senão, grava. Tela 9003
FORM zf_grava_aluguel.
  wa_aluguel_automovel-chassi = wa_cad_automoveis-chassi.
  wa_aluguel_automovel-codcli = wa_clientes-codcli.
  wa_aluguel_automovel-placa = wa_cad_automoveis-placa.


  IF wa_aluguel_automovel-codalu IS INITIAL AND
         wa_aluguel_automovel-datainicio IS INITIAL AND
         wa_aluguel_automovel-horainicio IS INITIAL AND
         wa_aluguel_automovel-datafim IS INITIAL AND
         wa_aluguel_automovel-horafim IS INITIAL AND
         wa_aluguel_automovel IS INITIAL.
    MESSAGE s398(00) WITH text-m02 DISPLAY LIKE 'E'.

  ELSE.
    MODIFY ztrtwes004 FROM wa_aluguel_automovel.
    IF sy-subrc IS INITIAL.
      CLEAR: wa_clientes,
             wa_aluguel_automovel,
             wa_cad_automoveis.
      MESSAGE s398(00) WITH 'Cadastro efetuado com sucesso'.
      PERFORM zf_gera_cod_autmatico_9003.
    ENDIF.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*       Form zf_calcula_valor_9003
*----------------------------------------------------------------------*
*FAZ O CALCULO DO VALOR FINAL DO ALUGUEL NA TELA 9003
FORM zf_calcula_valor_9003.
  DATA: vl_dias  TYPE  i,
        vl_valor TYPE  ztrtwes004-valor.

  vl_dias = (  wa_aluguel_automovel-datafim - wa_aluguel_automovel-datainicio ).
  vl_valor = ( vl_dias * wa_cad_automoveis-valor ).

  wa_aluguel_automovel-valor = vl_valor.

  IF rb_com_desconto = 'X' AND wa_aluguel_automovel-valor IS NOT INITIAL.
    PERFORM zf_calcula_desconto_9003.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*       Form zf_calcula_desconto_9003
*----------------------------------------------------------------------*
*FAZ O CALCULO DO DE 10% DO RADIO BUTTON NO ALUGUEL NA TELA 9003
FORM zf_calcula_desconto_9003.
  DATA: vl_desconto TYPE ztrtwes004-valor.

  vl_desconto =  wa_aluguel_automovel-valor / 10 .
  wa_aluguel_automovel-valor = wa_aluguel_automovel-valor - vl_desconto.

ENDFORM.
