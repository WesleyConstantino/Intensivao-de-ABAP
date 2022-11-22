*----------------------------------------------------------------------*
*                         TREINAMENTO                             *
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
REPORT ztrrwes001.

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

*       BEGIN OF ty_alv,
*         matnr TYPE makt-matnr,
*         ersda TYPE mara-ersda,
*         ernam TYPE mara-ernam,
*         maktx TYPE makt-maktx,
*       END OF ty_alv.

*&---------------------------------------------------------------------*
*                             CONSTANTS                                *
*&---------------------------------------------------------------------*
CONSTANTS : rbselected TYPE c LENGTH 1 VALUE 'X'.

*&---------------------------------------------------------------------*
*                             Tabelas                                  *
*&---------------------------------------------------------------------*
DATA: tg_mara TYPE TABLE OF ty_mara,
      tg_makt TYPE TABLE OF ty_makt.

*&---------------------------------------------------------------------*
*                          Work Areas                                  *
*&---------------------------------------------------------------------*
DATA: wg_mara TYPE  ty_mara, "Ou LIKE LINE tg_mara em vez de TYPE ty_mara
      wg_makt TYPE  ty_makt.

*&---------------------------------------------------------------------*
*                          t_out e wa_out                              *
*&---------------------------------------------------------------------*

*****************************ALV***************************************
                        "t_out e wa_out
DATA: t_out  TYPE TABLE OF ztrewes001,
      wa_out LIKE LINE OF t_out.


*&---------------------------------------------------------------------*
*                          Tela de seleção                             *
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-000.
*PARAMETERS: p_matnr TYPE mara-matnr.
SELECT-OPTIONS: s_matnr FOR mara-matnr NO-EXTENSION NO INTERVALS. "com uma campo só
SELECTION-SCREEN ULINE /1(52). "Linha na horizontal
SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.

*&---------------------------------------------------------------------*
*                          RADIO BUTTONS                               *
*&---------------------------------------------------------------------*
  SELECTION-SCREEN BEGIN OF BLOCK frame1 WITH FRAME TITLE text-000.
  SELECTION-SCREEN ULINE /5(48). "Linha na horizontal

  SELECTION-SCREEN BEGIN OF LINE.
  SELECTION-SCREEN POSITION 5. "Posição do primeiro Radio-Button
  PARAMETERS: rb1 RADIOBUTTON GROUP rb.
  SELECTION-SCREEN COMMENT 8(15) text-002. "Posição do primeiro texto do RADIO_BUTTON
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
  SELECTION-SCREEN POSITION 5. "Posição do segundo Radio-Button
  PARAMETERS: rb2 RADIOBUTTON GROUP rb.
  SELECTION-SCREEN COMMENT 8(15) text-003.  "Posição do segundo texto do RADIO_BUTTON
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN END OF BLOCK frame1.

*&---------------------------------------------------------------------*
*                            PERFORMS:                                 *
*                 zf_seleciona_dados e zf_imprime_dados                *
*&---------------------------------------------------------------------*
  PERFORM: zf_seleciona_dados,
           zf_imprime_dados.

  IF rb1 = rbselected.
    PERFORM zf_imprime_dados.
  ELSEIF rb2 = rbselected.
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

  FORMAT COLOR COL_BACKGROUND.
  WRITE:/ sy-uline(70). "(70) define o tamanho da linha
  WRITE:/   sy-vline,
       (20) 'Nº do material' COLOR COL_POSITIVE, sy-vline,  "(20) define o espaço que o texto ocupará
       (20) 'Texto breve de material' COLOR COL_POSITIVE, sy-vline,
       (20) 'Nome do responsável que criou o objeto' COLOR COL_POSITIVE, sy-vline.


  LOOP AT tg_mara INTO wg_mara.

    READ TABLE tg_makt INTO wg_makt WITH KEY matnr = wg_mara-matnr BINARY SEARCH.
    "para usar o BINARY SEARCH é necessario usar o SORT antes.

    WRITE:/ sy-uline(70). "sy-uline faz uma linha horizontal
    WRITE: / sy-vline,    "sy-vline faz uma linha vertical
            (20) wg_makt-matnr COLOR COL_TOTAL, sy-vline,  "COLOR define a cor da linha
            (20) wg_makt-maktx COLOR COL_HEADING, sy-vline,
            (20) wg_mara-ernam COLOR COL_NEGATIVE, sy-vline.

    CLEAR: wg_mara,
           wg_makt.

  ENDLOOP.
  FORMAT COLOR COL_BACKGROUND.
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

  LOOP AT tg_mara INTO wg_mara.
    READ TABLE tg_makt INTO wg_makt WITH KEY matnr = wg_mara-matnr.

    wa_out-matnr = wg_mara-matnr.
    wa_out-ersda = wg_mara-ersda.
    wa_out-ernam = wg_mara-ernam.
    wa_out-maktx =  wg_makt-maktx.

    APPEND wa_out TO t_out.

    CLEAR: wa_out,
           wg_mara,
           wg_makt.
  ENDLOOP.
  PERFORM f_display_alv.
ENDFORM.


*&---------------------------------------------------------------------*
*                      FORM:     f_display_alv                           *
*&---------------------------------------------------------------------*
FORM f_display_alv.

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
