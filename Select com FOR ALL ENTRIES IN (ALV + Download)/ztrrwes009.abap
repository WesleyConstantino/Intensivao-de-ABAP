*----------------------------------------------------------------------*
*                         TREINAMENTO                                  *
*----------------------------------------------------------------------*
* Autor....: Wesley Constantino dos Santos                             *
* Data.....: 12.12.2022                                                *
* Módulo...: TR                                                        *
* Descrição: Testes                                                    *
*----------------------------------------------------------------------*
*                    Histórico das Alterações                          *
*----------------------------------------------------------------------*
* DATA      | AUTOR             | Request    | DESCRIÇÃO               *
*----------------------------------------------------------------------*
*           |                   |            |                         *
*----------------------------------------------------------------------*
REPORT ztrrwes009.

*&---------------------------------------------------------------------*
*                                TABLES                                *
*&---------------------------------------------------------------------*
TABLES: sscrfields.
"vbrk.

*&---------------------------------------------------------------------*
*                                 TYPES                                *
*&---------------------------------------------------------------------*
TYPES: BEGIN OF ty_download,
         linha(2000) TYPE c,
       END   OF ty_download,

       BEGIN OF ty_out,
         name1   TYPE j_1bnfdoc-name1,
         cgc(18) TYPE c,
         nfnum   TYPE j_1bnfdoc-nfnum,
         parid   TYPE j_1bnfdoc-parid,
         credat  TYPE j_1bnfdoc-credat,
         zfbdt   TYPE bseg-zfbdt,
         bldat   TYPE bkpf-bldat,
         dmbtr   TYPE bseg-dmbtr,
         kbetr   TYPE konv-kbetr,
         kbetrs  TYPE konv-kbetr,
         kbetr1  TYPE konv-kbetr,
         kbetr2  TYPE konv-kbetr,
         kbetr3  TYPE konv-kbetr,
         kbetr4  TYPE konv-kbetr,
         sakn11  TYPE konv-sakn1,
         sakn12  TYPE konv-sakn1,
         sakn13  TYPE konv-sakn1,
         sakn14  TYPE konv-sakn1,
         sgtxt   TYPE bseg-sgtxt,
         pswbt   TYPE bseg-pswbt,
         augbl   TYPE bseg-augbl,
         augdt   TYPE bseg-augdt,
         blart   TYPE bkpf-blart,
         ltext   TYPE t003t-ltext,
         hkont   TYPE bseg-hkont,
       END OF ty_out,

       BEGIN OF ty_out_aux,
         vbeln     TYPE vbrk-vbeln,
         vbeln_aux TYPE c LENGTH 35,
         knumv     TYPE vbrk-knumv,
         docnum    TYPE j_1bnflin-docnum,
         name1     TYPE j_1bnfdoc-name1,
         cgc       TYPE j_1bnfdoc-cgc,
         nfnum     TYPE j_1bnfdoc-nfnum,
         parid     TYPE j_1bnfdoc-parid,
         credat    TYPE j_1bnfdoc-credat,
         zfbdt     TYPE bseg-zfbdt,
         bldat     TYPE bkpf-bldat,
         dmbtr     TYPE bseg-dmbtr,
         kbetr     TYPE konv-kbetr,
         kbetrs    TYPE konv-kbetr,
         kbetr1    TYPE konv-kbetr,
         kbetr2    TYPE konv-kbetr,
         kbetr3    TYPE konv-kbetr,
         kbetr4    TYPE konv-kbetr,
         sakn11    TYPE konv-sakn1,
         sakn12    TYPE konv-sakn1,
         sakn13    TYPE konv-sakn1,
         sakn14    TYPE konv-sakn1,
         sgtxt     TYPE bseg-sgtxt,
         pswbt     TYPE bseg-pswbt,
         augbl     TYPE bseg-augbl,
         augdt     TYPE bseg-augdt,
         blart     TYPE bkpf-blart,
         ltext     TYPE t003t-ltext,
         hkont     TYPE bseg-hkont,
       END OF ty_out_aux,

       BEGIN OF ty_j_1bnflin,
         docnum TYPE j_1bnflin-docnum,
         refkey TYPE j_1bnflin-refkey,
       END OF ty_j_1bnflin,

       BEGIN OF ty_j_1bnfdoc,
         name1  TYPE j_1bnfdoc-name1,
         cgc    TYPE j_1bnfdoc-cgc,
         nfnum  TYPE j_1bnfdoc-nfnum,
         parid  TYPE j_1bnfdoc-parid,
         credat TYPE j_1bnfdoc-credat,
         docnum TYPE j_1bnflin-docnum,
       END OF ty_j_1bnfdoc,

       BEGIN OF ty_bseg,
         belnr TYPE bseg-belnr,
         zfbdt TYPE bseg-zfbdt,
         dmbtr TYPE bseg-dmbtr,
         wrbtr TYPE bseg-wrbtr,
         sgtxt TYPE bseg-sgtxt,
         pswbt TYPE bseg-pswbt,
         augbl TYPE bseg-augbl,
         augdt TYPE bseg-augdt,
         hkont TYPE bseg-hkont,
         bukrs TYPE bseg-bukrs,
         koart TYPE bseg-koart,
       END OF ty_bseg,

       BEGIN OF ty_bkpf,
         bukrs TYPE bkpf-bukrs,
         belnr TYPE bkpf-belnr,
         bldat TYPE bkpf-bldat,
         blart TYPE bkpf-blart,
       END OF ty_bkpf,

       BEGIN OF ty_t003t,
         blart TYPE t003t-blart,
         ltext TYPE t003t-ltext,
         spras TYPE t003t-spras,
       END OF ty_t003t,

       BEGIN OF ty_konv,
         knumv TYPE konv-knumv,
         kbetr TYPE konv-kbetr,
         sakn1 TYPE konv-sakn1,
         kschl TYPE konv-kschl,
       END OF ty_konv,

       BEGIN OF ty_vbrk,
         vbeln     TYPE vbrk-vbeln,
         bukrs     TYPE vbrk-bukrs,
         knumv     TYPE vbrk-knumv,
         fkdat     TYPE vbrk-fkdat,
         kunrg     TYPE vbrk-kunrg,
         fkart     TYPE vbrk-fkart,
         vbeln_aux TYPE c LENGTH 35,
       END OF ty_vbrk.

