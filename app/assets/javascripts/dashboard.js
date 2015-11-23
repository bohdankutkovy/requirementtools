$(function() {

    draw_tree();
    get_page_content();


    function get_page_content(){
        var project_id = $("#project_select_id option:selected").val();
        load_page("/projects/" + project_id);
    }

    function load_page(path){
        $.get( path, function(data){
            $('#myFrame').html(data);
            $('#version_table').hide();

        });
    }

    function delete_page(path){
        $.ajax({
            type: "POST",
            url:  (path + '/clear'),
            success: function(data) {
                load_page(data.page);
                draw_tree();
            }
        });
        return false;
    }

    function create_page(valuesToSubmit, url_action){
        $.ajax({
            type: "POST",
            url: url_action,
            data: valuesToSubmit,
            dataType: "JSON",
            processData: false,
            contentType: false,
            success: function(data){
                load_page(data.page);
                draw_tree();
            },
            error: function (xhr, status, error) {
                var lines = xhr.responseText.split("\n");
                alert(lines[2]);
            }
        });
    }

    function version_update_page(path){
        $.ajax({
            type: "POST",
            url:  path,
            success: function(data) {
                load_page(data.page);
                draw_tree();
            }
        });
        return false;
    }

    function draw_tree(){
        var selected_project = $("#project_select_id option:selected").val();
        $.ajax('requirements', {
            type: 'GET',
            dataType: 'json',
            data: {
                project_id: selected_project
            },
            success: function(data){
                project_id = $("#project_select_id option:selected").val();
                if($.isNumeric(project_id)){
                    $("#project_assign").attr("href", "/assignments/"+project_id);
                }
                else{
                    $("#project_select_modal option:selected").removeAttr("selected");
                    $('#project_modal').modal('show');
                    $("#project_assign").removeAttr("href");
                }
                buildRequirementsTree(data["requirements"]);
            }
        });
    }



    $(document).on('change', '#project_select_id', function(evt) {
        draw_tree();
        get_page_content();
    });

    $(document).on('change', '#project_select_modal', function(evt){

        $('#project_modal').modal('hide');
        $('body').removeClass('modal-open');
        $('.modal-backdrop').remove();

        $('#project_select_id').val( $('#project_select_modal option:selected').val() ).trigger('change');

    });

    $(document).on('click', '.frame-link', function(event){
        event.preventDefault();
        load_page($(this).attr('href'));
    });

    $(document).on('click', '.delete-frame-link', function(event){
        event.preventDefault();
        delete_page( $(this).attr('href') );
    });

    $(document).on('click', '.create-frame-link', function(event){
        event.preventDefault();
        create_page( $(this).attr('href') );
    });

    $(document).on('click', '.version-frame-link', function(event){
        event.preventDefault();
        version_update_page( $(this).attr('href') );
    });


    $(document).on('submit', 'form.new_assignment', function(event){
        event.preventDefault();
        create_page( new FormData($(this)[0]), $(this).attr('action') );
    });

    $(document).on('submit', 'form.edit_assignment', function(event){
        event.preventDefault();
        create_page( new FormData($(this)[0]), $(this).attr('action') );
    });

    $(document).on('submit', 'form.new_requirement', function(event){
        event.preventDefault();
        create_page( new FormData($(this)[0]), $(this).attr('action') );
        draw_tree();
    });

    $(document).on('submit', 'form.edit_requirement', function(event){
        event.preventDefault();
        create_page( new FormData($(this)[0]), $(this).attr('action') );
        draw_tree();
    });

    $(document).on('submit', 'form.new_attachment', function(event){
        event.preventDefault();

        $('#myModal').modal('hide');
        $('body').removeClass('modal-open');
        $('.modal-backdrop').remove();

        create_page( new FormData($(this)[0]), $(this).attr('action') );
    });

    $( document ).ready(function() {
        if ( !($.isNumeric($('#project_select_id option:selected').val())))
        {
            $("#project_select_modal option:selected").removeAttr("selected");
            $('#project_modal').modal('show');
            $('#project_assign').hide();
            $('.tree_block').hide();
        }else
        {
            $('#project_assign').show();
            $('.tree_block').show("slow");
        }
    });

    $(document).on('change', '#project_select_id', function(evt) {
        if ( !($.isNumeric($('#project_select_id option:selected').val())))
        {
            $("#project_select_modal option:selected").removeAttr("selected");
            $('#project_modal').modal('show');
            $('#project_assign').hide();
            $('.tree_block').hide("slow");
        }else
        {
            $('#project_assign').show();
            $('.tree_block').show("slow");
        }
    });

    $(document).on('click', '.fileupload', function(event){
        event.preventDefault();
        $('form.edit_requirement').submit();
    });

    $(document).on('click', '#version_toggler', function(event){
        event.preventDefault();
        $("#version_table").toggle();
    });

});

