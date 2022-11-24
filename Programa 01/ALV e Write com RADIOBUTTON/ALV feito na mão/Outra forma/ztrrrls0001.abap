*----------------------------------------------------------------------*
*                       TREINAMENTO0001                                *
*----------------------------------------------------------------------*
* Autor....: Rafael Leite de Sá                                        *
* Data.....: 22.11.2022                                                *
* Módulo...: TR                                                        *
* Descrição: Programa para seleção da descrição de materiais.          *
*---------------------!! ALV APPEND 1 A 1 !!---------------------------*
*----------------------------------------------------------------------*
*                   Histórico das Alterações                           *
*----------------------------------------------------------------------*
* DATA      | AUTOR             | Request    | DESCRIÇÃO               *
*----------------------------------------------------------------------*
*           |                   |            |                         *
*----------------------------------------------------------------------*
REPORT ztrrrls0001.



*&---------------------------------------------------------------------*
*                       Tables                                         *
*&---------------------------------------------------------------------*
TABLES: mara.



*--------------------------------------------------------------------*
*                       Declaração de SLIS para ALV                  *
*--------------------------------------------------------------------*
TYPE-POOLS : slis.



*&---------------------------------------------------------------------*
*                       TYPES                                          *
*&---------------------------------------------------------------------*
TYPES: BEGIN OF ty_mara,
         matnr TYPE mara-matnr, "Nº do material
         ersda TYPE mara-ersda, "Data de criação
         ernam TYPE mara-ernam, "Nome do responsável
       END OF ty_mara,



      BEGIN OF ty_makt,
         matnr TYPE makt-matnr, "Nº do material
         maktx TYPE makt-maktx, "Texto breve de material
       END OF ty_makt,



      BEGIN OF ty_report,
         matnr TYPE mara-matnr, "Nº do material
         maktx TYPE makt-maktx, "Texto breve de material
         ersda TYPE mara-ersda, "Data de criação
         ernam TYPE mara-ernam, "Nome do responsável
       END OF ty_report.



*&---------------------------------------------------------------------*
*                       Internal Tables                                *
*&---------------------------------------------------------------------*
DATA: gt_mara   TYPE TABLE OF ty_mara,
      gt_makt   TYPE TABLE OF ty_makt,
      gt_report TYPE TABLE OF ty_report,  "Tabela de dados final para apresentação
      gt_fldcat TYPE slis_t_fieldcat_alv. "Tabela ALV



*&---------------------------------------------------------------------*
*                       Declaração de Estruturas                       *
*&---------------------------------------------------------------------*
DATA: gw_fldcat TYPE slis_fieldcat_alv, "Structure ALV
      gw_layout TYPE slis_layout_alv. "Tabela Config layout ALV



*&---------------------------------------------------------------------*
*                       Tela de Seleção                                *
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-t01.



SELECT-OPTIONS: s_matnr FOR mara-matnr. "NO INTERVALS NO-EXTENSION.



SELECTION-SCREEN END OF BLOCK b1.



SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-t02.



PARAMETERS: p_rtxt RADIOBUTTON GROUP rad1 DEFAULT 'X', "Modo de Saída de texto
            p_ralv RADIOBUTTON GROUP rad1.             "Modo de Saída ALV



SELECTION-SCREEN END OF BLOCK b2.




*&---------------------------------------------------------------------*
*                       Performs                                       *
*&---------------------------------------------------------------------*
START-OF-SELECTION.



 PERFORM: zf_seleciona_dados,
           zf_trata_dados.



 IF p_rtxt IS NOT INITIAL.



   PERFORM zf_mostra_dados_txt.



 ELSE. "IF p_rtxt IS NOT INITIAL.



   PERFORM zf_mostra_dados_alv.



 ENDIF. "IF p_rtxt IS NOT INITIAL.