*&---------------------------------------------------------------------*
*                        Tabelas Internas                              *
*&---------------------------------------------------------------------*
DATA: t_vbrk      TYPE TABLE OF ty_vbrk,
      t_konv      TYPE TABLE OF ty_konv,
      t_t003t     TYPE TABLE OF ty_t003t,
      t_bkpf      TYPE TABLE OF ty_bkpf,
      t_bseg      TYPE TABLE OF ty_bseg,
      t_j_1bnfdoc TYPE TABLE OF ty_j_1bnfdoc,
      t_j_1bnflin TYPE TABLE OF ty_j_1bnflin,
      t_download  TYPE TABLE OF ty_download,
      t_out       TYPE TABLE  OF ty_out,
      t_out_aux   TYPE TABLE  OF ty_out_aux.

*&---------------------------------------------------------------------*
*                            Workareas                                 *
*&---------------------------------------------------------------------*
DATA: wa_j_1bnflin LIKE LINE OF t_j_1bnflin,
      wa_vbrk      LIKE LINE OF t_vbrk,
      wa_konv      LIKE LINE OF t_konv,
      wa_t003t     LIKE LINE OF t_t003t,
      wa_bkpf      LIKE LINE OF t_bkpf,
      wa_bseg      LIKE LINE OF t_bseg,
      wa_j_1bnfdoc LIKE LINE OF t_j_1bnfdoc,
      wa_out       LIKE LINE OF t_out,
      wa_out_aux   LIKE LINE OF t_out_aux,
      wa_download  LIKE LINE OF t_download.

*&---------------------------------------------------------------------*
*                              Variãveis                               *
*&---------------------------------------------------------------------*
*Para os campos da tela de seleção
DATA: v_bukrs     TYPE vbrk-bukrs,
      v_fkdat     TYPE vbrk-fkdat,
      v_kunrg     TYPE vbrk-kunrg,
      vg_filename TYPE string.


*&---------------------------------------------------------------------*
*                         Tela de seleção                              *
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b0 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_empr FOR v_bukrs OBLIGATORY,
                s_dtfat FOR v_fkdat OBLIGATORY,
                s_cli   FOR v_kunrg.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-t02.
*Radio Buttons
PARAMETERS: rb_alv  RADIOBUTTON GROUP g1 DEFAULT 'X' USER-COMMAND cmd,
            rb_dwld RADIOBUTTON GROUP g1.
*Imput do caminho para download
PARAMETERS: p_dwld LIKE rlgrap-filename.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN END OF BLOCK b0.

