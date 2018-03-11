<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<t:html>
    <t:head>
        <title>OCR4All - Project Overview</title>

        <!-- jQuery DataTables -->
        <link rel="stylesheet" type="text/css" href="resources/css/datatables.min.css">
        <script type="text/javascript" charset="utf8" src="resources/js/datatables.min.js"></script>

        <script type="text/javascript">
            $(document).ready(function() {
                function datatable(){
                    // Allow reinitializing DataTable with new data
                    if( $.fn.DataTable.isDataTable("#overviewTable") ) {
                        $('#overviewTable').DataTable().clear().destroy();
                    }

                    var overviewTable = $('#overviewTable').DataTable( {
                        ajax : {
                            "type"   : "GET",
                            "url"    : "ajax/overview/list?"
                                           + "projectDir=" + encodeURIComponent($('#projectDir').val())
                                           + "&imageType=" + encodeURIComponent($('#imageType').val()),
                            "dataSrc": function (data) { return data; },
                            "error"  : function() {
                                if( !$('.collapsible').find('li').eq(0).hasClass('active') )
                                    $('.collapsible').collapsible('open', 0);
                                $('#projectDir').addClass('invalid');
                            }
                        },
                        columns: [
                            { title: "Page Identifier", data: "pageId" },
                            { title: "Preprocessing", data: "preprocessed" },
                            { title: "Noise Removal", data: "despeckled"},
                            { title: "Segmentation", data: "segmented" },
                            { title: "Region Extraction", data: "segmentsExtracted" },
                            { title: "Line Segmentation", data: "linesExtracted" },
                            { title: "Recognition", data: "recognition" },
                        ],
                        createdRow: function( row, data, index ){
                            $('td:first-child', row).html('<a href="pageOverview?pageId=' + data.pageId + '">' + data.pageId + '</a>');
                            $.each( $('td:not(:first-child)', row), function( idx, td ) {
                                if( $(td).html() === 'true' ) {
                                    $(td).html('<i class="material-icons green-text">check</i>');
                                }
                                else {
                                    $(td).html('<i class="material-icons red-text">clear</i>');
                                }
                            });
                        },
                        initComplete: function() {
                            if( !$('.collapsible').find('li').eq(1).hasClass('active') )
                                $('.collapsible').collapsible('open', 1);

                            // Initialize select input
                            $('select').material_select();

                            // Update overview continuously
                            setInterval( function() {
                                overviewTable.ajax.reload(null, false);
                            }, 10000);
                        },
                    });
                }
                $("button").click(function() {
                    if( $.trim($('#projectDir').val()).length === 0 ) {
                        if( !$('.collapsible').find('li').eq(0).hasClass('active') )
                            $('.collapsible').collapsible('open', 0);
                        $('#projectDir').addClass('invalid').focus();
                    }
                    else {
                        $.get( "ajax/overview/check?", { "projectDir" : $('#projectDir').val(),
                                                         "imageType" : $('#imageType').val() } )
                        .done(function( data ) {
                            if( data === true)
                                datatable();
                            else{
                                $('#modal_choose').modal('open');
                            }
                        })
                    }
                });
                $('#agree').click(function() {
                    $.get( "ajax/overview/rename" )
                    .done(function( data ) {
                        datatable();
                      })
                });

                // Trigger overview table fetching on pageload
                if( $.trim($('#projectDir').val()).length !== 0 ) {
                    $("button").first().trigger( "click" );
                } else {
                    $('.collapsible').collapsible('open', 0);
                }
            });
        </script>
    </t:head>
    <t:body heading="Project Overview">
        <div class="container">
            <div class="section">
                <button class="btn waves-effect waves-light" type="submit" name="action">
                    Load Project
                    <i class="material-icons right">send</i>
                </button>

                <ul class="collapsible" data-collapsible="accordion">
                    <li>
                        <div class="collapsible-header"><i class="material-icons">settings</i>Settings</div>
                        <div class="collapsible-body">
                            <table class="compact">
                                <tbody>
                                    <tr>
                                        <td>
                                            <p>
                                                Project directory path
                                            </p>
                                        </td>
                                        <td>
                                            <div class="input-field">
                                                <i class="material-icons prefix">folder</i>
                                                <input id="projectDir" type="text" class="validate suffix" value="${projectDir}" />
                                                <label for="projectDir" data-error="Directory path is empty or could not be accessed on the filesystem"></label>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <p>Project image type</p>
                                        </td>
                                        <td>
                                            <div class="input-field col s3">
                                                <i class="material-icons prefix">image</i>
                                                <c:choose>
                                                    <c:when test='${imageType == "Gray"}'><c:set value='selected="selected"' var="graySel"></c:set></c:when>
                                                    <c:otherwise><c:set value='selected="selected"' var="binarySel"></c:set></c:otherwise>
                                                </c:choose>
                                                <select id="imageType" name="imageType" class="suffix">
                                                    <option value="Binary" ${binarySel}>Binary</option>
                                                    <option value="Gray" ${graySel}>Gray</option>
                                                </select>
                                                <label></label>
                                            </div>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </li>
                    <li>
                        <div class="collapsible-header"><i class="material-icons">dehaze</i>Overview</div>
                        <div class="collapsible-body">
                            <table id="overviewTable" class="display centered" width="100%"></table>
                        </div>
                    </li>
                </ul>

                <button class="btn waves-effect waves-light" type="submit" name="action">
                    Load Project
                    <i class="material-icons right">send</i>
                </button>
            </div>
        </div>
        <div id="modal_choose" class="modal">
            <div class="modal-content">
                <h4>Information</h4>
                    <p>
                      By agreeing, files will be renamed according to the project standard
                    </p>
            </div>
            <div class="modal-footer">
                <a href="#!" class="modal-action modal-close waves-effect waves-green btn-flat ">Disagree</a>
                <a href="#!" id='agree' class="modal-action modal-close waves-effect waves-green btn-flat">Agree</a>
            </div>
         </div>
    </t:body>
</t:html>
