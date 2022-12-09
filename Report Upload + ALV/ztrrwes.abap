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

DATA: vg_arqv     LIKE rlgrap-filename,  "File local para Upload ou Download
      vg_filename TYPE string,
      vg_mode(1)  TYPE c.

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
      gt_cli     TYPE TABLE OF ty_saida, "ztrtwes001,
      gt_bdcdata TYPE TABLE OF bdcdata, "Tabela de Batch input. Irá receber o nome do meu programa Module Pool, número da tela...
      gt_msg     TYPE TABLE OF bdcmsgcoll, "Tabela para Agrupar mensagens no sistema SAP
      gt_imp     TYPE TABLE OF ty_imp. "Tabela para exibir ALV

*&---------------------------------------------------------------------*
*                              WORK AREAS                              *
*&---------------------------------------------------------------------*

DATA: "w_cli     TYPE ztrtwes001,
  w_cli     TYPE ty_saida,
  w_arq     TYPE ty_arq,
  w_bdcdata TYPE bdcdata,
  w_imp     TYPE ty_imp,
  w_msg     TYPE bdcmsgcoll.

*&---------------------------------------------------------------------*
*                   Tabelas Internas do ALV                            *
*&---------------------------------------------------------------------*
DATA: t_out      TYPE TABLE OF ty_saida,
      t_fieldcat TYPE slis_t_fieldcat_alv.

*&---------------------------------------------------------------------*
*                       Workareas do ALV                               *
*&---------------------------------------------------------------------*
DATA: wa_out    LIKE LINE  OF t_out,
      wa_layout TYPE slis_layout_alv.


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
           zf_monta_shdb,
           zf_show_alv.

*&---------------------------------------------------------------------*
*&      Form  ZF_SELECIONA_ARQUIVO
*&---------------------------------------------------------------------*

FORM zf_seleciona_arquivo  USING    p_arqv. "Seleciona o arquivo usando o parametro de entrada da tela de seleção

  CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
    EXPORTING
      mask          = 'Text Files (*.TXT;*.CSV;*.XLSX)|*.TXT;*.CSV;*.XLSX|'  "Tipos de arquivo que desejo que carrege
      fileoperation = 'R'
    CHANGING
      file_name     = vg_arqv "vg_arqv é a File local para Upload ou Download
    EXCEPTIONS
      mask_too_long = 1
      OTHERS        = 2.
  IF sy-subrc IS INITIAL.
    p_arqv = vg_arqv. "Passo meu parametro de entrada para a File local para Upload ou Download
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
      filename                = vg_filename  "Passa o nome do meu arquivo. Igual o inputado na tela de seleçao
      filetype                = 'ASC'  "Tipo de arquivo. ASC por padão
    TABLES
      data_tab                = gt_arq  "Tabela interna que recebe o arquivo .TXT, antes de fazer o split e tratamento
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


  LOOP AT gt_cli INTO w_cli. "gt_cli é do tipo a minha tabela de clientes; ztrtwes001

    CLEAR: gt_bdcdata, "Tabela de Batch input.
           gt_msg.     "Tabela interna de mensagens

    PERFORM zf_monta_bdc USING: 'X'  'SAPMZTRMPWES001'      '9000',
                                ' '  'BDC_OKCODE'         '=CAD_CLIENTES'.

    PERFORM zf_monta_bdc USING: 'X'  'SAPMZTRMPWES001'      '9001',
                                ' '  'WA_CLIENTES-NOMECLI'   w_cli-nomecli,
                                ' '  'WA_CLIENTES-RGCLI'     w_cli-rgcli,
                                ' '  'WA_CLIENTES-CPFCLI'    w_cli-cepcli,
                                ' '  'WA_CLIENTES-DATANASC'  w_cli-datanasc,
                                ' '  'WA_CLIENTES-RUACLI'    w_cli-ruacli,
                                ' '  'WA_CLIENTES-BAIRROCLI' w_cli-bairrocli,
                                ' '  'WA_CLIENTES-CIDADECLI' w_cli-cidadecli,
                                ' '  'WA_CLIENTES-CEPCLI'    w_cli-cepcli,
                                ' '  'WA_CLIENTES-SEXCLI'    w_cli-sexcli,
                                ' '  'BDC_OKCODE'         '=GRAVAR'.

    PERFORM zf_monta_bdc USING: 'X'  'SAPMZTRMPWES001'      '9001',
                                ' '  'BDC_OKCODE'         '=BACK'.

    PERFORM zf_monta_bdc USING: 'X'  'SAPMZTRMPWES001'      '9000',
                                ' '  'BDC_OKCODE'         '=BACK'.

    CALL TRANSACTION 'ZTRMWES003' USING gt_bdcdata
                                MODE  vg_mode
                                MESSAGES INTO gt_msg.

*Populando tabela do ALV
    READ TABLE gt_msg INTO w_msg WITH KEY msgtyp = 'S'. "Se a mensagem tiver codigo "S" de sucesso
    IF sy-subrc = 0.
      w_imp-numreg = w_cli-rgcli.
      w_imp-msg    = w_msg-msgv1. "Traz a mensagem de sucesso do meu programa do module pool
      w_imp-icon   = icon_led_green. "Traz o icone da mensagem
    ELSE.
      w_imp-numreg = w_cli-rgcli.
      w_imp-msg    = 'Não foi possível realizar a operação!'.
      w_imp-icon   = icon_led_red.
    ENDIF.

    APPEND w_imp TO gt_imp. "gt_imp é a tabela que passo para o meu perform ZF_SHOW_ALV

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
    w_bdcdata-program  = vl_name.  "vl_name recebe os nomes passados no imput
    w_bdcdata-dynpro   = vl_value. "Recebe o número da tela
  ELSE.
    w_bdcdata-fnam  = vl_name.
    w_bdcdata-fval  = vl_value.
  ENDIF.

  APPEND w_bdcdata TO gt_bdcdata.
  CLEAR  w_bdcdata.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ZF_SHOW_ALV
*&---------------------------------------------------------------------*
FORM zf_show_alv .

DATA: lo_table  TYPE REF TO cl_salv_table,  "Acessar a classe "cl_salv_table"
        lo_header TYPE REF TO cl_salv_form_layout_grid.   "Para criação do header

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = lo_table "Tabela local
                             CHANGING t_table = gt_imp ).       "t_table recele a tabela que desejo exibir

      lo_table->get_functions( )->set_all( abap_true ). "Ativar met codes


      CREATE OBJECT lo_header. "É necessário que criemos o objeto header

      lo_header->create_header_information( row = 1 column = 1 text = 'Dados do Cliente:' ). "Texto grande do header
      lo_header->add_row( ).


      lo_table->get_display_settings( )->set_striped_pattern( abap_true ).

      lo_table->set_top_of_list( lo_header ).

      lo_table->display( ) . "O dispay é fundamental para a exibição do ALV

    CATCH cx_salv_msg
          cx_root.

      MESSAGE s398(00) WITH 'Erro ao exibir tabela' DISPLAY LIKE 'E'.

  ENDTRY.

ENDFORM.