*&---------------------------------------------------------------------*
*&      Form  ZF_SELECIONA_DADOS
*&---------------------------------------------------------------------*
FORM zf_seleciona_dados .



 SELECT matnr
         ersda
         ernam
  FROM mara
  INTO TABLE gt_mara
  WHERE matnr IN s_matnr.



 IF gt_mara IS NOT INITIAL.



   SELECT matnr
           maktx
    FROM makt
    INTO TABLE gt_makt
    FOR ALL ENTRIES IN gt_mara
    WHERE matnr = gt_mara-matnr
          AND matnr IN s_matnr
          AND spras = 'P'.



 ELSE. "IF gt_mara IS NOT INITIAL.



   MESSAGE s398(00) WITH text-001 DISPLAY LIKE 'E'. "Nenhum dado encontrado.
    STOP.



 ENDIF. "IF gt_mara IS NOT INITIAL.



ENDFORM. " zf_seleciona_dados .



*&---------------------------------------------------------------------*
*&      Form  ZF_TRATA_DADOS
*&---------------------------------------------------------------------*
FORM zf_trata_dados .



 DATA: lw_mara   LIKE LINE OF gt_mara,
        lw_makt   LIKE LINE OF gt_makt,
        lw_report LIKE LINE OF gt_report.



 SORT: gt_makt BY matnr.



 LOOP AT gt_mara INTO lw_mara.



   READ TABLE gt_makt INTO lw_makt WITH KEY matnr = lw_mara BINARY SEARCH.



   lw_report-matnr = lw_mara-matnr.
    lw_report-ernam = lw_mara-ernam.
    lw_report-ersda = lw_mara-ersda.
    lw_report-maktx = lw_makt-maktx.



   APPEND lw_report TO gt_report.



   CLEAR: lw_report, lw_makt, lw_mara.



 ENDLOOP. "LOOP AT gt_mara INTO lw_mara.



ENDFORM. " zf_trata_dados



*&---------------------------------------------------------------------*
*&      Form  ZF_MOSTRA_DADOS_TXT
*&---------------------------------------------------------------------*
FORM zf_mostra_dados_txt .



 DATA: lw_report LIKE LINE OF gt_report.



 FORMAT RESET INTENSIFIED ON COLOR COL_GROUP. "Cor Laranja



 WRITE: / sy-uline(100).



 WRITE: / sy-vline, 'Nº do material',
         22 sy-vline, 'Texto breve do material',
         65 sy-vline, 'Nome responsável',
         100 sy-vline.



 WRITE: / sy-uline(100).



 LOOP AT gt_report INTO lw_report.



   IF sy-tabix MOD 2 <> 0.



     FORMAT RESET INTENSIFIED ON COLOR COL_KEY. "Azul Escuro



   ELSE. " IF sy-tabix MOD 2 <> 0.



     FORMAT RESET INTENSIFIED OFF COLOR COL_KEY. "Azul Claro



   ENDIF. " IF sy-tabix MOD 2 <> 0.



   WRITE: / sy-vline, lw_report-matnr, "Nº do material
             sy-vline, lw_report-maktx, "Texto breve do material
             sy-vline, lw_report-ernam, "Nome responsável
             100 sy-vline.



   WRITE: / sy-uline(100).



   CLEAR: lw_report.



 ENDLOOP. " LOOP AT gt_report INTO lw_report.



ENDFORM. " zf_imprimi_dados



*&---------------------------------------------------------------------*
*&      Form  ZF_MOSTRA_DADOS_ALV
*&---------------------------------------------------------------------*
FORM zf_mostra_dados_alv .



