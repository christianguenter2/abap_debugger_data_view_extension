CLASS zcl_debug_data_view_struc_enh DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS show_popup_w_content
      IMPORTING
        !it_struc_data TYPE tpda_struc_view_it
        !iv_struc_name TYPE string .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-METHODS prepare_output
      IMPORTING
        !it_struc_data     TYPE tpda_struc_view_it
        !iv_wrap_from_here TYPE i OPTIONAL
        !iv_struc_name     TYPE string
      RETURNING
        VALUE(rv_content)  TYPE string .
ENDCLASS.



CLASS ZCL_DEBUG_DATA_VIEW_STRUC_ENH IMPLEMENTATION.


  METHOD prepare_output.
    FIELD-SYMBOLS: <s_tab_line> TYPE tpda_struc_view.
    DATA: lv_string_main    TYPE string,
          lv_string_line    TYPE string,
          lv_wrap_from_here TYPE i VALUE 255.

    DATA(lv_wrap_from_text) = |{ 'add line wrap on character number:'(001) }|.
    IF iv_wrap_from_here IS NOT SUPPLIED.
      cl_demo_input=>request( EXPORTING text  = lv_wrap_from_text
                              CHANGING  field = lv_wrap_from_here ).
    ELSE.
      lv_wrap_from_here = iv_wrap_from_here.
    ENDIF.

    rv_content = |{ iv_struc_name } = VALUE #( |.
    LOOP AT it_struc_data ASSIGNING <s_tab_line>.
      "* print columns
      CHECK <s_tab_line>-varvalue IS NOT INITIAL AND
            <s_tab_line>-component NE |INDEX|.
      DATA(lv_dummy) = |{ lv_string_line } { <s_tab_line>-component } = '{ <s_tab_line>-varvalue }'|.
      DATA(lv_dummy_length) =  strlen( lv_dummy ).
      IF lv_dummy_length > lv_wrap_from_here.
        "* neue Spalte-Wert Kombi passt nicht mehr rein und muss umgebrochen werden
        rv_content = |{ rv_content }  { lv_string_line }\r|. "* umruch bei zu langer Zeile
        CLEAR: lv_string_line.
      ENDIF.
      lv_string_line = |{ lv_string_line } { <s_tab_line>-component } = '{ <s_tab_line>-varvalue }'\t|.

      IF lv_string_line NE space.
        rv_content = |{ rv_content }  { lv_string_line }|.
      ENDIF.
      CLEAR: lv_string_line.
    ENDLOOP.

    rv_content = |{ rv_content } ).|.
  ENDMETHOD.


  METHOD show_popup_w_content.
    DATA: lv_string_main TYPE string.
    lv_string_main  = prepare_output( iv_struc_name = iv_struc_name
                                      it_struc_data = it_struc_data ).

   cl_demo_output=>set_mode( cl_demo_output=>text_mode ). "set to text mode to be more compatible with minus signs and so on
   cl_demo_output=>display( lv_string_main ).
  ENDMETHOD.
ENDCLASS.
