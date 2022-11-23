*----------------------------------------------------------------------*
*                         TREINAMENTO                                  *
*----------------------------------------------------------------------*
* Autor....: Wesley Constantino dos Santos                             *
* Data.....: 22.11.2022                                                *
* Módulo...: TR                                                        *
* Descrição: Testes                                                    *
*----------------------------------------------------------------------*
*                    Histórico das Alterações                          *
*----------------------------------------------------------------------*
* DATA      | AUTOR             | Request    | DESCRIÇÃO               *
*----------------------------------------------------------------------*
*           |                   |            |                         *
*----------------------------------------------------------------------*
REPORT ztrrvas001.

*&---------------------------------------------------------------------*
*                                TABLES                                *
*&---------------------------------------------------------------------*
TABLES: mara.

*&---------------------------------------------------------------------*
*                                 TYPES                                *
*&---------------------------------------------------------------------*
TYPES: BEGIN OF ty_mara,
         matnr TYPE mara-matnr,
         ersda TYPE mara-ersda,
         ernam TYPE mara-ernam,
       END OF ty_mara,

       BEGIN OF ty_makt,
         matnr TYPE makt-matnr,
         maktx TYPE makt-maktx,
       END OF ty_makt.

*&---------------------------------------------------------------------*
*                             CONSTANTS                                *
*&---------------------------------------------------------------------*
CONSTANTS : c_x TYPE c VALUE 'X'.

*&---------------------------------------------------------------------*
*                             Tabelas                                  *
*&---------------------------------------------------------------------*
DATA: tg_mara TYPE TABLE OF ty_mara,
      tg_makt TYPE TABLE OF ty_makt.

*&---------------------------------------------------------------------*
*                          Work Areas                                  *
*&---------------------------------------------------------------------*
DATA: wa_mara TYPE ty_mara, "Ou LIKE LINE tg_mara em vez de TYPE ty_mara
      wa_makt TYPE ty_makt.

*&---------------------------------------------------------------------*
*                          t_out e wa_out                              *
*&---------------------------------------------------------------------*
*****************************ALV***************************************
"t_out e wa_out
DATA: t_out  TYPE TABLE OF ztrewes001,
      wa_out LIKE LINE  OF t_out.

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
  PERFORM: zf_seleciona_dados.

  IF rb_text = c_x.
    PERFORM zf_imprime_dados.
  ELSEIF rb_alv = c_x.
    PERFORM zf_show_alv.
  ENDIF.

*&---------------------------------------------------------------------*
*                      FORM:     zf_seleciona_dados                    *
*&---------------------------------------------------------------------*
FORM zf_seleciona_dados.

  SELECT matnr
         ersda
         ernam
    FROM mara
    INTO TABLE tg_mara
    WHERE matnr IN s_matnr. "Condição adicionada

  IF NOT tg_mara IS INITIAL.

    SELECT matnr
           maktx
      FROM makt
      INTO TABLE tg_makt
      FOR ALL ENTRIES IN tg_mara
      WHERE matnr EQ tg_mara-matnr
      AND spras EQ 'P'.

  ELSE.
    MESSAGE s398(00) WITH text-001 DISPLAY LIKE 'E'. "mensagem de erro
    STOP. "STOP para o programa após a mensagem de erro a cima
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*                      FORM:     zf_imprime_dados                      *
*&---------------------------------------------------------------------*
FORM zf_imprime_dados.

  SORT: tg_makt BY matnr. "SORT ordena os blocos

  FORMAT COLOR COL_TOTAL INTENSIFIED ON .
  WRITE:/ sy-uline(70). "(70) define o tamanho da linha
  WRITE:/   sy-vline,
       (20) 'Nº do material', sy-vline,  "(20) define o espaço que o texto ocupará
       (20) 'Texto breve de material' , sy-vline,
       (20) 'Nome do responsável que criou o objeto' , sy-vline.


  LOOP AT tg_mara INTO wa_mara.

    FORMAT COLOR COL_HEADING.

    READ TABLE tg_makt INTO wa_makt WITH KEY matnr = wa_mara-matnr BINARY SEARCH.
    "para usar o BINARY SEARCH é necessario usar o SORT antes.

    WRITE:/ sy-uline(70). "sy-uline faz uma linha horizontal
    WRITE: / sy-vline,    "sy-vline faz uma linha vertical
            (20) wa_makt-matnr, sy-vline,
            (20) wa_makt-maktx, sy-vline,
            (20) wa_mara-ernam, sy-vline.

    CLEAR: wa_mara,
           wa_makt.

  ENDLOOP.

  WRITE: / sy-uline(70).

ENDFORM.
*----------------------------------------------------------------------*
*                             ****ALV******                            *
*                           Daqui para baixo                           *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*                      FORM:     zf_show_alv                           *
*&---------------------------------------------------------------------*
FORM zf_show_alv.

  PERFORM: zf_trata_dados,
           zf_display_alv.

ENDFORM.
*---------------------------------------------------------------------*
*      Form  ZF_TRATA_DADOS
*---------------------------------------------------------------------*
FORM zf_trata_dados .

  SORT: tg_makt BY matnr. "SORT ordena os blocos

  LOOP AT tg_mara INTO wa_mara.
    READ TABLE tg_makt INTO wa_makt WITH KEY matnr = wa_mara-matnr BINARY SEARCH.

    wa_out-matnr = wa_mara-matnr.
    wa_out-ersda = wa_mara-ersda.
    wa_out-ernam = wa_mara-ernam.
    wa_out-maktx = wa_makt-maktx.

    APPEND wa_out TO t_out.

    CLEAR: wa_out,
           wa_mara,
           wa_makt.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*                    FORM:     f_display_alv                           *
*&---------------------------------------------------------------------*
FORM zf_display_alv.

* Declaração das variáveis base do ALV
  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv,
        wa_layout   TYPE slis_layout_alv.


* Declaração das variáveis base do ALV
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZTREWES001'  " Tabela Transaparente, Criada na SE11.
      i_client_never_display = abap_true
    CHANGING
      ct_fieldcat            = lt_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2.


* Chamada da função que exibe o ALV em tela
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      is_layout     = wa_layout
      it_fieldcat   = lt_fieldcat[]
    TABLES
      t_outtab      = t_out[]  " Inserir a Tabela Interna.
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.

ENDFORM.