*&---------------------------------------------------------------------*
*                       Declaração Estrutura ALV                       *
*&---------------------------------------------------------------------*
  gw_fldcat-fieldname   = 'matnr'.
  gw_fldcat-tabname     = 'gt_report'.
  gw_fldcat-seltext_m   = 'Nº Material'.
  gw_fldcat-seltext_s   = 'Nº Mat.'.
  gw_fldcat-key         = 'X'.
  APPEND gw_fldcat TO gt_fldcat.
  CLEAR gw_fldcat.



 gw_fldcat-fieldname   = 'maktx'.
  gw_fldcat-tabname     = 'gt_report'.
  gw_fldcat-seltext_m   = 'Descrição Material'.
  gw_fldcat-seltext_s   = 'Desc. Mat.'.
  APPEND gw_fldcat TO gt_fldcat.
  CLEAR gw_fldcat.



 gw_fldcat-fieldname   = 'ersda'.
  gw_fldcat-tabname     = 'gt_report'.
  gw_fldcat-seltext_m   = 'Data de Criação'.
  gw_fldcat-seltext_s   = 'Dt Criação'.
  APPEND gw_fldcat TO gt_fldcat.
  CLEAR gw_fldcat.



 gw_fldcat-fieldname   = 'ernam'.
  gw_fldcat-tabname     = 'gt_report'.
  gw_fldcat-seltext_m   = 'Resposável'.
  gw_fldcat-seltext_s   = 'Resp.'.
  APPEND gw_fldcat TO gt_fldcat.
  CLEAR gw_fldcat.



*&---------------------------------------------------------------------*
*                       Definição das opções de layout                 *
*&---------------------------------------------------------------------*
  gw_layout-window_titlebar = text-t03. "Declara titulo do resultado do report - 'Dados de Materiais'
  gw_layout-colwidth_optimize = 'X'. "Otimização de largura de colunas
  gw_layout-zebra = 'X'. "Faz com que linhas apareçam zebradas



*&---------------------------------------------------------------------*
*                       Execução do ALV                                *
*&---------------------------------------------------------------------*
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      it_fieldcat        = gt_fldcat
      i_callback_program = sy-repid
      is_layout          = gw_layout
    TABLES
      t_outtab           = gt_report.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE s398(00) WITH text-002 DISPLAY LIKE 'E'. "Erro ao mostrar ALV
  ENDIF. "IF sy-subrc IS NOT INITIAL.



ENDFORM. " zf_mostra_dados_alv*----------------------------------------------------------------------*
*                       TREINAMENTO0001                                *
*----------------------------------------------------------------------*
* Autor....: Rafael Leite de Sá                                        *
* Data.....: 22.11.2022                                                *
* Módulo...: TR                                                        *
* Descrição: Programa para seleção da descrição de materiais.          *
*---------------------!! ALV APPEND 1 A 1 !!---------------------------*
*----------------------------------------------------------------------*
*                   Histórico das Alterações                           *
*----------------------------------------------------------------------*
* DATA      | AUTOR             | Request    | DESCRIÇÃO               *
*----------------------------------------------------------------------*
*           |                   |            |                         *
*----------------------------------------------------------------------*
REPORT ztrrrls0001.



*&---------------------------------------------------------------------*
*                       Tables                                         *
*&---------------------------------------------------------------------*
TABLES: mara.



*--------------------------------------------------------------------*
*                       Declaração de SLIS para ALV                  *
*--------------------------------------------------------------------*
TYPE-POOLS : slis.



*&---------------------------------------------------------------------*
*                       TYPES                                          *
*&---------------------------------------------------------------------*
TYPES: BEGIN OF ty_mara,
         matnr TYPE mara-matnr, "Nº do material
         ersda TYPE mara-ersda, "Data de criação
         ernam TYPE mara-ernam, "Nome do responsável
       END OF ty_mara,



      BEGIN OF ty_makt,
         matnr TYPE makt-matnr, "Nº do material
         maktx TYPE makt-maktx, "Texto breve de material
       END OF ty_makt,



      BEGIN OF ty_report,
         matnr TYPE mara-matnr, "Nº do material
         maktx TYPE makt-maktx, "Texto breve de material
         ersda TYPE mara-ersda, "Data de criação
         ernam TYPE mara-ernam, "Nome do responsável
       END OF ty_report.



