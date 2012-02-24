ActionView::Base.send(:include, GroupedSelectTag::ActionViewExtension)
ActionView::Helpers::InstanceTag.send(:include, GroupedSelectTag::InstanceTagExtension)

ActionView::Base.default_form_builder = DivFormBuilder