"Para trazer o caminho do download

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_dwld.
  PERFORM zf_seleciona_diretorio.

*Início da execusão
START-OF-SELECTION.
  "PERFORM zf_valida_s_dtfat. """""""""""""""""""""""""""""""""""""""""""""""""
  PERFORM: zf_select,
           zf_monta_t_out.

  IF rb_alv = 'X'.
    PERFORM zf_exibe_alv_poo.
  ELSE.
    PERFORM: zf_msg_caminho_vazio,
             zf_prepara_download.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  ZF_SELECT
*&---------------------------------------------------------------------*
FORM zf_select.
  SELECT vbeln
         bukrs
         knumv
         fkdat
         kunrg
         fkart
         vbeln
    INTO TABLE t_vbrk "Selecionar todos os campos da minha tabela interna
    FROM vbrk
    WHERE bukrs IN s_empr
      AND fkdat IN s_dtfat
      AND kunrg IN s_cli
      AND ( fkart = 'ZTSO' OR fkart = 'ZS3' ). "FKART = PTI3358_TIPO_FAT (Parâmetro STVARV) "Com valores fixos

  IF NOT t_vbrk IS INITIAL.

    LOOP AT t_vbrk INTO wa_vbrk.  "Loop para fazer a modificação no meu campo auxiliar
      wa_vbrk-vbeln_aux = wa_vbrk-vbeln.
      MODIFY t_vbrk FROM wa_vbrk TRANSPORTING vbeln_aux.
    ENDLOOP.


    SELECT docnum
           refkey
         INTO TABLE t_j_1bnflin
         FROM j_1bnflin
         FOR ALL ENTRIES IN t_vbrk
    WHERE refkey EQ t_vbrk-vbeln_aux.

    "IF sy-subrc EQ 0.
    IF NOT t_j_1bnflin IS INITIAL.

      SELECT name1
             cgc
             nfnum
             parid
             credat
             docnum
        FROM j_1bnfdoc
        INTO TABLE t_j_1bnfdoc
        FOR ALL ENTRIES IN t_j_1bnflin
      WHERE docnum = t_j_1bnflin-docnum.

    ENDIF.

    SELECT belnr
           zfbdt
           dmbtr
           wrbtr
           sgtxt
           pswbt
           augbl
           augdt
           hkont
           bukrs
           koart
      FROM bseg
      INTO TABLE t_bseg
      FOR ALL ENTRIES IN t_vbrk
      WHERE belnr EQ t_vbrk-vbeln
        AND bukrs EQ t_vbrk-bukrs
    AND koart = 'D'.


    SELECT bukrs
           belnr
           bldat
           blart
      FROM bkpf
      INTO TABLE t_bkpf
      FOR ALL ENTRIES IN t_vbrk
      WHERE belnr EQ t_vbrk-vbeln
    AND bukrs EQ t_vbrk-bukrs.

    "IF sy-subrc EQ 0.
    IF NOT t_bkpf IS INITIAL.

      SELECT  blart
              ltext
              spras
        FROM t003t
        INTO TABLE t_t003t
        FOR ALL ENTRIES IN t_bkpf
        WHERE blart = t_bkpf-blart
      AND spras = 'P'.

    ENDIF.

    SELECT knumv
           kbetr
           sakn1
           kschl
      FROM konv
      INTO TABLE t_konv
      FOR ALL ENTRIES IN t_vbrk
    WHERE knumv EQ t_vbrk-knumv
    AND ( kschl = 'ZFE1' OR kschl = 'ZFE2'
    OR    kschl = 'ZFE3' OR kschl = 'ZFE4' ).

    SORT t_konv BY knumv
                   kschl.
    DELETE ADJACENT DUPLICATES FROM t_konv COMPARING knumv kschl. "Deletar as duplicidades de konv




  ELSE.
    MESSAGE s398(00) WITH 'Não há registros!' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

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

