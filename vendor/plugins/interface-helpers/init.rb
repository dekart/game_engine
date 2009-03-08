require "fieldset_helper"
require "form_helper"
require "misc_helper"

ActionView::Base.send :include, InterfaceHelpers::FieldsetHelper
ActionView::Base.send :include, InterfaceHelpers::MiscHelper

ActionView::Base.default_form_builder = InterfaceHelpers::FormBuilder