module Cms
  module SourceManagerHelper

    # Escaped JavaScript there:
    def open_in_editor sourceObj
      #p sourceObj.class
      editor_name = sourceObj.get_id.to_s
      editor_name = "haml_editor" if (sourceObj.type == Cms::SourceType::LAYOUT)
      editor_name = "haml_editor" if (sourceObj.type == Cms::SourceType::HIDDEN_LAYOUT)
      editor_name = "haml_editor" if (sourceObj.type == Cms::SourceType::CONTENT)
      editor_name = "css_editor" if (sourceObj.type == Cms::SourceType::CSS)
      "
      editorManager.getEditor('#{ editor_name }').setSourceWithSeparator('#{ sourceObj.get_id }', '#{ sourceObj.get_source_name }', '#{escape_javascript(sourceObj.get_data) }');
      ".html_safe
    end
  end
end
