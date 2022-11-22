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


*&---------------------------------------------------------------------*
*                          Tabelas globais                             *
*&---------------------------------------------------------------------*
DATA: tg_mara TYPE TABLE OF ty_mara,
      tg_makt TYPE TABLE OF ty_makt.

*&---------------------------------------------------------------------*
*                          Work Areas                                  *
*&---------------------------------------------------------------------*
DATA: wg_mara TYPE  ty_mara, "Ou LIKE LINE tg_mara em vez de TYPE ty_mara
      wg_makt TYPE  ty_makt.

*&---------------------------------------------------------------------*
*                          Tela de seleção                             *
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-000.
*PARAMETERS: p_matnr TYPE mara-matnr.
SELECT-OPTIONS: s_matnr FOR mara-matnr no-EXTENSION no INTERVALS. "SELECT-OPTIONS com uma campo só
SELECTION-SCREEN END OF BLOCK b1.


START-OF-SELECTION.
*&---------------------------------------------------------------------*
*                            PERFORMS:                                 *
*                 zf_seleciona_dados e zf_imprime_dados                *
*&---------------------------------------------------------------------*
  PERFORM: zf_seleciona_dados,
           zf_imprime_dados.

*&---------------------------------------------------------------------*
*                      FORM:     zf_seleciona_dados                    *
*&---------------------------------------------------------------------*
FORM zf_seleciona_dados.

  SELECT matnr
         ersda
         ernam
    FROM mara
    INTO TABLE tg_mara
    WHERE matnr in s_matnr. "Condição adicionada

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
