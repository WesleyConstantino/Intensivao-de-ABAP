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
REPORT ztrrwes002.

*&---------------------------------------------------------------------*
*                                TABLES                                *
*&---------------------------------------------------------------------*
TABLES: mara.

*&---------------------------------------------------------------------*
*                             CONSTANTS                                *
*&---------------------------------------------------------------------*
CONSTANTS : c_x TYPE c VALUE 'X'.

*&---------------------------------------------------------------------*
*                  t_out, t_fieldcat e wa_out                          *
*&---------------------------------------------------------------------*
*****************************ALV***************************************
"t_out e wa_out
DATA: t_out      TYPE TABLE OF ztrewes001,
      wa_out     LIKE LINE  OF t_out,
      t_fieldcat TYPE slis_t_fieldcat_alv.

DATA: wa_layout   TYPE slis_layout_alv.       "Work Area responsável pelo layout

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

*&---------------------------------------------------------------------*
*                         o---> FORMS <---o                            *
*               Local destinado para criação de Forms                  *
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*      Form  ZF_SELECIONA_DADOS
*----------------------------------------------------------------------*
*       Form para seleção de dados do report
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
    PERFORM zf_display_alv.
  ENDIF.

ENDFORM.


*---------------------------------------------------------------------*
*      Form  ZF_IMPRIMI_DADOS
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
*&                      Form  ZF_DISPLAY_ALV
*&---------------------------------------------------------------------*
*                           Imprime ALV
*----------------------------------------------------------------------*
FORM zf_display_alv .




  PERFORM zf_build_fieldcat USING:  "Todos os campos abaixo são passados para as variáveis de "zf_build_fieldcat" em ordem horizontal
 "Ordem:   1     2        3       4       5        6               7
          '1' 'matnr'   't_out' 'MAKT' 'matnr' 'Matrícula'        'X',
          '2' 'maktx'   't_out' 'MAKT' 'maktx' 'Descrição'        '' ,
          '3' 'ernam'   't_out' 'MARA' 'ernam' 'Responsável'      '' ,
          '4' 'ersda'   't_out' 'MARA' 'ersda' 'Data de Criação'  '' .

  wa_layout-window_titlebar = 'Dados de Materiais'.   " Insere um Titulo na ALV
  wa_layout-colwidth_optimize = abap_true.            " Auto Ajuste das Colunas
  wa_layout-zebra             = abap_true.            " Layout Zebrado (Cor Sim e Cor Não)


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'  "Função que gera nosso ALV
    EXPORTING
      it_fieldcat        = t_fieldcat    "Passamos nosso t_fieldcat
      i_callback_program = sy-repid
      is_layout          = wa_layout     "Nossa Work area responsável pelo layout
    TABLES
      t_outtab           = t_out " Tabela Interna.
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  ZF_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
FORM zf_build_fieldcat USING  VALUE(p_col_pos)     TYPE c  "1    "Recebe os parâmetros passados do "zf_display_alv", aqui em ordem vertical
                              VALUE(p_fieldname)   TYPE c  "2
                              VALUE(p_tabname)     TYPE c  "3
                              VALUE(p_ref_tabname) TYPE c  "4
                              VALUE(p_ref_field)   TYPE c  "5
                              VALUE(p_seltext_m)   TYPE c  "6
                              VALUE(p_key)         TYPE c. "7

  DATA: wa_fieldcat LIKE LINE OF t_fieldcat[]. " Criação da Workarea do fieldcat.

* Parâmetros Para Configuração da ALV.
  CLEAR: wa_fieldcat.
  wa_fieldcat-col_pos       = p_col_pos.
  wa_fieldcat-fieldname     = p_fieldname.
  wa_fieldcat-tabname       = p_tabname.
  wa_fieldcat-ref_fieldname = p_ref_field.
  wa_fieldcat-ref_tabname   = p_ref_tabname.
  wa_fieldcat-seltext_m     = p_seltext_m.
  wa_fieldcat-key           = p_key.
  APPEND wa_fieldcat TO t_fieldcat[].

ENDFORM.
