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
REPORT ztrrwes.

*----------------------------------------------------------------------*
*                                Variáveis                             *
*----------------------------------------------------------------------*

DATA: vg_arqv     LIKE rlgrap-filename,
      vg_filename TYPE string,
      vg_mode(1)  TYPE c.

*&---------------------------------------------------------------------*
*                                 Includes                             *
*&---------------------------------------------------------------------*

INCLUDE <icon>.

*&---------------------------------------------------------------------*
*                                 TYPES                                *
*&---------------------------------------------------------------------*
TYPES: BEGIN OF ty_saida,
         "codcli    TYPE ztrtwes001-codcli,
         nomecli   TYPE ztrtwes001-nomecli,
         rgcli     TYPE ztrtwes001-rgcli,
         cpfcli    TYPE ztrtwes001-cpfcli,
         datanasc  TYPE ztrtwes001-datanasc,
         ruacli    TYPE ztrtwes001-ruacli,
         bairrocli TYPE ztrtwes001-bairrocli,
         cidadecli TYPE ztrtwes001-cidadecli,
         cepcli    TYPE ztrtwes001-cepcli,
         sexcli    TYPE ztrtwes001-sexcli,
       END OF ty_saida,

       BEGIN OF ty_arq, "Recebe todo o arquivo .txt em uma única linha
         linha(2000) TYPE c,
       END   OF ty_arq,

       BEGIN OF ty_imp,
         icon(4)  TYPE c,
         numreg   TYPE ztrtwes001-rgcli,
         msg(100) TYPE c,
       END   OF ty_imp.

*&---------------------------------------------------------------------*
*                          Tabelas Internas                            *
*&---------------------------------------------------------------------*

DATA: gt_arq     TYPE TABLE OF ty_arq, "Tabela interna para receber o arquivo .txt
      gt_cli     TYPE TABLE OF ztrtwes001,
      gt_bdcdata TYPE TABLE OF bdcdata,
      gt_msg     TYPE TABLE OF bdcmsgcoll,
      gt_imp     TYPE TABLE OF ty_imp.

*&---------------------------------------------------------------------*
*                              WORK AREAS                              *
*&---------------------------------------------------------------------*

DATA: "w_cli     TYPE ztrtwes001,
      w_cli     TYPE ty_saida,
      w_arq     TYPE ty_arq,
      w_bdcdata TYPE bdcdata,
      w_imp     TYPE ty_imp,
      w_msg     TYPE bdcmsgcoll.


*----------------------------------------------------------------------*
*                               PARAMETER                            *
*----------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-000.

PARAMETERS: p_arqv LIKE rlgrap-filename.

SELECTION-SCREEN END OF BLOCK b1.


*----------------------------------------------------------------------*
*                         SELECTION-SCREEN                             *
*----------------------------------------------------------------------*

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_arqv. "Evento no PARAMETER

  PERFORM zf_seleciona_arquivo USING p_arqv.

************************************************************************
*Começo da Lógica do programa
************************************************************************
START-OF-SELECTION.

  PERFORM: zf_carrega_dados,
           zf_trata_dados,
           zf_monta_shdb.
  "zf_show_alv.

*&---------------------------------------------------------------------*
*&      Form  ZF_SELECIONA_ARQUIVO
*&---------------------------------------------------------------------*

FORM zf_seleciona_arquivo  USING    p_arqv.

  CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
    EXPORTING
      mask          = '*.txt,.'  "Tipo de arquivo que desejo que carrege
      fileoperation = 'R'
    CHANGING
      file_name     = vg_arqv
    EXCEPTIONS
      mask_too_long = 1
      OTHERS        = 2.
  IF sy-subrc IS INITIAL.
    p_arqv = vg_arqv.
  ENDIF.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ZF_CARREGA_DADOS
*&---------------------------------------------------------------------*
FORM zf_carrega_dados .

*  Função para o upload do arquivo .txt.
  vg_filename = p_arqv.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = vg_filename
      filetype                = 'ASC'  "Tipo de arquivo. ASC por padão
    TABLES
      data_tab                = gt_arq
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.
  IF sy-subrc <> 0.
    MESSAGE s398(00) WITH text-001 DISPLAY LIKE 'E'.
    STOP.
  ENDIF.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ZF_TRATA_DADO
