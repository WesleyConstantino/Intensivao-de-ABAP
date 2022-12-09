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
         cor        TYPE ztewes_nomecor,
         modelo     TYPE ztrtwes002-modelo,
         datainicio TYPE ztrtwes004-datainicio,
         datafim    TYPE ztrtwes004-datafim,
         valor      TYPE ztrtwes004-valor,
       END OF ty_saida,

       BEGIN OF ty_download,
         linha(2000) TYPE c,
       END   OF ty_download.
*----------------------------------------------------------------------*
*                                Variáveis                             *
*----------------------------------------------------------------------*

DATA: vg_arqv     LIKE rlgrap-filename,  "File local para Upload ou Download
      vg_filename TYPE string.
*&---------------------------------------------------------------------*
*                        Tabelas Internas                              *
*&---------------------------------------------------------------------*
DATA: t_out      TYPE TABLE OF ty_saida,
      t_fieldcat TYPE slis_t_fieldcat_alv,
      t_download TYPE TABLE OF ty_download.

*&---------------------------------------------------------------------*
*                          Workareas                                   *
*&---------------------------------------------------------------------*
DATA: wa_out      LIKE LINE OF t_out,
      wa_layout   TYPE slis_layout_alv,
      wa_download TYPE ty_download.

DATA: ti_cor TYPE dd07v OCCURS 0 WITH HEADER LINE,
      wa_cor LIKE LINE OF ti_cor.
*&---------------------------------------------------------------------*
*                          Tela de seleção                             *
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-t01.
*Campos de entrada
"PARAMETERS:
SELECT-OPTIONS: p_codcli FOR ztrtwes004-codcli, "MODIF ID CLI, "Campo 1; MODIF ID modifica o nome desse campo; em vez de 001, agora ele se chama CLI
                p_data   FOR ztrtwes004-datainicio. "Campo 002
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-t02.

*Radio Buttons
PARAMETERS: rb_cli  RADIOBUTTON GROUP g1 DEFAULT 'X' USER-COMMAND uc1, "Gera evento no radio button
            rb_data RADIOBUTTON GROUP g1.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-t07.
PARAMETERS: rb_alv  RADIOBUTTON GROUP g2 DEFAULT 'X' USER-COMMAND cm1,
            rb_dwld RADIOBUTTON GROUP g2.

PARAMETERS: p_dwld LIKE rlgrap-filename.

SELECTION-SCREEN END OF BLOCK b3.

SELECTION-SCREEN END OF BLOCK b1.

*Para trazer o caminho do download
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_dwld.
  PERFORM zf_seleciona_diretorio.

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


  IF rb_alv = 'X'.
    PERFORM zf_exibe_alv_poo.
  ELSE.
    PERFORM zf_prepara_download.
  ENDIF.


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
    WHERE ztrtwes004~codcli IN p_codcli AND
          ztrtwes004~datainicio IN p_data.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE s398(00) WITH 'Não há registros!' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

  "PERFORM zf_trata_dados.

ENDFORM.

*&---------------------------------------------------------------------*
*                      FORM zf_trata_dados                            *
*&---------------------------------------------------------------------*
FORM zf_trata_dados.
  PERFORM zf_ajusta_cor.
  DATA: lv_sy_tabix TYPE sy-tabix.

  LOOP AT t_out INTO wa_out.
    lv_sy_tabix = sy-tabix.
    READ TABLE ti_cor INTO wa_cor WITH KEY valpos = wa_out-cor.
    wa_out-cor = wa_cor-ddtext.
    MODIFY t_out FROM wa_out INDEX lv_sy_tabix.
    CLEAR: wa_cor,
           wa_out.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*                      FORM zf_esconde_campo_cliente                            *
*&---------------------------------------------------------------------*
FORM zf_esconde_campo_cliente .

  LOOP AT SCREEN.
    IF screen-group4 = '001'. "screen-group4 ='001'. "Campo CLI é o campo de Cliente da tela de seleção
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
*&      Form  ZF_ajusta_cor
*&---------------------------------------------------------------------*
FORM zf_ajusta_cor.
  CALL FUNCTION 'GET_DOMAIN_VALUES'
    EXPORTING
      domname         = 'ZTDWES_COR'
    TABLES
      values_tab      = ti_cor
    EXCEPTIONS
      no_values_found = 1
      OTHERS          = 2.


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

  p_dwld = path_str.

ENDFORM.

FORM zf_prepara_download.
  DATA: vl_cor(3)    TYPE c, "Crio variáveis do tipo string para receber dados numéricos
        vl_valor(12) TYPE c.

  LOOP AT t_out INTO wa_out.
    vl_cor = wa_out-cor.  "As variáveis que eram numéricas se tornam strings
    vl_valor = wa_out-valor.

    CONCATENATE wa_out-codalu "Concatenate só aceita strings
                wa_out-codcli
                wa_out-nomecli
                wa_out-cpfcli
                wa_out-chassi
                wa_out-placa
                vl_cor
                wa_out-modelo
                wa_out-datainicio
                wa_out-datafim
                vl_valor
                INTO  wa_download-linha SEPARATED BY ';'.

    APPEND wa_download TO t_download.
    CLEAR  wa_download.

  ENDLOOP.

  IF NOT t_download[] IS INITIAL.
    PERFORM zf_seleciona_diretorio_saida.
  ELSE.
    MESSAGE e398(00) WITH text-009.
  ENDIF.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  zf_seleciona_diretorio_saida
*&---------------------------------------------------------------------*
FORM zf_seleciona_diretorio_saida.

  CONCATENATE p_dwld '\' 'Tabela ' '.csv' INTO  vg_filename.

*Chamando a função de download, passando a minha tabela tratada e o nome do arquivo.
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = vg_filename
      filetype                = 'ASC'
    TABLES
      data_tab                = t_download
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