*&---------------------------------------------------------------------*
*                       Internal Tables                                *
*&---------------------------------------------------------------------*
DATA: gt_mara   TYPE TABLE OF ty_mara,
      gt_makt   TYPE TABLE OF ty_makt,
      gt_report TYPE TABLE OF ty_report,  "Tabela de dados final para apresentação
      gt_fldcat TYPE slis_t_fieldcat_alv. "Tabela ALV



*&---------------------------------------------------------------------*
*                       Declaração de Estruturas                       *
*&---------------------------------------------------------------------*
DATA: gw_fldcat TYPE slis_fieldcat_alv, "Structure ALV
      gw_layout TYPE slis_layout_alv. "Tabela Config layout ALV



*&---------------------------------------------------------------------*
*                       Tela de Seleção                                *
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-t01.



SELECT-OPTIONS: s_matnr FOR mara-matnr. "NO INTERVALS NO-EXTENSION.



SELECTION-SCREEN END OF BLOCK b1.



SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-t02.



PARAMETERS: p_rtxt RADIOBUTTON GROUP rad1 DEFAULT 'X', "Modo de Saída de texto
            p_ralv RADIOBUTTON GROUP rad1.             "Modo de Saída ALV



SELECTION-SCREEN END OF BLOCK b2.




*&---------------------------------------------------------------------*
*                       Performs                                       *
*&---------------------------------------------------------------------*
START-OF-SELECTION.



 PERFORM: zf_seleciona_dados,
           zf_trata_dados.



 IF p_rtxt IS NOT INITIAL.



   PERFORM zf_mostra_dados_txt.



 ELSE. "IF p_rtxt IS NOT INITIAL.



   PERFORM zf_mostra_dados_alv.



 ENDIF. "IF p_rtxt IS NOT INITIAL.



*&---------------------------------------------------------------------*
*&      Form  ZF_SELECIONA_DADOS
*&---------------------------------------------------------------------*
FORM zf_seleciona_dados .



 SELECT matnr
         ersda
         ernam
  FROM mara
  INTO TABLE gt_mara
  WHERE matnr IN s_matnr.



 IF gt_mara IS NOT INITIAL.



   SELECT matnr
           maktx
    FROM makt
    INTO TABLE gt_makt
    FOR ALL ENTRIES IN gt_mara
    WHERE matnr = gt_mara-matnr
          AND matnr IN s_matnr
          AND spras = 'P'.



 ELSE. "IF gt_mara IS NOT INITIAL.



   MESSAGE s398(00) WITH text-001 DISPLAY LIKE 'E'. "Nenhum dado encontrado.
    STOP.



 ENDIF. "IF gt_mara IS NOT INITIAL.



ENDFORM. " zf_seleciona_dados .



*&---------------------------------------------------------------------*
*&      Form  ZF_TRATA_DADOS
*&---------------------------------------------------------------------*
FORM zf_trata_dados .



 DATA: lw_mara   LIKE LINE OF gt_mara,
        lw_makt   LIKE LINE OF gt_makt,
        lw_report LIKE LINE OF gt_report.



 SORT: gt_makt BY matnr.



 LOOP AT gt_mara INTO lw_mara.



   READ TABLE gt_makt INTO lw_makt WITH KEY matnr = lw_mara BINARY SEARCH.



   lw_report-matnr = lw_mara-matnr.
    lw_report-ernam = lw_mara-ernam.
    lw_report-ersda = lw_mara-ersda.
    lw_report-maktx = lw_makt-maktx.



   APPEND lw_report TO gt_report.



   CLEAR: lw_report, lw_makt, lw_mara.



 ENDLOOP. "LOOP AT gt_mara INTO lw_mara.



ENDFORM. " zf_trata_dados