*Mudar nome das colinas do ALV
      lo_table->get_columns( )->get_column( 'CGC' )->set_short_text( 'CNPJ' ).  "Mudar o texto curto da tabela
      lo_table->get_columns( )->get_column( 'CGC' )->set_medium_text( 'CNPJ' ). "Mudar o texto médio da tabela
      lo_table->get_columns( )->get_column( 'CGC' )->set_long_text( 'CNPJ' ).   "Mudar o texto longo da tabela
                                            "CGC é o nome do campo que desejo mudar na minha t_out

      lo_table->get_columns( )->get_column( 'KBETRS' )->set_short_text( 'Soma' ).
      lo_table->get_columns( )->get_column( 'KBETRS' )->set_medium_text( 'Soma' ).
      lo_table->get_columns( )->get_column( 'KBETRS' )->set_long_text( 'Soma' ).

      CREATE OBJECT lo_header. "É necessário que criemos o objeto header

      lo_header->create_header_information( row = 1 column = 1 text = 'Relatório ALV' ). "Texto grande do header
      lo_header->add_row( ).


      lo_table->get_display_settings( )->set_striped_pattern( abap_true ).

      lo_table->set_top_of_list( lo_header ).

      lo_table->display( ) . "O dispay é fundamental para a exibição do ALV

    CATCH cx_salv_msg
          cx_root.

      MESSAGE s398(00) WITH 'Erro ao exibir tabela' DISPLAY LIKE 'E'.

  ENDTRY.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ZF_PREPARA_DOWNLOAD
*&---------------------------------------------------------------------*
FORM zf_prepara_download .

  DATA: vl_dmbtr(15)  TYPE c, "Crio variáveis do tipo string para receber dados numéricos
        vl_pswbt(15)  TYPE c,
        vl_kbetrs(11) TYPE c,
        vl_kbetr1(11) TYPE c,
        vl_kbetr2(11) TYPE c,
        vl_kbetr3(11) TYPE c,
        vl_kbetr4(11) TYPE c..

  LOOP AT t_out INTO wa_out.
    vl_dmbtr = wa_out-dmbtr.
    vl_kbetrs = wa_out-kbetrs.
    vl_kbetr1 = wa_out-kbetr1.
    vl_kbetr2 = wa_out-kbetr2.
    vl_kbetr3 = wa_out-kbetr3.
    vl_kbetr4 = wa_out-kbetr4.
    vl_pswbt = wa_out-pswbt.  "As variáveis que eram numéricas se tornam strings

    CONCATENATE wa_out-name1         "Concatenate só aceita strings
                wa_out-cgc        "Deixar na mesma ordem que a tabela transparente
                wa_out-nfnum
                wa_out-parid
                wa_out-credat
                wa_out-zfbdt
                wa_out-bldat
                vl_dmbtr
                vl_kbetrs
                vl_kbetr1
                vl_kbetr2
                vl_kbetr3
                vl_kbetr4
                wa_out-sakn11
                wa_out-sakn12
                wa_out-sakn13
                wa_out-sakn14
                wa_out-sgtxt
                vl_pswbt
                wa_out-augbl
                wa_out-augdt
                wa_out-blart
                wa_out-ltext
                wa_out-hkont
                INTO  wa_download-linha SEPARATED BY ';'.

    APPEND wa_download TO t_download.
    CLEAR  wa_download.

  ENDLOOP.

  IF NOT t_download[] IS INITIAL.
    PERFORM zf_seleciona_diretorio_saida.
  ELSE.
    MESSAGE e398(00) WITH text-003.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  ZF_SELECIONA_DIRETORIO_SAIDA
*&---------------------------------------------------------------------*
FORM zf_seleciona_diretorio_saida .

  CONCATENATE p_dwld '\' 'Tabela ' '.csv' INTO  vg_filename.

*Chamando a função de download, passando a minha tabela tratada e o nome do arquivo.
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = vg_filename     "Passa passar o falename
      filetype                = 'ASC'
    TABLES
      data_tab                = t_download      "Tabela interna de saída
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.

  IF sy-subrc IS INITIAL.
    MESSAGE s398(00) WITH text-008.
  ELSE.
    MESSAGE s398(00) WITH text-009 DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  zf_seleciona_diretorio
*&---------------------------------------------------------------------*
FORM zf_seleciona_diretorio .