*&---------------------------------------------------------------------*
FORM zf_trata_dados.

  "Populando a tabela.
  IF gt_arq[] IS NOT INITIAL. "Tabela interna que receberá o arquivo .txt - Se estiver vazia...
    LOOP AT gt_arq INTO w_arq. "Fazemos um loop para a workarea...
      SPLIT w_arq-linha AT ';' INTO "w_cli-codcli      "Fazemos um SPLIT na w_arq-linha para separar o conteúdo do txt por ';' ...
                                    w_cli-nomecli   "Jogamos os campos separados no ';' ordenadamente para a workarea da tabela de saída
                                    w_cli-rgcli     "É indispensável que o .txt esteja na mesma ordem que estes campos
                                    w_cli-cpfcli
                                    w_cli-datanasc
                                    w_cli-ruacli
                                    w_cli-bairrocli
                                    w_cli-cidadecli
                                    w_cli-cepcli
                                    w_cli-sexcli.
      APPEND w_cli TO gt_cli.
      CLEAR  w_cli.
    ENDLOOP.

    "  IF gt_cli IS NOT INITIAL. "ty_saida
    "   MODIFY  ztrtwes001 FROM TABLE gt_cli.
    "  ENDIF.

  ELSE.
    MESSAGE s398(00) WITH text-002 DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ZF_MONTA_SHDB
*&---------------------------------------------------------------------*
FORM zf_monta_shdb .

*Populando a tabela bdcdata para fazer o input dos dados.
  vg_mode = 'N'.


  LOOP AT gt_cli INTO w_cli.

    CLEAR: gt_bdcdata,
           gt_msg.

    PERFORM zf_monta_bdc USING: 'X'  'SAPMZTRMPWES001'      '9000',
                                ' '  'BDC_OKCODE'         '=CAD_CLIENTES'.

    PERFORM zf_monta_bdc USING: 'X'  'SAPMZTRMPWES001'      '9001',
                                ' '  'WA_CLIENTES-NOMECLI'  w_cli-nomecli,
                                ' '  'WA_CLIENTES-RGCLI'  w_cli-rgcli,
                                ' '  'WA_CLIENTES-CPFCLI'   w_cli-cepcli,
                                ' '  'WA_CLIENTES-DATANASC'  w_cli-datanasc,
                                ' '  'WA_CLIENTES-RUACLI'  w_cli-ruacli,
                                ' '  'WA_CLIENTES-BAIRROCLI'   w_cli-bairrocli,
                                ' '  'WA_CLIENTES-CIDADECLI'  w_cli-cidadecli,
                                ' '  'WA_CLIENTES-CEPCLI' w_cli-cepcli,
                                ' '  'WA_CLIENTES-SEXCLI'   w_cli-sexcli,
                                ' '  'BDC_OKCODE'         '=GRAVAR'.

    PERFORM zf_monta_bdc USING: 'X'  'SAPMZTRMPWES001'      '9001',
                                ' '  'BDC_OKCODE'         '=BACK'.

    PERFORM zf_monta_bdc USING: 'X'  'SAPMZTRMPWES001'      '9000',
                                ' '  'BDC_OKCODE'         '=BACK'.

    CALL TRANSACTION 'ZTRMWES003' USING gt_bdcdata
                                MODE  vg_mode
                                MESSAGES INTO gt_msg.

*Populando a tabela de impressão do ALV
    READ TABLE gt_msg INTO w_msg WITH KEY msgtyp = 'S'.
    IF sy-subrc = 0.
      w_imp-numreg = w_cli-rgcli.
      w_imp-msg    = w_msg-msgv1.
      w_imp-icon   = icon_led_green.
    ELSE.
      w_imp-numreg = w_cli-rgcli.
      w_imp-msg    = w_msg-msgv1.
      w_imp-icon   = icon_led_red.
    ENDIF.

    APPEND w_imp TO gt_imp.

    CLEAR w_imp.


  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ZF_MONTA_BDC
*&---------------------------------------------------------------------*
FORM zf_monta_bdc  USING    vl_dynbegin vl_name vl_value.

*Lógica de quando atribuir os dados, dependendo se é tela ou não.
  IF vl_dynbegin EQ 'X'.
    w_bdcdata-dynbegin = vl_dynbegin.
    w_bdcdata-program  = vl_name.
    w_bdcdata-dynpro   = vl_value.
  ELSE.
    w_bdcdata-fnam  = vl_name.
    w_bdcdata-fval  = vl_value.
  ENDIF.

  APPEND w_bdcdata TO gt_bdcdata.
  CLEAR  w_bdcdata.

ENDFORM.