*&---------------------------------------------------------------------*
*&      Form  ZF_MOSTRA_DADOS_TXT
*&---------------------------------------------------------------------*
FORM zf_mostra_dados_txt .



 DATA: lw_report LIKE LINE OF gt_report.



 FORMAT RESET INTENSIFIED ON COLOR COL_GROUP. "Cor Laranja



 WRITE: / sy-uline(100).



 WRITE: / sy-vline, 'Nº do material',
         22 sy-vline, 'Texto breve do material',
         65 sy-vline, 'Nome responsável',
         100 sy-vline.



 WRITE: / sy-uline(100).



 LOOP AT gt_report INTO lw_report.



   IF sy-tabix MOD 2 <> 0.



     FORMAT RESET INTENSIFIED ON COLOR COL_KEY. "Azul Escuro



   ELSE. " IF sy-tabix MOD 2 <> 0.



     FORMAT RESET INTENSIFIED OFF COLOR COL_KEY. "Azul Claro



   ENDIF. " IF sy-tabix MOD 2 <> 0.



   WRITE: / sy-vline, lw_report-matnr, "Nº do material
             sy-vline, lw_report-maktx, "Texto breve do material
             sy-vline, lw_report-ernam, "Nome responsável
             100 sy-vline.



   WRITE: / sy-uline(100).



   CLEAR: lw_report.



 ENDLOOP. " LOOP AT gt_report INTO lw_report.



ENDFORM. " zf_imprimi_dados



*&---------------------------------------------------------------------*
*&      Form  ZF_MOSTRA_DADOS_ALV
*&---------------------------------------------------------------------*
FORM zf_mostra_dados_alv .



*&---------------------------------------------------------------------*
*                       Declaração Estrutura ALV                       *
*&---------------------------------------------------------------------*
  gw_fldcat-fieldname   = 'matnr'.
  gw_fldcat-tabname     = 'gt_report'.
  gw_fldcat-seltext_m   = 'Nº Material'.
  gw_fldcat-seltext_s   = 'Nº Mat.'.
  gw_fldcat-key         = 'X'.
  APPEND gw_fldcat TO gt_fldcat.
  CLEAR gw_fldcat.



 gw_fldcat-fieldname   = 'maktx'.
  gw_fldcat-tabname     = 'gt_report'.
  gw_fldcat-seltext_m   = 'Descrição Material'.
  gw_fldcat-seltext_s   = 'Desc. Mat.'.
  APPEND gw_fldcat TO gt_fldcat.
  CLEAR gw_fldcat.



 gw_fldcat-fieldname   = 'ersda'.
  gw_fldcat-tabname     = 'gt_report'.
  gw_fldcat-seltext_m   = 'Data de Criação'.
  gw_fldcat-seltext_s   = 'Dt Criação'.
  APPEND gw_fldcat TO gt_fldcat.
  CLEAR gw_fldcat.



 gw_fldcat-fieldname   = 'ernam'.
  gw_fldcat-tabname     = 'gt_report'.
  gw_fldcat-seltext_m   = 'Resposável'.
  gw_fldcat-seltext_s   = 'Resp.'.
  APPEND gw_fldcat TO gt_fldcat.
  CLEAR gw_fldcat.



*&---------------------------------------------------------------------*
*                       Definição das opções de layout                 *
*&---------------------------------------------------------------------*
  gw_layout-window_titlebar = text-t03. "Declara titulo do resultado do report - 'Dados de Materiais'
  gw_layout-colwidth_optimize = 'X'. "Otimização de largura de colunas
  gw_layout-zebra = 'X'. "Faz com que linhas apareçam zebradas



*&---------------------------------------------------------------------*
*                       Execução do ALV                                *
*&---------------------------------------------------------------------*
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      it_fieldcat        = gt_fldcat
      i_callback_program = sy-repid
      is_layout          = gw_layout
    TABLES
      t_outtab           = gt_report.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE s398(00) WITH text-002 DISPLAY LIKE 'E'. "Erro ao mostrar ALV
  ENDIF. "IF sy-subrc IS NOT INITIAL.



ENDFORM. " zf_mostra_dados_alv
