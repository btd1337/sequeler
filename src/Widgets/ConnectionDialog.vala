/*
* Copyright (c) 2011-2018 Alecaddd (http://alecaddd.com)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Alessandro "Alecaddd" Castellani <castellani.ale@gmail.com>
*/

public class Sequeler.Widgets.ConnectionDialog : Gtk.Dialog {
    public weak Sequeler.Window window { get; construct; }

    public Sequeler.Partials.ButtonClass test_button;
    public Sequeler.Partials.ButtonClass connect_button;

    private Gtk.Label header_title;
    private Gtk.ColorButton color_picker;

    private Sequeler.Partials.Entry title_entry;
    private Gee.HashMap<int, string> db_types;
    private Gtk.ComboBox db_type_entry;

    private Gtk.Spinner spinner;
    private Sequeler.Partials.ResponseMessage response_msg;

    enum Column {
        DBTYPE
    }

    public ConnectionDialog (Sequeler.Window? parent) {
        Object (
            border_width: 5,
            deletable: false,
            resizable: false,
            title: _("Connection"),
            transient_for: parent,
            window: parent
        );
    }

    construct {
        build_content ();
        build_actions ();
        populate_data ();

        response.connect (on_response);
    }

    private void build_content () {
        var body = get_content_area ();

        db_types = new Gee.HashMap<int, string> ();
        db_types.set (0,"MySQL");
        db_types.set (1,"MariaDB");
        db_types.set (2,"PostgreSQL");
        db_types.set (3,"SQLite");

        var header_grid = new Gtk.Grid ();
        header_grid.margin_start = 5;
        header_grid.margin_end = 5;
        header_grid.margin_bottom = 20;

        var image = new Gtk.Image.from_icon_name ("drive-multidisk", Gtk.IconSize.DIALOG);
        image.margin_end = 10;

        header_title = new Gtk.Label (_("New Connection"));
        header_title.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        header_title.halign = Gtk.Align.START;
        header_title.margin_end = 10;
        header_title.set_line_wrap (true);
        header_title.hexpand = true;

        color_picker = new Gtk.ColorButton.with_rgba ({ 222, 222, 222, 255 });
        color_picker.set_use_alpha (true);
        color_picker.get_style_context ().add_class ("color-picker");
        color_picker.can_focus = false;

        header_grid.attach (image, 0, 0, 1, 2);
        header_grid.attach (header_title, 1, 0, 1, 2);
        header_grid.attach (color_picker, 2, 0, 1, 1);

        body.add (header_grid);

        var form_grid = new Gtk.Grid ();
        form_grid.margin = 5;
        form_grid.row_spacing = 10;
        form_grid.column_spacing = 20;

        var title_label = new Gtk.Label (_("Connection Name:"));
        title_entry = new Sequeler.Partials.Entry (_("Connection's name"), title);
        title_entry.changed.connect (() => {
            header_title.label = title_entry.text;
        });
        form_grid.attach (title_label, 0, 0, 1, 1);
        form_grid.attach (title_entry, 1, 0, 1, 1);

        var db_type_label = new Gtk.Label (_("Database Type:"));
        var list_store = new Gtk.ListStore (1, typeof (string));
        
        for (int i = 0; i < db_types.size; i++){
            Gtk.TreeIter iter;
            list_store.append (out iter);
            list_store.set (iter, Column.DBTYPE, db_types[i]);
        }

        db_type_entry = new Gtk.ComboBox.with_model (list_store);
        var cell = new Gtk.CellRendererText ();
        db_type_entry.pack_start (cell, false);

        db_type_entry.set_attributes (cell, "text", Column.DBTYPE);
        db_type_entry.set_active (0);
        db_type_entry.changed.connect (() => { 
            db_type_changed ();
        });

        form_grid.attach (db_type_label, 0, 1, 1, 1);
        form_grid.attach (db_type_entry, 1, 1, 1, 1);

        body.add (form_grid);

        spinner = new Gtk.Spinner ();
        response_msg = new Sequeler.Partials.ResponseMessage ();

        body.add (spinner);
        body.add (response_msg);
    }

    private void build_actions () {
        var cancel_button = new Sequeler.Partials.ButtonClass (_("Close"), null);
        var save_button = new Sequeler.Partials.ButtonClass (_("Save Connection"), null);

        test_button = new Sequeler.Partials.ButtonClass (_("Test Connection"), null);
        test_button.sensitive = false;

        connect_button = new Sequeler.Partials.ButtonClass (_("Connect"), "suggested-action");
        connect_button.sensitive = false;

        add_action_widget (test_button, 1);
        add_action_widget (save_button, 2);
        add_action_widget (cancel_button, 3);
        add_action_widget (connect_button, 4);
    }

    private void populate_data () {
        if (window.data_manager.data == null || window.data_manager.data.size == 0) {
            return;
        }
    }

    private void db_type_changed () {

    }

    private void on_response (Gtk.Dialog source, int response_id) {
        switch (response_id) {
            case 1:
                //  test_connection ();
                break;
            case 2:
                //  save_data (true);
                break;
            case 3:
                destroy ();
                break;
            case 4:              
                //  init_connection ();
                break;
        }
    }

    public void toggle_spinner (bool type) {
        if (type == true) {
            spinner.start ();
            return;
        }

        spinner.stop ();
    }

    public void write_response (string? response_text) {
        response_msg.label = response_text;
    }
}