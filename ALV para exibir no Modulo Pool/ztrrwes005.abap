*----------------------------------------------------------------------*
*                         TREINAMENTO                                  *
*----------------------------------------------------------------------*
* Autor....: Wesley Constantino dos Santos                             *
* Data.....: 06.12.2022                                                *
* Módulo...: TR                                                        *
* Descrição: Testes                                                    *
*----------------------------------------------------------------------*
*                    Histórico das Alterações                          *
*----------------------------------------------------------------------*
* DATA      | AUTOR             | Request    | DESCRIÇÃO               *
*----------------------------------------------------------------------*
*           |                   |            |                         *
*----------------------------------------------------------------------*
REPORT ztrrwes005.

*&---------------------------------------------------------------------*
*                                TABLES                                *
*&---------------------------------------------------------------------*
TABLES: ztrtwes004.

*&---------------------------------------------------------------------*
*                                 TYPES                                *
*&---------------------------------------------------------------------*
TYPES: BEGIN OF ty_saida,
         codalu     TYPE ztrtwes004-codalu,
         codcli     TYPE ztrtwes004-codcli,
         nomecli    TYPE ztrtwes001-nomecli,
         cpfcli     TYPE ztrtwes001-cpfcli,
         chassi     TYPE ztrtwes004-chassi,
         placa      TYPE ztrtwes004-placa,
         cor        TYPE ztrtwes002-cor,
         modelo     TYPE ztrtwes002-modelo,
         datainicio TYPE ztrtwes004-datainicio,
         datafim    TYPE ztrtwes004-datafim,
         valor      TYPE ztrtwes004-valor,
       END OF ty_saida.

*&---------------------------------------------------------------------*
*                        Tabelas Internas                              *
*&---------------------------------------------------------------------*
DATA: t_out      TYPE TABLE OF ty_saida,
      t_fieldcat TYPE slis_t_fieldcat_alv.

*&---------------------------------------------------------------------*
*                          Workareas                                   *
*&---------------------------------------------------------------------*
DATA: wa_out    LIKE LINE  OF t_out,
      wa_layout TYPE slis_layout_alv.

*&---------------------------------------------------------------------*
*                          Tela de seleção                             *
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-t01.
*Campos de entrada
"PARAMETERS:
SELECT-OPTIONS: p_codcli FOR ztrtwes004-codcli MODIF ID CLI, "Campo 1; MODIF ID modifica o nome desse campo; em vez de 001, agora ele se chama CLI
                p_data   FOR ztrtwes004-datainicio. "Campo 002
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-t02.

*Radio Buttons
PARAMETERS: rb_cli  RADIOBUTTON GROUP g1 DEFAULT 'X' USER-COMMAND uc1, "Gera evento no radio button
            rb_data RADIOBUTTON GROUP g1.
SELECTION-SCREEN END OF BLOCK b2.
SELECTION-SCREEN END OF BLOCK b1.

*Eventos dos Radios Buttons
AT SELECTION-SCREEN OUTPUT.
  IF rb_cli = ''.
    PERFORM zf_esconde_campo_cliente.
    CLEAR: p_codcli,
             p_data.
  ELSE.
    PERFORM zf_esconde_campo_data.
    CLEAR: p_codcli,
             p_data.
  ENDIF.

*Início da lógica
START-OF-SELECTION.
  PERFORM zf_select.
  PERFORM zf_exibe_alv_poo.

*&---------------------------------------------------------------------*
*                      FORM zf_select                            *
*&---------------------------------------------------------------------*
FORM zf_select.

  SELECT ztrtwes004~codalu
         ztrtwes004~codcli
         ztrtwes001~nomecli
         ztrtwes001~cpfcli
         ztrtwes004~chassi
         ztrtwes004~placa
         ztrtwes002~cor
         ztrtwes002~modelo
         ztrtwes004~datainicio
         ztrtwes004~datafim
         ztrtwes004~valor
    INTO TABLE t_out
    FROM ztrtwes004 INNER JOIN ztrtwes001
    ON ztrtwes004~codcli EQ ztrtwes001~codcli
    INNER JOIN ztrtwes002
    ON ztrtwes004~chassi EQ ztrtwes002~chassi
    WHERE ztrtwes004~codcli IN p_codcli OR
          ztrtwes004~datainicio IN p_data.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE s398(00) WITH 'Não há registros!' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.


ENDFORM.

*&---------------------------------------------------------------------*
*                      FORM zf_esconde_campo_cliente                            *
*&---------------------------------------------------------------------*
FORM zf_esconde_campo_cliente .

  LOOP AT SCREEN.
    IF screen-group4 ='CLI'. "Campo CLI é o campo de Cliente da tela de seleção
      screen-active = '0'.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*                      FORM zf_esconde_campo_data                            *
*&---------------------------------------------------------------------*
FORM zf_esconde_campo_data .

  LOOP AT SCREEN.
    IF screen-group4 ='002'. "Campo 002 é o campo de Data da tela de seleção
      screen-active = '0'.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  ZF_exibe_alv_poo
*&---------------------------------------------------------------------*
FORM zf_exibe_alv_poo.

  DATA: lo_table  TYPE REF TO cl_salv_table,  "Acessar a classe "cl_salv_table"
        lo_header TYPE REF TO cl_salv_form_layout_grid.   "Para criação do header

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = lo_table "Tabela local
                             CHANGING t_table = t_out ).

      lo_table->get_functions( )->set_all( abap_true ). "Ativar met codes


      CREATE OBJECT lo_header. "É necessário que criemos o objeto header

      lo_header->create_header_information( row = 1 column = 1 text = 'Header' ). "Texto grande do header
      lo_header->add_row( ).


      lo_table->get_display_settings( )->set_striped_pattern( abap_true ).

      lo_table->set_top_of_list( lo_header ).

      lo_table->display( ) . "O dispay é fundamental para a exibição do ALV

    CATCH cx_salv_msg
          cx_root.

      MESSAGE s398(00) WITH 'Erro ao exibir tabela' DISPLAY LIKE 'E'.

  ENDTRY.

ENDFORM.
