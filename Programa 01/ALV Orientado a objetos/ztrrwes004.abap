*&---------------------------------------------------------------------*
*& Report  ZTRRWES004
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT ztrrwes004.


*&---------------------------------------------------------------------*
*                                TABLES                                *
*&---------------------------------------------------------------------*
TABLES: mara.

*&---------------------------------------------------------------------*
*                             CONSTANTS                                *
*&---------------------------------------------------------------------*
CONSTANTS : c_x TYPE c VALUE 'X'.

*&---------------------------------------------------------------------*
*                 tabelas internas e workareas                        *
*&---------------------------------------------------------------------*
*Tabelas internas
DATA: t_out      TYPE TABLE OF ztrewes001,
      t_fieldcat TYPE slis_t_fieldcat_alv.

*Workareas
DATA: wa_out     LIKE LINE  OF t_out,
      wa_layout   TYPE slis_layout_alv.       "Work Area responsável pelo layout

*&---------------------------------------------------------------------*
*                          Tela de seleção                             *
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-000.
*PARAMETERS: p_matnr TYPE mara-matnr.
SELECT-OPTIONS: s_matnr FOR mara-matnr NO-EXTENSION NO INTERVALS. "com um campo só

SELECTION-SCREEN SKIP. "Pula linha

*** RADIO BUTTONS
SELECTION-SCREEN BEGIN OF BLOCK frame1 WITH FRAME TITLE text-004.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 5. "Posição do primeiro Radio-Button
PARAMETERS: rb_text RADIOBUTTON GROUP rb.
SELECTION-SCREEN COMMENT 8(15) text-002. "Posição do primeiro texto do RADIO_BUTTON
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 5. "Posição do segundo Radio-Button
PARAMETERS: rb_alv RADIOBUTTON GROUP rb.
SELECTION-SCREEN COMMENT 8(15) text-003.  "Posição do segundo texto do RADIO_BUTTON
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK frame1.
SELECTION-SCREEN END OF BLOCK b1.

*&---------------------------------------------------------------------*
*                            PERFORMS:                                 *
*                 zf_seleciona_dados e zf_imprime_dados                *
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM: zf_seleciona_dados,
           zf_display.


*----------------------------------------------------------------------*
*      Form  ZF_SELECIONA_DADOS
*----------------------------------------------------------------------*
FORM zf_seleciona_dados .

  SELECT mara~matnr "Este select precisa estar na mesma ordem da minha estrutura
         mara~ersda
         mara~ernam
         makt~maktx
    FROM mara INNER JOIN makt
      ON makt~matnr EQ mara~matnr "ON(Onde) makt~matnr EQ(Igual) mara~matnr
    INTO TABLE t_out
    WHERE mara~matnr IN s_matnr
      AND makt~spras EQ 'P'.

  IF t_out IS INITIAL.
    MESSAGE s398(00) WITH text-003 DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

ENDFORM.



*&---------------------------------------------------------------------*
*&      Form  ZF_DISPLAY
*&---------------------------------------------------------------------*
* Form responsavel pela escolha da impressão e exibição dos RADIO BUTTONS
*
*----------------------------------------------------------------------*
FORM zf_display .

  IF rb_text = 'X'.
    PERFORM zf_display_write.
  ELSE.
    PERFORM zf_exibe_alv_poo.
  ENDIF.

ENDFORM.


*---------------------------------------------------------------------*
*       Impressão de dados de forma zebrada atravez do Write
*----------------------------------------------------------------------*
FORM zf_display_write.

* <----- variável para controle do zebrado
  DATA: lv_colorcontrol(1) TYPE c VALUE abap_true.
* ----->

* <----- cabeçalho da tabela (write)
  FORMAT COLOR COL_GROUP INTENSIFIED.
  WRITE:/ sy-uline(99).
  WRITE:/ sy-vline,
         (18) 'Matricula'       , sy-vline,
         (40) 'Descrição'       , sy-vline,
         (12) 'Responsável'     , sy-vline,
         (16) 'Data de Criação' , sy-vline.
  WRITE:/ sy-uline(99).
* ----->

  LOOP AT t_out INTO wa_out.

* <----- controle do zebrado da impressão.
    IF lv_colorcontrol = abap_true.
      FORMAT COLOR COL_KEY INTENSIFIED ON.
      lv_colorcontrol = abap_false.
    ELSE.
      FORMAT COLOR COL_KEY INTENSIFIED OFF.
      lv_colorcontrol = abap_true.
    ENDIF.
* ----->

    WRITE: / sy-vline,
             wa_out-matnr , sy-vline,
             wa_out-maktx , sy-vline,
             wa_out-ernam , sy-vline,
        (16) wa_out-ersda , sy-vline.
    WRITE:/ sy-uline(99).


    CLEAR: wa_out.

  ENDLOOP.
ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  ZF_exibe_alv_poo
*&---------------------------------------------------------------------*
FORM zf_exibe_alv_poo.

  DATA lo_table TYPE REF TO cl_salv_table.  "Acessar a classe "cl_salv_table"

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = lo_table "Tabela local
                             CHANGING t_table = t_out ).

      lo_table->get_functions( )->set_all( abap_true ). "Ativar met codes

      lo_table->get_columns( )->get_column( 'MATNR' )->set_short_text( 'Texto' ). "Mudar o texto curto da tabela

      lo_table->display( ) . "O dispay é fundamental para a exibição do ALV

    CATCH cx_salv_msg.

ENDTRY.

ENDFORM.