*Search help para selecionar um directorio.
  DATA: path_str TYPE string.

  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title    = 'Selecione Diretório'
    CHANGING
      selected_folder = path_str
    EXCEPTIONS
      cntl_error      = 1.

  p_dwld = path_str. "Passo o que tem em path_str para p_dwld; meu parametro de entrada do caminho de download

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  zf_msg_caminho_vazio
*&---------------------------------------------------------------------*
FORM zf_msg_caminho_vazio.
  IF p_dwld IS INITIAL.
    MESSAGE s398(00) WITH 'Informe um diretório para poder prosseguir!' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.
ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  ZF_VALIDA_S_DTFAT
*&---------------------------------------------------------------------*
"FORM zf_valida_s_dtfat .
"  IF s_dtfat < 01112017.
"    MESSAGE s398(00) WITH 'Informar data igual ou maior que 01.11.2017' DISPLAY LIKE 'E'.
"    STOP.
"  ENDIF.
"ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  zf_monta_t_out
*&---------------------------------------------------------------------*
FORM zf_monta_t_out .

  LOOP AT t_vbrk INTO wa_vbrk.

    READ TABLE t_j_1bnflin INTO wa_j_1bnflin WITH KEY refkey = wa_vbrk-vbeln_aux.

    IF sy-subrc IS INITIAL.

      READ TABLE t_j_1bnfdoc INTO wa_j_1bnfdoc WITH KEY docnum = wa_j_1bnflin-docnum.

      IF sy-subrc IS INITIAL.
        wa_out-credat = wa_j_1bnfdoc-credat.
        wa_out-nfnum  = wa_j_1bnfdoc-nfnum.
        wa_out-parid  = wa_j_1bnfdoc-parid.
        wa_out-name1  = wa_j_1bnfdoc-name1.
        WRITE wa_j_1bnfdoc-cgc USING EDIT MASK '__.___.___/____-__' TO wa_out-cgc.  "Máscara para o campo do cnpj
      ENDIF.
    ENDIF.

    READ TABLE t_bseg INTO wa_bseg WITH KEY belnr = wa_vbrk-vbeln
                                            bukrs = wa_vbrk-bukrs
                                            koart = 'D'.

    IF sy-subrc IS INITIAL.
      wa_out-augdt = wa_bseg-augdt.
      wa_out-augbl = wa_bseg-augbl.
      wa_out-dmbtr = wa_bseg-dmbtr.
      wa_out-pswbt = wa_bseg-pswbt.
      wa_out-sgtxt = wa_bseg-sgtxt.
      wa_out-hkont = wa_bseg-hkont.
      wa_out-zfbdt = wa_bseg-zfbdt.
    ENDIF.

    LOOP AT t_konv INTO wa_konv WHERE knumv = wa_vbrk-knumv.

      IF wa_konv-kschl   = 'ZFE1'.
        wa_out-kbetr1 = wa_konv-kbetr.
        wa_out-sakn11 = wa_konv-sakn1.
        "wa_out-somakbetr = wa_out-somakbetr + wa_konv-kbetr.
      ELSEIF wa_konv-kschl  = 'ZFE2'.
        wa_out-kbetr2 = wa_konv-kbetr.
        wa_out-sakn12 = wa_konv-sakn1.
        "wa_out-somakbetr = wa_out-somakbetr + wa_konv-kbetr.
      ELSEIF wa_konv-kschl  = 'ZFE3'.
        wa_out-kbetr3 = wa_konv-kbetr.
        wa_out-sakn13 = wa_konv-sakn1.
        "wa_out-somakbetr = wa_out-somakbetr + wa_konv-kbetr.
      ELSE.
        wa_out-kbetr4 = wa_konv-kbetr.
        wa_out-sakn14 = wa_konv-sakn1.
        "wa_out-somakbetr = wa_out-somakbetr + wa_konv-kbetr. "Também posso fazer a soma aqui
      ENDIF.
      wa_out-kbetrs = wa_out-kbetr1 + wa_out-kbetr2 + wa_out-kbetr3 + wa_out-kbetr4.  "Soma
    ENDLOOP.


    READ TABLE t_bkpf INTO wa_bkpf WITH KEY belnr = wa_vbrk-vbeln
                                            bukrs = wa_vbrk-bukrs.

    IF sy-subrc IS INITIAL.
      wa_out-bldat = wa_bkpf-bldat.
      wa_out-blart = wa_bkpf-blart.

      IF sy-subrc IS INITIAL.

        READ TABLE t_t003t INTO wa_t003t WITH KEY blart = wa_bkpf-blart
                                                  spras = 'P'.

        IF sy-subrc IS INITIAL.
          wa_out-ltext = wa_t003t-ltext.
        ENDIF.

      ENDIF.

    ENDIF.

    APPEND wa_out TO t_out.
    CLEAR: wa_out,
           wa_bkpf,
           wa_bseg,
           wa_j_1bnflin,
           wa_j_1bnfdoc,
           wa_konv,
           wa_t003t,
           wa_vbrk.

  ENDLOOP.

ENDFORM.
