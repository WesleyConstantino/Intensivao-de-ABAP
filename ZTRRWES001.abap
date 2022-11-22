*&---------------------------------------------------------------------*
*& Report  ZTRRWES001
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT ztrrwes001.

TYPES: BEGIN OF ty_mara,
         matnr TYPE mara-matnr,
         ersda TYPE mara-ersda,
         ernam TYPE mara-ernam,
       END OF ty_mara,

       BEGIN OF ty_makt,
         matnr TYPE makt-matnr,
         maktx TYPE makt-maktx,
       END OF ty_makt.


DATA: tg_mara TYPE TABLE OF ty_mara,
      tg_makt TYPE TABLE OF ty_makt.

DATA: wg_mara TYPE  ty_mara,
      wg_makt TYPE  ty_makt.

PERFORM: zf_seleciona_dados,
         zf_imprime_dados.

FORM zf_seleciona_dados.
  SELECT matnr
         ersda
         ernam
    FROM mara
    INTO TABLE tg_mara.

  IF NOT tg_mara IS INITIAL.

    SELECT matnr
           maktx
      FROM makt
      INTO TABLE tg_makt
      FOR ALL ENTRIES IN tg_mara
      WHERE matnr EQ tg_mara-matnr
      AND spras EQ 'P'.

  ENDIF.

ENDFORM.

FORM zf_imprime_dados.

  SORT: tg_makt BY matnr. "SORT ordena os blocos

  LOOP AT tg_mara INTO wg_mara.

    READ TABLE tg_makt INTO wg_makt WITH KEY matnr = wg_mara-matnr BINARY SEARCH.
    "para usar o BINARY SEARCH é necessario usar o SORT antes.
    WRITE: / wg_makt-matnr,
             wg_makt-maktx,
             wg_mara-ernam.

    CLEAR: wg_mara,
           wg_makt.

  ENDLOOP.

ENDFORM.
